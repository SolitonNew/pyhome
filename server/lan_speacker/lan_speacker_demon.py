#!/usr/bin/python3
#-*- coding: utf-8 -*-

import socket
import threading
import pyaudio
import time

threads = []

class SpeackThread(threading.Thread):
    def __init__(self, accept):
        threading.Thread.__init__(self)
        #self.daemon = True
        self.acceptData = accept
        print("CONNECT: %s" % accept[1][0])        
        
    def run(self):
        CHUNK = 1024
        FORMAT = pyaudio.paInt16
        CHANNELS = 2
        RATE = 16000
        
        p = pyaudio.PyAudio()
        try:
            stream = p.open(format=FORMAT,
                            channels=CHANNELS,
                            rate=RATE,
                            input=True,
                            input_device_index=0,
                            frames_per_buffer=CHUNK)
        except:
            stream = False
        
        conn = self.acceptData[0]
        while True:            
            try:                
                conn.send(stream.read(CHUNK))
                conn.recv(1024)
            except:                
                break

        conn.close()
        if stream:
            stream.stop_stream()
            stream.close()
        p.terminate()
        print("DISCONNECT: %s" % self.acceptData[1][0])
        del(threads[threads.index(self)])

p = pyaudio.PyAudio()
for i in range(p.get_device_count()):
    print(p.get_device_info_by_index(i)['name'])
p.terminate()
print('---------------------------------------------------------------------')

port = 8084

err = 0
while True:    
    try:        
        sock = socket.socket()
        sock.bind(("", port))
        sock.listen(5)

        err = 0

        print("\nBIND TO PORT %s" % (port))

        while True:
            t = SpeackThread(sock.accept())
            threads += [t]
            t.start()
            print(threads)

        for t in threads:
            if t:
                t.conn.close()

        sock.close()
    except:
        time.sleep(1)
        if err == 0:
            print("ERROR. PORT BIND REPEAT: ", end='')
        else:
            print("*", end='')
        err += 1
