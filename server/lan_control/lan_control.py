#!/usr/bin/python3
#-*- coding: utf-8 -*-

import socket
import threading
import pyaudio
import time
from db_connector import DBConnector

threads = []

class MetaThread(threading.Thread):
    def __init__(self, accept):
        threading.Thread.__init__(self)
        self.acceptData = accept        
        print("CONNECT META: %s" % accept[1][0])
        self.db = DBConnector()
        print("CONNECT DB")

    def sendpack(self, pack):
        conn = self.acceptData[0]
        i = 0
        for k in range(50):
            i =+ conn.send(pack[i::])
            if i == len(pack):
                break
        
    def run(self):
        buf = ''
        conn = self.acceptData[0]
        while True:            
            try:                                
                line = conn.recv(1024)
                if line != b'':
                    buf = "".join([buf, line.decode('cp1251')])
                    packs = buf.split(chr(2))
                    if len(packs) > 0:
                        buf = packs[len(packs) - 1]
                    for i in range(len(packs) - 1):
                        pack = packs[i]
                        if (pack == 'load'):
                            self.load_devs(conn)
                        else:
                            a = pack.split(";")
                            if a[0] == "setvar":
                                var_id = a[1]
                                var_v = float(a[2])
                                try:
                                    self.db.IUD("call CORE_SET_VARIABLE(%s, %s, null)" % (var_id, var_v))
                                    self.db.commit()
                                except:
                                    pass
                            else:
                                print(a)
                            
                # ---------------------------------------------
                pack_changes = bytearray(0)
                for rec in self.db.variable_changes():
                    pack_changes += str(rec[1]).encode("cp1251")
                    pack_changes += b'\x01'
                    pack_changes += str(rec[2]).encode("cp1251")
                    pack_changes += b'\x01'
                self.sendpack(b'synk' + pack_changes + b'\x02')
                # ---------------------------------------------
                time.sleep(0.5)                   
            except Exception as e:
                print("{}".format(e.args))
                break
                
        conn.close()
        print("DISCONNECT META: %s" % self.acceptData[1][0])
        del(threads[threads.index(self)])

    def load_devs(self, conn):
        pack = bytearray(0)
        for rec in self.db.select("select ID, NAME, COMM, APP_CONTROL, VALUE "
                                  "  from core_variables order by COMM"):
            pack += str(rec[0]).encode("cp1251")
            pack += b'\x01'
            pack += rec[1].decode("utf-8").encode("cp1251")
            pack += b'\x01'
            pack += rec[2].decode("utf-8").encode("cp1251")
            pack += b'\x01'
            pack += str(rec[3]).encode("cp1251")
            pack += b'\x01'
            pack += str(rec[4]).encode("cp1251")
            pack += b'\x01'
            
        self.sendpack(b'load' + pack + b'\x02')
        
        print("LOAD PACK SEND")

class SoundThread(threading.Thread):
    def __init__(self, accept):
        threading.Thread.__init__(self)
        self.acceptData = accept
        print("CONNECT SOUND: %s" % accept[1][0])        
        
    def run(self):
        CHUNK = 1024
        FORMAT = pyaudio.paInt16
        CHANNELS = 2
        RATE = 44100
        
        p = pyaudio.PyAudio()
        try:
            stream = p.open(format=FORMAT,
                            channels=CHANNELS,
                            rate=RATE,
                            input=True,
                            frames_per_buffer=CHUNK)
        except:
            stream = False
        
        conn = self.acceptData[0]
        while True:            
            try:                
                conn.send(stream.read(CHUNK))
                conn.recv(4)
            except:                
                break

        conn.close()
        if stream:
            stream.stop_stream()
            stream.close()
        p.terminate()
        print("DISCONNECT SOUND: %s" % self.acceptData[1][0])
        del(threads[threads.index(self)])    

port_meta = 8090
port_sound = 8091

err = 0
while True:    
    try:        
        sock_meta = socket.socket()
        sock_meta.bind(("", port_meta))
        sock_meta.listen(32)

        sock_sound = socket.socket()
        sock_sound.bind(("", port_sound))
        sock_sound.listen(32)

        err = 0

        print("\nBIND TO PORTS %s, %s" % (port_meta, port_sound))

        while True:
            t = MetaThread(sock_meta.accept())
            threads += [t]
            t.start()

            t = SoundThread(sock_sound.accept())
            threads += [t]
            t.start()
            

        for t in threads:
            if t:
                t.conn.close()

        sock_sound.close()
        sock_meta.close()
    except:
        time.sleep(1)
        if err == 0:
            print("ERROR. PORT BIND REPEAT: ", end='')
        else:
            print("*", end='')
        err += 1
