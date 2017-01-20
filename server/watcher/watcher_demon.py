#!/usr/bin/python3
#-*- coding: utf-8 -*-

from db_connector import DBConnector
import time

class Main():
    def __init__(self):
        self.db = DBConnector()
        self.termostats = []
        self._add_termostat(50, 49, "В спальне 3") #Спальня №3
        self._add_termostat(60, 59, "В гостинной") #Гостинная
        
        self.run()
        
    def run(self):
        termostats_time_step = 0
        while True:
            relIds = []
            for keys in self.db.select("select CORE_GET_LAST_CHANGE_ID()"):
                if keys[0] - 1 > self.db.lastVarChangeID:
                    # c.ID, c.VARIABLE_ID, c.VALUE, v.APP_CONTROL, v.GROUP_ID
                    for row in self.db.variable_changes():
                        if row[3] == 1: # Слежение за светом
                            relIds += [str(row[1]), ","]
                        elif row[3] == 4: #Термометры
                            for r in self.termostats:
                                if r[2] == row[1]:
                                    r[3] = row[2]
                        elif row[3] == 5: #Термостаты
                            for r in self.termostats:
                                if r[0] == row[1]:
                                    r[1] = row[2]

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

            if termostats_time_step == 0:
                termostats_time_step = round(15 * 60 / 0.2)
                for t in self.termostats:
                    if t[3] > t[1] + 0.2: # Перегрели
                        self._add_command('speech("%s жарко")' % (t[4]))
                    elif t[3] < t[1] - 0.2: # Переостудили
                        self._add_command('speech("%s холодно")' % (t[4]))
            termostats_time_step -= 1
            time.sleep(0.2)

    def _add_termostat(self, tst_id, trm_id, title):
        # Зачитка стартовых значений
        for rec in self.db.select("select VALUE from core_variables where ID = %s" % (tst_id)):
            tst_val = rec[0]
        for rec in self.db.select("select VALUE from core_variables where ID = %s" % (trm_id)):
            trm_val = rec[0]
        # ---------------------------
        self.termostats += [[tst_id, tst_val, trm_id, trm_val, title]]
            
    def _add_command(self, command):
        print("[%s] %s" % (time.strftime("%d-%m-%Y %H:%M"), command))
        """
        for row in self.db.select("select ID from core_execute where COMMAND = '%s'" % command):
            self.db.IUD("delete from core_execute where ID = %s" % row[0])
            self.db.commit()
        """
        if self.get_quiet_time():
            try:
                command.index("speech(")
                command = "speech(\"\")"
            except:
                pass
        self.db.IUD("insert into core_execute (COMMAND) values ('%s')" % command)
        self.db.commit()

    def get_quiet_time(self):
        for rec in self.db.select("select VALUE from core_variables where NAME = 'QUIET_TIME'"):
            if rec[0]:
                return True
        return False


print(
"=============================================================================\n"
"               МОДУЛЬ НАБЛЮДЕНИЯ ЗА СОСТОЯНИЕМ СИСТЕМОЙ v0.1\n"
"\n"
"=============================================================================\n"
)

if __name__ == "__main__":    
    Main()
