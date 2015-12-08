"""
A set of drivers to work with liquid cristal screens.
Copyright (c) 2015, Moklyak Alexandr.

Phones screens that are supported:
    - Mitsubishi TiumMars
    - Nokia 3210
    - Nokia 5210
    - Nokia 1110i *not checked
"""

import pyb
import math

class SoftSPI(object):
    """
    The class is software emulator of SPI protocol.
    """
    def __init__(self, pin_data, pin_clk, polarity=0, bits=8):
        self.data_value = pyb.Pin(pin_data, pyb.Pin.OUT_PP).value
        self.clk_value = pyb.Pin(pin_clk, pyb.Pin.OUT_PP).value
        self.polarity = polarity
        self.bits = bits

    def send(self, b):
        clk_value = self.clk_value
        data_value = self.data_value
        
        if self.polarity:
            for i in range(self.bits):
                clk_value(1)
                data_value(b & 0x80)
                b <<= 1
                clk_value(0)
        else:
            for i in range(self.bits):
                clk_value(0)
                data_value(b & 0x80)
                b <<= 1
                clk_value(1)
    
class TriumMars(object):
    """
    The driver for screen of Mitsubishi Tium Mars phone.
    """
    CHIP_W = 102
    CHIP_H = 65
    SCREEN_W = 96
    SCREEN_H = 65
   
    def __init__(self, spi_port, pin_rst, pin_dc):
        self.spi = spi_port
        if type(self.spi) == pyb.SPI:
            self.spi.init(pyb.SPI.MASTER, baudrate=600000, polarity=0)
        elif type(self.spi) == SoftSPI:
            self.spi.polarity = 0            
        self.rst_value = pyb.Pin(pin_rst, pyb.Pin.OUT_PP).value
        self.dc_value = pyb.Pin(pin_dc, pyb.Pin.OUT_PP).value

        # Reset
        self.dc_value(0)
        self.rst_value(0)
        pyb.delay(1)
        self.rst_value(1)
        pyb.delay(1)

        # Init
        self.dc_value(0)
        self.spi.send(0x21) # LCD Extended Commands.
        self.spi.send(0x9f) # Set LCD Vop
        self.spi.send(0x06) # Set Temp coefficent.
        #self.spi.send(0x15) # BIAS
        self.spi.send(0x20) # LCD Standard Commands
        self.spi.send(0x0c) # LCD in normal mode D=1 E=0 (&h0d- invert)
        self.spi.send(0x1b)
        self.dc_value(1)
        
    def send(self, data):
        spi_send = self.spi.send
        
        self.dc_value(0)
        spi_send(0x80)
        spi_send(0x40)

        self.dc_value(1)
        dw = self.CHIP_W - self.SCREEN_W + 1
        cw = self.CHIP_W
        for y in range(math.ceil(self.CHIP_H / 8)):
            for x in range(cw - dw, -dw, -1):
                bt = data[y * cw + x]
                b = 0
                for i in range(8):
                    b <<= 1
                    b |= bt & 1
                    bt >>= 1               
                spi_send(b)

    def contrast(self, value):
        self.dc_value(0)
        self.spi.send(0x21) # LCD Extended Commands.
        self.spi.send(0x10 + round(6 * value / 100)) # BIAS
        self.spi.send(0x20) # LCD Standard Commands
        self.dc_value(1)

class PCD8544(object):
    """
    Driver screen controller PCD8544 and their analogues.
    """
    CHIP_W = 84
    CHIP_H = 48
    SCREEN_W = 84
    SCREEN_H = 48
   
    def __init__(self, spi_port, pin_rst, pin_dc):
        self.spi = spi_port
        if type(self.spi) == pyb.SPI:
            self.spi.init(pyb.SPI.MASTER, baudrate=600000, polarity=0)
        elif type(self.spi) == SoftSPI:
            self.spi.polarity = 0            
        self.rst_value = pyb.Pin(pin_rst, pyb.Pin.OUT_PP).value
        self.dc_value = pyb.Pin(pin_dc, pyb.Pin.OUT_PP).value

        # Reset
        self.dc_value(0)
        self.rst_value(0)
        pyb.delay(1)
        self.rst_value(1)
        pyb.delay(1)

        # Init
        self.dc_value(0)
        self.spi.send(0x21) # LCD Extended Commands.
        self.spi.send(0xC3) # Set LCD Vop
        self.spi.send(0x04) # Set Temp coefficent.
        self.spi.send(0x20) # LCD Standard Commands, Horizontal addressing mode.
        self.spi.send(0x0C) # LCD in normal mode.        
        self.dc_value(1)
        
    def send(self, data):
        spi_send = self.spi.send
        
        self.dc_value(0)
        spi_send(0x80)
        spi_send(0x40)

        self.dc_value(1)
        for b in data:
            spi_send(b)
        self.dc_value(0)
        self.spi.send(0)

    def contrast(self, value):
        self.dc_value(0)
        self.spi.send(0x21) # LCD Extended Commands.
        self.spi.send(0x10 + round(6 * value / 100)) # BIAS
        self.spi.send(0x20) # LCD Standard Commands.
        self.dc_value(1)

class N3210(PCD8544):
    """
    The driver for screen of Nokia 3210 phone.
    """
    pass

class N5210(PCD8544):
    """
    The driver for screen of Nokia 5210 phone.
    """
    def send(self, data):
        spi_send = self.spi.send
        
        self.dc_value(0)
        spi_send(0x80)
        spi_send(0x40)

        self.dc_value(1)
        w = self.CHIP_W
        for y in range(math.ceil(self.CHIP_H / 8)):
            for x in range(w - 1, -1, -1):
                spi_send(data[y * w + x])
        self.dc_value(0)
        spi_send(0)

    def contrast(self, value):
        self.dc_value(0)
        self.spi.send(0x7f - round(0xf * value / 100)) # BIAS (смещение-общая тёмность)

class N1110i(object):
    """
    The driver for screen of Nokia 1110i phone.
    Not checked !!!!!!!    
    """
    CHIP_W = 96
    CHIP_H = 68
    SCREEN_W = 96
    SCREEN_H = 68
   
    def __init__(self, spi_port, pin_rst):
        self.spi = spi_port
        if type(self.spi) == pyb.SPI:
            self.spi.init(pyb.SPI.MASTER, baudrate=600000, polarity=1, bits=9)
        elif type(self.spi) == SoftSPI:
            self.spi.polarity = 1
            self.spi.bits = 9
        self.rst_value = pyb.Pin(pin_rst, pyb.Pin.OUT_PP).value

        # Reset
        self.rst_value(0)
        pyb.delay(1)
        self.rst_value(1)
        pyb.delay(1)

        # Init
        self.spi.send(0xE2 << 1) #Internal reset
        self.spi.send(0xEB << 1) #Thermal comp. on
        self.spi.send(0x2F << 1) #Supply mode
        self.spi.send(0xA1 << 1) #Horisontal reverse: Reverse - 0xA9, Normal - 0xA1
        self.spi.send(0xA4 << 1) #Clear screen
        self.spi.send(0xA6 << 1) #Positive - A7, Negative - A6
        self.spi.send(0xAF << 1) #Enable LCD
        
    def send(self, data):
        self.spi.send(0xB0 << 1)
        self.spi.send(0x10 << 1)
        #self.spi.comm(0x0)
        for b in data:
            self.spi.send(b << 1 & 1)
        self.spi.send(0x0)

    def contrast(self, value):
        self.spi.send((0x80 + round(0x1f / 100 * value) << 1)) # BIAS
        self.spi.send(0x0)
