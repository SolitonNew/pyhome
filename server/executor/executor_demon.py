#!/usr/bin/python3
#-*- coding: utf-8 -*-

import mysql.connector
from db_connector import DBConnector
import time
from play import Play
from variable import Variable
from speech import Speech
from info import Info

class Main():
    def __init__(self):
        self.commans = (Play(), Variable(), Speech(), Info())
        self.db = DBConnector()
        # Очищаем список команд. Список не актуален.        
        self.db.IUD("delete from core_execute")
        self.db.commit()
        self.run()
        
    def run(self):        
        while True:
            try:
                for row in self.db.select("select * from core_execute order by ID"):
                    self.execute(str(row[1], "utf-8"))
                    self.db.IUD("delete from core_execute where ID = %s" % row[0])
                    self.db.commit()
                time.sleep(1)

                # Дергаем секундный таймер, может кому пригодится
                for cmd in self.commans:
                    cmd.time_handler()  
            except mysql.connector.Error as e:
                self.execute('speech("пропала связь с базой")')
                time.sleep(10)
            
    def execute(self, command):
        print("[%s] выполняется %s" % (time.strftime("%d-%m-%Y %H:%M"), command))
        for cmd in self.commans:
            if cmd.check_comm(self.db, command):
                break

print(
"=============================================================================\n"
"                      МОДУЛЬ КОМАНДНОГО ПРОЦЕССОРА v0.1\n"
"\n"
"=============================================================================\n"
)

if __name__ == "__main__":    
    Main()
