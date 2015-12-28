from timethread import TimeThread
from rs485 import RS485
from onewire import OneWire
from ds18b20 import DS18B20
import utils

import pyb
try:
    import config
except:
    pass

ow = OneWire('Y12')
DS18B20(ow).start_measure()

rs485 = RS485(3, 'Y11', 1)

def rs485_thread():
    buf = rs485.check_wire()
    typ = 0
    if buf:
        typ = buf[1]
        
    if typ == RS485.PACK_PING:
        print("PING")
        rs485.send(typ, False)
        
    elif typ == RS485.PACK_REBOOT:
        print("Команда перезагрузки.")
        rs485.send(typ, False)
        pyb.hard_reset()
        
    elif typ == RS485.PACK_SET_CONFIG:
        print("Получили конфигурационный файл.")        
        f = open("config.py", "wb")
        f.write(buf[2:len(buf) - 1:])
        f.close()
        rs485.send(typ, False)
        
    elif typ == RS485.PACK_SCAN_OW:
        print("Запрос сканирования OneWire сети.")        
        rs485.send(typ, False)
        ow.search()
        
    elif typ == RS485.PACK_ROMS_OW:
        print("Отсылка на управляющий узел список OneWire устройств.")
        roms = []
        for rom in ow.roms:
            for r in rom:
                roms += [r]
        rs485.send(typ, roms)

    th.set_time_out(0, rs485_thread)

def onewire_alarms():
    alarms = ow.alarm_search()
    for a in alarms:
        if a[0] == 0x28:
            ds = DS18B20(ow)
            ds.set_config(a, 125, -55, 12)
            ds.save_config()
        print(utils.rom_to_string(a))
    th.set_time_out(10, onewire_alarms)

def onewire_termometrs():
        
    th.set_time_out(1000, onewire_termometrs)

th = TimeThread(1, True)
onewire_termometrs()
onewire_alarms()
rs485_thread()
th.run()
