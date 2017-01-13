#!/usr/bin/python3
#-*- coding: utf-8 -*-

import sys
from PyQt5.QtWidgets import (QApplication, QWidget, QHBoxLayout, QVBoxLayout,
                             QListWidget, QListWidgetItem)
from PyQt5.QtGui import (QPicture, QColor, QFont)
from PyQt5.QtCore import Qt, QRect, QSize
from controls.main_menu import MainMenu

class Main(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('lan control v1.0')
        self._createUI()
        self.showFullScreen()

    def _createUI(self):
        self.mainList = QListWidget(self)
        self.mainMenu = MainMenu(self)
        self._rebuildMainList()

    def _rebuildMainList(self):
        ls = self.mainList
        ls.clear()        
        for k in range(100):
            item = QListWidgetItem("Item %s" % (k), ls)
            f = QFont()
            f.setPixelSize(40)
            item.setFont(f)
            #ls.addItem()

    def resizeEvent(self, event):
        self.mainMenu.resizeEvent(event)
        self.mainList.resize(self.width(), self.height())

    def _mainMenuChange(self, index):
        pass

if __name__ == '__main__':
    app = QApplication(sys.argv)
    form = Main()
    sys.exit(app.exec_())
