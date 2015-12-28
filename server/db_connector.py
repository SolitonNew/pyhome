import mysql.connector
import time
from datetime import datetime

class DBConnnector(object):
    MYSQL_DB_NAME = "smarthome"
    MYSQL_USER = "smarthome"
    MYSQL_PASS = "smarthomepass"
    
    def __init__(self):
        self.mysqlConn = mysql.connector.connect(host="localhost",
                                                 database=self.MYSQL_DB_NAME,
                                                 user=self.MYSQL_USER,
                                                 password=self.MYSQL_PASS)
        
        self.query("SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED")
        
        self.lastQueueId = self.load_last_queue_id()                
        self.load_controllers()

    def query(self, sql, vars = []):
        q = self.mysqlConn.cursor()
        q.execute(sql, vars)
        return q

    def commit(self):
        self.mysqlConn.commit()

    def load_controllers(self):
        self.controllers = []
        q = self.query("select * from core_controllers order by ID")
        row = q.fetchone()
        while row is not None:
            self.controllers += [row]
            row = q.fetchone()
        q.close()
        
    def load_last_queue_id(self):
        q = self.query("select MAX(ID) from core_queue")
        row = q.fetchone()
        q.close()
        return row[0]

    def load_queue(self):
        queue = []
        q = self.query("select ID, CONTROLLER_ID, TYP "
                       "  from core_queue "
                       " where ID > %s "
                       "order by ID", [self.lastQueueId])
        row = q.fetchone()
        while row is not None:
            queue += [[row[1], row[2]]]
            self.lastQueueId = row[0]
            row = q.fetchone()
        q.close()
        return queue

    def append_scan_rom(self, dev_id, rom):
        data = [dev_id] + rom
        q = self.query("select count(*)"
                       "  from core_ow_devs"
                       " where CONTROLLER_ID = %s"
                       "   and ROM_1 = %s"
                       "   and ROM_2 = %s"
                       "   and ROM_3 = %s"
                       "   and ROM_4 = %s"
                       "   and ROM_5 = %s"
                       "   and ROM_6 = %s"
                       "   and ROM_7 = %s"
                       "   and ROM_8 = %s", data)
        row = q.fetchone()
        q.close()
        if row[0] == 0:
            q = self.query("insert into core_ow_devs "
                           "(CONTROLLER_ID, ROM_1, ROM_2, ROM_3, ROM_4, ROM_5, ROM_6, ROM_7, ROM_8)"
                           " values "
                           "(%s, %s, %s, %s, %s, %s, %s, %s, %s)", data)
            self.commit()
            q.close()
            return True        
        return False
