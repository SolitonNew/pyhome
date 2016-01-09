import time

class BaseForm(object):
    def __init__(self, db, params):
        self.db = db
        self.params = params

    def load_view(self, action):
        f = open("skins" + action + ".html", 'r')
        buf = f.read()
        f.close()
        return buf

    def get_select_list(self, data, keyNum, labelNum, selKey = None):
        if selKey != None:
            selKey = str(selKey)
        else:
            selKey = ''
        
        res = []
        for row in data:
            label = row[labelNum]
            if type(label) == bytearray:
                label = str(label, "utf-8")
            else:
                label = str(label)
                
            key = row[keyNum]
            if type(key) == bytearray:
                key = str(key, "utf-8")
            else:
                key = str(key)

            if key == selKey:
                res += "<option value=\"%s\" selected>%s</option>" % (key, label)
            else:
                res += "<option value=\"%s\">%s</option>" % (key, label)
        return "".join(res)

    def get_param(self, name):
        try:
            res = self.params[name][0]
            if type(res) == bytearray:
                res = str(res, "utf-8")
            else:
                res = str(res)
            return res
        except:
            return ''

            

class Index(BaseForm):
    ACTION = "/index"

class VariableSettings(BaseForm):
    ACTION = "/variable_settings"
    
    def get(self):
        try:
            a = self.params['refresh_ow']
            key = self.get_param('key')

            controllers = self.db.select("select ID, NAME from core_controllers order by ID")

            self.db.set_property("RS485_COMMAND_INFO", "")
            self.db.set_property("RS485_COMMAND", "SCAN_OW")            
            for i in range(30):
                s = self.db.get_property("RS485_COMMAND_INFO")
                try:
                    s.index("TERMINAL EXIT")
                    break
                except:
                    pass
                time.sleep(1)            
            return self._load_ow_devs(key).encode("utf-8")
        except:
            pass
        
        try:
            a = self.params['form']
            return self._view()
        except:
            return self._process()


    def _load_ow_devs(self, selID):
        data = self.db.select("select ID, ROM_1, ROM_2, ROM_3, ROM_4, ROM_5, ROM_6, ROM_7, ROM_8 from core_ow_devs order by ID")
        ow_list = []
        for row in data:
            u = self.db.select("select count(*) c from core_variables where OW_ID = %s" % row[0])
            rom = []

            rom += ["[%s]  " % u[0]]
            
            for i in range(1, 9):
                s = hex(row[i])
                rom += s, " "
            del rom[len(rom) - 1]
                
            ow_list += [[row[0], "".join(rom)]]
        return self.get_select_list(ow_list, 0, 1, selID)

    def _view(self):
        buf = self.load_view(self.ACTION)
        KEY = self.get_param('key')        

        row = self.db.select("select ID, CONTROLLER_ID, ROM, DIRECTION, NAME, COMM, VALUE, CHANNEL, OW_ID "
                             "  from core_variables where ID = %s" % KEY)        
        if row:
            row = row[0]            
            CONTROLLER_ID = str(row[1])
            ROM = str(row[2], "utf-8")
            DIRECTION = str(row[3])
            NAME = str(row[4], "utf-8")
            COMM = str(row[5], "utf-8")
            VALUE = str(row[6])
            CHANNEL = str(row[7], "utf-8")
            OW_ID = row[8]
        else:
            CONTROLLER_ID, ROM, DIRECTION, NAME, COMM, VALUE, CHANNEL, OW_ID = ("", "", "", "", "", "", "", "")
        
        buf = buf.replace("@KEY@", KEY)
        buf = buf.replace("@CONTROLLER_LIST@", self.get_select_list(self.db.select("select ID, NAME from core_controllers order by ID"), 0, 1, CONTROLLER_ID))
        buf = buf.replace("@TYPE_LIST@", self.get_select_list([["ow"], ["pyb"], ["variable"]], 0, 0, ROM))
        buf = buf.replace("@OW_LIST@", self._load_ow_devs(OW_ID))        
        buf = buf.replace("@READ_ONLY_LIST@", self.get_select_list([['0', "ДА"], ['1', "НЕТ"]], 0, 1, DIRECTION))
        buf = buf.replace("@NAME@", NAME)        
        buf = buf.replace("@COMM@", COMM)
        buf = buf.replace("@VALUE@", VALUE)
        buf = buf.replace("@CHANNEL@", CHANNEL)
        
        return buf.encode("utf-8")

    def _process(self):
        OW_ID = self.get_param('VAR_OW')
        if OW_ID == "" or self.get_param('VAR_TYPE') != "ow":
            OW_ID = "null"
        sql = ""
        if self.get_param('VAR_KEY') == '-1':
            sql = ("insert into core_variables "
                   "   (CONTROLLER_ID, ROM, DIRECTION, NAME, COMM, CHANNEL, OW_ID) "
                   "values "
                   "   (%s, '%s', %s, '%s', '%s', '%s', %s)")

            sql = sql % (self.get_param('VAR_CONTROLLER'),
                         self.get_param('VAR_TYPE'),
                         self.get_param('VAR_READ_ONLY'),
                         self.get_param('VAR_NAME'),
                         self.get_param('VAR_COMM'),
                         self.get_param('VAR_CHANNEL'),
                         OW_ID)
        else:
            sql = ("update core_variables "
                   "   set CONTROLLER_ID = %s,"
                   "       ROM = '%s',"
                   "       DIRECTION = %s,"
                   "       NAME = '%s',"
                   "       COMM = '%s',"
                   "       CHANNEL = '%s',"
                   "       OW_ID = %s"
                   " where ID = %s")
            
            sql = sql % (self.get_param('VAR_CONTROLLER'),
                         self.get_param('VAR_TYPE'),
                         self.get_param('VAR_READ_ONLY'),
                         self.get_param('VAR_NAME'),
                         self.get_param('VAR_COMM'),
                         self.get_param('VAR_CHANNEL'),
                         OW_ID,
                         self.get_param('VAR_KEY'))
            

        try:
            self.db.IUD(sql)
            if self.get_param('VAR_TYPE') == 'variable':
                self.db.IUD("call CORE_SET_VARIABLE(%s, %s, %s)" %
                             (self.get_param('VAR_KEY'), self.get_param('VAR_VALUE'), 'null'))
            self.db.commit()
            return "OK".encode("utf-8")
        except:
            return "ERROR".encode("utf-8")



