from base_form import BaseForm

from widgets import TextField
from datetime import datetime

class Page5_3(BaseForm):
    ACTION = "page5_3"
    VIEW = "page5_3.tpl"

    def create_widgets(self):
        pass

    def query(self, query_type):
        if query_type == "refresh":
            return self._get_content()

    def _get_content(self):
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
                stat = self._calcStat(y, i + 1)
                if stat != None:
                    if i == 0:
                        res += ["<hr>"]
                    res += ["<p>"]
                    res += ["<div><b>%s/%s</b></div>" % (y, i + 1)]
                    res += ["<div style='padding-left:40px;'>Длительность освещения (ч): <b>%s</b></div>" % (stat[0])]
                    res += ["<div style='padding-left:40px;'>Потребленная мощьность (кВт/ч): <b>%s</b></div>" % (stat[1])]
                    res += ["</p>"]

        return "".join(res)

    def _calcStat(self, year, month, var_id=None):
        time_from = datetime(year, month, 1, 5).timestamp()
        if month == 12:
            year += 1
            month = 0
        time_to = datetime(year, month + 1, 1, 5).timestamp()
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
                                  "order by 1, 2" % (time_from, time_to, var_sql)):

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
