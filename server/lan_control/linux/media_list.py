from PyQt5.QtWidgets import QWidget, QLabel
from PyQt5.QtGui import (QColor, QFont, QPixmap, QPainter, QImage, QPen, QBrush,
                         QFontMetrics, QLinearGradient)
from PyQt5.QtCore import Qt, QSize, QTimer

from base_layer import BaseLayer
from string_list import StringList
from connector import ItemList

class MediaList(BaseLayer):
    def __init__(self, parent):
        super().__init__(parent)
        self._selectedPanel = 0

        self.groupListBg = QLabel(self.content)
        
        self.groupList = StringList(self.content)
        self.groupList.row_gradients = [[0.0, [0xff, 0xff, 0xff, 0xff]],
                                        [0.95, [0xff, 0xff, 0xff, 0xff]],
                                        [1.0, [0xff, 0xff, 0xff, 0x0]]]

        self.trackList = StringList(self.content)
        self.trackList.isFocused = False
        self.trackList.row_gradients = [[0.0, [0xff, 0xff, 0xff, 0xff]],
                                        [0.95, [0xff, 0xff, 0xff, 0xff]],
                                        [1.0, [0xff, 0xff, 0xff, 0x0]]]

        self.showFullScreen()

    def resizeEvent(self, event):
        size = self.size()
        l_w = size.width() / 2.6
        self.groupList.resize(l_w, size.height())

        self.groupListBg.resize(l_w, size.height())
        pix = QPixmap(l_w, size.height())
        pix.fill(QColor(0xff, 0xff, 0xff, 0x33))
        self.groupListBg.setPixmap(pix)

        c_w, c_h = size.width() - l_w, size.height()
        c_x, c_y = l_w, size.height() - c_h
        self.trackList.move(c_x, c_y)
        self.trackList.resize(c_w, c_h)

        self.redraw()

    def selectedIndex(self, index=None):
        if self._selectedPanel == 0:
            res = self.groupList.selectedIndex(index)
        else:
            res = self.trackList.selectedIndex(index)
        if index != None:
            if self._selectedPanel == 0:
                self.recalcGroupTracks()

        return res

    def setGroupData(self, data):
        self.groupList.setData(data)

    def setTrackData(self, data):
        self.trackData = data
        self.recalcGroupTracks()

    def recalcGroupTracks(self):
        group = self.groupList.data[self.groupList.selectedIndex()]
        g_lab = group.LABEL.upper()
        g_lab_len = len(g_lab)
        tmp = self.query("get groups cross", group.data[0])
        for i in range(len(tmp)):
            try:
                tmp[i] = int(tmp[i][0])
            except:
                pass

        tracks = []
        for t in self.trackData:
            try:
                tmp.index(t[0])
                l = ItemList(t, 1)
                for rep in range(3):
                    if l.LABEL[:g_lab_len:].upper() == g_lab:                    
                        l.LABEL = l.LABEL[g_lab_len::]
                        z = 0
                        for c in l.LABEL:
                            if c == " " or c == "-" or c == "_":
                                z += 1
                            else:
                                break
                        l.LABEL = l.LABEL[z::]
                    else:
                        break
                tracks += [l]
            except:
                pass
        self.trackList.setData(tracks)
            
    def selectedRow(self):
        try:
            if self._selectedPanel == 0:
                return self.groupList.data[self.groupList.selectedIndex()]
            else:
                return self.trackList.data[self.trackList.selectedIndex()]
        except:
            return None

    def selectedPanel(self, index=None):
        if index == None:
            return self._selectedPanel

        self._selectedPanel = index
        if self._selectedPanel > 1:
            self._selectedPanel = 0
        if self._selectedPanel < 0:
            self._selectedPanel = 1

        self.groupList.isFocused = (self._selectedPanel == 0)
        self.trackList.isFocused = (self._selectedPanel == 1)

        self.redraw()

    def redraw(self):
        self.groupList.redraw()
        self.trackList.redraw()

    def play(self):
        try:
            d = self.trackList.data[self.trackList.selectedIndex()].data
            ip = ""
            id = d[0]
            for sess in  self.mainForm.sessions:
                if sess[0] == d[2]:
                    ip = sess[2]
                    break
            url = "http://%s:8092/%s" % (ip, id)
            self.mainForm.player.play(url)
            self.off()
        except Exception as e:
            print(e)

    def playNext(self):
        pass

    def playPrev(self):
        pass
