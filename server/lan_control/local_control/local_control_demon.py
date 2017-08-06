#!/usr/bin/python3
#-*- coding: utf-8 -*-

import time
from db_connector import DBConnector
from datetime import datetime
import subprocess

print(
"=============================================================================\n"
"         МОДУЛЬ СЕРВЕРНОГО ОЗВУЧИВАНИЯ ЗВУКОВОГО ОПОВЕЩЕНИЯ v0.1\n"
"\n"
"=============================================================================\n"
)

db = DBConnector()
lastSpeechId = -1
for rec in db.select("select MAX(ID) from app_control_exe_queue"):
    lastSpeechId = rec[0]
if lastSpeechId == None:
    lastSpeechId = -1

beep_time = datetime.now().timestamp()
while True:
    for rec in db.select("select ID, EXE_TYPE, SPEECH_AUDIO_ID, SPEECH_TYPE "
                         "  from app_control_exe_queue "
                         " where ID > %s "
                         "order by ID" % (lastSpeechId)):
        lastSpeechId = rec[0]
        if str(rec[1], "utf-8") == "speech":
            try:                
                print("Звучит: %s" % (rec[2]))
                now = datetime.now().timestamp()
                if now - beep_time > 5:
                    subprocess.call("aplay /home/pyhome/server/executor/%s.wav" % (str(rec[3], "utf-8")), shell=True)
                f_name = "/var/tmp/wisehouse/audio_%s.wav" % (rec[2])
                subprocess.call("aplay %s" % (f_name), shell=True)
                beep_time = datetime.now().timestamp()
            except Exception as e:
                print(e)
    time.sleep(0.2)