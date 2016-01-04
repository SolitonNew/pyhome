"""
This module contain vector font in the style of seven-segment display.
Copyright (c) 2015, Moklyak Alexandr.

Class DgFont is compatible with Font class.
EXAMPLE:
>>> from pyb import SPI
>>> from lcd import LCD
>>> from lcddrv import TriumMars
>>> from dgfont import Dgfont
>>> spi = SPI(1)
>>> lcd = LCD(TriumMars(spi, 'X5', 'X7'), False)
>>> lcd.text(0, 0, '123', DgFont(10, 20, 3))
"""

import math

class Dgfont(object):
    def __init__(self, charWidth, charHeight, charWeight):
        """
        """
        self.charWidth = charWidth
        self.charHeight = charHeight
        self.charWeight = charWeight
        self.charMeta = ((0, 1, 2, 4, 5, 6),
                         (2, 5),
                         (0, 2, 3, 4, 6),
                         (0, 2, 3, 5, 6),
                         (1, 2, 3, 5),
                         (0, 1, 3, 5, 6),
                         (0, 1, 3, 4, 5, 6),
                         (0, 2, 5),
                         (0, 1, 2, 3, 4, 5, 6),
                         (0, 1, 2, 3, 5, 6))

    def char_size(self, c):
        """
        Returns back tuple (0, width).
        """
        if c == 46:
            return (0, self.charWeight * 2)
        else:
            return (0, self.charWidth + self.charWeight)

    def _line_0(self, charBuff, charWeight):
        l = charWeight // 2
        for x in range(1, self.charWidth - 1):
            b = 0x0
            if x < charWeight:
                y2 = x
            elif x > self.charWidth - charWeight - 1:
                y2 = self.charWidth - x - 1
            else:                
                y2 = charWeight
            
            for y in range(y2):
                b |= (1<<y)
            charBuff[x + l] |= b

    def _line_1(self, charBuff, charWeight):
        l = charWeight // 2
        ch2 = self.charHeight // 2 - 2
        for x in range(charWeight):
            b = 0x0
            y1 = x
            y2 = ch2 - x + 1
            if y2 > ch2:
                y2 = ch2
            
            for y in range(y1, y2):
                b |= (1<<(y + 1))

            for y in range(y1, y2):
                b |= (1<<(y + 1))                
            charBuff[x + l] |= b

    def _line_2(self, charBuff, charWeight):
        l = charWeight // 2
        xoff = self.charWidth - charWeight
        ch2 = self.charHeight // 2 - 2
        for x in range(charWeight):
            b = 0x0
            y1 = charWeight - x - 1
            y2 = ch2 - charWeight + x + 2
            if y2 > ch2:
                y2 = ch2
            
            for y in range(y1, y2):
                b |= (1<<(y + 1))

            for y in range(y1, y2):
                b |= (1<<(y + 1))                
            charBuff[x + xoff + l] |= b

    def _line_3(self, charBuff, charWeight):
        l = charWeight // 2
        cw2 = math.ceil(charWeight / 2)
        off = self.charHeight // 2 - cw2        
        for x in range(1, self.charWidth - 3):
            b = 0x0
            if x < cw2:
                y1 = cw2 - x
                y2 = charWeight - y1
            elif x > self.charWidth - cw2 - 3:
                y1 = x - (self.charWidth - cw2 - 3)
                y2 = charWeight - y1
            else:
                y1 = 0
                y2 = charWeight
            
            for y in range(y1, y2):
                b |= (1<<(y + off))                
            charBuff[x + 1 + l] |= b

    def _line_4(self, charBuff, charWeight):
        l = charWeight // 2
        m = charWeight - l * 2
        ch2 = self.charHeight // 2 - m
        bottom = self.charHeight - ch2 - 1
        for x in range(charWeight):
            b = 0x0
            y1 = x
            y2 = bottom - x
            if y1 < 1:
                y1 = 1
            
            for y in range(y1, y2):
                b |= (1<<(y + ch2))                
            charBuff[x + l] |= b

    def _line_5(self, charBuff, charWeight):
        l = charWeight // 2
        m = charWeight - l * 2
        ch2 = self.charHeight // 2 - m
        bottom = self.charHeight - ch2 - 1
        for x in range(charWeight):
            b = 0x0
            y1 = x
            y2 = bottom - x
            if y1 < 1:
                y1 = 1
            
            for y in range(y1, y2):
                b |= (1<<(y + ch2))                
            charBuff[self.charWidth - x - 1 + l] |= b

    def _line_6(self, charBuff, charWeight):
        l = charWeight // 2
        off = self.charHeight - 1
        for x in range(1, self.charWidth - 1):
            b = 0x0
            if x < charWeight:
                y2 = x
            elif x > self.charWidth - charWeight - 1:
                y2 = self.charWidth - x - 1
            else:                
                y2 = charWeight
            
            for y in range(y2):
                b |= (1<<(off - y))
            charBuff[x + l] |= b

    def char_data(self, c):
        """
        The method is for getting symbol image.
        Returns back bit masks list for font drawing.
        """
        lines = (self._line_0, self._line_1, self._line_2, self._line_3,
                 self._line_4, self._line_5, self._line_6)        

        if c == 46:
            charBuff = [False] * (self.charWeight * 2)
            l = self.charWeight // 2
            t = self.charHeight - self.charWeight
            for x in range(self.charWeight):
                b = 0x0
                for y in range(self.charWeight):
                    b |= (1 << (t + y))
                charBuff[x + l] |= b
        else:    
            if c < 48:
                c = 48
            if c > 58:
                c = 58

            c -= 48

            charBuff = [False] * (self.charWidth + self.charWeight)

            for m in self.charMeta[c]:
                funct = lines[m]
                funct(charBuff, self.charWeight)

        return charBuff

    def height(self):
        """
        The method is for getting symbol height.
        """
        return self.charHeight
