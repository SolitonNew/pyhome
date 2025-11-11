from PyQt5.QtWidgets import QWidget, QLabel
from PyQt5.QtGui import (QColor, QFont, QPixmap, QPainter, QImage, QPen, QBrush,
                         QFontMetrics, QLinearGradient)
from PyQt5.QtCore import Qt, QSize, QPoint, QTimer, QPropertyAnimation

class StringList(QWidget):    
    ROW_COUNT = 15
    ACTIVE_ROW_COUNT = 9
    
    def __init__(self, parent, drawHandler = None):
        super().__init__(parent)
        
        self.scrollOff = 0

        self.row_gradients = [[0.0, [0xff,0xff,0xff,0xff]],
                              [0.55, [0xff,0xff,0xff,0xff]],
                              [0.70, [0xff,0xff,0xff,0]]]

        self.paintListContainer = QWidget(self)
        self.rowCursor = QLabel(self.paintListContainer)        
        self.paintList = QLabel(self.paintListContainer)

        self.isFocused = True
        self.drawHandler = drawHandler
        self._selectedIndex = -1
        self._topIndex = 0
        self.decor = QLabel(self)
        self.data = []
        self.scrollAnimation = QPropertyAnimation(self.paintListContainer, "pos")
        self.scrollAnimation.setDuration(350)
        self.scrollAnimation.finished.connect(self.scrollFinished)

    def setData(self, data):
        self.data = data
        self.selectedIndex(0)
        self.redraw()

    def resizeEvent(self, event):
        self.paintListContainer.resize(self.size().width(), self.size().height() * 3)
        self.redrawRowCursor()
        self.redrawDecor()
        self.redraw()

    def selectedIndex(self, val = None):
        if len(self.data) == 0:
            return None        
        
        if val == None:
            return self._selectedIndex

        if self.scrollAnimation.state() == self.scrollAnimation.Running:
            return

        if val > self._selectedIndex:
            k = 1
        else:
            k = -1
        self._selectedIndex = val

        topIndex = self._topIndex
        for z in range(2):
            if self._selectedIndex > len(self.data) - 1:
                self._selectedIndex = 0
                topIndex = 0
            if self._selectedIndex < 0:
                self._selectedIndex = len(self.data) - 1
                topIndex = len(self.data) - self.ACTIVE_ROW_COUNT

            if self.data[self._selectedIndex].LABEL == "":
                self._selectedIndex += k
                k = 0
            else:
                break

        if self._selectedIndex > topIndex + self.ACTIVE_ROW_COUNT - 1:
            topIndex += self.ACTIVE_ROW_COUNT
        if topIndex > len(self.data) - self.ACTIVE_ROW_COUNT:
            topIndex = len(self.data) - self.ACTIVE_ROW_COUNT

        if self._selectedIndex < topIndex:
            topIndex -= self.ACTIVE_ROW_COUNT
        if topIndex < 0:
            topIndex = 0

        self.setTopIndex(topIndex)
        self.syncRowCursor()

    def redraw(self):
        size = self.size()
        self.paintListContainer.move(0, -size.height())
        self.paintList.resize(size.width(), size.height() * 3)
        line_height = size.height() / (self.ROW_COUNT - 1)
        font_size = line_height / 1.5
        v_offset = line_height * (self.ROW_COUNT - self.ACTIVE_ROW_COUNT) / 2 - line_height / 2
        pix = QPixmap(size.width(), size.height() * 3)
        pix.fill(QColor(0,0,0,0))
        p = QPainter()
        p.begin(pix)
        cf = p.font()        
        cf.setPixelSize(font_size)
        fm = QFontMetrics(cf)
        t_h = fm.height()
        rect_padding_left = line_height / 4

        o = 0 # round(self.scrollOff / line_height)

        n = self.ROW_COUNT - 1

        for i in range(-5 - n, 16 + n):
            x, y = line_height, v_offset + i * line_height
            w, h = self.width() - line_height * 2, line_height            
            y += size.height()
            i += self._topIndex

            if i > -1 and i < len(self.data):
                """
                if i == self._selectedIndex:
                    pen = QPen()
                    pen.setWidth(line_height / 15)
                    if self.isFocused:
                        pen.setColor(QColor(0xffffff))
                    else:
                        pen.setColor(QColor(0xff, 0xff, 0xff, 0x33))
                    pen.setStyle(Qt.SolidLine)
                    pen.setJoinStyle(Qt.RoundJoin)
                    p.setPen(pen)
                    p.setBrush(QBrush(QColor(0xff, 0xff, 0xff, 0x33), Qt.SolidPattern))
                    p.drawRect(x - rect_padding_left, y, w + rect_padding_left * 2, h)
                """
                
                g = QLinearGradient(x, y, x + w, y)
                for g_i in self.row_gradients:
                    if len(g_i[1]) > 3:
                        g.setColorAt(g_i[0], QColor(g_i[1][0], g_i[1][1], g_i[1][2], g_i[1][3]))           
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
        self.paintList.setPixmap(pix)
        self.redrawRowCursor()

    def paintEvent(self, event):
        pass

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
        line_height = self.size().height() / (self.ROW_COUNT - 1)
        self._scrollTopIndex = topIndex
        step = (self._topIndex - topIndex) * line_height
        self.scrollAnimation.setStartValue(QPoint(0, -self.size().height()))
        self.scrollAnimation.setEndValue(QPoint(0, -self.size().height() + step))
        self.scrollAnimation.start()

    def scrollFinished(self):
        #self.scrollOff = 0        
        self._topIndex = self._scrollTopIndex
        self.redraw()
        self.repaint()
        self.syncRowCursor()

    def syncRowCursor(self):
        size = self.size()
        line_height = size.height() / (self.ROW_COUNT - 1)
        rect_padding_left = line_height / 4
        v_offset = line_height * (self.ROW_COUNT - self.ACTIVE_ROW_COUNT) / 2 - line_height / 2
        i = self._selectedIndex - self._topIndex
        x, y = line_height - line_height / 4, v_offset + i * line_height        
        self.rowCursor.move(x, size.height() + y)

    def redrawRowCursor(self):
        size = self.size()
        line_height = size.height() / (self.ROW_COUNT - 1)
        v_offset = line_height * (self.ROW_COUNT - self.ACTIVE_ROW_COUNT) / 2 - line_height / 2
        w, h = self.width() - line_height * 1.5, line_height
        self.rowCursor.resize(w, h)
        pix = QPixmap(w, h)
        pix.fill(QColor(0xff, 0xff, 0xff, 0x33))
        if self.isFocused:
            p_w = line_height / 15
            p = QPainter()
            p.begin(pix)  
            pen = QPen()
            pen.setWidth(p_w)
            pen.setColor(QColor(0xffffff))
            pen.setStyle(Qt.SolidLine)
            pen.setJoinStyle(Qt.RoundJoin)
            p.setPen(pen)
            p.setBrush(QBrush(Qt.NoBrush))
            p.drawRect(p_w / 2, p_w / 2, w - p_w, h - p_w)
            p.end()
        self.rowCursor.setPixmap(pix)
        self.syncRowCursor()

        """
        pen = QPen()
        pen.setWidth(line_height / 15)
        if self.isFocused:
            pen.setColor(QColor(0xffffff))
        else:
            pen.setColor(QColor(0xff, 0xff, 0xff, 0x33))
        pen.setStyle(Qt.SolidLine)
        pen.setJoinStyle(Qt.RoundJoin)
        p.setPen(pen)
        p.setBrush()
        p.drawRect(x - rect_padding_left, y, w + rect_padding_left * 2, h)
        """
