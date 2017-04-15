from PyQt5.QtWidgets import QWidget, QLabel
from PyQt5.QtGui import QPainter, QPixmap, QColor
from PyQt5.QtCore import Qt

class BaseLayer(QWidget):
    def __init__(self, parent):
        super().__init__(None)
        self.mainForm = parent
        self.query = parent.conn.query        
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.content = QWidget(self)
        self.off()

    def keyPressEvent(self, event):
        self.mainForm.keyPressEvent(event)

    def isOn(self):
        return self.content.isVisible()

    def on(self):
        self.content.setVisible(True)

    def off(self):
        self.content.setVisible(False)

