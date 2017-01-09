#!/usr/bin/python3
#-*- coding: utf-8 -*-

import socket
import threading
import pyaudio
import time
from db_connector import DBConnector
import numpy

class MetaThread(threading.Thread):
    def __init__(self, accept, owner):
        threading.Thread.__init__(self)
        self.acceptData = accept
        self.conn = accept[0]
        #self.conn.settimeout(60)
        self.owner = owner
        print("CONNECT META: %s" % accept[1][0])
        self.db = DBConnector()
        print("    connect db")
        self.app_id = -1
        self.app_sessions = False

    def sendpack(self, pack):
        i = 0
        for k in range(1024):
            i =+ self.conn.send(pack[i::])
            if i == len(pack):
                break

    def senddata(self, pack_type, data):
        cols = 0
        pack = b''
        for rec in data:
            cols = 0
            for cell in rec:
                if type(cell) == bytes:
                    pack += cell.decode("utf-8").encode("cp1251")
                else:
                    pack += str(cell).encode("cp1251")
                pack += b'\x01'
                cols += 1
        self.sendpack(pack_type.encode('cp1251') + str(cols).encode('cp1251') + b'\x01' + pack + b'\x02')
        return len(pack)

    def sendcursor(self, pack_type, sql):
        return self.senddata(pack_type, self.db.select(sql))
        
    def run(self):
        buf = ''
        while self.owner.is_alive():
            try:
                line = self.conn.recv(1024)
                if line != b'':
                    buf += line.decode('cp1251')
                    packs = buf.split(chr(2))
                    if len(packs) > 0:
                        buf = packs[len(packs) - 1]
                    for pack in packs[:-1:]:
                        a = pack.split(chr(1))
                        if a[0] == "ping":
                            pass
                        elif a[0] == "load":
                            self.init_load(a[1])
                        elif a[0] == "apps":
                            pack = b''
                            self.sendcursor('apps', ("select ID, COMM "
                                                     " from app_controls "
                                                     "order by COMM"))
                        elif a[0] == "regi":
                            self.db.IUD("insert into app_controls (COMM) values ('%s')" % (a[1]))
                            self.db.commit()
                            self.senddata('regi', [[self.db.last_insert_id()]])
                        elif a[0] == "name":
                            self.db.IUD("update app_controls "
                                        "   set COMM = '%s'"
                                        " where ID = %s" % (a[1], self.app_id))
                            self.db.commit()
                        elif a[0] == "setvar":
                            var_id = a[1]
                            var_v = float(a[2])
                            try:
                                self.db.IUD("call CORE_SET_VARIABLE(%s, %s, null)" % (var_id, var_v))
                                self.db.commit()
                            except:
                                pass
                        elif a[0] == "media_transfer":
                            self._add_to_queue(10, a[2], a[3], int(a[1]))
                        elif a[0] == "medi":
                            if a[1] == "get folders":
                                self.sendcursor("medi", ("select SEARCH_FOLDERS "
                                                         "  from app_controls where ID = %s" % (self.app_id)))
                            elif a[1] == "set folders":
                                self.db.IUD("update app_controls "
                                            "   set SEARCH_FOLDERS = '%s' "
                                            " where ID = %s" % (a[2], self.app_id))
                                self.db.commit()
                            elif a[1] == "get media list":
                                l = self.sendcursor("mdls", ("select ID, APP_CONTROL_ID, TITLE, FILE_NAME "
                                                             "  from media_lib "
                                                             " where APP_CONTROL_ID = %s"
                                                             " union all "
                                                             "select ID, APP_CONTROL_ID, TITLE, FILE_NAME "
                                                             "  from media_lib"
                                                             " where APP_CONTROL_ID <> %s") % (self.app_id, self.app_id))
                                print("    media lib pack [%s bytes]" % (l))
                            elif a[1] == "add files":
                                for f in a[2:-1:]:
                                    title = f.split('\\')[-1::][0]
                                    f = f.replace("'", "\\'")
                                    title = title.replace("'", "\\'")
                                    try:
                                        sql = "insert into media_lib (APP_CONTROL_ID, TITLE, FILE_NAME) values (%s, '%s', '%s')" % (self.app_id, title, f)
                                        self.db.IUD(sql)
                                        self._add_to_queue(0, self.db.last_insert_id())
                                    except Exception as e:
                                        print("ADD " + str(e))
                                self.db.commit()
                                self.senddata('m_ok', [["OK"]])
                            elif a[1] == "del files":
                                try:
                                    self.db.IUD("delete from media_lib where ID in (%s)" % (a[2]))
                                    for i in a[2].split(","):
                                        self._add_to_queue(2, i)
                                    self.db.commit()
                                except Exception as e:                                    
                                    print("DEL [%s] %s " % (self.app_id, str(e)))
                                
                        else:
                            print(a)
                            
                # ---------------------------------------------
                self.senddata('synk', self.db.variable_changes())
                # ---------------------------------------------
                sess = self.db.select("select c.ID, c.COMM, s.IP"
                                      "  from app_controls c, app_control_sess s "
                                      " where s.APP_CONTROL_ID = c.ID "
                                      "order by 1")
                if self.app_sessions != sess:
                    self.app_sessions = sess
                    self.senddata('sess', self.app_sessions)
                # ---------------------------------------------
                queueSql = ("select q.ID, q.TYP, q.VALUE, q.VALUE_2, m.APP_CONTROL_ID, m.TITLE, m.FILE_NAME"
                            "  from app_control_queue q, media_lib m "
                            " where q.VALUE = m.ID"
                            "   and q.APP_CONTROL_ID = %s"
                            "   and q.TYP in (0, 1) "
                            "union all "
                            "select q.ID, q.TYP, q.VALUE, q.VALUE_2, q.APP_CONTROL_ID, '' TITLE, '' FILE_NAME"
                            "  from app_control_queue q"
                            " where q.APP_CONTROL_ID = %s"
                            "   and q.TYP in (2, 10) "
                            "order by 1" % (self.app_id, self.app_id))
                queue = self.db.select(queueSql)
                self.senddata("m__q", queue)
                if len(queue) > 0:
                    self.db.IUD("delete from app_control_queue "
                                " where APP_CONTROL_ID = %s"
                                "   and ID <= %s"% (self.app_id, queue[-1::][0][0]))
                    self.db.commit()                
                # ---------------------------------------------
                #time.sleep(0.5)                   
            except Exception as e:
                print("    error: " + str(e))
                break
        try:
            self.conn.close()
        except:
            print("error: self.conn.close()")
        
        try:
            self.db.IUD("delete from app_control_sess where APP_CONTROL_ID = %s" % (self.app_id))
            self.db.IUD("delete from app_control_queue where APP_CONTROL_ID = %s" % (self.app_id))
            self.db.commit()
        except Exception as e:
            print("ERROR 1: " + str(e))        
        self.db = False
        print("DISCONNECT META [%s]" % self.acceptData[1][0])
        threads = self.owner.threads
        del(threads[threads.index(self)])

    def init_load(self, app_id):
        self.app_id = app_id
        # The registry session in base
        self.db.IUD("delete from app_control_sess where APP_CONTROL_ID = %s" % (app_id))
        self.db.IUD("delete from app_control_queue where APP_CONTROL_ID = %s" % (app_id))
        self.db.IUD(" insert into app_control_sess (APP_CONTROL_ID, IP)"
                    " values "
                    " (%s, '%s')" % (app_id, self.acceptData[1][0]))
        self.db.commit()
        # Packed data for client
        l = self.sendcursor('load', ("select ID, NAME, COMM, APP_CONTROL, VALUE "
                                     "  from core_variables order by COMM"))
        print("    load pack [%s bytes]" % (l))

    def _add_to_queue(self, typ, value, value2 = 0, target = None):
        for r in self.app_sessions:
            if r[2] != b'':
                if target == None or r[0] == target:
                    self.db.IUD("insert into app_control_queue (APP_CONTROL_ID, TYP, VALUE, VALUE_2) values (%s, %s, %s, %s)" % (r[0], typ, value, value2))

