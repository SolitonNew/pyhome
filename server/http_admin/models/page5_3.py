from base_form import BaseForm

from widgets import TextField
from widgets import Grid
from datetime import datetime

class Page5_3(BaseForm):
    ACTION = "page5_3"
    VIEW = "page5_3.tpl"

    def create_widgets(self):
        gr = Grid("POWER_TABLE", "ID", "select ID, CHANGE_DATE, YEAR, MONTH, LIGHT_TIME, LIGHT_POWER from web_stat_power ")
        gr.add_column("Дата расчета", "CHANGE_DATE", 130, sort="asc")
        gr.add_column("Месяц", "YEAR", 90, func=self._monthFunc)
        gr.add_column("Длительность освещения (ч)", "LIGHT_TIME", 90)
        gr.add_column("Потребление освещением (кВт/ч)", "LIGHT_POWER", 90)
        self.add_widget(gr)

    def query(self, query_type):
        if query_type == "recalc_stat":
            self.recalc_stat()
            return "OK"

    def _monthFunc(self, index, row):
        y, m = str(row[2]), str(row[3])
        if len(m) == 1:
            m = "0" + m
        return "%s/%s" % (y, m)

    def calc_month_interval(self, year, month):
        time_from = datetime(year, month, 1, 5, 0, 0).timestamp()
        if month == 12:
            year += 1
            month = 0
        time_to = datetime(year, month + 1, 1, 5, 0, 0).timestamp()
        return [time_from, time_to]

    def recalc_stat(self):
        calcs = self.db.select("select CHANGE_DATE, YEAR, MONTH from web_stat_power")
        
        min_time = datetime.now()
        max_time = datetime.now()
        
        for rec in self.db.select("select MIN(CHANGE_DATE), MAX(CHANGE_DATE) "
                                  "  from core_variable_changes "):
            min_time = rec[0]
            max_time = rec[1]
            
        year_from = min_time.year
        year_to   = max_time.year
        
        res = []

        for y in range(year_from, year_to + 1):
            for i in range(12):
                b = True
                for c in calcs:
                    if c[1] == y and c[2] == (i+1):
                        mi = self.calc_month_interval(c[1], c[2])
                        try:
                            ts = c[0].timestamp()
                            if ts > mi[1]:
                                b = False
                                break
                        except Exception as e:
                            print(e)
                if b:
                    self.db.IUD("delete from web_stat_power "
                                " where YEAR=%s and MONTH=%s" % (y, i + 1))
                    stat = self._calcStat(y, i + 1)
                    if stat != None:
                        print("OK")
                        self.db.IUD("insert into web_stat_power "
                                    "   (YEAR, MONTH, LIGHT_TIME, LIGHT_POWER) "
                                    " values "
                                    "   (%s, %s, %s, %s)" % (y, i+1, stat[0], stat[1]))
                    self.db.commit()
                else:
                    print("CANCEL")

    def _calcStat(self, year, month, var_id=None):
        time_from, time_to = self.calc_month_interval(year, month)
        power_high = [29, 30] # Двойные лампочки
        prev_var_id = None
        prev_var_value = None
        prev_var_time = None
        all_power = 0
        all_time = 0

        prev_rec = None

        var_sql = ''
        if var_id != None:
            var_sql = "   and v.ID = %s " % (var_id)
    
        for rec in self.db.select("select c.VARIABLE_ID, UNIX_TIMESTAMP(c.CHANGE_DATE), c.VALUE, c.CHANGE_DATE "
                                  "  from core_variable_changes c, core_variables v "
                                  " where UNIX_TIMESTAMP(c.CHANGE_DATE) >= %s "
                                  "   and UNIX_TIMESTAMP(c.CHANGE_DATE) <= %s "
                                  "   and v.ID = c.VARIABLE_ID "
                                  "   and v.APP_CONTROL = 1 "
                                  "   %s "
                                  "order by c.VARIABLE_ID, c.ID" % (time_from, time_to, var_sql)):

            if prev_rec == None:
                prev_rec = rec

            if prev_var_id == None:
                prev_var_id = rec[0]
            else:
                if prev_var_id != rec[0]:
                    prev_var_time = None
                    prev_var_value = None
                    prev_rec = None
            prev_var_id = rec[0]

            if prev_var_time == None:
                prev_var_time = rec[1]
            
            if prev_var_value == None:
                prev_var_value = rec[2]

            if prev_var_value != rec[2]:
                if rec[2] > 0: # Включили лампочку
                    prev_var_time = rec[1]
                else: # Лампочку выключили и щитаем сколько горела
                    dt = rec[1] - prev_var_time
                    all_time += dt
                    # Определяем мощьность лампочки по ID
                    pw = 13
                    try:
                        power_high.index(rec[0])
                        pw = 28
                    except:
                        pass
                    all_power += pw * (dt / 3600)

            prev_var_value = rec[2]
            prev_rec = rec

        if month == 0:
            month = 12
        if all_time > 0:
            return [round(all_time / 3600, 1), round(all_power / 1000, 3)]
        else:
            return None
