from datetime import datetime

class Info():
    def __init__(self):
        pass

    def check_comm(self, db, command):
        try:
            command.index("info()")

            d = datetime.now().hour - 1
            m = datetime.now().minute
            hours = ("Один час ночи",
                     "Два час*а ночи",
                     "Три час*а ночи",
                     "Четыре час*а ночи",
                     "Пять часов утр*а",
                     "Шесть часов утр*а",
                     "Семь часов утр*а",
                     "Восемь часов утр*а",
                     "Девять часов утр*а",
                     "Десять часов утр*а",
                     "Одинадцать часов утр*а",
                     "Двенадцать часов дня",
                     "Один час дня",
                     "Два час*а дня",
                     "Три час*а дня",
                     "Четыре час*а дня",
                     "Пять часов в*ечера",
                     "Шесть часов в*ечера",
                     "Семь часов в*ечера",
                     "Восемь часов в*ечера",
                     "Девять часов в*ечера",
                     "Десять часов в*ечера",
                     "Одинадцать часов ночи",
                     "Двенадцать часов ночи")

            minutes_2 = ("",
                         "одна",
                         "две",
                         "три",
                         "четыре",
                         "пять",
                         "шесть",
                         "семь",
                         "восемь",
                         "девять")

            minutes_1 = ("",
                         "",
                         "двадцать", 
                         "тридцать",
                         "сорок",
                         "пятдесят",
                         "шестьдесят")

            minutes = ("минут",
                       "минута",
                       "минуты",
                       "минуты",
                       "минуты",
                       "минут",
                       "минут",
                       "минут",
                       "минут",
                       "минут")            

            minute = ""
            if m > 0:
                minute = str(m)
                if m < 10:
                    minute = minutes_2[m] + " " + minutes[m]
                elif m < 20:
                    minute += " " + minutes[9]
                else:
                    try:
                        minute = minutes_1[int(minute[0])] + " " + minutes_2[int(minute[1])] + " " + minutes[int(minute[1])]
                    except Exception as e:
                        pass
                minute = ", %s" % minute

            t_in = self._get_temp(db, "49,59,91,92", False)
            t_out = self._get_temp(db, "-1", True)
            
            text = "%s%s. Средняя температура по дому %s. Температура на улице %s." % (hours[d], minute, t_in, t_out)

            print(text)

            db.IUD("insert into core_execute (COMMAND) values ('speech(\"%s\")')" % text)
            db.commit()

            return True
        except:
            pass
        return False

    def _get_temp(self, db, ids, plus):
        temps = ("градусов",
                 "градус",
                 "градуса", 
                 "градуса",
                 "градуса",
                 "градусов",
                 "градусов",
                 "градусов",
                 "градусов",
                 "градусов")
        v = 0
        c = 0
        for row in db.select("select v.VALUE from core_variables v where ID in (%s)" % ids):
            v += row[0]
            c += 1

        if c == 0:
            return "неизвестна"

        res = ""
        v = round(v / c)
        t_s = str(abs(int(v)))
        znak = ""
        if v < 0:
            znak = " мороза"
        elif v > 0 and plus:
            znak = " тепла"
        
        return "%s %s%s" % (t_s, temps[int(t_s[-1:])], znak)

    def time_handler(self):
        pass
