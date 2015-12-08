import config
import utils
from onewire import OneWire
from timethread import TimeThread
from homeswitch import HomeSwitch
from hometermostat import HomeTermostat
from ds18b20 import DS18B20

def alert_handler():
    """
    Вызывается каждую милисекунду. Обработка вызовов устройств с флагом ALERT
    и реакция на информацию с них.
    """
    for rom in ow.alarm_search():
        dev = dev_by_rom(rom)
        if dev:
            d = dev.check_data()
            if d:
                print(d)
    th.set_time_out(1, alert_handler)

dev_10_index = 0
def termometrs_hadler():
    """
    Вызывается каждые 10 секунд. Обработка термостатов.
    """
    global dev_10_index
    currTermostat = False
    for i in range(dev_10_index + 1, len(DEVS)):
        if type(DEVS[i]) == HomeTermostat:
            currTermostat = DEVS[i]
            dev_10_index = i
            break
            
    if not currTermostat:
        for i in range(len(DEVS)):
            if type(DEVS[i]) == HomeTermostat:
                currTermostat = DEVS[i]
                dev_10_index = i
                break

    if currTermostat:
        print(currTermostat.check_data())
        
    th.set_time_out(10000, termometrs_hadler)

def dev_by_rom(rom):
    """
    Поиск записи устройства по его ключу.
    """
    for dev in DEVS:
        if rom == dev.rom:
            return dev
    return False

def scan_one_wire():
    """
    Выводит в консоль информацию о состоянии шины. Список устройств представлен
    как объедененный список зарегистрированных объектов и всех активных
    устройств на шине.
    """
    states = ["   НЕАКТИВНО  ",
              "     АКТИВНО  ",
              "       НОВОЕ  "]
    
    ow_roms = ow.search()
    for dev in DEVS:
        try:
            i = ow_roms.index(dev.rom)
            del ow_roms[i]
            print(states[1] + utils.rom_to_string(dev.rom))
        except:
            print(states[0] + utils.rom_to_string(dev.rom))

    for rom in ow_roms:
        print(states[2] + utils.rom_to_string(rom))


def init_config():
    devs = []
    for dev in config.DEVS:
        if dev[0] == "switch":
            devs += [HomeSwitch(ow, dev[1], dev[2], dev[3], dev[4])]
        elif dev[0] == "termostat":
            devs += [HomeTermostat(ow, dev[1], dev[2], dev[3], dev[4])]

    return devs

# Создаем экземпляр для доступа к сети OneWire
ow = OneWire('X1')
DS18B20(ow).start_measure()
DEVS = init_config()

print("")
print("Начинаем работу контроллера")
print("Анализ переферии:")
print("---------------------------------------------------------")
scan_one_wire()
print("---------------------------------------------------------")
print("")

# Создаем и преднастраиваем главный цыкл обработки по таймингам.
th = TimeThread(1, True)
alert_handler()
termometrs_hadler()
th.run()
