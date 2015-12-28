import utils
from pyb import Pin
from home_sensor import HomeSensor

class HomeSwitch(HomeSensor):
    SENSOR_L = 8
    SENSOR_R = 16
    """
    Класс для работы с двойной сенсорной кнопкой.
    """
    def __init__(self, ow, label, rom, pinL, pinR):        
        super().__init__(ow)
        self.label = label
        self.rom = rom
        self.pinL = Pin(pinL, Pin.OUT_PP).value
        self.pinR = Pin(pinR, Pin.OUT_PP).value
        self.stL = 0
        self.stR = 0

    def check_data(self):
        d = self.get_data(self.rom)

        if (d & self.SENSOR_L):
            if self.stL == 0:
                self.stL = 1
                self.pinL(not self.pinL())
        else:
            self.stL = 0

        if (d & self.SENSOR_R):
            if self.stR == 0:
                self.stR = 1
                self.pinR(not self.pinR())
        else:
            self.stR = 0

        if d:
            return self.get_log_data()
        else:
            return False

    def get_log_data(self):
        vals = ["выкл.", "вкл."]
        res = ["ОСВЕЩЕНИЕ (", self.label,"): ",
               utils.rom_to_string(self.rom),
               "     ЛАМПА 1: ",
               vals[self.pinL()],
               "     ЛАМПА 2: ",
               vals[self.pinR()]]
        return "".join(res)
