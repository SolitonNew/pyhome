#!/usr/bin/python3
#-*- coding: utf-8 -*-

from db_connector import DBConnector
import time
import datetime
import subprocess

class Main():
    def __init__(self):
        self.db = DBConnector()                
        self.run()
        
    def run(self):
        while True:
            # -------------------------------------------


            # -------------------------------------------
            if datetime.datetime.now().hour == 4:
                if not clear_db_mem_time_ignore:
                    clear_db_mem_time_ignore = True
                    self.clear_mem_db()
                    self.clear_values()
            else:
                clear_db_mem_time_ignore = False
            # -------------------------------------------
            
            time.sleep(0.2)

    def _clear_mem_db_table(self, table, space=100):
        for rec in self.db.select("select MAX(ID) from %s" % (table)):
            if rec[0]:
                max_id = rec[0] - space
                self.db.IUD("delete from %s where ID < %s" % (table, max_id))
                self.db.commit()
    
    def clear_mem_db(self):
        try:
            self._clear_mem_db_table("app_control_exe_queue")
            self._clear_mem_db_table("app_control_queue")
            self._clear_mem_db_table("app_control_sess")
            self._clear_mem_db_table("core_execute")
            self._clear_mem_db_table("core_variable_changes_mem")
            print("[%s] CLEAR MEM TABLES" % (time.strftime("%d-%m-%Y %H:%M")))
        except Exception as e:
            print(e)

    def clear_values(self):
        try:
            subprocess.call('python3 /var/www/pyhome/server/watcher/clear_values_15.py', shell=True)
        except:
            pass        

print(
"=============================================================================\n"
"                  SYSTEM STATUS MONITORING MODULE v0.1\n"
"\n"
"=============================================================================\n"
)

if __name__ == "__main__":    
    Main()
