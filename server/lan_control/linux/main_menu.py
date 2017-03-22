from PyQt5.QtWidgets import QWidget, QLabel
from PyQt5.QtGui import QColor, QFont, QPixmap, QPainter, QImage, QPen
from PyQt5.QtCore import Qt, QSize, QTimer

from base_layer import BaseLayer

class MainMenu(BaseLayer):
    def __init__(self, parent):
        super().__init__(parent)        

        self.timer = QTimer(self)
        self.timer.timeout.connect(self.timerHandler)

        self.isExpanded = False
        self.drawWidth = 0
        self.drawOpacity = 1
        self.fill_bg = QLabel(self)
        self.canvas = QLabel(self)

        self._selIndex = 0
        self.items = []

        self.btnMaxSize = 0
        
        self.addItem("Свет/Розетки", "1.png")
        self.addItem("Температура/Термостаты/Влажность", "2.png")
        self.addItem("Вентиляция/Газконтроль/Атмосферное давление", "3.png")
        #self.addItem("Расписание", "4.png")
        self.addItem("Мультимедия", "5.png")
        self.addItem("Видеонаблюдение", "6.png")

        self.drawWidthEnd = 0
        self.drawOpacityEnd = 1

        self.redraw()

        self.showFullScreen()

    def addItem(self, title, img):
        img = QImage("images/%s" % (img))
        self.items += [[img, title]]
        self.btnMaxSize = max(self.btnMaxSize, max(img.width(), img.height()))

    def toTop(self):
        self.raise_()
        self.activateWindow()        

    def selIndex(self, val = None):
        if val == None:
            return self._selIndex

        if not self.isExpanded:
            return None
        
        self._selIndex = val
        if self._selIndex < 0:
            self._selIndex = len(self.items) - 1
        if self._selIndex > len(self.items) - 1:
            self._selIndex = 0
        
        self.redraw()

    def _calcWidth(self, large):
        if large:
            return self.mainForm.width() // 2
        else:
            return self.mainForm.width() // 4

    def _calcOpacity(self, large):
        if large:
            return 1.0
        else:
            return 0.4

    def timerHandler(self):        
        is_finish = False
        if self.isExpanded:
            if self.drawWidth + self.widthStep >= self.drawWidthEnd:
                id_finish = True
            else:
                self.drawWidth += self.widthStep
                self.drawOpacity += self.opacityStep
        else:
            if self.drawWidth + self.widthStep <= self.drawWidthEnd:
                id_finish = True
                self.fill_bg.setVisible(False)
            else:
                self.drawWidth += self.widthStep
                self.drawOpacity += self.opacityStep

        if is_finish:
            self.timer.stop()            
            self.drawWidth = self.drawWidthEnd
            self.drawOpacity = self.drawOpacityEnd
        self.redraw()

    def expand(self):       
        self.isExpanded = True
        self.fill_bg.setVisible(True)
        
        self.widthStep = (self._calcWidth(True) - self._calcWidth(False)) / 12
        self.drawWidth = self.drawWidthEnd
        self.drawWidthEnd = self._calcWidth(True)

        self.opacityStep = (self._calcOpacity(True) - self._calcOpacity(False)) / 12
        self.drawOpacity = self.drawOpacityEnd
        self.drawOpacityEnd = self._calcOpacity(True)
        
        self.timer.start(10)

    def collapse(self):       
        self.isExpanded = False
        
        self.widthStep = (self._calcWidth(False) - self._calcWidth(True)) / 12
        self.drawWidth = self.drawWidthEnd
        self.drawWidthEnd = self._calcWidth(False)

        self.opacityStep = (self._calcOpacity(False) - self._calcOpacity(True)) / 12
        self.drawOpacity = self.drawOpacityEnd
        self.drawOpacityEnd = self._calcOpacity(False)
        
        self.timer.start(10)

    def resizeEvent(self, event):
        self.fill_bg.resize(self.size())
        pix = QPixmap(self.width(), self.height())
        pix.fill(QColor(0, 0, 0, 0xaa))
        self.fill_bg.setPixmap(pix)

        self.drawWidth = self._calcWidth(self.isExpanded)
        self.drawWidthEnd = self.drawWidth
        self.drawOpacity = self._calcOpacity(self.isExpanded)
        self.drawOpacityEnd = self.drawOpacity
        self.redraw()

    def redraw(self):
        w = self.drawWidth # self.parentWidget().width() // 2
        item_wh = w / len(self.items)
        p_w = item_wh / 20
        self.resize(self.mainForm.size())        
        self.canvas.resize(QSize(w + p_w, item_wh + p_w + p_w))
        self.canvas.move((self.mainForm.width() - w) / 2, item_wh / 5)
        btn_size_k = item_wh / (self.btnMaxSize * 1.4);

        pen = QPen()
        pen.setWidth(p_w)
        pen.setColor(QColor(0xffffff))
        pen.setStyle(Qt.SolidLine)
        pen.setJoinStyle(Qt.RoundJoin)

        pix = QPixmap(w + 10, item_wh + p_w + p_w)
        pix.fill(QColor(0,0,0,0))
        p = QPainter()        
        p.begin(pix)
        p.setOpacity(self.drawOpacity)
        p.setPen(pen)
        for i in range(len(self.items)):
            btn = self.items[i]
            img = btn[0]
            x = i * item_wh + p_w / 2
            y = p_w
            if i == self._selIndex:
                p.setBrush(QColor(0xff, 0xff, 0xff, 0x33))
                p.drawRect(x, y, item_wh, item_wh)
                
            nw, nh = img.width() * btn_size_k, img.height() * btn_size_k
            img_s = img.scaled(nw, nh, transformMode=Qt.SmoothTransformation)
            p.drawImage(x + (item_wh - nw) / 2, y + (item_wh - nh) / 2, img_s)
        p.end()
        self.canvas.setPixmap(pix)

        
