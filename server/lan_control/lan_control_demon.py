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
        self.media_exts = [["AVI", "MP4", "MKV"], ["MP3", "WAV"], ["JPG", "TIFF", "PSD"]]
        threading.Thread.__init__(self)
        self.acceptData = accept
        self.conn = accept[0]
        self.conn.setblocking(True)
        self.owner = owner
        self._print("CONNECT META: %s" % accept[1][0])
        self.db = DBConnector()
        self._print("    connect db")
        self.app_id = -1
        self.app_sessions = False

    def sendpack(self, pack):
        i = 0
        for k in range(1024):
            i =+ self.conn.send(pack[i::])
            if i == len(pack):
                break

    def senddata(self, data):
        cols = 0
        pack = []
        for rec in data:
            cols = 0
            for cell in rec:
                if type(cell) == bytes:
                    pack += [cell.decode("utf-8").encode("cp1251")]
                else:
                    pack += [str(cell).encode("cp1251")]
                pack += [b'\x01']
                cols += 1
        pack_j = b''.join(pack)                
        self.sendpack(str(cols).encode('cp1251') + b'\x01' + pack_j + b'\x02')
        return len(pack_j)

    def sendcursor(self, sql):
        return self.senddata(self.db.select(sql))
        
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
                            self.senddata([["OK"]])
                        elif a[0] == "sync":
                            self._sync()
                        elif a[0] == "sessions":
                            self._sess()
                        elif a[0] == "media queue":
                            self._media_queue()
                        elif a[0] == "load variables":
                            self.init_load(a[1])
                        elif a[0] == "registration":
                            self.db.IUD("insert into app_controls (COMM) values ('%s')" % (a[1]))
                            self.db.commit()
                            self.senddata([[self.db.last_insert_id()]])
                        elif a[0] == "apps list":
                            self.sendcursor("select ID, COMM from app_controls order by 2")
                        elif a[0] == "name":
                            self.db.IUD("update app_controls "
                                        "   set COMM = '%s'"
                                        " where ID = %s" % (a[1], self.app_id))
                            self.db.commit()
                            self.senddata([["OK"]])
                        elif a[0] == "setvar":
                            var_id = a[1]
                            var_v = float(a[2])
                            try:
                                self.db.IUD("delete from core_scheduler where TEMP_VARIABLE_ID = %s" % (var_id))
                                self.db.IUD("call CORE_SET_VARIABLE(%s, %s, null)" % (var_id, var_v))
                                self.db.commit()
                                self._sync()
                            except:
                                pass
                        elif a[0] == "media transfer":
                            self._add_to_queue(10, a[2], a[3], int(a[1]))
                            self.senddata([["OK"]])
                        elif a[0] == "get media exts":
                            s = ""
                            for re in self.media_exts:
                                for ec in re:
                                    s += ec + ';'
                            self.senddata([[s[:-1:]]])
                        elif a[0] == "get media folders":
                            self.sendcursor("select SEARCH_FOLDERS "
                                            "  from app_controls where ID = %s" % (self.app_id))
                        elif a[0] == "set media folders":
                            self.db.IUD("update app_controls "
                                        "   set SEARCH_FOLDERS = '%s' "
                                        " where ID = %s" % (a[1], self.app_id))
                            self.db.commit()
                            self.senddata([["OK"]])
                        elif a[0] == "get media list":
                            l = self.sendcursor("select ID, APP_CONTROL_ID, TITLE, FILE_NAME, FILE_TYPE "
                                                "  from media_lib "
                                                "order by ID")
                            self._print("    media lib pack [%s bytes]" % (l))
                        elif a[0] == "add media files":
                            for f in a[1:-1:]:
                                title = self._parse_media_title(f)
                                title = title.replace("'", "\\'")
                                f = f.replace("\\", "\\\\")
                                f = f.replace("'", "\\'")
                                try:
                                    # Добавляем запись в библиотеку
                                    sql = ("insert into media_lib "
                                           "   (APP_CONTROL_ID, TITLE, FILE_NAME, FILE_TYPE) "
                                           "values "
                                           "   (%s, '%s', '%s', %s)") % (self.app_id, title, f, self._parse_media_type(f))
                                    self.db.IUD(sql)
                                    # Регистрируем изменения в очереди
                                    self._add_to_queue(0, self.db.last_insert_id())
                                except Exception as e:
                                    self._print("ADD " + str(e))
                            self.db.commit()
                            self.senddata([["OK"]])
                        elif a[0] == "edit media file":
                            self.db.IUD(("update media_lib"
                                         "   set TITLE = '%s'"
                                         " where ID = %s") % (a[2], a[1]))
                            self.db.commit()
                            self._add_to_queue(1, a[1])
                            self.senddata([["OK"]])
                        elif a[0] == "del media files":
                            try:
                                self.db.IUD("delete from media_lib_2_group where LIB_ID in (%s)" % (a[1]))
                                self.db.IUD("delete from media_lib where ID in (%s)" % (a[1]))
                                for i in a[1].split(","):
                                    self._add_to_queue(2, i)
                                self.db.commit()
                            except Exception as e:                                    
                                self._print("DEL [%s] %s " % (self.app_id, str(e)))
                            self.senddata([["OK"]])
                        elif a[0] == "get scheduler list":
                            self.sendcursor("select ID, COMM, ACTION, ACTION_DATETIME, INTERVAL_TIME_OF_DAY, INTERVAL_DAY_OF_TYPE, INTERVAL_TYPE, TEMP_VARIABLE_ID "
                                            "  from core_scheduler "
                                            "order by COMM")
                        elif a[0] == "edit scheduler":
                            if a[1] == "-1":
                                self.db.IUD("delete from core_scheduler where TEMP_VARIABLE_ID = %s" % (a[7]))
                                if a[2] != '':
                                    self.db.IUD(("insert into core_scheduler "
                                                 " (COMM, ACTION, INTERVAL_TYPE, INTERVAL_TIME_OF_DAY, INTERVAL_DAY_OF_TYPE, TEMP_VARIABLE_ID)"
                                                 "values"
                                                 " ('%s', '%s', %s, '%s', '%s', %s)") % (a[2], a[3], a[4], a[5], a[6], a[7]))
                                self.db.commit();
                            else:
                                self.db.IUD(("update core_scheduler "
                                             " set COMM = '%s', "
                                             "     ACTION = '%s', "
                                             "     INTERVAL_TYPE = %s, "
                                             "     INTERVAL_TIME_OF_DAY = '%s', "
                                             "     INTERVAL_DAY_OF_TYPE = '%s' "
                                             "where ID = %s") % (a[2], a[3], a[4], a[5], a[6], a[1]))
                                self.db.commit();
                            self.senddata([["OK"]])
                        elif a[0] == "del scheduler":
                            self.db.IUD("delete from core_scheduler where ID = %s" % (a[1]))
                            self.db.commit()
                            self.senddata([["OK"]])
                        elif a[0] == "execute":
                            self.db.IUD("insert into core_execute (COMMAND) values ('%s')" % (a[1]))
                            self.db.commit()
                            self.senddata([["OK"]])
                        elif a[0] == "get app info":
                            self.sendcursor(("select COMM "
                                             "  from app_controls "
                                             "where ID = %s") % (a[1]))
                        elif a[0] == "get groups list":
                            self.sendcursor("select ID, TYP, COMM "
                                            "  from media_groups "
                                            "order by TYP, COMM")
                        elif a[0] == "edit groups list":
                            if a[1] == "-1":
                                self.db.IUD("insert into media_groups (TYP, COMM) values (1, '%s')" % (a[2]))
                                row_id = self.db.last_insert_id()
                            else:
                                self.db.IUD("update media_groups set COMM = '%s' where ID = %s" % (a[2], a[1]))
                                row_id = -1
                            self.db.commit()
                            self.senddata([["%s" % (row_id)]])
                            self._add_to_queue(20, row_id)
                        elif a[0] == "del groups list":
                            self.db.IUD("delete from media_groups where ID = %s" % (a[1]))
                            self.db.IUD("delete from media_lib_2_group where GROUP_ID = %s" % (a[1]))
                            self.db.commit()
                            self.senddata([["OK"]])
                            self._add_to_queue(20, -1)
                        elif a[0] == "get groups cross":
                            if a[1] == "-1":
                                self.sendcursor("select l.ID "
                                                "  from media_lib l "
                                                " where not exists (select 1 from media_lib_2_group g where g.LIB_ID = l.ID)")
                            else:
                                self.sendcursor(("select LIB_ID "
                                                 "  from media_lib_2_group "
                                                 " where GROUP_ID = %s") % (a[1]))
                        elif a[0] == "add groups cross":
                            self.db.IUD("delete from media_lib_2_group where LIB_ID = %s and GROUP_ID = %s" % (a[1], a[2]))
                            self.db.IUD("insert into media_lib_2_group (LIB_ID, GROUP_ID) values (%s, %s)" % (a[1], a[2]))
                            self.db.commit()
                            self.senddata([["OK"]])
                            self._add_to_queue(21, a[2])
                        elif a[0] == "del groups cross":
                            self.db.IUD("delete from media_lib_2_group where LIB_ID = %s and GROUP_ID = %s" % (a[1], a[2]))
                            self.db.commit()
                            self.senddata([["OK"]])
                            self._add_to_queue(21, a[2])
                        else:
                            self.senddata([["OK"]])
                            self._print(a)
                else:
                    break
            except Exception as e:
                self._print("    error: " + str(e))
                break
        
        try:
            self.conn.close()
        except:
            self._print("error: self.conn.close()")
        
        try:
            self.db.IUD("delete from app_control_sess where APP_CONTROL_ID = %s" % (self.app_id))
            self.db.IUD("delete from app_control_queue where APP_CONTROL_ID = %s" % (self.app_id))
            self.db.commit()
        except Exception as e:
            self._print("ERROR 1: " + str(e))        
        self.db = False
        self._print("DISCONNECT META [%s]" % self.acceptData[1][0])
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
        l = self.sendcursor(("select ID, NAME, COMM, APP_CONTROL, VALUE "
                             "  from core_variables order by COMM"))
        self._print("    load pack [%s bytes]" % (l))
        self._sess(True)

    def _add_to_queue(self, typ, value, value2 = 0, target = None):
        for r in self.app_sessions:
            if r[2] != b'':
                if target == None or r[0] == target:
                    self.db.IUD("insert into app_control_queue (APP_CONTROL_ID, TYP, VALUE, VALUE_2) values (%s, %s, %s, %s)" % (r[0], typ, value, value2))

    def _sync(self):
        self.senddata(self.db.variable_changes())

    def _sess(self, nosend = False):
        sess = self.db.select("select c.ID, c.COMM, s.IP"
                              "  from app_controls c, app_control_sess s "
                              " where s.APP_CONTROL_ID = c.ID "
                              "order by 1")
        if self.app_sessions != sess:
            self.app_sessions = sess
            
        if not nosend:
            self.senddata(self.app_sessions)

    def _media_queue(self):
        queueSql = ("select q.ID, q.TYP, q.VALUE, q.VALUE_2, m.APP_CONTROL_ID, m.TITLE, m.FILE_NAME, m.FILE_TYPE"
                    "  from app_control_queue q, media_lib m "
                    " where q.VALUE = m.ID"
                    "   and q.APP_CONTROL_ID = %s"
                    "   and q.TYP in (0, 1) "
                    "union all "
                    "select q.ID, q.TYP, q.VALUE, q.VALUE_2, q.APP_CONTROL_ID, '' TITLE, '' FILE_NAME, 0 FILE_TYPE"
                    "  from app_control_queue q"
                    " where q.APP_CONTROL_ID = %s"
                    "   and q.TYP in (2, 10, 20, 21) "
                    "order by 1" % (self.app_id, self.app_id))
        queue = self.db.select(queueSql)
        self.senddata(queue)
        if len(queue) > 0:
            self.db.IUD("delete from app_control_queue "
                        " where APP_CONTROL_ID = %s"
                        "   and ID <= %s"% (self.app_id, queue[-1::][0][0]))
            self.db.commit()

    def _parse_media_type(self, file_name):
        ext = file_name.split(".")[-1::][0].upper()
        for i in range(len(self.media_exts)):
            try:
                self.media_exts[i].index(ext)
                return i + 1
            except:
                pass
        return 0

    def _parse_media_title(self, file_name):
        f = file_name.split("\\")
        title = f[-1::][0]
        try:
            title = f[-2::][0] + " - " + title
        except:
            pass
        try:
            title = f[-3::][0] + " - " + title
        except:
            pass
        return title

    def _print(self, text):
        print("[%s] %s" % (time.strftime("%d-%m-%Y %H:%M:%S"), text))

class SoundThread(threading.Thread):
    def __init__(self, accept, owner):
        threading.Thread.__init__(self)
        self.acceptData = accept
        self.conn = accept[0]
        self.owner = owner
        self._print("CONNECT SOUND [%s]" % accept[1][0])        
        
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
            except Exception as e:
                #print("sound error %s" % (e))
                break

        try:
            self.conn.close()
        except:
            pass
        
        if stream:
            stream.stop_stream()
            stream.close()
        p.terminate()
        self._print("DISCONNECT SOUND: %s" % self.acceptData[1][0])
        threads = self.owner.threads
        del(threads[threads.index(self)])

    def _print(self, text):
        print("[%s] %s" % (time.strftime("%d-%m-%Y %H:%M:%S"), text))


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
                self.sock = socket.socket()
                self.sock.bind(("", self.port))
                print("binding for port %s OK" % (self.port))
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
