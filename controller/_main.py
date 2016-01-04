import pyb
from timethread import TimeThread
from rs485 import RS485
from onewire import OneWire
from ds18b20 import DS18B20
import utils
import variables
import config
import ujson

# Инициализация шин
ow = OneWire('Y12')
DS18B20(ow).start_measure()
rs485 = RS485(3, 'Y11', 1)

# Создаем драйвера для переменных сети OneWire и передаем им экземпляр OW.
variables.set_variable_drivers(ow, rs485.dev_id)
# ------------------------

def rs485_check():
    buf = rs485.check_wire()
    typ = 0
    if buf:
        typ = buf[1]
        
    if typ == RS485.PACK_SYNC:
        print("Синхронизация")
        data = ujson.dumps(variables.get_sync_change_variables())
        rs485.send(typ, data)
        print(data)
        
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

def onewire_alarms():
    alarms = ow.alarm_search()
    for a in alarms:
        rs485_check()
        if a[0] == 0x28: # Если вдруг в сеть попадет термометр с нестандартными настройками
            ds = DS18B20(ow)
            ds.set_config(a, 125, -55, 12)
            ds.save_config()
        else:
            variables.check_driver_value(a)
    th.set_time_out(10, onewire_alarms)

curr_termometr_index = -1

def onewire_termometrs():
    global curr_termometr_index

    d = []
    for driver in variables.driverList:
        if driver and driver.rom and (driver.rom[0] == 0x28):
            d += [driver]

    if d:
        curr_termometr_index += 1
        if curr_termometr_index > (len(d) - 1):
            curr_termometr_index = 0
        variables.check_driver_value(d[curr_termometr_index].rom)
    
    th.set_time_out(5000, onewire_termometrs)


th = TimeThread(1, rs485_check, True)
onewire_termometrs()
onewire_alarms()
th.run()
