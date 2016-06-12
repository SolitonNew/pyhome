from base_form import BaseForm
import time
from widgets import TextField
from widgets import ListField
from widgets import TreeField

class VarEditDialog(BaseForm):
    ACTION = "var_edit_dialog"
    VIEW = "var_edit_dialog.tpl"

    def create_widgets(self):
        KEY = self.param_str("key")

        CONTROLLER_ID, ROM, DIRECTION, NAME, COMM, VALUE, CHANNEL, OW_ID, CONTROL = (1, "", "", "", "", "", "", "-1", "0")
        try:
            GROUP_ID = int(self.param_str("default_group"))
        except:
            GROUP_ID = -1

        for row in self.db.select("select ID, CONTROLLER_ID, ROM, DIRECTION, NAME, COMM, VALUE, CHANNEL, OW_ID, GROUP_ID, APP_CONTROL "
                                  "  from core_variables where ID = '%s'" % KEY):
            CONTROLLER_ID = row[1]
            ROM = str(row[2], "utf-8")
            DIRECTION = row[3]
            NAME = str(row[4], "utf-8")
            COMM = str(row[5], "utf-8")
            VALUE = str(row[6])
            CHANNEL = str(row[7], "utf-8")
            OW_ID = row[8]
            GROUP_ID = row[9]
            CONTROL = row[10]
            
        self.add_widget(TextField("KEY", KEY))
        self.add_widget(TextField("VAR_OW_KEY", str(OW_ID)))
        self.add_widget(ListField("VAR_CONTROLLER", 0, 1, CONTROLLER_ID, self.db.select("select ID, NAME from core_controllers order by NAME")))
        self.add_widget(ListField("TYPE_LIST", 0, 0, ROM, [["ow"], ["pyb"], ["variable"]]))
        self.add_widget(ListField("OW_LIST", 0, 1, OW_ID, self._load_ow_devs(CONTROLLER_ID)))
        self.add_widget(ListField("READ_ONLY_LIST", 0, 1, DIRECTION, [(0, "ДА"), (1, "НЕТ")]))
        self.add_widget(TextField("NAME", NAME))
        self.add_widget(TextField("COMM", COMM))
        self.add_widget(TextField("VALUE", VALUE))
        self.add_widget(TextField("CHANNEL", CHANNEL))
        self.add_widget(TreeField("VAR_GROUP_TREE", 0, 1, 2, GROUP_ID, self.db.select("select ID, PARENT_ID, NAME from plan_parts order by ORDER_NUM")))
        self.add_widget(ListField("VAR_CONTROL", 0, 1, CONTROL, [(0, "--//--")] + self.db.select("select ID, NAME from core_variable_controls order by ID")))

    def _load_ow_devs(self, controller_id):
        data = self.db.select("select ID, ROM_1, ROM_2, ROM_3, ROM_4, ROM_5, ROM_6, ROM_7, ROM_8 "
                              "  from core_ow_devs "
                              " where CONTROLLER_ID = %s "
                              "order by ID" % controller_id)
        ow_list = [[-1, "-- нет --"]]
        for row in data:
            u = self.db.select("select count(*) c from core_variables where OW_ID = %s" % row[0])
            rom = []

            rom += ["[%s]  " % u[0]]
            
            for i in range(1, 9):
                s = hex(row[i]).upper()
                if len(s) == 3:
                    s = s.replace("0X", "0x0")
                else:
                    s = s.replace("0X", "0x")
                rom += s, " "
            del rom[len(rom) - 1]
                
            ow_list += [[row[0], "".join(rom)]]
        return ow_list    

    def query(self, query_type):
        if query_type == "update":
            OW_ID = self.param_str('VAR_OW')
            if OW_ID == "" or self.param('VAR_TYPE') != "ow":
                OW_ID = "null"
            sql = ""
            if self.param_str('VAR_KEY') == '-1':
                sql = ("insert into core_variables "
                       "   (CONTROLLER_ID, ROM, DIRECTION, NAME, COMM, CHANNEL, OW_ID, GROUP_ID, APP_CONTROL) "
                       "values "
                       "   (%s, '%s', %s, '%s', '%s', '%s', %s, %s, %s)")

                sql = sql % (self.param_str('VAR_CONTROLLER'),
                             self.param_str('VAR_TYPE'),
                             self.param_str('VAR_READ_ONLY'),
                             self.param_str('VAR_NAME'),
                             self.param_str('VAR_COMM'),
                             self.param_str('VAR_CHANNEL'),                             
                             OW_ID,
                             self.param_str('VAR_GROUP'),
                             self.param_str('VAR_CONTROL'))
            else:
                sql = ("update core_variables "
                       "   set CONTROLLER_ID = '%s',"
                       "       ROM = '%s',"
                       "       DIRECTION = '%s',"
                       "       NAME = '%s',"
                       "       COMM = '%s',"
                       "       CHANNEL = '%s',"
                       "       OW_ID = %s,"
                       "       GROUP_ID = %s,"
                       "       APP_CONTROL = %s"
                       " where ID = %s")
            
                sql = sql % (self.param_str('VAR_CONTROLLER'),
                             self.param_str('VAR_TYPE'),
                             self.param_str('VAR_READ_ONLY'),
                             self.param_str('VAR_NAME'),
                             self.param_str('VAR_COMM'),
                             self.param_str('VAR_CHANNEL'),
                             OW_ID,
                             self.param_str('VAR_GROUP'),
                             self.param_str('VAR_CONTROL'),
                             self.param_str('VAR_KEY'))
            try:
                self.db.IUD(sql)
                if self.param_str('VAR_KEY') == "-1":
                    key_id = self.db._lastID
                else:
                    key_id = self.param('VAR_KEY')
                if self.param('VAR_TYPE') == 'variable':
                    self.db.IUD("call CORE_SET_VARIABLE(%s, %s, %s)" %
                                 (key_id, self.param('VAR_VALUE'), 'null'))
                self.db.commit()
                return "OK"
            except Exception as e:
                self.db.rollback()
                return "ERROR: {}".format(e.args)
            
        elif query_type == "delete":
            try:
                key = self.param("VAR_KEY")
                self.db.IUD("delete from core_variable_changes where VARIABLE_ID = %s" % (key))
                self.db.IUD("delete from core_variable_events where VARIABLE_ID = %s" % (key))
                self.db.IUD("delete from core_variables where ID = %s" % (key))
                self.db.commit()
                return "OK"
            except Exception as e:
                self.db.rollback()
                return "ERROR: {}".format(e.args)
            
        elif query_type == "reload_ow_devs":
            lf = ListField("OW_LIST", 0, 1, int(self.param("ow_key")), self._load_ow_devs(self.param("controller")))            
            return lf.html()
