from PyQt5.QtWidgets import QLabel
from PyQt5.QtGui import (QPixmap, QPainter, QImage, QFontMetrics, QColor,
                         QPen, QBrush, QLinearGradient)
from PyQt5.QtCore import Qt, QSize
import math
import time, datetime

class VarChart(QLabel):
    def __init__(self, parent):
        super().__init__(parent)
        self.variable = None

    def resizeEvent(self, event):
        self.redraw()

    def redraw(self):
        if self.variable != None:
            if (self.variable.typ == 4 or
                self.variable.typ == 10 or
                self.variable.typ == 11 or
                self.variable.typ == 13):
                self.drawLineChart()
            elif self.variable.typ == 7:
                self.drawLinearChart()


    def drawLineChart(self):
        size = self.size()
        v_pad, h_pad = self.parentWidget().size().width() / 20, self.parentWidget().size().height() / 10
        pix = QPixmap(size.width(), size.height())
        pix.fill(QColor(0,0,0,0))

        r_x, r_y, r_w, r_h = v_pad, h_pad, size.width() - v_pad * 2, size.height() - h_pad * 2
        
        p = QPainter()
        p.begin(pix)
        cf = p.font()        
        cf.setPixelSize(v_pad / 4)
        p.setFont(cf)
        fm = QFontMetrics(cf)

        pen = QPen()
        pen.setWidth(v_pad / 20)
        pen.setColor(QColor(0xffffff))
        p.setPen(pen)
        p.setBrush(QColor(0xff, 0xff, 0xff, 0x33))
        p.drawRect(r_x, r_y, r_w, r_h)

        pen = QPen()
        pen.setWidth(v_pad / 50)
        pen.setColor(QColor(0xffffff))
        p.setPen(pen)        

        # Отрисовка вертикальной сетки часов
        k_x = r_w / 24
        x = r_x + k_x
        for i in range(1, 24):
            p.drawLine(x, r_y, x, r_y + r_h)
            x += k_x

        # Отрисовка значений сетки часов
        x = r_x + k_x
        for i in range(13):
            if i == 12:
                lab = "0"
            else:
                lab = str(i + i)
            p.drawText(x - k_x - fm.width(lab) / 2, r_y + r_h + fm.height(), lab)
            x += k_x + k_x

        if self.variable != None:
            mi, ma = self.variable.varDataRange
            v_nums = math.trunc(r_h / (fm.height() * 1.5))
            c = round(ma - mi)
            resolut = c / v_nums
            if resolut > 9:
                step = 10
            else:
                step = 1

            # Отрисовка горизонтальной сетки
            mi_trunc = math.floor(mi / step)
            ma_trunc = math.ceil(ma / step)           
            
            k_y = r_h / ((ma_trunc - mi_trunc) * step)
            for i in range(1, ma_trunc - mi_trunc):
                y = r_y + r_h - i * step * k_y
                pen = QPen()
                pen.setColor(QColor(0xffffff))
                if y == 0:
                    pen.setWidth(v_pad / 20)
                else:
                    pen.setWidth(v_pad / 50)
                p.setPen(pen)
                p.drawLine(r_x, y, r_x + r_w, y)

            lab_step = math.ceil(fm.height() * 1.5 / (step * k_y))
            lab_k = mi_trunc - (mi_trunc // lab_step) * lab_step
            # Отрисовка значений по оси Y
            for i in range(ma_trunc - mi_trunc + 1):
                y = r_y + r_h - i * step * k_y
                lab = str((mi_trunc + i) * step)
                x = r_x - fm.width(lab) - fm.height() / 2
                if lab_k == 0:
                    p.drawText(x, y + fm.height() / 3, lab)
                    lab_k = lab_step
                lab_k -= 1

            pen = QPen()
            pen.setWidth(v_pad / 20)
            pen.setColor(QColor(0xff0000))
            p.setPen(pen)
            data = self.variable.varData

            d = datetime.datetime.now()
            start_time = datetime.datetime(d.year, d.month, d.day).timestamp()            

            mi_t = mi_trunc * step
            i_x = 3600 / k_x
            p_x, p_y = data[0]
            p_x = (p_x - start_time) / i_x + r_x
            p_y = r_y + r_h - ((p_y - mi_t) * k_y)
            for i in range(1, len(data)):
                x, y = data[i]
                x = (x - start_time) / i_x + r_x
                y = r_y + r_h - ((y - mi_t) * k_y)
                p.drawLine(p_x, p_y, x, y)
                p_x, p_y = x, y
        p.end()
        self.setPixmap(pix)

    def drawLinearChart(self):
        size = self.size()
        v_pad, h_pad = self.parentWidget().size().width() / 20, self.parentWidget().size().height() / 10
        pix = QPixmap(size.width(), size.height())
        pix.fill(QColor(0,0,0,0))

        r_x, r_y, r_w, r_h = v_pad, h_pad, size.width() - v_pad * 2, size.height() - h_pad * 2
        
        p = QPainter()
        p.begin(pix)
        cf = p.font()        
        cf.setPixelSize(v_pad / 4)
        p.setFont(cf)
        fm = QFontMetrics(cf)

        pen = QPen()
        pen.setWidth(v_pad / 20)
        pen.setColor(QColor(0xffffff))
        p.setPen(pen)
        p.setBrush(QColor(0xff, 0xff, 0xff, 0x33))
        p.drawRect(r_x, r_y, r_w, r_h)

        pen = QPen()
        pen.setWidth(v_pad / 50)
        pen.setColor(QColor(0xffffff))
        p.setPen(pen)        

        # Отрисовка вертикальной сетки часов
        k_x = r_w / 24
        x = r_x + k_x
        for i in range(1, 24):
            p.drawLine(x, r_y, x, r_y + r_h)
            x += k_x

        # Отрисовка значений сетки часов
        x = r_x + k_x
        for i in range(13):
            if i == 12:
                lab = "0"
            else:
                lab = str(i + i)
            p.drawText(x - k_x - fm.width(lab) / 2, r_y + r_h + fm.height(), lab)
            x += k_x + k_x

        if self.variable != None:
            mi, ma = self.variable.varDataRange
            v_nums = math.trunc(r_h / (fm.height() * 1.5))
            c = round(ma - mi)
            resolut = c / v_nums
            if resolut > 9:
                step = 10
            else:
                step = 1
            
            # Отрисовка горизонтальной сетки
            mi_trunc = math.floor(mi / step)
            ma_trunc = math.ceil(ma / step)           
            
            k_y = r_h / ((ma_trunc - mi_trunc) * step)
            for i in range(1, ma_trunc - mi_trunc):
                y = r_y + r_h - i * step * k_y
                p.drawLine(r_x, y, r_x + r_w, y)

            lab_step = math.ceil(fm.height() * 1.5 / (step * k_y))
            lab_k = mi_trunc - (mi_trunc // lab_step) * lab_step
            # Отрисовка значений по оси Y
            for i in range(ma_trunc - mi_trunc + 1):
                y = r_y + r_h - i * step * k_y
                lab = str((mi_trunc + i) * step)
                x = r_x - fm.width(lab) - fm.height() / 2
                if lab_k == 0:
                    p.drawText(x, y + fm.height() / 3, lab)
                    lab_k = lab_step
                lab_k -= 1

            pen = QPen()
            pen.setWidth(v_pad / 20)
            pen.setColor(QColor(0xff0000))
            p.setPen(pen)
            data = self.variable.varData

            d = datetime.datetime.now()
            start_time = datetime.datetime(d.year, d.month, d.day).timestamp()            

            mi_t = mi_trunc * step
            i_x = 3600 / k_x
            p_x, p_y = data[0]
            p_x = (p_x - start_time) / i_x + r_x
            p_y = r_y + r_h - ((p_y - mi_t) * k_y)
            for i in range(1, len(data)):
                x, y = data[i]
                x = (x - start_time) / i_x + r_x
                y = r_y + r_h - ((y - mi_t) * k_y)
                p.drawLine(p_x, p_y, x, p_y)
                p.drawLine(x, p_y, x, y)
                p_x, p_y = x, y
        p.end()
        self.setPixmap(pix)        
