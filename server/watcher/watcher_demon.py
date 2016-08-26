#!/usr/bin/python3
#-*- coding: utf-8 -*-

from db_connector import DBConnector
import time

class Main():
    def __init__(self):
        self.db = DBConnector()
        self.run()
        
    def run(self):
        while True:
            relIds = []
            for keys in self.db.select("select CORE_GET_LAST_CHANGE_ID()"):
                if keys[0] - 1 > self.db.lastVarChangeID:
                    # c.ID, c.VARIABLE_ID, c.VALUE, v.APP_CONTROL, v.GROUP_ID
                    for row in self.db.variable_changes():
                        if row[3] == 1: # Слежение за светом
                            relIds += [str(row[1]), ","]

                    if len(relIds) > 0:
                        for row in self.db.select("select v.APP_CONTROL, c.NAME, p.NAME, v.VALUE "
                                                  "  from core_variables v, core_variable_controls c, plan_parts p "
                                                  " where v.ID in (%s) "
                                                  "   and v.APP_CONTROL = c.ID "
                                                  "   and v.GROUP_ID = p.ID "
                                                  " order by v.ID" % ("".join(relIds[:-1]),)):
                            s = [str(row[2], "utf-8"), ". ", str(row[1], "utf-8"), " "]
                            if row[3]:
                                s += ["включен"]
                            else:
                                s += ["выключен"]
                                
                            self._add_command('speech("%s")' % "".join(s).lower())
            time.sleep(1)
            
    def _add_command(self, command):
        print(command)
        for row in self.db.select("select ID from core_execute where COMMAND = '%s'" % command):
            self.db.IUD("delete from core_execute where ID = %s" % row[0])
            self.db.commit()
        
        self.db.IUD("insert into core_execute (COMMAND) values ('%s')" % command)
        self.db.commit()

print(
"=============================================================================\n"
"               МОДУЛЬ НАБЛЮДЕНИЯ ЗА СОСТОЯНИЕМ СИСТЕМОЙ v0.1\n"
"\n"
"=============================================================================\n"
)

if __name__ == "__main__":    
    Main()
