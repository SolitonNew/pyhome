import mysql.connector

class DBConnector(object):
    MYSQL_DB_NAME = "smarthome"
    MYSQL_USER = "smarthome"
    MYSQL_PASS = "smarthomepass"
    
    def __init__(self):
        self.mysqlConn = mysql.connector.connect(host="localhost",
                                                 database=self.MYSQL_DB_NAME,
                                                 user=self.MYSQL_USER,
                                                 password=self.MYSQL_PASS)
        
        self.query("SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED")
        
    def query(self, sql, vars = []):
        q = self.mysqlConn.cursor()
        q.execute(sql, vars)
        return q

    def commit(self):
        self.mysqlConn.commit()

    def select(self, sql, vars = []):
        res = []        
        q = self.query(sql, vars)
        try:
            row = q.fetchone()
            while row:
                res += [row]
                row = q.fetchone()
        except:
            pass
        q.close()
        return res

    def IUD(self, sql, vars = []):
        q = self.query(sql, vars)
        q.close()

    def get_property(self, name):        
        data = self.select("select VALUE from core_propertys where NAME='%s'" % name)
        if data:
            return str(data[0][0], "utf-8")
        else:
            return ''

    def set_property(self, name, value):
        self.IUD("update core_propertys set VALUE = '%s' where NAME = '%s'" % (value, name))
        self.commit()
