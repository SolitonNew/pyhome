#!/usr/bin/python3
# -*- coding: utf-8 -*-

from db_connector import DBConnector
import serial
import datetime
import time
import json
from config_utils import generate_config_file
import math

class Main():
    SERIAL_PORT = "/dev/ttyUSB0"
    SERIAL_SPEED = 57600

    PACK_SYNC = 1
    PACK_COMMAND = 2

    def __init__(self):
        self.fast_timeput = 0.1
        
        # Connect to serial port
        try:
            self.serialPort = serial.Serial(self.SERIAL_PORT, self.SERIAL_SPEED, parity='O', timeout=self.fast_timeput)
        except:
            print("Ошибка подключения к '%s'" % self.SERIAL_PORT)

        self.db = DBConnector()
        self.db.load_controllers()
        self.queue = []

        # Run main loop
        self.run()

    def send_pack(self, dev_id, pack_type, pack_data, flush=True):
        buf = json.dumps([dev_id, pack_type, pack_data]).encode("utf-8")
        buf += bytearray([0x0])
        self.serialPort.write(buf)
        if flush:
            self.serialPort.flush() 

    def _store_variable_to_db(self, dev_id, pack_data):
        for var in pack_data:
            self.db.set_variable_value(var[0], var[1], dev_id)

    def check_lan(self):
        try:
            buf = self.serialPort.readline()
            resp = buf.decode("utf-8")
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
            lt = time.localtime()
            t = time.mktime((2000, 1, 1, 0, 0, 0, 0, 0, lt.tm_isdst))
            pack_data += [[-100, round(time.time() - t)]] #Передаем системное время в контроллеры
            for var in var_data:
                if var[2] != dev[0]:
                    pack_data += [[var[0], var[1]]]

            date = datetime.datetime.now().strftime('%H:%M:%S')
            print("[%s] SYNC. '%s': " % (date, dev[1]), end="")
            self.send_pack(dev[0], self.PACK_SYNC, pack_data)
            res_pack = self.check_lan()
            if res_pack:
                if res_pack[2] == "RESET":
                    print("RESET ", end="")
                    self.send_pack(dev[0], self.PACK_SYNC, self._reset_pack())
                    if self.check_lan():
                        print("OK\n")
                    else:
                        print("ERROR\n")
                else:
                    self._store_variable_to_db(res_pack[0], res_pack[2])
                    print("OK")
                    print("   >> ", pack_data)
                    print("   << ", res_pack[2], "\n")
            else:
                print("ERROR\n")

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
                            rom_s = []
                            for r in rom:
                                ss = hex(r).upper()
                                if len(ss) == 3:
                                    ss = ss.replace("0X", "0x0")
                                else:
                                    ss = ss.replace("0X", "0x")
                                rom_s += [ss]
                                rom_s += [", "]
                            self._command_info("".join(rom_s[:-1]))
                            if self.db.append_scan_rom(dev[0], rom):
                                count += 1
                        self._command_info("Всего найдено устройств: %s. Новых: %s" % (allCount, count))
                    else:
                        self._command_info(error_text)
                else:
                    self._command_info(error_text)
            elif command == "CONFIG_UPDATE":
                self.serialPort.timeout = 1
                try:
                    self._command_info("CONFIG FILE UPLOAD '%s'..." % dev[1])
                    pack_data = generate_config_file(self.db)
                    self._command_info(str(len(pack_data)) + ' bytes.')

                    bts = 512
                    cou = math.ceil(len(pack_data) / bts)
                    self.send_pack(dev[0], self.PACK_COMMAND, ["SET_CONFIG_FILE", cou, False], False)
                    for i in range(cou):
                        t = i * bts
                        s = pack_data[t:t + bts]
                        self.send_pack(dev[0], self.PACK_COMMAND, ["SET_CONFIG_FILE", i + 1, s], i == cou - 1)

                    is_ok = False
                    for i in range(30):
                        if self.check_lan():
                            is_ok = True
                            break

                    if is_ok:
                        self._command_info("OK")
                    else:
                        self._command_info(error_text)
                except:
                    pass
                self.serialPort.timeout = self.fast_timeput
            elif command == "REBOOT_CONTROLLERS":
                self._command_info("Запрос перезагрузки контроллера '%s'..." % dev[1])
                self.send_pack(dev[0], self.PACK_COMMAND, ["REBOOT_CONTROLLER", ""])
                if self.check_lan():
                    self._command_info("OK")
                else:
                    self._command_info(error_text)
            elif command == "GET_OW_VALUES":
                pass
                
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
