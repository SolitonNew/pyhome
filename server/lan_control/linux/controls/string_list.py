from PyQt5.QtWidgets import QWidget, QLabel
from PyQt5.QtGui import (QColor, QFont, QPixmap, QPainter, QImage, QPen, QBrush,
                         QFontMetrics, QLinearGradient)
from PyQt5.QtCore import Qt, QSize, QTimer

class StringList(QWidget):    
    ROW_COUNT = 15
    ACTIVE_ROW_COUNT = 9
    
    def __init__(self, parent, drawHandler = None):
        super().__init__(parent)
        self.drawHandler = drawHandler
        self._selectedIndex = -1
        self._topIndex = 0
        self.canvas = QLabel(self)
        self.decor = QLabel(self)
        self.data = []
        self.scrollOff = 0
        self.timer = QTimer()
        self.timer.timeout.connect(self.timerHandler)

    def setData(self, data):
        self.data = data
        self.selectedIndex(0)
        self.redraw()

    def resizeEvent(self, event):
        self.redrawDecor()
        
        self.redraw()

    def selectedIndex(self, val = None):
        if val == None:
            return self._selectedIndex

        if val > self._selectedIndex:
            k = 1
        else:
            k = -1
        self._selectedIndex = val

        topIndex = self._topIndex
        for z in range(2):
            if self._selectedIndex < 0:
                self._selectedIndex = len(self.data) - 1
                topIndex = len(self.data) - self.ACTIVE_ROW_COUNT
            if self._selectedIndex > len(self.data) - 1:
                self._selectedIndex = 0
                topIndex = 0

            if self.data[self._selectedIndex].LABEL == "":
                self._selectedIndex += k
                k = 0
            else:
                break

        if self._selectedIndex < topIndex:
            topIndex -= self.ACTIVE_ROW_COUNT
        if topIndex < 0:
            topIndex = 0

        if self._selectedIndex > topIndex + self.ACTIVE_ROW_COUNT - 1:
            topIndex += self.ACTIVE_ROW_COUNT
        if topIndex > len(self.data) - self.ACTIVE_ROW_COUNT:
            topIndex = len(self.data) - self.ACTIVE_ROW_COUNT

        self.setTopIndex(topIndex)
            
        self.redraw()

    def redraw(self):
        size = self.size()
        self.canvas.resize(size)

        line_height = size.height() / (self.ROW_COUNT - 1)
        font_size = line_height / 1.5
        v_offset = line_height * (self.ROW_COUNT - self.ACTIVE_ROW_COUNT) / 2 - line_height / 2

        pix = QPixmap(size.width(), size.height())
        pix.fill(QColor(0,0,0,0))
        p = QPainter()
        p.begin(pix)
        cf = p.font()        
        cf.setPixelSize(font_size)
        fm = QFontMetrics(cf)
        t_h = fm.height()
        rect_padding_left = line_height / 4

        o = round(self.scrollOff / line_height)
        
        for i in range(-5 - o, 16 - o):
            x, y = line_height, v_offset + i * line_height
            w, h = self.width() - line_height * 2, line_height            
            y += self.scrollOff
            i += self._topIndex

            if i > -1 and i < len(self.data):
                if i == self._selectedIndex:
                    pen = QPen()
                    pen.setWidth(line_height / 15)
                    pen.setColor(QColor(0xffffff))
                    pen.setStyle(Qt.SolidLine)
                    pen.setJoinStyle(Qt.RoundJoin)
                    p.setPen(pen)
                    p.setBrush(QBrush(QColor(0xff, 0xff, 0xff, 0x33), Qt.SolidPattern))
                    p.drawRect(x - rect_padding_left, y, w + rect_padding_left * 2, h)

                g = QLinearGradient(x, y, x + w, y)
                g.setColorAt(0.0, QColor(0xff,0xff,0xff,0xff))
                g.setColorAt(0.55, QColor(0xff,0xff,0xff,0xff))
                g.setColorAt(0.70, QColor(0xff,0xff,0xff,0))
            
                p.setFont(cf)
                pen = QPen()
                pen.setColor(QColor(0xffffff))
                pen.setBrush(QBrush(g))
                pen.setStyle(Qt.SolidLine)
                p.setPen(pen)
                #p.setBrush(QBrush(QColor(0xffffff), Qt.SolidPattern))                
                p.drawText(x, y + t_h, self.data[i].LABEL)

                if self.drawHandler:
                    self.drawHandler(p, [x, y, w, h], self.data[i])

        p.end()
        self.canvas.setPixmap(pix)

    def redrawDecor(self):
        size = self.size()
        self.decor.resize(size)
        pix = QPixmap(size.width(), size.height())
        pix.fill(QColor(0,0,0,0))
        p = QPainter()
        p.begin(pix)
        g = QLinearGradient(0, 0, 0, size.height())
        g.setColorAt(0.0, QColor(0,0,0,0xf0))
        g.setColorAt(0.3, QColor(0,0,0,0))
        g.setColorAt(0.7, QColor(0,0,0,0))
        g.setColorAt(1.0, QColor(0,0,0,0xf0))
        p.setBrush(QBrush(g))
        p.setPen(QPen())
        p.drawRect(0, 0, size.width(), size.height())
        p.end()
        self.decor.setPixmap(pix)

    def setTopIndex(self, topIndex):
        if self._topIndex == topIndex:
            return
        loops = 25
        line_height = self.size().height() / (self.ROW_COUNT - 1)        
        #self._topIndex -= round(self.scrollOff / line_height)                
        self._scrollTopIndex = topIndex        
        self.scrollOffMax = (self._topIndex - topIndex) * line_height
        self.scrollOffDirection = self.scrollOffMax / loops
        self.timer.start(1)

    def timerHandler(self):
        if abs(self.scrollOff) > abs(self.scrollOffMax - self.scrollOffDirection):
            self.timer.stop()
            self.scrollOff = 0
            self._topIndex = self._scrollTopIndex

            self.selectedIndex(self._selectedIndex)
        else:
            self.scrollOff += self.scrollOffDirection
        self.redraw()

    