class SoundThread(threading.Thread):
    def __init__(self, accept, owner):
        threading.Thread.__init__(self)
        self.acceptData = accept
        self.conn = accept[0]
        self.owner = owner
        print("CONNECT SOUND [%s]" % accept[1][0])        
        
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
        
        silent = 0
        while True:
            try:
                """
                data = stream.read(CHUNK)
                a = sum(data)
                if a == 0:
                    silent += 1
                else:
                    silent = 0
                if silent < 10:
                    conn.send(data)
                    conn.recv(4)
                else:
                    conn.send(b'\x00')
                    conn.recv(4)

                """
                self.conn.send(stream.read(CHUNK))
                self.conn.recv(4)
            except:                
                break

        try:
            self.conn.close()
        except:
            pass
        
        if stream:
            stream.stop_stream()
            stream.close()
        p.terminate()
        print("DISCONNECT SOUND: %s" % self.acceptData[1][0])
        threads = self.owner.threads
        del(threads[threads.index(self)])


class ThreadManager(threading.Thread):
    def __init__(self, threadClass, port):
        threading.Thread.__init__(self)
        self.isRun = True
        self.threadClass = threadClass
        self.port = port
        self.threads = []
        self.start()
        
    def run(self):
        while True:
            try:
                self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                self.sock.bind(("", self.port))
                self.sock.listen(32)

                while True:
                    try:
                        accept = self.sock.accept()
                        if self.isRun: 
                            t = self.threadClass(accept, self)
                            self.threads += [t]
                            t.start()
                        else:
                            accept[0].close()
                            print(str(self.threadClass) + " EXIT")
                            break
                    except Exception as e:
                        print(str(self.threadClass) + " THREAD ERROR")
                        break
        
                self._close_threads()
                try:
                    self.sock.close()
                except:
                    print("error: sock.close()")
            except:
                time.sleep(5)
                print("binding error for port: %s" % (self.port))

    def _close_threads(self):
        for t in self.threads:
            if t:
                try:
                    t.conn.close()
                except:
                    pass

    def stopDemon(self):
        self.isRun = False
        self._close_threads()
        self.sock.close()

port_meta = 8090
port_sound = 8091

class Main():
    def __init__(self):
        metaThread = ThreadManager(MetaThread, port_meta)
        soundThread = ThreadManager(SoundThread, port_sound)
        try:
            while True:
                time.sleep(1)
        except:
            pass
        metaThread.stopDemon()
        soundThread.stopDemon()

print(
"=============================================================================\n"
"               МОДУЛЬ УДАЛЕННОГО КОНТРОЛЯ И УПРАВЛЕНИЯ v0.1\n"
"\n"
" Порты: %s, %s \n"
"=============================================================================\n"
% (port_meta, port_sound)
)

if __name__ == "__main__":
    Main()
