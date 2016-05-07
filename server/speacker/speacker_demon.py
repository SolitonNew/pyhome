#!/usr/bin/python3

import pyaudio
import numpy
import wave
from db_connector import DBConnector
import datetime
import time

class Main():
    def __init__(self):        
        self.prev_val = 0
        #self.play_file("samples/on.wav")
        self.db = DBConnector()
        self.run()

    def play_file(self, file):
        CHUNK = 2048
        FORMAT = pyaudio.paInt16
        CHANNELS = 2
        RATE = 16000

        p = pyaudio.PyAudio()      

        stream = p.open(format=FORMAT,
                        channels=CHANNELS,
                        rate=RATE,
                        output=True)

        f = wave.open(file,'rb')
        prev_filter_val = 0
        while True:            
            data = f.readframes(CHUNK)
            if len(data) > 0:
                samples = numpy.fromstring(data, numpy.int16)
                prev_filter_val = self.sound_processor(samples, prev_filter_val)
                stream.write(numpy.fromstring(samples, numpy.int8))
            else:
                break;
            
        stream.stop_stream()
        stream.close()

        f.close()
        p.terminate()

    def sound_processor(self, data, pv):
        res = pv
        for i in range(len(data)):            
            val = data[i]
            """
            # Фильтруем высокие частоты
            c = pv + (val - pv) // 2
            val = c
            """
            # Корректируем громкость
            val = val * 2
            if val > 32000:
                val = 32000
            elif val < -32000:
                val = -32000
                
            data[i] = val
            res = pv
        return res

    def run(self):
        while True:
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
