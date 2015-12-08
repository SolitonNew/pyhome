import utils
from pyb import Pin
from ds18b20 import DS18B20

class HomeTermostat(DS18B20):
    TEMP_DELTA = 0.5
    """
    Класс для работы с термометром DS18B20.
    Управляет термостатической головкой на два положения: ВКЛ/ВЫКЛ.
    """
    def __init__(self, ow, label, rom, pinTap, temp):
        super().__init__(ow)
        self.label = label
        self.rom = rom
        self.pinTap = Pin(pinTap, Pin.OUT_PP).value
        self.set_temp(temp)
        self.last_temp = False
        
        self.set_config(self.rom, 100, -30, 12)
        self.save_config(self.rom)

    def check_data(self):
        temp = self.get_temp(self.rom)
        temp = round(temp * 100) / 100
        self.start_measure(self.rom)
        if temp > self.selTemp + self.TEMP_DELTA and self.pinTap():
            self.pinTap(0)
        elif temp < self.selTemp - self.TEMP_DELTA and self.pinTap() == 0:
            self.pinTap(1)
        self.last_temp = temp            
        return self.get_log_data()

    def set_temp(self, temp):
        self.selTemp = temp

    def get_log_data(self):
        vals = ["закрыт", "открыт"]
        res = ["ТЕРМОСТАТ (", self.label, "): ",
               utils.rom_to_string(self.rom),
               "     ТЕМП.: ",
               str(self.last_temp),
               "     КРАН: ",
               vals[self.pinTap()]]
        return "".join(res)

        
