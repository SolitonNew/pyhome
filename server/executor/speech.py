import os
import subprocess
import time

class Speech():
    def __init__(self):
        pass

    def check_comm(self, db, command):
        try:            
            command.index("speech")
            s = command.replace("speech", "")
            s = s.replace("(", "")
            s = s.replace(")", "")
            s = s.replace("\"", "")

            shell_comm = "aplay /home/pyhome/server/executor/notify.wav"
            subprocess.call(shell_comm, shell=True)
            #time.sleep(0.5)
            shell_comm = 'echo "' + s + '" | spd-say -o rhvoice -l ru -e -t female1'            
            subprocess.call(shell_comm, shell=True)
            return True
        except:
            pass
        return False

    def time_handler(self):
        pass
