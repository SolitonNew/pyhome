#!/usr/bin/python3
#-*- coding: utf-8 -*-

import time
from db_connector import DBConnector
import subprocess

print(
"=============================================================================\n"
"         МОДУЛЬ СЕРВЕРНОГО ОЗВУЧИВАНИЯ ЗВУКОВОГО ОПОВЕЩЕНИЯ v0.1\n"
"\n"
"=============================================================================\n"
)

db = DBConnector()
lastSpeechId = -1
for rec in db.select("select MAX(ID) from app_control_speech"):
    lastSpeechId = rec[0]
if lastSpeechId == None:
    lastSpeechId = -1

while True:
    for rec in db.select("select ID, SPEECH_AUDIO_ID, SPEECH_TYPE from app_control_speech "
                         " where ID > %s "
                         "order by ID" % (lastSpeechId)):
        lastSpeechId = rec[0]
        try:
            print("Звучит: %s" % (rec[1]))
            subprocess.call("aplay /home/pyhome/server/executor/%s.wav" % (str(rec[2], "utf-8")), shell=True)
            f_name = "/var/tmp/wisehouse/audio_%s.wav" % (rec[1])
            subprocess.call("aplay %s" % (f_name), shell=True)
        except Exception as e:
            print(e)
    time.sleep(0.1)
