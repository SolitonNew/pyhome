import socket
import random
import time, datetime

class Connector():
    def __init__(self, app_id):
        self.app_id = app_id
        self.sock = socket.socket()
        self.sock.connect(("192.168.40.2", 8090))

    def close(self):
        self.sock.close()

    def query(self, packName, packData = ""):
        res = []
        sock = self.sock
        pack = "".join([packName, chr(1), packData, chr(2)])
        sock.sendall(pack.encode("cp1251"))
        line = []
        while True:
            l = sock.recv(1024).decode("cp1251")
            line += [l]
            try:
                l.index(chr(2))
                line = "".join(line)
                break
            except:
                pass
            
        for pack in line.split(chr(2))[:-1:]:
            cells = pack.split(chr(1))
            cols = int(cells[0])
            if cols > 0:
                res = [None] * ((len(cells) - 1) // cols)
                i = 1
                for c in range(len(res)):
                    row = [None] * cols
                    for v in range(cols):
                        row[v] = cells[i]
                        i += 1
                    res[c] = row
        return res
        
class ItemList():
    def __init__(self, data=None, labelIndex=0):
        self.data = data
        if data:
            self.LABEL = data[labelIndex]
        else:
            self.LABEL = ""

class VarItem():
    def __init__(self, data=None):
        if data:
            self.id = int(data[0])
            self.name = data[1]
            self.comm = data[2]
            self.typ = int(data[3])
            if data[4] == "None":
                self.value = None
            else:
                self.value = float(data[4])
            self.group = int(data[5])
        else:
            self.id = -1
            self.name = ''
            self.comm = ''
            self.typ = 0
            self.value = None
            self.group = -1
        
        self.link_id = -1
        self.link_value = None

        self.varData = []
        self.varDataRange = [None, None]
        
        self.LABEL = self.comm
        
        self._getVarData()

    def _getVarData(self):
        d = datetime.datetime.now()
        d = datetime.datetime(d.year, d.month, d.day).timestamp()
        self.varData = [None] * 240
        mi, ma = self.varDataRange
        r1 = random.randrange(-10, 10)
        r2 = random.randrange(20, 100)
        for t in range(240):
            x = d + t * 360
            y = random.randrange(r1, r2)
            self.varData[t] = [x, y]
            if mi == None or mi > y:
                mi = y
            if ma == None or ma < y:
                ma = y
        self.varDataRange = [mi, ma]
    
