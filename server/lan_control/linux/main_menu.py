from PyQt5.QtWidgets import QWidget, QLabel
from PyQt5.QtGui import QColor, QFont, QPixmap, QPainter, QImage, QPen
from PyQt5.QtCore import Qt, QSize, QRect, QTimer, QPropertyAnimation

from base_layer import BaseLayer

class MainMenu(BaseLayer):
    def __init__(self, parent):
        super().__init__(parent)     
        self.toolBar = MainToolBar(self)
        self.playerControl = PlayerControlPanel(self)
        self.showFullScreen()

    def isExpanded(self):
        return self.toolBar.isExpanded

    def selIndex(self, val = None):
        if not self.isExpanded and val != None:
            return 0
        return self.toolBar.selIndex(val)

    def expand(self):       
        self.toolBar.expand()
        self.repaint()

    def collapse(self):
        self.toolBar.collapse()
        self.repaint()

    def resizeEvent(self, event):
        self.toolBar.updatePos()
        self.playerControl.resize(self.size())

    def paintEvent(self, event):
        p = QPainter()
        p.begin(self)
        if self.toolBar.isExpanded:
            p.fillRect(0, 0, self.width(), self.height(), QColor(0,0,0,0xaa))        
        p.end()

class PlayerControlPanel(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.player = parent.mainForm.player

    def paintEvent(self, event):
        p = QPainter()
        p.begin(self)
        self.drawPos(p)
        self.drawVolume(p)
        p.end()

    def drawPos(self, painter):
        size = self.size()

        p_w = size.height() / 200
        w, h = size.width() / 1.5, size.height() / 25
        x, y = (size.width() - w) / 2, size.height() - h * 2

        pen = QPen()
        pen.setWidth(p_w)
        pen.setColor(QColor(0xffffff))
        pen.setStyle(Qt.SolidLine)
        pen.setJoinStyle(Qt.RoundJoin)

        painter.setPen(pen)
        painter.setBrush(QColor(0,0,0,0))
        painter.drawRect(x, y, w, h)

        pos, posLen = self.player.getMediaRange()

        x += p_w
        y += p_w
        w -= p_w * 2
        h -= p_w * 2
        if posLen > 0:
            x_pos = w / posLen * pos
        else:
            x_pos = 0
        painter.setPen(QColor(0,0,0,0))
        painter.setBrush(QColor(0xffffff))
        painter.drawRect(x, y, x_pos, h)

    def drawVolume(self, painter):
        size = self.size()

        p_w = size.height() / 200
        w, h = size.width() / 25, size.height() / 1.5
        x, y = size.width() - w * 2, (size.height() - h) / 2

        pen = QPen()
        pen.setWidth(p_w)
        pen.setColor(QColor(0xffffff))
        pen.setStyle(Qt.SolidLine)
        pen.setJoinStyle(Qt.RoundJoin)

        painter.setPen(pen)
        painter.setBrush(QColor(0,0,0,0))
        painter.drawRect(x, y, w, h)

        vol = self.player.volume()

        x += p_w
        y += p_w * 1.5
        w -= p_w * 2
        h -= p_w * 2
        y_vol = h - (h / 200 * vol)
        painter.setPen(QColor(0,0,0,0))
        painter.setBrush(QColor(0xffffff))
        painter.drawRect(x, y + y_vol, w, h - y_vol)

class MainToolBar(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.animate = QPropertyAnimation(self, "geometry")
        self.animate.setDuration(150)
        self.isExpanded = False
        self._selIndex = 0
        self.btnMaxSize = 0
        self.items = []
        self.addItem("Свет/Розетки", "1.png")
        self.addItem("Температура/Термостаты/Влажность", "2.png")
        self.addItem("Вентиляция/Газконтроль/Атмосферное давление", "3.png")
        self.addItem("Мультимедия", "5.png")
        self.addItem("Видеонаблюдение", "6.png")

        self.minBarWidth = 0
        self.maxBarWidth = 0

    def addItem(self, title, img):
        img = QImage("images/%s" % (img))
        self.items += [[img, title]]
        self.btnMaxSize = max(self.btnMaxSize, max(img.width(), img.height()))

    def updatePos(self):
        x, y, w, h = self._calcToolBarRect(False)
        self.resize(w, h)
        self.move(x, y)

    def selIndex(self, val = None):
        if val == None:
            return self._selIndex
        
        self._selIndex = val
        if self._selIndex < 0:
            self._selIndex = len(self.items) - 1
        if self._selIndex > len(self.items) - 1:
            self._selIndex = 0
        self.repaint()

    def expand(self):       
        self.isExpanded = True
        x, y, w, h = self._calcToolBarRect(False)
        self.animate.setStartValue(QRect(x, y, w, h))
        x, y, w, h = self._calcToolBarRect(True)
        self.animate.setEndValue(QRect(x, y, w, h))
        self.animate.start()

    def collapse(self):       
        self.isExpanded = False
        x, y, w, h = self._calcToolBarRect(True)
        self.animate.setStartValue(QRect(x, y, w, h))
        x, y, w, h = self._calcToolBarRect(False)
        self.animate.setEndValue(QRect(x, y, w, h))
        self.animate.start()

    def paintEvent(self, event):
        size = self.size()
        p_w = size.height() / 20
        btn_size_k = size.height() / (self.btnMaxSize * 1.4);
        
        pen = QPen()
        pen.setWidth(p_w)
        pen.setColor(QColor(0xffffff))
        pen.setStyle(Qt.SolidLine)
        pen.setJoinStyle(Qt.RoundJoin)

        #op =  self.minBarWidth
        mab, mib = self.maxBarWidth, self.minBarWidth
        op = (size.width() - mib) * 0.6 / (mab - mib) + 0.4
        if op > 1:
            op = 1
        p = QPainter()        
        p.begin(self)
        p.setOpacity(op)
        p.setPen(pen)
        for i in range(len(self.items)):
            btn = self.items[i]
            img = btn[0]
            x = i * size.height() + p_w / 2
            y = p_w / 2
            w, h = size.height() - p_w, size.height() - p_w
            if i == self._selIndex:
                p.setBrush(QColor(0xff, 0xff, 0xff, 0x33))
                p.drawRect(x, y, w, h)
            nw, nh = img.width() * btn_size_k, img.height() * btn_size_k
            img_s = img.scaled(nw, nh, transformMode=Qt.SmoothTransformation)
            p.drawImage(x + (size.height() - nw) / 2 - p_w / 2, y + (size.height() - nh) / 2 - p_w / 2, img_s)
        p.end()

    def _calcToolBarRect(self, large):
        self.minBarWidth = self.parent().mainForm.width() // 4
        self.maxBarWidth = self.parent().mainForm.width() // 2
        if large:
            w = self.maxBarWidth
        else:
            w = self.minBarWidth
        h = w / len(self.items)
        try:
            x, y = (self.parent().mainForm.width() - w) / 2, h / 10
        except:
            x, y = 0, 0
        return [x, y, w, h]
        
