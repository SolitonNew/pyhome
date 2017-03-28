from PyQt5.QtWidgets import QWidget, QLabel
from PyQt5.QtGui import (QColor, QFont, QPixmap, QPainter, QImage, QPen,
                         QFontMetrics)
from PyQt5.QtCore import Qt, QSize, QRect, QTimer, QPropertyAnimation

from base_layer import BaseLayer

class MainMenu(BaseLayer):
    def __init__(self, parent):
        super().__init__(parent)     
        self.toolBar = MainToolBar(self)
        self.playerPosPanel = PlayerPosPanel(self)
        self.playerVolumePanel = PlayerVolumePanel(self)
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
        self.playerPosPanel.resize(self.size())
        self.playerVolumePanel.resize(self.size())

    def paintEvent(self, event):
        p = QPainter()
        p.begin(self)
        if self.toolBar.isExpanded:
            p.fillRect(0, 0, self.width(), self.height(), QColor(0,0,0,0xaa))        
        p.end()

    def playerPosInfo(self, val=None, temporary=True):
        if val == None:
            return self.playerPosPanel.isVisible()
        
        if (self.playerPosPanel.isVisible() != val):
            self.playerPosPanel.setVisible(val)
        else:
            if val:
                self.playerPosPanel.showEvent(None)
            else:
                self.playerPosPanel.hideEvent(None)
        if not temporary:
            self.playerPosPanel.timer.stop()

    def showVolume(self):
        self.playerVolumePanel.showVolume()

    def timeOut(self):
        if self.mainForm.player.isPlaying() and not self.isExpanded():
            self.toolBar.hide()

class PlayerPosPanel(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.timerHandler)
        self.hide()
        self.player = parent.mainForm.player

    def update(self):
        if self.isVisible():
            self.repaint()

    def timerHandler(self):
        self.timer.stop()
        self.hide()
        self.parentWidget().timeOut()

    def showEvent(self, event):
        self.timer.stop()
        self.timer.start(10000)        

    def hideEvent(self, event):
        self.timer.stop()

    def paintEvent(self, event):
        p = QPainter()
        p.begin(self)
        self.drawPos(p)
        p.end()

    def _time_2_str(self, sec):
        h = sec // 3600
        m = (sec - h * 3600) // 60
        s = sec - h * 3600 - m * 60

        h_s = "%s" % (h)
        if m > 9:
            m_s = "%s" % (m)
        else:
            m_s = "0%s" % (m)
        if s > 9:
            s_s = "%s" % (s)
        else:
            s_s = "0%s" % (s)
        
        return "%s:%s:%s" % (h_s, m_s, s_s)

    def drawPos(self, painter):
        size = self.size()

        p_w = size.height() / 200
        w, h = size.width() / 1.5, size.height() / 25
        x, y = (size.width() - w) / 2, size.height() - h * 2

        font_height = h

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

        font = painter.font()
        font.setPixelSize(font_height)
        fm = QFontMetrics(font)
        painter.setFont(font)
        text_pos = self._time_2_str(pos)
        text_len = self._time_2_str(posLen)
        painter.setPen(QColor(0xffffff))
        f_y = y + h + (font_height - fm.height()) / 2
        painter.drawText(x - fm.width(text_pos) - p_w * 5, f_y, text_pos)
        painter.drawText(x + w + p_w * 5, f_y, text_len)
        try:
            textTitle = self.parentWidget().mainForm.page_media.playingData[1]
        except:
            textTitle = ""
        painter.drawText((size.width() - fm.width(textTitle)) / 2, y - h, textTitle)

class PlayerVolumePanel(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.timerHandler)
        self.hide()
        self.player = parent.mainForm.player

    def timerHandler(self):
        self.timer.stop()
        self.hide()

    def showVolume(self):
        self.timer.stop()
        self.timer.start(10000)
        self.show()
        self.repaint()

    def paintEvent(self, event):
        p = QPainter()
        p.begin(self)
        self.drawVolume(p)
        p.end()

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
        self.show()
        self.isExpanded = True
        x, y, w, h = self._calcToolBarRect(False)
        self.animate.setStartValue(QRect(x, y, w, h))
        x, y, w, h = self._calcToolBarRect(True)
        self.animate.setEndValue(QRect(x, y, w, h))
        self.animate.start()

    def collapse(self):
        self.show()
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
        
