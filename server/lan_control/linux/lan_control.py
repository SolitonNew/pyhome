#!/usr/bin/python3
#-*- coding: utf-8 -*-

import sys
from PyQt5.QtWidgets import QApplication, QWidget, QLabel
from PyQt5.QtGui import (QPixmap, QPainter, QImage, QFontMetrics, QColor,
                         QPen, QBrush, QLinearGradient)
from PyQt5.QtCore import Qt, QSize, QTimer
from main_menu import MainMenu
from var_list import VarList
from media_list import MediaList
from cam_viewer import CamViewer
from connector import Connector
from connector import VarItem
from connector import ItemList

import vlc

class Main(QWidget):
    def __init__(self):
        super().__init__()
        self.vlc_inst = vlc.Instance()        
        
        self.varGroups = []
        self.varList = []
        self.mediaExts = ''
        self.mediaFolders = []
        self.mediaList = []
        
        self.conn = Connector(3)

        self.selectedPage = None
        
        self.setWindowTitle('lan control v1.0')
        self.bgImage = QImage("images/bg.png")
        self.bg = QLabel(self)
        self.showFullScreen()
        
        self.timer = QTimer(self)
        self.timer.timeout.connect(self._onTimer)
        self.timer.start(200)

        self.eventTimer = QTimer(self)
        self.eventTimer.timeout.connect(self._syncHandler)

        self.createChilds()

    def createChilds(self):        
        self.page_var_1 = VarList(self)
        self.page_var_2 = VarList(self)
        self.page_var_3 = VarList(self)
        self.page_media = MediaList(self)
        self.page_cam = CamViewer(self)

        self.pages = [self.page_var_1,
                      self.page_var_2,
                      self.page_var_3,
                      self.page_media,
                      self.page_cam]

        self.mainMenu = MainMenu(self)
        self.mainMenu.collapse()

        self.showPage()

    def _onTimer(self):        
        self.timer.stop()
        self.showPage()
        self._startLoad()

    def resizeEvent(self, event):
        self.bg.resize(self.size())
        self.bg.setPixmap(QPixmap.fromImage(self.bgImage.scaled(self.size())))

        if self.selectedPage:
            self.showPage()

    def keyPressEvent(self, event):
        key = event.nativeVirtualKey()
        if key == 65362:
            self.onKeyUp()
        elif key == 65364:
            self.onKeyDown()
        elif key == 65361:
            self.onKeyLeft()
        elif key == 65363:
            self.onKeyRight()
        elif key == 32:    # SPACE
            self.onKeyMenu()
        elif key == 65293: # ENTER
            self.onKeyOk()
        elif key == 65479: # F10
            self.timer.stop()
            QApplication.closeAllWindows()
            self.conn.close()
        else:
            print(key)

    def showEvent(self, event):
        pass

    def showPage(self):
        if self.selectedPage:
            self.selectedPage.off()
        page = self.pages[self.mainMenu.selIndex()]
        page.resize(self.size())
        page.redraw()
        self.selectedPage = page
        self.selectedPage.on()

    # ---------------------------------------------------------------------
    #   Кнопки управления
    # ---------------------------------------------------------------------
    
    def onKeyMenu(self):
        if self.mainMenu.isExpanded:
            self.mainMenu.collapse()
        else:
            self.mainMenu.expand()

    def onKeyOk(self):
        if self.mainMenu.isExpanded:
            self.mainMenu.collapse()

    def onKeyUp(self):
        if self.mainMenu.isExpanded:
            pass
        else:
            if self.selectedPage:
                self.selectedPage.selectedIndex(self.selectedPage.selectedIndex() - 1)

    def onKeyDown(self):
        if self.mainMenu.isExpanded:
            pass
        else:
            if self.selectedPage:
                self.selectedPage.selectedIndex(self.selectedPage.selectedIndex() + 1)

    def onKeyLeft(self):
        if self.mainMenu.isExpanded:
            self.mainMenu.selIndex(self.mainMenu.selIndex() - 1)
            self.showPage()
        else:
            if type(self.selectedPage) == VarList:
                var = self.selectedPage.selectedRow()
                if var.typ == 4:
                    v = var.link_value
                    var_id = var.link_id
                else:
                    v = var.value
                    var_id = var.id
                prev_v = v
                if v != None:
                    v -= 1
                    
                    if var.typ == 1 or var.typ == 3: # Свет/Розетки
                        if v < 0:
                            v = 0
                    elif var.typ == 4: # Термостаты 5
                        if v < 10:
                            v = 10
                    elif var.typ == 7: # Вентиляция
                        if v < 0:
                            v = 0
                    else:
                        v = None
                    if v != None and var_id > 0 and v != prev_v:
                        self._setVar(var_id, v)
            elif type(self.selectedPage) == MediaList:
                self.selectedPage.selectedPanel(self.selectedPage.selectedPanel() - 1)

    def onKeyRight(self):
        if self.mainMenu.isExpanded:
            self.mainMenu.selIndex(self.mainMenu.selIndex() + 1)
            self.showPage()
        else:
            if type(self.selectedPage) == VarList:
                var = self.selectedPage.selectedRow()
                if var.typ == 4:
                    v = var.link_value
                    var_id = var.link_id
                else:
                    v = var.value
                    var_id = var.id
                prev_v = v
                if v != None:
                    v += 1
                
                    if var.typ == 1 or var.typ == 3: # Свет/Розетки
                        if v > 1:
                            v = 1
                    elif var.typ == 4: # Термостаты 5
                        if v > 30:
                            v = 30
                    elif var.typ == 7: # Вентиляция
                        if v > 10:
                            v = 10
                    else:
                        v = None
                    if v != None and var_id > 0 and v != prev_v:
                        self._setVar(var_id, v)
            elif type(self.selectedPage) == MediaList:
                self.selectedPage.selectedPanel(self.selectedPage.selectedPanel() + 1)

    def onKeyVolumeUp(self):
        pass

    def onKeyVolumeDown(self):
        pass

    # ---------------------------------------------------------------------

    def _setVar(self, id, val):
        res = self.conn.query("setvar", "".join([str(id), chr(1), str(val)]))
        self._syncHandler(res)

    def _syncHandler(self, res=None):
        if res == None:
            res = self.conn.query("sync")
        for row in res:
            try:
                for var in self.varList:
                    if int(row[1]) == var.id:
                        var.value = float(row[2])
                    elif int(row[1]) == var.link_id:
                        var.link_value = float(row[2])
            except:
                print("ERR: ", res)
                    
        if len(res) > 0:
            self.selectedPage.redraw()

    def _startLoad(self):
        self.varGroups = self.conn.query("load variable group")
        tmp = self.conn.query("load variables", str(self.conn.app_id))
        self.varList = [None] * len(tmp)
        for i in range(len(tmp)):
            self.varList[i] = VarItem(tmp[i])
        self._groupingVars()
        self._splitVarData(self.page_var_1, [1, 3])
        self._splitVarData(self.page_var_2, [4, 5, 10])
        self._splitVarData(self.page_var_3, [7, 11, 13])
        self.mediaExts = self.conn.query("get media exts")[0][0]
        self.mediaFolders = self.conn.query("get media folders")
        
        tmp = self.conn.query("get groups list")
        self.mediaGroupList = [None] * len(tmp)
        for i in range(len(tmp)):
            self.mediaGroupList[i] = ItemList(tmp[i], 2)
        self.page_media.setGroupData(self.mediaGroupList)

        tmp = self.conn.query("get media list")
        self.mediaTrackList = [None] * len(tmp)
        for i in range(len(tmp)):
            self.mediaTrackList[i] = (int(tmp[i][0]), tmp[i][2])
        self.page_media.setTrackData(self.mediaTrackList)

        #self.page_media.setTrackData([])
            
        self.eventTimer.start(500)

    def _varIndexAtLabel(self, notId, typ, label):
        for i in range(len(self.varList)):
            var = self.varList[i]
            if notId != var.id and var.typ == typ and var.LABEL == label:
                return i
        return -1

    def _getParentGroupID(self, id):
        for g in self.varGroups:
            if g[0] == str(id):
                try:
                    return int(g[2])
                except:
                    return -1
        return -1

    def _getGroupNAME(self, id):
        for g in self.varGroups:
            if g[0] == str(id):
                return g[1]
        return ''

    def _groupingVars(self):
        # Соединяем термометры с термостатами
        while True:
            is_ok = True
            for i in range(len(self.varList) - 2, -1, -1):
                var = self.varList[i]
                if var.typ == 4:
                    ind = self._varIndexAtLabel(var.id, 5, var.LABEL)
                    if ind > 0:
                        var.link_id = self.varList[ind].id
                        var.link_value = self.varList[ind].value
                        del self.varList[ind]
                        is_ok = False
                        break
            if is_ok:
                break

        # Подправляем группы
        for var in self.varList:
            var.group = self._getParentGroupID(var.group)

        # Сортируем по группам
        is_ok = False
        while not is_ok:
            is_ok = True
            for i in range(len(self.varList) - 1):
                var1 = self.varList[i]
                var2 = self.varList[i + 1]
                if var1.group > var2.group:
                    self.varList[i] = var2
                    self.varList[i + 1] = var1
                    is_ok = False

        prev_g = -1000
        tmp = []
        for i in range(len(self.varList)):
            var = self.varList[i]
            if var.group != prev_g:
                s = self._getGroupNAME(var.group)
                if s != "":
                    var1 = VarItem()
                    var1.comm = s
                    var1.typ = -100
                    tmp += [var1]
            tmp += [var]
            prev_g = var.group
        self.varList = tmp

    def _splitVarData(self, sl, keys):
        keys += [-100]
        tmp = []
        for var in self.varList:
            try:
                keys.index(var.typ)
                tmp += [var]
            except:
                pass
        sl.setData(tmp)

    
if __name__ == '__main__':
    app = QApplication(sys.argv)
    mainForm = Main()
    sys.exit(app.exec_())
