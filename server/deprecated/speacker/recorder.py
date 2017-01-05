#!/usr/bin/python3

import numpy
import pyaudio
import wave
import time
import datetime

class Main():
    def __init__(self):
        self.record()


    def record(self):
        CHUNK = 1024
        FORMAT = pyaudio.paInt16
        CHANNELS = 2
        RATE = 16000

        while True:
            print("Для начала записи нажмите ENTER", end="")
            input()            
            p = pyaudio.PyAudio()
            stream = p.open(format=FORMAT,
                            channels=CHANNELS,
                            rate=RATE,
                            input=True,
                            frames_per_buffer=CHUNK)
            print("\n        [     Запись!!!     ]\n")
            frames = []
            cy = 0xffff // 2
            dt = datetime.datetime.now().timestamp() + 1
            while True:
                data = stream.read(CHUNK)
                samples = numpy.fromstring(data, numpy.int16)
                if abs(sum(samples)) < 6000:
                    if datetime.datetime.now().timestamp() > dt:
                        break
                else:
                    dt = datetime.datetime.now().timestamp() + 0.5
                frames.append(data)

            print("        [  Запись окончена  ]\n\n        Имя файла: ", end='')
            stream.stop_stream()
            stream.close()
            p.terminate()

            wf = wave.open("samples/%s.wav" % input(), 'wb')
            wf.setnchannels(CHANNELS)
            wf.setsampwidth(p.get_sample_size(FORMAT))
            wf.setframerate(RATE)
            wf.writeframes(b''.join(frames))
            wf.close()

            print("\nГотово. Для новой записи нажмите ENTER", end="")
            input()

print(
"=============================================================================\n"
"                   МОДУЛЬ ЗАПИСИ ЗВУКОВОЙ ИНДИКАЦИИ  v0.1\n"
"\n"
"=============================================================================\n"
)

if __name__ == "__main__":
    Main()
