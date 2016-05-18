#!/usr/bin/python3

from subprocess import Popen, PIPE
import time

class Main():
    def __init__(self):        
        #self.db = DBConnector()
        self.alarm_file = "/home/administrator/pyhome_musik/03 Beautiful Creatures.m4a"
        self.run()        
        

    def play_file(self, file):
        pass

    def run(self):        
        player = Popen(["mplayer", "-slave", "-quiet", "-idle", "-volume", "0", "-loop", "0", self.alarm_file],
                       stdin=PIPE, stdout=PIPE, stderr=PIPE)

        while True:
            player.stdin.write(b'set_volume 50\n')
            player.stdin.flush()
            time.sleep(1)
        
        #while True:
            """
            for row in self.db.variable_changes():
                if row[3] == 1:
                    try:
                        self.play_file("samples/part_%s.wav" % (row[4]))
                    except:
                        pass
                    if row[2]:
                        self.play_file("samples/on.wav")
                    else:
                        self.play_file("samples/off.wav")
            time.sleep(0.1)            
            """
            #player.stdin.write((input() + '\n').encode("utf-8"))
            #player.stdin.flush()
            
            #player.stdout.readline()

        #self.player.stdin.write(b'quit\n')

print(
"=============================================================================\n"
"                     МОДУЛЬ ЗВУКОВОЙ ИНДИКАЦИИ v0.1\n"
"\n"
" Каналов: %s \n"
" Битность: %s \n"
" Частота: %s \n"
"=============================================================================\n"
% (2, 16, 16000)
)

if __name__ == "__main__":    
    Main()
