from ds18b20 import DS18B20
from homesensor import HomeSensor
from fancontrol import FanControl
from pyb import Pin

class Termometr(DS18B20):
    def __init__(self, ow, rom):
        super().__init__(ow)
        self.rom = rom
        self.is_started = False
    
    def value(self, val = None, channel = ''):
        if val == None:
            if self.is_started:
                res = self.get_temp(self.rom)
            else:
                res = None
            self.start_measure()
            self.is_started = True
            return res
        else:
            return False
            

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

            if d != None:
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

class Fan(FanControl):
    def __init__(self, ow, rom):
        super().__init__(ow)
        self.rom = rom
        self.data = bytearray(4)
    
    def value(self, val = None, channel = ''):
        if val == None:
            d = self.get_data(self.rom)

            if d != None:
                self.data = bytearray(d)

            return {'F1':self.data[0], 'F2':self.data[1], 'F3':self.data[2], 'F4':self.data[3]}
        else:
            if channel == 'F1':
                self.data[0] = int(val)
            elif channel == 'F2':
                self.data[1] = int(val)
            elif channel == 'F3':
                self.data[2] = int(val)
            elif channel == 'F4':
                self.data[3] = int(val)
            
            self.set_data(self.data, self.rom)


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
