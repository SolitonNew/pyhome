from datetime import datetime

class Info():
    def __init__(self):
        pass

    def check_comm(self, db, command):
        try:
            command.index("info()")            

            d = datetime.now().hour - 1
            hours = ("Один час ночи",
                     "Два час*а ночи",
                     "Три час*а ночи",
                     "Четыре час*а ночи",
                     "Пять часов утр*а",
                     "Шесть часов утр*а",
                     "Семь часов утр*а",
                     "Восемь часов утр*а",
                     "Девять часов дня",
                     "Десять часов дня",
                     "Одинадцать часов дня",
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

            t_in = self._get_temp(db, "49,59,91,92", False)
            t_out = self._get_temp(db, "-1", True)
            
            text = "%s. Средняя температура по дому %s. Температура на улице %s." % (hours[d], t_in, t_out)

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
        v = v // c
        t_s = str(abs(int(v)))
        znak = ""
        if v < 0:
            znak = "мороза"
        elif v > 0 and plus:
            znak = "тепла"
        
        return "%s %s %s" % (t_s, temps[int(t_s[-1:])], znak)

    def time_handler(self):
        pass
