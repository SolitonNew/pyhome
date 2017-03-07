import os
import subprocess
import time

class Speech():
    def __init__(self):
        pass

    def check_comm(self, db, id, command):
        try:            
            command.index("speech")
            a = command.split('"')

            text = a[1]
            try:
                audio = a[3]
            except:
                audio = 'notify'

            res = db.select("select ID from core_execute_audio where COMMAND = '%s'" % (command))
            if len(res) == 0:
                db.IUD("insert into core_execute_audio (COMMAND) values ('%s')" % (command))
                exe_id = db._lastID
                subprocess.call('echo "' + text + '" | RHVoice-test -p Anna -o /var/tmp/wisehouse/audio_%s.wav' % (exe_id), shell=True)
            else:
                exe_id = res[0][0]

            db.IUD("update core_execute "
                   "   set AUDIO = '%s', "
                   "       PROCESSED = %s "
                   " where ID = %s" % (audio, 1, id))
            db.commit()
                
            subprocess.call("aplay /home/pyhome/server/executor/notify.wav", shell=True)
            subprocess.call("aplay /var/tmp/wisehouse/audio_%s.wav" % (exe_id), shell=True)
            print("")
                
            return True
        except Exception as e:
            pass
        return False

    def time_handler(self):
        pass
