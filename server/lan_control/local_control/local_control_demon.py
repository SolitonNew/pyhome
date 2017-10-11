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

def correctVolume():
    global db

    QUIET_TIME = 123
    BOILER_PRESENS = 125
    BOILER_PRESENS_OUT = 127
    
    def check_vol(curr, new):
        if new < curr:
            return new
        else:
            return curr
    
    ids = (QUIET_TIME, BOILER_PRESENS, BOILER_PRESENS_OUT)
    new_volume = 90
    for rec in db.select("select ID from core_variables "
                         " where VALUE > 1 and ID in %s" %(str(ids))):
        if rec[0] == QUIET_TIME:
            new_volume = check_vol(new_volume, 30)
            
        if rec[0] == BOILER_PRESENS:
            new_volume = check_vol(new_volume, 30)
            
        if rec[0] == BOILER_PRESENS_OUT:
            new_volume = check_vol(new_volume, 50)
            
    subprocess.call("amixer set Master %s" % (new_volume), shell=True)

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
                correctVolume()
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
