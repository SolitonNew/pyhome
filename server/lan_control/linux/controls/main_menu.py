from PyQt5.QtWidgets import QWidget, QHBoxLayout, QPushButton
from PyQt5.QtGui import (QPicture, QColor, QFont)

class MainMenu(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.buttons = []
        self.group = QHBoxLayout(self)
        self.setLayout(self.group)
        
        self.addItem("Свет")
        self.addItem("Розетки")
        self.addItem("Температура")
        self.addItem("Термостаты")
        self.addItem("Вентиляция")
        self.addItem("Медия")

    def addItem(self, title):
        btn = QPushButton(title)
        f = QFont()
        f.setPixelSize(30)
        btn.setFont(f)
        btn.setMinimumSize(100, 100)
        self.group.addWidget(btn)
        self.buttons += [btn]

    def resizeEvent(self, event):
        w1 = self.parentWidget().width()
        w2 = self.width()
        self.move((w1 - w2) / 2, 0)
