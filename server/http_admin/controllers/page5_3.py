from base_form import BaseForm

from widgets import TextField
from widgets import Grid
from datetime import datetime

class Page5_3(BaseForm):
    ACTION = "page5_3"
    VIEW = "page5_3.tpl"

    def create_widgets(self):
        sql = ("select ID, CHANGE_DATE, YEAR, MONTH, LIGHT_TIME, LIGHT_POWER, "
               "       CIRC_PUMP_TIME, CIRC_PUMP_POWER, BOILER_TIME, BOILER_POWER "
               "  from web_stat_power ")
        gr = Grid("POWER_TABLE", "ID", sql)
        gr.add_column("Дата расчета", "CHANGE_DATE", 130, sort="asc")
        gr.add_column("Месяц", "YEAR", 90, func=self._monthFunc)
        gr.add_column("Длительность освещения (ч)", "LIGHT_TIME", 90)
        gr.add_column("Потребление освещением (кВт/ч)", "LIGHT_POWER", 90)
        gr.add_column("Длительность работы насосов (ч)", "CIRC_PUMP_TIME", 90)
        gr.add_column("Потребление насосами (кВт/ч)", "CIRC_PUMP_POWER", 90)
        gr.add_column("Длительность работы бойлера (ч)", "BOILER_TIME", 90)
        gr.add_column("Потребление бойлером (кВт/ч)", "BOILER_POWER", 90)
        gr.add_column("Общее потребление (кВт/ч)", "BOILER_POWER", 90, func=self._totalPower)
        
        self.add_widget(gr)

    def query(self, query_type):
        if query_type == "recalc_stat":
            self.recalc_stat()
            return "OK"

    def _totalPower(self, index, row):
        p1 = row[5]
        p2 = row[7]
        p3 = row[9]
        return "%s" % (round(p1 + p2 + p3, 3))

    def _monthFunc(self, index, row):
        y, m = str(row[2]), str(row[3])
        if len(m) == 1:
            m = "0" + m
        return "%s-%s" % (m, y)

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
                    try:
                        stat = self._calcLight(y, i + 1)
                        pump_stat = self._calcPumps(y, i + 1)
                        boiler_stat = self._calcBoiler(y, i + 1)
                        
                        if stat != None:
                            print("OK")
                            self.db.IUD("insert into web_stat_power "
                                        "   (YEAR, MONTH, "
                                        "    LIGHT_TIME, LIGHT_POWER, "
                                        "    CIRC_PUMP_TIME, CIRC_PUMP_POWER, "
                                        "    BOILER_TIME, BOILER_POWER) "
                                        " values "
                                        "   (%s, %s, %s, %s, "
                                        "    %s, %s, %s, %s)" %
                                        (y, i+1, stat[0], stat[1],
                                         pump_stat[0], pump_stat[1],
                                         boiler_stat[0], boiler_stat[1]))
                    except Exception as e:
                        print(e)
                    self.db.commit()
                else:
                    print("CANCEL")

    def _calcLight(self, year, month):
        time_from, time_to = self.calc_month_interval(year, month)
        power_high = [29, 30] # Двойные лампочки
        prev_var_id = None
        prev_var_value = None
        prev_var_time = None
        all_power = 0
        all_time = 0

        prev_rec = None
    
        for rec in self.db.select("select c.VARIABLE_ID, UNIX_TIMESTAMP(c.CHANGE_DATE), c.VALUE, c.CHANGE_DATE "
                                  "  from core_variable_changes c, core_variables v "
                                  " where UNIX_TIMESTAMP(c.CHANGE_DATE) >= %s "
                                  "   and UNIX_TIMESTAMP(c.CHANGE_DATE) <= %s "
                                  "   and v.ID = c.VARIABLE_ID "
                                  "   and v.APP_CONTROL = 1 "
                                  "order by c.VARIABLE_ID, c.ID" % (time_from, time_to)):

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
            return [round(all_time / 3600, 2), round(all_power / 1000, 3)]
        else:
            return None

    def _calcPumps(self, year, month):
        var_info = [[93, 35, 32], [93, 40, 67]]
        
        a = []
        for i in var_info:
            a += ["%s" % (i[0]), ","]
        var_ids = "".join(a[:-1:])

    
        time_from = datetime(year, month, 1, 5).timestamp()
        if month == 12:
            year += 1
            month = 0
        time_to = datetime(year, month + 1, 1, 5).timestamp()

    
        prev_var_times = [None] * len(var_info)
        prev_var_ons = [None] * len(var_info)
    
        all_power = 0
        all_time = 0
    
        for rec in self.db.select("select UNIX_TIMESTAMP(c.CHANGE_DATE), c.VALUE "
                                  "  from core_variable_changes c "
                                  " where UNIX_TIMESTAMP(c.CHANGE_DATE) >= %s "
                                  "   and UNIX_TIMESTAMP(c.CHANGE_DATE) <= %s "
                                  "   and c.VARIABLE_ID in (%s) "
                                  "order by 1" % (time_from, time_to, var_ids)):
            i = 0
            for var in var_info:           
                is_on = rec[1] >= var[1]
    
                if prev_var_times[i] == None:
                    prev_var_times[i] = rec[0]

                if prev_var_ons[i] == None:
                    prev_var_ons[i] = is_on

                if prev_var_ons[i] != is_on:
                    if rec[1] > var[1]: # Включили мотор
                        prev_var_times[i] = rec[0]
                    else: # Мотор выключили и щитаем сколько работал
                        dt = rec[0] - prev_var_times[i]
                        all_time += dt
                        all_power += var[2] * (dt / 3600)

                prev_var_ons[i] = is_on
                i += 1

        if month == 0:
            month = 12
        if all_time > 0:
            return [round(all_time / 3600, 2), round(all_power / 1000, 3)]
        else:
            return [0, 0]

    def _calcBoiler(self, year, month):
        rele_id = 82
        rele_on = False
        temp_id = 152
        temp_on = 50        
        var_ids = "%s, %s" % (rele_id, temp_id)        
        a = []    
        time_from = datetime(year, month, 1, 5).timestamp()
        if month == 12:
            year += 1
            month = 0
        time_to = datetime(year, month + 1, 1, 5).timestamp()
    
        prev_var_time = None
        prev_var_on = None
        prev_var_val = None
    
        all_power = 0
        all_time = 0
    
        for rec in self.db.select("select UNIX_TIMESTAMP(c.CHANGE_DATE), c.VALUE, c.VARIABLE_ID "
                                  "  from core_variable_changes c "
                                  " where UNIX_TIMESTAMP(c.CHANGE_DATE) >= %s "
                                  "   and UNIX_TIMESTAMP(c.CHANGE_DATE) <= %s "
                                  "   and c.VARIABLE_ID in (%s) "
                                  "order by c.CHANGE_DATE" % (time_from, time_to, var_ids)):
            if rec[2] == temp_id:
                if prev_var_time == None:
                    prev_var_time = rec[0]

                if prev_var_val == None:
                    prev_var_val = rec[1]

                is_on = rec[1] <= temp_on or (rec[1] - prev_var_val) > 0.25

                if prev_var_on == None:
                    prev_var_on = is_on

                if prev_var_on != is_on:
                    if is_on: # Включили бойлер
                        prev_var_time = rec[0]
                    else: # Бойлер выключили и щитаем сколько работал
                        dt = rec[0] - prev_var_time
                        all_time += dt
                        all_power += 1250 * (dt / 3600)

                prev_var_on = is_on
                prev_var_val = rec[1]
            else:
                rele_on = rec[1] > 0

        if month == 0:
            month = 12
        if all_time > 0:
            return [round(all_time / 3600, 2), round(all_power / 1000, 3)]
        else:
            return [0, 0]
