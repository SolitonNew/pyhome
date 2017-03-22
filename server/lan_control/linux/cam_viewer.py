from PyQt5.QtWidgets import QWidget, QLabel, QFrame
from PyQt5.QtGui import (QPixmap, QPainter, QImage, QFontMetrics, QColor,
                         QPen, QBrush, QLinearGradient)
from PyQt5.QtCore import Qt, QTimer

from base_layer import BaseLayer
import vlc

class CamViewer(BaseLayer):
    def __init__(self, parent):
        super().__init__(parent)
        self.cams = []
        self.camFrames = []
        self.showFullScreen()
        
    def start(self):
        self.cams = self.query("cams")
        for rec in self.cams:
            f = CamFrame(self, self.mainForm.vlc_inst, rec[2])
            self.camFrames += [f]
        self.reset_layout()
        self.redraw()

    def stop(self):
        try:
            for p in self.camFrames:
                p.hide()
            self.camFrames = []
        except:
            pass

    def on(self):
        super().on()
        self.start()

    def off(self):
        super().off()
        self.stop()

    def reset_layout(self):
        size = self.size()
        nums = 2
        if len(self.cams) > 4:
            nums = 4
        w_num, h_num = round(size.width() / nums), round(size.height() / nums)
        i = 0
        f_w, f_h = w_num, h_num
        for y in range(nums):
            for x in range(nums):
                f_x, f_y  = x * f_w, y * f_h 
                try:
                    f = self.camFrames[i]
                    f.move(f_x, f_y)
                    f.resize(f_w, f_h)
                except:
                    pass
                i += 1

    def resizeEvent(self, event):
        self.reset_layout()

    def redraw(self):
        pass
    
class CamFrame(QWidget):
    def __init__(self, parent, inst, url):
        super().__init__(parent)
        self.inst = inst
        self.url = url
        self.show()

    def showEvent(self, event):
        inst = self.inst
        self.player = inst.media_player_new(self.url)
        self.player.set_xwindow(self.winId())
        #self.player.video_set_aspect_ratio("16:11")
        self.player.play()

    def resizeEvent(self, event):
        size = event.size()
        w, h = round(size.width()), round(size.height())
        try:
            self.player.video_set_aspect_ratio("%s:%s" % (w, h))
        except:
            pass

    def hideEvent(self, event):
        self.player.stop()
        self.player.release()
