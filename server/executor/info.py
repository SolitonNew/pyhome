from dotenv import load_dotenv
import os
from datetime import datetime
from num2words import num2words

class Info():
    def __init__(self):
        pass

    def check_comm(self, db, command):
        try:
            command.index("info()")

            text = (self._get_current_time(db), self._get_themperature(db))

            db.IUD("insert into core_execute (COMMAND) values ('speech(\"%s\", \"notify\")')" % ";".join(text).replace("'", "\'"))
            db.commit()            

            return True
        except:
            pass
        return False
    
    def _get_current_time(self, db):
        h = datetime.now().hour
        m = datetime.now().minute
        
        if m == 0:
            return f"{num2words(h)} o'clock".capitalize()
        elif m == 30:
            return f"half past {num2words(h)}".capitalize()
        elif m < 30:
            return f"{num2words(m)} past {num2words(h)}".capitalize()
        else:
            return f"{num2words(60 - m)} to {num2words((h + 1) % 12 or 12)}".capitalize()
        
    def _get_themperature(self, db):
        load_dotenv()
        tempId = int(os.getenv("WATCHER_OUTSIDE_TEMP_ID"))
        tempValue = 0
        for row in db.select("select v.VALUE "
                             "  from core_variables v "
                             " where v.ID = %s " % (tempId)):
            tempValue = int(row[0])

        t = abs(tempValue)
        words = num2words(t)
        if tempValue > 0:
            return f"The temperature outside is {words} degrees above zero."
        elif tempValue < 0:
            return f"The temperature outside is {words} degrees below zero."
        else:
            return "The temperature outside is zero degrees."

    def time_handler(self):
        pass
