from ds18b20 import DS18B20
from homesensor import HomeSensor
from pyb import Pin

class Termometr(DS18B20):
    def __init__(self, ow, rom):
        super().__init__(ow)
        self.rom = rom
        self.ERRORS = 0
    
    def value(self, val = None, channel = ""):
        res = False
        try:
            res = round(self.get_temp(self.rom), 1)
        except:
            self.ERRORS += 1
        self.start_measure(self.rom)
        return {'':res, 'ERRORS':self.ERRORS}
            

class Switch(HomeSensor):
    SENSOR_L = 8
    SENSOR_R = 16
    
    def __init__(self, ow, rom):
        super().__init__(ow)
        self.rom = rom
        self.stL = 0
        self.stR = 0
    
    def value(self, val = None, channel = ''):
        if val == None:
            resL = False
            resR = False
            
            d = self.get_data(self.rom)
    
            if (d & self.SENSOR_L):
                if self.stL == 0:
                    self.stL = 1
                    resL = True
            else:
                self.stL = 0

            if (d & self.SENSOR_R):
                if self.stR == 0:
                    self.stR = 1
                    resR = True
            else:
                self.stR = 0

            return {'LEFT':resL, 'RIGHT':resR}


class Pyboard(object):
    def __init__(self):
        self.available_pins = ('X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7', 'X8',
                               'X9', 'X10', 'X11', 'X12',
                               'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8')
        self.rom = 'pyb'
        self.channels = []

    def _find_channel(self, channel):
        for c in self.channels:
            if c.names()[1] == channel:
                return c
        return False

    def declare_channel(self, channel, direction):
        try:
            self.available_pins.index(channel)
            if self._find_channel(channel):
                return ;
            pin = Pin(channel)
            if direction:
                pin.init(Pin.OUT_PP)
            else:
                pin.init(Pin.IN, Pin.PULL_UP)
            self.channels += [pin]
        except:
            pass

    def value(self, val = None, channel = ''):
        pin = self._find_channel(channel)
        if pin:
            if val == None:
                return pin.value()
            else:
                pin.value(val)
        else:
            return False
