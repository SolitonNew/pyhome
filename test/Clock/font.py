"""
The class is a font container. Is used as a font driver for text() method
of LCD class.
Copyright (c) 2015, Moklyak Alexandr.

Font file is a binary file created by font_generator utilit. This file
contains pixel image of awery symbol ASCII. When Font() class is created
the path to font file needs to be pointed. Symbol position, size and bit
masks are read avery time directly from the file. Thus, the display time
increases slightly but significantly save memory.
"""

import math

class Font(object):  
    def __init__(self, fileName, cached = False):        
        self.file = None
        self.fileName = fileName
        self.cached = cached
        self.open()

    def open(self):
        """
        The method openes font file for reading. This method is could
        automaticle when created. But is file close by close() method you
        can open a file with this method again.
        """
        if not self.file:
            self.file = open(self.fileName, 'rb')
            self.header = self.file.read(32)
            if self.cached:
                self.fontData = self.file.read()
                self.close()

    def close(self):
        """
        The method closes font file stream.
        Don't for get to coll it when font is not needed.
        """
        if self.file: self.file.close()
        self.file = None

    def char_size(self, c):
        """
        The method reads from font file header raster position and symbol width.
        Returns back tuple (position, width).
        """
        cFrom = self.header[29]
        cTo = self.header[30]
        
        if c < cFrom:
            c = cFrom
        if c > cTo:
            c = cTo

        if not self.cached:
            f = self.file
            # Offset to the stream to the desired character
            f.seek(32 + (c - cFrom) * 3)
            p = f.read(3)
            x = (p[1] << 8) + p[0]
            w = p[2]
        else:
            i = (c - cFrom) * 3
            x = (self.fontData[i + 1] << 8) + self.fontData[i]
            w = self.fontData[i + 2]
        return(x, w)
        
    def char_data(self, c):
        """
        The method is for getting symbol image.
        Returns back bit masks list for font drawing.
        """
        cFrom = self.header[29]
        cTo = self.header[30]
        height = self.header[31]

        if c < cFrom:
            c = cFrom
        if c > cTo:
            c = cTo        
        
        cs = self.char_size(c)        
        bh = math.ceil(height / 8)
        res = []

        if not self.cached:        
            f = self.file
            # Offset to the stream to the desired character
            f.seek(32 + (cTo - cFrom + 1) * 3 + cs[0] * bh)
            # Read char
            for x in range(cs[1]):
                b = 0
                for y in range(bh):
                    r = f.read(1)
                    b |= r[0] << (y * 8)
                res.append(b)
        else:
            fd = self.fontData
            i = (cTo - cFrom + 1) * 3 + cs[0] * bh
            for x in range(cs[1]):
                b = 0
                for y in range(bh):
                    b |= fd[i] << (y * 8)
                    i += 1
                res.append(b)
        return res

    def height(self):
        """
        The method is for getting symbol height.
        """
        return self.header[31]
