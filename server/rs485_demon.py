#!/usr/bin/python3

from db_connector import DBConnector
import serial
import time
import json
from config_utils import generate_config_file

class Main():
    SERIAL_PORT = "/dev/ttyUSB0"
    SERIAL_SPEED = 38400

    PACK_SYNC = 1
    PACK_COMMAND = 2

    def __init__(self):
        # Connect to serial port
        try:
            self.serialPort = serial.Serial(self.SERIAL_PORT, self.SERIAL_SPEED, parity='O', timeout=0.5)
        except:
            print("Ошибка подключения к '%s'" % self.SERIAL_PORT)

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
        try:
            resp = self.serialPort.readline().decode("utf-8")
            for pack in resp.split(chr(0x0)):
                return json.loads(pack)
        except:
            return False

    def _sync_variables(self):
        # Зачитываем изменения в БД
        var_data = self.db.variable_changes()

        # Рассылаем изменения в БД и паралельно читаем обновления
        for dev in self.db.controllers:
            pack_data = []
            for var in var_data:
                if var[2] != dev[0]:
                    pack_data += [[var[0], var[1]]]
            
            print("Запрос синхронизации контроллера '%s'." % (dev[1]))
            self.send_pack(dev[0], self.PACK_SYNC, pack_data)
            res_pack = self.check_lan()
            if res_pack:
                if res_pack[2] == "RESET":
                    print("Получен запрос сброса переменных контроллера '%s'.\n" % dev[1])
                    self.send_pack(dev[0], self.PACK_SYNC, self._reset_pack())
                    if self.check_lan():
                        print("OK.\n")
                    else:
                        print("Контроллер '%s' не ответил.\n" % dev[1])
                else:
                    self._store_variable_to_db(res_pack[0], res_pack[2])
                    print("OK.\n")
            else:
                print("Контроллер '%s' не ответил.\n" % dev[1])

    def _reset_pack(self):
        return self.db.all_variables();

    def _command_info(self, text):
        print(text)
        text = text.replace("'", "`")
        s = self.db.get_property('RS485_COMMAND_INFO')
        self.db.set_property('RS485_COMMAND_INFO', s + '<p>' + text + '</p>')

    def _send_commands(self):
        command = self.db.get_property('RS485_COMMAND')

        if command == "":
            return

        self.db.set_property('RS485_COMMAND_INFO', '')
        
        for dev in self.db.controllers:            
            error_text = "Контроллер '%s' не ответил." % dev[1]

            if command == "SCAN_OW":
                self._command_info("Запрос поиска OneWire устройств для контроллера '%s'..." % dev[1])
                self.send_pack(dev[0], self.PACK_COMMAND, ["SCAN_ONE_WIRE", ""])
                res_pack = self.check_lan()
                if res_pack:
                    self._command_info("Пауза 3с...")
                    time.sleep(3)
                    self._command_info("Запрос списка найденых на шине OneWire устройств для контроллера '%s'" % dev[1])
                    self.send_pack(dev[0], self.PACK_COMMAND, ["LOAD_ONE_WIRE_ROMS", ""])
                    res_pack = self.check_lan()
                    if res_pack:
                        count = 0
                        allCount = len(res_pack[2][1])                        
                        for rom in res_pack[2][1]:
                            self._command_info(str(rom))
                            if self.db.append_scan_rom(dev[0], rom):
                                count += 1
                        self._command_info("Всего найдено устройств: %s. Новых: %s" % (allCount, count))
                    else:
                        self._command_info(error_text)
                else:
                    self._command_info(error_text)
            elif command == "CONFIG_UPDATE":
                self.serialPort.timeout = 5
                try:
                    self._command_info("Запрос обновления конфигурационного файла контроллера '%s'..." % dev[1])
                    pack_data = generate_config_file(self.db)
                    self._command_info(str(len(pack_data)) + ' байт.')
                    self.send_pack(dev[0], self.PACK_COMMAND, ["SET_CONFIG_FILE", pack_data])
                    if self.check_lan():
                        self._command_info("OK")
                    else:
                        self._command_info(error_text)
                except:
                    pass
                self.serialPort.timeout = 0.5
            elif command == "REBOOT_CONTROLLERS":
                self._command_info("Запрос перезагрузки контроллера '%s'..." % dev[1])
                self.send_pack(dev[0], self.PACK_COMMAND, ["REBOOT_CONTROLLER", ""])
                if self.check_lan():
                    self._command_info("OK")
                else:
                    self._command_info(error_text)
                
        self.db.set_property('RS485_COMMAND', '')
        self._command_info("Готово.")
        time.sleep(2)
        self._command_info("TERMINAL EXIT")

    SYNC_STATE = ""
            
    def run(self):
        serialPort = self.serialPort        
        while True:
            # Синхронизируем переменные между сервером и контроллерами
            SYNC_STATE = self.db.get_property('SYNC_STATE')

            stateChange = SYNC_STATE != self.SYNC_STATE
            if SYNC_STATE == "RUN":
                if stateChange:
                    print("Синхронизация запущена")
                self._sync_variables()
            else:
                if stateChange:
                    print("Синхронизация остановлена")

            self.SYNC_STATE = SYNC_STATE

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
