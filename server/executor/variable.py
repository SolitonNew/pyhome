import os
from subprocess import Popen, PIPE

class Variable():
    def __init__(self):
        pass

    def check_comm(self, db, id, command):
        return (self._check_comm(db, id, command, "on", 1) or
                self._check_comm(db, id, command, "off", 0))

    def _check_comm(self, db, id, command, tag, val):
        try:            
            command.index(tag + "(")
            s = command.replace(tag + "(", "")
            s = s.replace(")", "")
            s = s.replace("\"", "")
            for v in db.select("select ID, VALUE from core_variables where NAME='%s'" % s.strip()):
                if v[1] != val:
                    db.IUD("call CORE_SET_VARIABLE(%s, %s, null)" %
                           (v[0], val))
                    db.commit()
            db.IUD("update core_execute "
                   "   set PROCESSED = %s "
                   " where ID = %s" % (1, id))
            db.commit()
            return True
        except:
            pass
        
        return False

    def time_handler(self):
        pass
