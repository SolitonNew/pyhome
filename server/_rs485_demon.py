#!/usr/bin/python3

from db_connector import DBConnector
import serial
import time
import json

class Main():
    SERIAL_PORT = "/dev/ttyUSB0"

    SERIAL_SPEED = 921600

    # Количество повторов при неподтверждении приема данных контроллером
    PACK_REPEAT_NUM = 2

    # Пакет проверки связи.
    PACK_SYNC = 1

    # Запрос перезагрузить контроллер.
    PACK_REBOOT = 2

    # Запрос передающий на контроллер конфигурационный файл настроек.
    PACK_SET_CONFIG = 3

    # Запрос просканировать сеть OneWire контроллера.
    PACK_SCAN_OW = 5

    # Запрос вернуть контроллеру список ROM просканированой сети OneWire
    PACK_ROMS_OW = 6


    def __init__(self):
        self.pingStep = 0
        self.repeat_queue = self.PACK_REPEAT_NUM
        # Connect to serial port
        self.serialPort = serial.Serial(self.SERIAL_PORT, self.SERIAL_SPEED, timeout=0.5)

        self.db = DBConnector()
        self.db.load_controllers()
        self.queue = []
        self._prepare_queue()

        # Run main loop
        self.run()

    def _create_sync_pack(self):
        """
        The method creates empty record in queue.
        Метод вызывается с максимально возможной частотой. Но пополнение очереди
        пакетами проверки связи возникает в 10 раз реже.
        """
        if self.pingStep < 10:
            self.pingStep += 1
            return

        self.pingStep = 0
        
        for c in self.db.controllers:
            buf = [c[0], self.PACK_SYNC]
            self.queue += [buf]

    def exec_response(self, send_dev, data):
        if len(data) == 0:
            if self.repeat_queue == 1: 
                print("СИСТЕМА [%s]: Контроллер '%d' не ответил. \n" % (time.strftime("%H:%M:%S"), send_dev))
            else:
                print("СИСТЕМА [%s]: Повторная попытка отсылки пакета контроллеру '%d'." % (time.strftime("%H:%M:%S"), send_dev))
            return False

        """"
        if self.crc8(data) != 0:
            if self.repeat_queue == 1: 
                print("СИСТЕМА [%s]: Не совпала CRC. Контроллер '%d'. \n" % (time.strftime("%H:%M:%S"), send_dev))
            else:
                print("СИСТЕМА [%s]: Повторная отсылка пакета контроллеру '%d'." % (time.strftime("%H:%M:%S"), send_dev))
            return False
        """

        try:
            data = json.loads(data)

            print(self._decode_pack_type(data[1]) % ("ОТВЕТ [%s]" % time.strftime("%H:%M:%S"), send_dev))

            if data[1] == self.PACK_SYNC:
                #vars = json.loads(data[2:len(data)-1:].decode('utf-8'))
                #for var in vars:
                #    print(var)
                print(data)
            elif data[1] == self.PACK_SCAN_OW:
                print("СИСТЕМА [%s]: Пауза 3сек." % time.strftime("%H:%M:%S"))
                time.sleep(3)
                self.queue += [[data[0], self.PACK_ROMS_OW]]
            
            elif data[1] == self.PACK_ROMS_OW:
                roms = []
                rom = []
                for r in range(2, len(data) - 1):
                    rom += [data[r]]
                    if len(rom) == 8:
                        roms += [rom]
                        rom = []
                # Store to DB
                c = 0
                for rom in roms:
                    if self.db.append_scan_rom(data[0], rom):
                        c += 1
                print("СИСТЕМА [%s]: Добавлено новых устройств %dшт." % (time.strftime("%H:%M:%S"), c))
            
        except:
            pass
        print("")
        return True

    def _decode_pack_type(self, typ):
        if typ == self.PACK_SYNC:
            return "%s: Синхронизация с контроллером '%d'."
        if typ == self.PACK_REBOOT:
            return "%s: Комманда перезагрузки контроллера '%d'."
        if typ == self.PACK_SET_CONFIG:
            return "%s: Передача контроллеру '%d' конфигурационного файла."
        elif typ == self.PACK_SCAN_OW:
            return "%s: Сканирование OneWire сети для контроллера '%d'."
        elif typ == self.PACK_ROMS_OW:
            return "%s: Получение списка OneWire устройств для контроллера '%d'."
        else:
            return "%s: Неопознанный пакет. Контроллер '%d'."

    def _generate_config(self, dev_id):
        time.sleep(0.5)
        res = "print('The config is work!!!')".encode("utf-8")
        return res

    def _prepare_queue(self):        
        queue = self.db.load_queue()
        for q in queue:            
            if q[1] == self.PACK_SET_CONFIG:
                q += self._generate_config(q[0])
            self.queue += [q]

    def run(self):
        queue = self.queue
        serialPort = self.serialPort        
        while True:
            self._prepare_queue()
            if queue:
                if len(queue[0]) > 1:
                    data = queue[0]
                    #data += [self.crc8(data)]
                    print(self._decode_pack_type(queue[0][1]) % ("ЗАПРОС [%s]" % time.strftime("%H:%M:%S"), queue[0][0]))
                    print(json.dumps(data)) 
                    serialPort.write(json.dumps(data).encode("utf-8"))
                    serialPort.sendBreak()
                    
                    if self.exec_response(data[0], serialPort.readline()) or (self.repeat_queue == 1):
                        self.repeat_queue = self.PACK_REPEAT_NUM
                        del queue[0]
                    else:
                        self.repeat_queue -= 1
                else:
                    self.repeat_queue = self.PACK_REPEAT_NUM
                    del queue[0]

            self._create_sync_pack()
            time.sleep(0.1)

print(
"=============================================================================\n"
"                  МОДУЛЬ ВЗАИМОДЕЙСТВИЯ ПО ШИНЕ RS485 v0.1\n"
"\n"
" Порт: %s \n"
" Скорость: %s \n"
"=============================================================================\n"
% (Main.SERIAL_PORT, Main.SERIAL_SPEED)
)

if __name__ == "__main__":
    Main()
