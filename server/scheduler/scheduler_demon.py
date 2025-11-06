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
        self.db.IUD("update core_scheduler set ACTION_DATETIME = NULL")
        self.db.commit()
        
        print("-- Futured Tasks --")
        for row in self.db.select("select ID, COMM, ACTION, ACTION_DATETIME, INTERVAL_TIME_OF_DAY, INTERVAL_DAY_OF_TYPE, INTERVAL_TYPE, ENABLE from core_scheduler"):
            next_time = self.parse_time(None, str(row[4], "utf-8"), str(row[5], "utf-8"), row[6])
            enable = ""
            if row[7] == 0:
                enable = "      [DO NOT EXECUTE!!!]"
            print("[%s] %s %s" % (datetime.datetime.fromtimestamp(next_time), str(row[1], "utf-8"), enable))
        print("------------------------")
        self.check_time()
        self.run()

    def check_time(self):
        now = datetime.datetime.now().timestamp()
        for row in self.db.select("select ID, COMM, ACTION, ACTION_DATETIME, INTERVAL_TIME_OF_DAY, INTERVAL_DAY_OF_TYPE, INTERVAL_TYPE, ENABLE from core_scheduler"):
            next_time = None
            if row[3] == None: # This is a reset date - it will be recalculated to a blank date relative to the current one.
                next_time = self.parse_time(None, str(row[4], "utf-8"), str(row[5], "utf-8"), row[6])
            elif row[3].timestamp() <= now: # This is the date that has arrived for completion. We complete it and reread it.
                next_time = self.parse_time(row[3].timestamp(), str(row[4], "utf-8"), str(row[5], "utf-8"), row[6])
                if row[7]: # Check for Execute/Not Execute
                    self.execute(str(row[1], "utf-8"), str(row[2], "utf-8"))
                if row[6] == 4: # The one-time task has been completed. Let's delete its entry.
                    self.db.IUD("delete from core_scheduler where ID = %s" % (row[0]))
                    self.db.commit()
            if next_time != None:
                #self.db.IUD("update core_scheduler set ACTION_DATETIME = FROM_UNIXTIME(%s) where ID = %s" % (next_time, row[0]))
                d_s = datetime.datetime.fromtimestamp(next_time).strftime("%Y-%m-%d %H:%M:%S")
                self.db.IUD("update core_scheduler set ACTION_DATETIME = '%s' where ID = %s" % (d_s, row[0]))
                self.db.commit()

    def calc_suntime(self, d, sun_type):
        st = GetSunTime(d // (24 * 3600), 49.697287, 34.354388, 90.8333333333333, (-time.altzone // 3600) - 1, sun_type)
        hour = math.trunc(st)
        minutes = round((st - hour) * 60)
        return (hour * 60 + minutes) * 60

    def parese_sun_delta(self, comm):
        """
        SUNRISE - 1
        SUNRISE - 1:03
        SUNRISE - 1:03:02
        """
        s = comm
        s = s.replace("SUNSET", "")
        s = s.replace("SUNRISE", "")
        s = s.replace(" ", "")
        try:        
            is_minus = s[0] == "-"
        except:
            is_minus = False
        s = s.replace("-", "")
        a = s.split(":")
        h, m, s = 0, 0, 0
        try:
            if len(a) > 0:
                h = int(a[0])
            if len(a) > 1:
                m = int(a[1])
            if len(a) > 2:
                s = int(a[2])
        except:
            pass

        res = h * 3600 + m * 60 + s
        if is_minus:
            res = -res
        return res

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
            """
            This is a special case of wandering time. 
            Date/time assembly is performed separately here, 
            and the code will not proceed further.
            """

            sun_delta = self.parese_sun_delta(time_of_day.upper())
            
            d1 = now.timestamp()
            d2 = now.timestamp() + 24 * 3600
            dt = [d1 + self.calc_suntime(d1, time_type) + sun_delta,
                  d2 + self.calc_suntime(d2, time_type) + sun_delta]

            dt.sort()

            # We check which date from the schedule is ready for execution.
            for d in dt:
                if d > action_datetime:
                    return d
            return None
        else:
            # We get a list of times in seconds
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
            # Today's date and tomorrow's
            dates += [now.timestamp(), now.timestamp() + 24 * 3600]
        elif int_type == 1:
            # We get the date of Monday of this week in seconds
            dw = now.timestamp() - now.weekday() * 24 * 3600
            # We get the date of Monday of the next week in seconds
            dw_next = dw + 7 * 24 * 3600
            w = ["пн", "вт", "ср", "чт", "пт", "сб", "вс"]
            for d in day_of_type.split(","):
                s = w.index(d.strip().lower())
                dates += [dw + (s * 24 * 3600)]
                dates += [dw_next + (s * 24 * 3600)]
        elif int_type == 2:
            # We get the 1st day of this month in seconds
            m = datetime.datetime(now.year, now.month, 1).timestamp()
            # We get the 1st day of the next month in seconds
            if now.month < 12:
                m_next = datetime.datetime(now.year, now.month, 1).timestamp()
            else:
                m_next = datetime.datetime(now.year + 1, 1, 1).timestamp()
            
            for d in day_of_type.split(","):
                s = int(d.strip())
                dates += [m + (s * 24 * 3600)]
                dates += [m_next + (s * 24 * 3600)]
                
        elif int_type == 3 or int_type == 4: # Annually or Just once
            for d in day_of_type.split(","):
                m = d.split("-")
                s = datetime.datetime(now.year, int(m[1].strip()), int(m[0].strip())).timestamp()
                dates += [s]
                s_next = datetime.datetime(now.year + 1, int(m[1].strip()), int(m[0].strip())).timestamp()
                dates += [s_next]

        dt = []

        # We collect the date and time of the schedule into one
        for tim in times:
            if len(dates) > 0:
                for dat in dates:
                    dt += [dat + tim]
                
        dt.sort()

        # We check which date from the schedule is ready for execution.
        for d in dt:
            if d > action_datetime:
                return d
                
        return None

    def execute(self, comm, action):
        self.db.IUD("insert into core_execute (COMMAND) values ('%s')" % (action))
        self.db.commit()
        print("[%s] An event has occurred \"%s\"" % (time.strftime("%d-%m-%Y %H:%M"), comm))
        print("                   and requested command %s" % (action))

    def run(self):
        while True:
            self.check_time()
            time.sleep(1)

print(
"=============================================================================\n"
"                           Schedule Module v0.1\n"
"\n"
"=============================================================================\n"
)

if __name__ == "__main__":    
    Main()
