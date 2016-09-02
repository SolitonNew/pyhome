#!/usr/bin/python3

import numpy
import pyaudio
import wave
import time
import datetime

print("Введите обучаемое слово: ", end='')
word = input()

try:
    f = open("words/%s" % word, "rb")
    word_data = numpy.fromstring(f.read(), numpy.int16)
    f.close()
except:
    word_data = bytearray()

def start(word, word_data):
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
        print("-- Идет запись!!!")
        frames = []
        cy = 0xffff // 2
        dt = datetime.datetime.now().timestamp() + 1
        while True:
            data = stream.read(CHUNK)
            samples = numpy.fromstring(data, numpy.int16)
            vol = 0
            for v in samples:
                vol += abs(v)
            vol = vol / len(samples)
            
            if vol < 120: # Чувствительность
                if datetime.datetime.now().timestamp() > dt:
                    break
            else:
                dt = datetime.datetime.now().timestamp() + 0.1
                frames.append(data)
            
        stream.stop_stream()
        stream.close()
        p.terminate()

        print("-- Запись окончена. Успешно?: ", end='')
        if input() == "д":
            track_data = numpy.fromstring(b''.join(frames), numpy.int16)
            
            # Сравниваем шаблон с входным файлом
            if len(word_data) == 0:
                word_data = track_data
            else:
                res = []
                for i in range(min(len(word_data), len(track_data))):
                    vol1 = word_data[i]
                    vol2 = track_data[i]
                    vol = min(vol1, vol2)
                    res += [vol]
                word_data = b''.join(res)

            # Записываем результат сравнения
            f = open("words/%s" % word, "wb")
            f.write(word_data)
            f.close()

            # Записываем результат сравнения
            f = open("words/%s.txt" % word, "w")
            for w in word_data: 
                f.write(str(w) + "\n")
            f.close()

            wf = wave.open("words/%s.wav" % word, 'wb')
            wf.setnchannels(CHANNELS)
            wf.setsampwidth(p.get_sample_size(FORMAT))
            wf.setframerate(RATE)
            wf.writeframes(b''.join(frames))
            wf.close()

            print("-- Записано ")
        
        print("-- еще?: ", end='')
        if input() != "д":
            break

start(word, word_data)
