#!/usr/bin/python3
#-*- coding: utf-8 -*-

from db_connector import DBConnector
from subprocess import Popen, PIPE
import time
import datetime
import math
import os
from solar_time import GetSunTime

class Main():
    def __init__(self):
        self.db = DBConnector()
        print("-- Предстоящие задачи --")
        for row in self.db.select("select ID, COMM, ACTION, ACTION_DATETIME, INTERVAL_TIME_OF_DAY, INTERVAL_DAY_OF_TYPE, INTERVAL_TYPE from core_scheduler"):
            next_time = self.parse_time(None, str(row[4], "utf-8"), str(row[5], "utf-8"), row[6])
            print("[%s] %s" % (datetime.datetime.fromtimestamp(next_time), str(row[1], "utf-8")))
        print("------------------------")
        
        self.check_time()
        self.run()

    def check_time(self):
        now = datetime.datetime.now().timestamp()
        for row in self.db.select("select ID, COMM, ACTION, ACTION_DATETIME, INTERVAL_TIME_OF_DAY, INTERVAL_DAY_OF_TYPE, INTERVAL_TYPE from core_scheduler"):
            next_time = None
            if row[3] == None: # Это обнуленная дата - будет перещитана в холостую относительно текущей
                next_time = self.parse_time(None, str(row[4], "utf-8"), str(row[5], "utf-8"), row[6])
            elif row[3].timestamp() <= now: # Это дата, что пришла для выполнения. Выполняем и перещитываем.
                next_time = self.parse_time(row[3].timestamp(), str(row[4], "utf-8"), str(row[5], "utf-8"), row[6])
                self.execute(str(row[1], "utf-8"), str(row[2], "utf-8"))

            if next_time != None:
                self.db.IUD("update core_scheduler set ACTION_DATETIME = FROM_UNIXTIME(%s) where ID = %s" % (next_time, row[0]))
                self.db.commit()

    def parse_time(self, action_datetime, time_of_day, day_of_type, int_type):
        if action_datetime == None:
            action_datetime = datetime.datetime.now().timestamp();
        
        now = datetime.datetime.now()
        now = datetime.datetime(now.year, now.month, now.day)
        
        times = []
        dates = []

        time_type = ""
        try:
            time_of_day.upper().index("SUNRISE")
            time_type = "Sunrise"
        except:
            pass

        try:
            time_of_day.upper().index("SUNSET")
            time_type = "Sunset"
        except:
            pass

        if time_type == "Sunrise" or time_type == "Sunset":
            st = GetSunTime(now.timestamp() // (24 * 3600), 49.697287, 34.354388, 90.8333333333333, 3, time_type)
            hour = math.trunc(st)
            minutes = round((st - hour) * 60)
            times += [(hour * 60 + minutes) * 60]
        else:
            # Получаем список времени в секундах
            for t in time_of_day.split(","):
                m = t.split(":")
                hour = int(m[0].strip()) * 60
                minutes = 0
                try:
                    minutes = int(m[1].strip())
                except:
                    pass
                sec = 0
                try:
                    sec = int(m[2].strip())
                except:
                    pass
                s = hour + minutes
                times += [s * 60 + sec]

        if int_type == 0:
            # Сегодняшняя дата и завтрашняя
            dates += [now.timestamp(), now.timestamp() + 24 * 3600]
        elif int_type == 1:
            # Получаем дату понедельника этой недели в секундах
            dw = now.timestamp() - now.weekday() * 24 * 3600
            # Получаем дату понедельника следующей недели в секундах
            dw_next = dw + 7 * 24 * 3600
            w = ["пн", "вт", "ср", "чт", "пт", "сб", "вс"]
            for d in day_of_type.split(","):
                s = w.index(d.strip().lower())
                dates += [dw + (s * 24 * 3600)]
                dates += [dw_next + (s * 24 * 3600)]
                
        elif int_type == 2:
            # Получаем 1 число этого месяца в секундах
            m = datetime.datetime(now.year, now.month, 1).timestamp()
            # Получаем 1 число следующего месяца в секундах
            if now.month < 12:
                m_next = datetime.datetime(now.year, now.month, 1).timestamp()
            else:
                m_next = datetime.datetime(now.year + 1, 1, 1).timestamp()
            
            for d in day_of_type.split(","):
                s = int(d.strip())
                dates += [m + (s * 24 * 3600)]
                dates += [m_next + (s * 24 * 3600)]
                
        elif int_type == 3:            
            for d in day_of_type.split(","):
                m = d.split("-")
                s = datetime.datetime(now.year, int(m[1].strip()), int(m[0].strip())).timestamp()
                dates += [s]
                s_next = datetime.datetime(now.year + 1, int(m[1].strip()), int(m[0].strip())).timestamp()
                dates += [s_next]

        dt = []

        # Собираем дату и время расписания в одно
        for tim in times:
            if len(dates) > 0:
                for dat in dates:
                    dt += [dat + tim]
                
        dt.sort()

        # Проверяем какая дата из расписания готова к выполнению
        for d in dt:
            if d > action_datetime:
                return d
                
        return None

    def execute(self, comm, action):
        self.db.IUD("insert into core_execute (COMMAND) values ('%s')" % action)
        self.db.commit()

        print("[%s] Произошло событие \"%s\"" % (time.strftime("%d-%m-%Y %H:%M"), comm))
        print("                   и запрошена команда %s" % (action))

    def run(self):
        while True:
            self.check_time()
            time.sleep(1)

print(
"=============================================================================\n"
"                         МОДУЛЬ РАСПИСАНИЯ v0.1\n"
"\n"
"=============================================================================\n"
)

if __name__ == "__main__":    
    Main()
