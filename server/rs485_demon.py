#!/usr/bin/python3

from db_connector import DBConnector
import serial
import time
import json

class Main():
    SERIAL_PORT = "/dev/ttyUSB0"
    SERIAL_SPEED = 38400

    PACK_SYNC = 1
    PACK_COMMAND = 2

    def __init__(self):
        # Connect to serial port
        self.serialPort = serial.Serial(self.SERIAL_PORT, self.SERIAL_SPEED, parity='O', timeout=0.5)

        self.db = DBConnector()
        self.db.load_controllers()
        self.queue = []

        # Run main loop
        self.run()

    def send_pack(self, dev_id, pack_type, pack_data):
        buf = json.dumps([dev_id, pack_type, pack_data]).encode("utf-8")
        buf += bytearray([0x0])
        self.serialPort.write(buf)
        self.serialPort.flush()

    def _store_variable_to_db(self, dev_id, pack_data):
        for var in pack_data:
            self.db.set_variable_value(var[0], var[1], dev_id)

    def check_lan(self):        
        resp = self.serialPort.readline().decode("utf-8")        
        try:
            for pack in resp.split(chr(0x0)):
                return json.loads(pack)
        except:
            print("ОШИБКА: ", resp)
            return False

    def _sync_variables(self):
        # Зачитываем изменения в БД
        pack_data = self.db.variable_changes()

        # Рассылаем изменения в БД и паралельно читаем обновления
        for dev in self.db.controllers:
            print("ЗАПРОС: Синхронизация контроллера '%s'." % (dev[0]))
            self.send_pack(dev[0], self.PACK_SYNC, pack_data)
            res_pack = self.check_lan()
            if res_pack:
                self._store_variable_to_db(res_pack[0], res_pack[2])
                print("Синхронизация прошла успешно.")
            else:
                print("Контроллер '%s' не ответил." % dev[0])

    def _send_commands(self):
        for command in self.db.commands():
            print(command)
            pack_data = ""
            comm = command[1]
            if comm == "SCAN_ONE_WIRE":
                pass
            elif comm == "LOAD_ONE_WIRE_ROMS":
                pass
            elif comm == "SET_CONFIG_FILE":
                pack_data = "The config file!!!"
            elif comm == "REBOOT_CONTROLLER":
                pass
            
            self.send_pack(command[0], self.PACK_COMMAND, [command[1], pack_data])
            res_pack = self.check_lan()
            if res_pack == False:
                print("Контроллер '%s' не ответил." % command[0])
                comm = ""

            if comm == "SCAN_ONE_WIRE":
                print("Послана комманда опроса OneWire сети. Пауза 3с...")
                time.sleep(3)
            elif comm == "LOAD_ONE_WIRE_ROMS":
                count = 0
                allCount = len(res_pack[2][1])
                print(res_pack[2][1])
                for rom in res_pack[2][1]:
                    if self.db.append_scan_rom(command[0], rom):
                        count += 1
                print("Получен список OneWire устройств. Всего устройств %sшт. Добавлено новых %sшт." % (allCount, count))
            
            elif comm == "SET_CONFIG_FILE":
                pass
            elif comm == "REBOOT_CONTROLLER":
                pass

    def run(self):
        serialPort = self.serialPort        
        while True:
            # Синхронизируем переменные между сервером и контроллерами
            self._sync_variables()

            # Рассылаем системные комманды, если требуется
            self._send_commands()
            
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