class SystemUtilites(BaseForm):
    ACTION = "/system_utilites"

    def get(self):
        try:
            a = self.params['terminal']
            buf = self.db.get_property("RS485_COMMAND_INFO")
            return buf.encode("utf-8")
        except:
            pass
        
        try:            
            a = self.params['query']            
            return self._process()
        except:
            return self._view()

    def _view(self):
        buf = self.load_view(self.ACTION)
        buf = buf.replace("@SYNC_STATUS@", self.db.get_property("SYNC_STATE"))
        return buf.encode("utf-8")    

    def _process(self):
        try:
            target_prop_name = ""
            target_prop_value = ""
            p = self.get_param('query')            
            if p == 'SYNC_TOGGLE':
                target_prop_name = "SYNC_STATE"
                target_prop_value = "RUN"
                if self.db.get_property(target_prop_name) == "RUN":
                    target_prop_value = "STOP"
                self.db.set_property(target_prop_name, target_prop_value)
                return self.db.get_property(target_prop_name).encode("utf-8")
            else:
                target_prop_name = "RS485_COMMAND"
                target_prop_value = p
                self.db.set_property("RS485_COMMAND_INFO", "")
                self.db.set_property(target_prop_name, target_prop_value)
                return "START_TERMINAL".encode("utf-8")
        except:
            return "ERROR".encode("utf-8")
