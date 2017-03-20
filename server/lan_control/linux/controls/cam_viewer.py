from PyQt5.QtWidgets import QWidget, QLabel
from PyQt5.QtGui import (QPixmap, QPainter, QImage, QFontMetrics, QColor,
                         QPen, QBrush, QLinearGradient)

class CamViewer(QWidget):
    def __init__(self, parent):
        super().__init__(parent)        
        self.query = parent.conn.query
        self.cams = []
        self.camList = []
        self.canvas = QLabel(self)
        #self.start()
        self.setVisible(False)
        #QCamera
        
    def start(self):
        self.cams = self.query("cams")
        self.redraw()

        for rec in self.cams:
            pass

    def stop(self):
        pass

    def setVisible(self, val):
        super().setVisible(val)
        if val:
            self.start()
        else:
            self.stop()

    def resizeEvent(self, event):
        self.canvas.resize(self.size())

    def redraw(self):
        size = self.size()
        penWidth = size.width() / 15
        nums = 2
        if len(self.cams) > 4:
            nums = 4

        pix = QPixmap(size.width(), size.height())
        pix.fill(QColor(0xffffff))
        p = QPainter()
        p.begin(pix)

        w_num, h_num = round(size.width() / nums), round(size.height() / nums)
        for y in range(nums):
            for x in range(nums):
                pen = QPen()
                pen.setWidth(penWidth)
                pen.setColor(QColor(0xffffff))
                p.setPen(QColor(0xffffff))
                p.setBrush(QColor(0x333333))
                p.drawRect(x * w_num, y * h_num, (x + 1) * w_num, (y + 1) * h_num)

        p.end()
        self.canvas.setPixmap(pix)
                
            

        
