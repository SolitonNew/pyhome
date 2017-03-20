from PyQt5.QtWidgets import QWidget, QLabel
from PyQt5.QtGui import (QColor, QFont, QPixmap, QPainter, QImage, QPen, QBrush,
                         QFontMetrics, QLinearGradient)
from PyQt5.QtCore import Qt, QSize, QTimer

from controls.string_list import StringList
from controls.var_chart import VarChart

class VarList(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.setVisible(False)        
        self.itemList = StringList(self, self.drawHandler)
        self.varChart = VarChart(self)

    def resizeEvent(self, event):
        size = self.size()
        l_w = size.width() / 2
        self.itemList.resize(l_w, size.height())
        self.redraw()

        c_w, c_h = size.width() - l_w, size.height() / 2.5
        c_x, c_y = l_w, size.height() - c_h
        self.varChart.move(c_x, c_y)
        self.varChart.resize(c_w, c_h)

        """
        h_pad, v_pad = size.width() / 20, size.height() / 8
        pw, ph = size.width() / 2.1 - h_pad, size.height() / 1.2 - v_pad
        px, py = size.width() - pw - h_pad, (size.height() - ph) / 2
        self.varPreview.resize(pw, ph)
        self.varPreview.move(px, py)
        self.varPreview.redraw()
        """

    def selectedIndex(self, index=None):
        res = self.itemList.selectedIndex(index)
        if index != None:
            self.varChart.variable = self.selectedRow()
            self.varChart.redraw()
        return res

    def setData(self, data):
        self.itemList.setData(data)
        self.selectedIndex(self.selectedIndex())

    def selectedRow(self):
        try:
            return self.itemList.data[self.itemList.selectedIndex()]
        except:
            return None

    def drawHandler(self, painter, rect, var):
        x, y, w, h = rect
        fm = QFontMetrics(painter.font())
        if var.LABEL == "":
            padd = h / 4
            t_w = fm.width(var.comm)
            painter.setPen(QColor(0xff, 0xff, 0xff, 0x99))
            painter.drawText(x + (w - t_w) / 2, y + fm.height(), var.comm)

            g = QLinearGradient(x - padd, y, x - padd, y + h)
            g.setColorAt(0.0, QColor(0xff,0xff,0xff,0))
            g.setColorAt(0.4, QColor(0xff,0xff,0xff,0x22))
            g.setColorAt(0.6, QColor(0xff,0xff,0xff,0x22))
            g.setColorAt(1.0, QColor(0xff,0xff,0xff,0))
            painter.setBrush(QBrush(g))
            painter.setPen(QColor(0,0,0,0))
            painter.drawRect(x - padd, y, w + padd * 2, h)
            return 
        
        lab, lab2 = "", ""
        if var.typ == 1 or var.typ == 3: # Свет, Розетки
            if var.value == 1.0:
                lab = "ВКЛ."
                painter.setPen(QColor(0xff0000))
            else:
                lab = "ВЫКЛ."
                painter.setPen(QColor(0x00ff00))
        elif var.typ == 4: # Термометры (Термостаты)
            if var.value != None:
                lab = "%sºC" % (var.value)
            if var.link_id > 0 and var.link_value != None:
                lab2 = "<%s>" % (round(var.link_value))
            painter.setPen(QColor(0xF8F835))
        elif var.typ == 7: # Вентилятор
            lab = ("%s " % (var.value)) + "%"
            painter.setPen(QColor(0x00ffff))
        elif var.typ == 10: # Гигрометр
            lab = ("%s " % (var.value)) + "%"
            painter.setPen(QColor(0xa0a0ff))
        elif var.typ == 11: # Газометры
            lab = ("%s " % (round(var.value, 1))) + "ppm"
            painter.setPen(QColor(0xff00ff))
        elif var.typ == 13: # Барометр
            lab = ("%s " % (var.value)) + "mm"
            painter.setPen(QColor(0xff00ff))
            
        painter.drawText(x + w - fm.width(lab), y + fm.height(), lab)
        if lab2 != "":
            painter.drawText(x + w - fm.width("WWWWWW"), y + fm.height(), lab2)

    def redraw(self):
        self.itemList.redraw()
        self.varChart.redraw()
        
