#!/usr/bin/python3
#-*- coding: utf-8 -*-

from db_connector import DBConnector
from subprocess import Popen, PIPE
import time
import math
import os

class Main():
    ALARM_FILES = []
    ALARM_LOOPS = 5
    
    def __init__(self):
        self.player = False
        self.db = DBConnector()
        self.timer_id = 101
        self.timer_on = 102
        self.timer_len = 0.5
        self.get_start_time()
        self.volume = 0
        self.run()

    def _curr_time(self, curr = True):
        if curr:
            return time.strftime("%d-%m-%Y %H:%M:%S", time.localtime())
        else:
            return time.strftime("%d-%m-%Y %H:%M:%S", time.localtime(self.time_start))

    def get_start_time(self):
        for row in self.db.select("select VALUE from core_variables where ID = %s" % (self.timer_id)):
            lt = time.localtime()
            h = math.floor(row[0])
            m = round((row[0] - h) * 60)
            self.time_start = time.mktime((lt.tm_year, lt.tm_mon, lt.tm_mday, h, m, 0, 0, 0, lt.tm_isdst))
            if time.time() > self.time_start:
                self.time_start += 24 * 3600
            print("Время будильника установлено на: %s" % self._curr_time(False))
            
    def check_time(self):
        if time.time() >= self.time_start:
            self.db.IUD("call CORE_SET_VARIABLE(%s, %s, null)" % (self.timer_on, 1))
            self.db.commit()
            self.get_start_time()
        
    def run(self):        
        while True:
            for row in self.db.variable_changes():
                if row[1] == self.timer_id:
                    try:
                        self.time_start = row[2]
                        self.get_start_time()                        
                    except:
                        pass
                elif row[1] == self.timer_on:
                    if row[2]:
                        print("%s   Начали будить" % self._curr_time())
                        self.start()
                    else:
                        self.user_stop()
                elif row[3] == 2: #Реакция на любой выключатель
                    self.user_stop()

            if self.player:
                self.volume += 1
                if self.volume > 60:
                    self.volume = 60
                self.send_cmd("volume %s 100" % round(40 + self.volume))

            self.check_time()

            time.sleep(1)

    def user_stop(self):
        if self.player:
            print("%s   Проснулись" % self._curr_time())
        self.stop()

    def start(self):
        if self.player:
            return
        self.volume = 0
        self.player = Popen(["mplayer", "-slave", "-quiet", "-loop", str(Main.ALARM_LOOPS), "-volume", "0"] + Main.ALARM_FILES,
                             stdin=PIPE, stdout=PIPE, stderr=PIPE)

    def stop(self):
        self.send_cmd("q")
        self.player = False

    def send_cmd(self, cmd):
        if self.player:
            try:
                self.player.stdin.write((cmd + "\n").encode("utf-8"))
                self.player.stdin.flush()
            except:
                self.player = False
                print("%s   Не разбудили" % self._curr_time())

p = "/home/pyhome/server/player/tracks/"
for f in os.listdir(p):
    Main.ALARM_FILES += [p + f]

print(
"=============================================================================\n"
"                     МОДУЛЬ ЗВУКОВОЙ ИНДИКАЦИИ v0.1\n"
"\n"
" Рингтоны: %s \n"
" Повторять раз: %s \n"
"=============================================================================\n"
% (Main.ALARM_FILES, Main.ALARM_LOOPS)
)

if __name__ == "__main__":    
    Main()
