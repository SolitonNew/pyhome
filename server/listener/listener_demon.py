#!/usr/bin/python3

import numpy
import pyaudio
import wave
import time
import datetime

def start():
    siquence = 1
    
    CHUNK = 1024
    FORMAT = pyaudio.paInt16
    CHANNELS = 1
    RATE = 16000
    
    while True:
        p = pyaudio.PyAudio()
        stream = p.open(format=FORMAT,
                        channels=CHANNELS,
                        rate=RATE,
                        input=True,
                        frames_per_buffer=CHUNK)
        frames = []
        cy = 0xffff // 2
        dt = datetime.datetime.now().timestamp() + 1
        started = False
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
                started = True
                dt = datetime.datetime.now().timestamp() + 0.5

            if started:                
                frames.append(data)
                print("rec")
            
        stream.stop_stream()
        stream.close()
        p.terminate()

        #track_data = numpy.fromstring(b''.join(frames), numpy.int16)

        if len(frames) > 0:
            wf = wave.open("data/%s.wav" % siquence, 'wb')
            siquence += 1
            wf.setnchannels(CHANNELS)
            wf.setsampwidth(p.get_sample_size(FORMAT))
            wf.setframerate(RATE)
            wf.writeframes(b''.join(frames))
            wf.close()
        
start()
