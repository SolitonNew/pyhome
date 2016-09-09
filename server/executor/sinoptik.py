from datetime import datetime
import http.client
from urllib import parse

class Sinoptik():
    def __init__(self):
        pass

    def parseTag(self, content, tag1, tag2):
        i1 = content.index(tag1) + len(tag1)
        i2 = content[i1:].index(tag2)
        s = content[i1:i1 + i2].strip()
        return s

    def parceDescr(self, content):
        return self.parseTag(content, "<div class=\"description\">", "</div>")

    def parceTemp(self, content):
        t1 = self.parseTag(content, "<div class=\"min\">", "</div>")
        t1 = self.parseTag(t1, "<span>", "</span>")
        t1 = t1.replace("&deg;", "")
        
        t2 = self.parseTag(content, "<div class=\"max\">", "</div>")
        t2 = self.parseTag(t2, "<span>", "</span>")
        t2 = t2.replace("&deg;", "")
        
        return (t1, t2)

    def check_comm(self, db, command):
        try:
            command.index("sinoptik()")

            conn = http.client.HTTPSConnection("sinoptik.ua")
            conn.request("GET", "/" + parse.quote_plus("погода-долина-303007327"))
            resp = conn.getresponse()
            print(resp.status)
            content = resp.read().decode("utf-8")
            conn.close()

            text = "Прогноз погоды. " + self.parceDescr(content)
            t = self.parceTemp(content)
            text = text + " Температура воздуха %s %s градуса." % t

            text = text.replace("вечера", "в*ечера")

            db.IUD("insert into core_execute (COMMAND) values ('speech(\"%s\")')" % text)
            db.commit()
            
            return True
        except Exception as e:
            print("{}".format(e.args))
        return False

    def time_handler(self):
        pass
