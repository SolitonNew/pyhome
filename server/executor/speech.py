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

            """
            shell_comm = "aplay /home/pyhome/server/executor/notify.wav"
            subprocess.call(shell_comm, shell=True)
            #time.sleep(0.5)

            if len(s) > 0:
                shell_comm = 'echo "' + s + '" | spd-say -o rhvoice -l ru -e -t female1'
                subprocess.call(shell_comm, shell=True)
            """
            
            if len(s) > 0:
                subprocess.call('echo "' + s + '" | RHVoice-test -p Anna -o speech.wav', shell=True)
                subprocess.call("aplay /home/pyhome/server/executor/notify.wav", shell=True)
                subprocess.call("aplay speech.wav", shell=True)
                
            return True
        except:
            pass
        return False

    def time_handler(self):
        pass
