from PyQt5.QtWidgets import QWidget, QLabel, QFrame
from PyQt5.QtGui import (QPixmap, QPainter, QImage, QFontMetrics, QColor,
                         QPen, QBrush, QLinearGradient)
from PyQt5.QtCore import Qt, QTimer

from vlc import EventType

class MediaPlayer(QWidget):
    def __init__(self, parent, inst):
        super().__init__(parent)
        self.inst = inst

        self.currTime = 0
        self.currLen = 0
        self.currVol = 50
        
        self.player = inst.media_player_new()
        self.events = self.player.event_manager()
        self.events.event_attach(EventType.MediaPlayerEndReached, self.playEndHandler)
        self.events.event_attach(EventType.MediaPlayerTimeChanged, self.playTimeHandler)
        self.events.event_attach(EventType.MediaPlayerLengthChanged, self.playLengthHandler)
        self.events.event_attach(EventType.MediaPlayerAudioVolume, self.playVolumeHandler)

    def playEndHandler(self, event):
        self.parentWidget().mainMenu.repaint()

    def playTimeHandler(self, event):
        pos = self.position()
        if pos != self.currTime:
            self.currTime = pos
            self.parentWidget().mainMenu.playerPosPanel.update()

    def playLengthHandler(self, event):
        l = self.length()
        if l != self.currLen:
            self.currLen = l

    def playVolumeHandler(self, event):
        pass

    def showEvent(self, event):
        inst = self.inst
        self.player.set_xwindow(self.winId())

    def hideEvent(self, event):
        self.player.stop()

    def play(self, url):
        self.stop()
        self.player.set_media(self.inst.media_new(url))
        self.player.play()
        self.volume(self.volume())

    def stop(self):
        self.player.stop()

    def pause(self):
        self.player.pause()

    def volume(self, value=None):
        if value == None:
            if self.currVol == None:
                self.currVol = self.player.audio_get_volume()
            return self.currVol

        self.currVol = value
        self.player.audio_set_volume(value)

    def mute(self):
        self.player.audio_toggle_mute()

    def isPlaying(self):
        return self.player.is_playing()

    def playState(self):
        return self.player.get_state()

    def getMediaRange(self):
        return [self.position(), self.length()]

    def length(self):
        try:
            return self.player.get_length() // 1000
        except:
            return 0

    def position(self, pos=None):
        if pos == None:
            return self.player.get_time() // 1000        
        self.player.set_time(pos * 1000)
