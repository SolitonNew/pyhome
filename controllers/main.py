import pyb
from pyb import delay
from pyb import Timer
from rs485 import RS485
from onewire import OneWire
from ds18b20 import DS18B20
import utils
try:
    import config
except:
    pyb.LED(4).on()
import variables

IS_START = True

PACK_SYNC = 1
PACK_COMMAND = 2
PACK_ERROR = 3

# Инициализация шин
ow = OneWire('Y12')
DS18B20(ow).start_measure()
rs485 = RS485(3, 'Y11', 1)

# Создаем драйвера для переменных сети OneWire и передаем им экземпляр OW.
variables.set_variable_drivers(ow, rs485.dev_id)

# Отбираем отдельный список термометров
termometrs = []
for driver in variables.driverList:
    if driver and driver.rom and (driver.rom[0] == 0x28):
        termometrs += [driver]

# Создаем специальный таймер для синхронизации обновлений термометров.
timer_1_flag = False
def timer_1_handler(timer):
    global timer_1_flag
    timer_1_flag = True
Timer(1, freq=0.1).callback(timer_1_handler)

# Создаем специальный таймер для синхронизации опроса поиска OneWire alarms.
timer_2_flag = False
def timer_2_handler(timer):
    global timer_2_flag
    timer_2_flag = True
Timer(2, freq=500).callback(timer_2_handler)

def onewire_alarms():
    global timer_2_flag
    if timer_2_flag == False:
        return
    timer_2_flag = False
    alarms = ow.alarm_search()
    for a in alarms:
        if a[0] == 0x28: # Если вдруг в сеть попадет термометр с нестандартными настройками
            ds = DS18B20(ow)
            ds.set_config(a, 125, -55, 12)
            ds.save_config()
        else:
            variables.check_driver_value(a)

curr_termometr_index = -1
def onewire_termometrs():
    global timer_1_flag
    
    if timer_1_flag == False:
        return
    timer_1_flag = False
    
    global curr_termometr_index

    if termometrs:
        curr_termometr_index += 1
        if curr_termometr_index > (len(termometrs) - 1):
            curr_termometr_index = 0
        variables.check_driver_value(termometrs[curr_termometr_index].rom)

switch = pyb.Switch().callback(lambda: pyb.LED(4).off())

while True:
    for pack in rs485.check_lan():
        if pack:
            if pack[1] == PACK_SYNC:
                if IS_START:
                    rs485.send_pack(PACK_SYNC, "RESET")
                    IS_START = False;
                else:
                    variables.set_sync_change_variables(pack[2])
                    pack_data = variables.get_sync_change_variables()
                    rs485.send_pack(PACK_SYNC, pack_data)
            elif pack[1] == PACK_COMMAND:
                comm_data = pack[2]
                if comm_data[0] == "SCAN_ONE_WIRE":
                    pyb.LED(3).on()
                    rs485.send_pack(PACK_COMMAND, [comm_data[0], False])
                    ow.search()
                elif comm_data[0] == "LOAD_ONE_WIRE_ROMS":
                    roms = []
                    for rom in ow.roms:
                        rr = []
                        for r in rom:
                            rr += [r]
                        roms += [rr]
                    rs485.send_pack(PACK_COMMAND, [comm_data[0], roms])
                    pyb.LED(3).off()
                elif comm_data[0] == "SET_CONFIG_FILE":
                    #pyb.LED(3).toggle()
                    rs485.send_pack(PACK_COMMAND, [comm_data[0], rs485.file_parts_i])
                elif comm_data[0] == "REBOOT_CONTROLLER":
                    rs485.send_pack(PACK_COMMAND, [comm_data[0], False])
                    pyb.hard_reset()
            elif pack[1] == PACK_ERROR:
                rs485.send_pack(PACK_ERROR, [rs485.error])
                rs485.error = []

    onewire_alarms()
    onewire_termometrs()
