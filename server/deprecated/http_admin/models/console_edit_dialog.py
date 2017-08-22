from base_form import BaseForm
import time
from widgets import TextField
from widgets import ListField

class ConsoleEditDialog(BaseForm):
    ACTION = "console_edit_dialog"
    VIEW = "console_edit_dialog.tpl"

    def create_widgets(self):
        KEY = self.param("key")
        
        row = self.db.select("select ID, NAME, COMM, TYP, PINCODE "
                             "  from app_consoles where ID = %s" % KEY)        
        if row:
            row = row[0]
            NAME = str(row[1], "utf-8")
            COMM = str(row[2], "utf-8")
            TYP = row[3]
            try:
                if row[4] > 0:
                    PINCODE = str(row[4])
                else:
                    PINCODE = ""
            except:
                PINCODE = ""
        else:
            NAME, COMM, TYP, PINCODE = ("", "", 0, "")
            
        self.add_widget(TextField("KEY", KEY))
        self.add_widget(TextField("NAME", NAME))
        self.add_widget(TextField("COMM", COMM))
        self.add_widget(ListField("TYP", 0, 1, TYP, [[0, "Настольный ПК"], [1, "Смартфон"], [2, "Планшет"]]))
        self.add_widget(TextField("PINCODE", PINCODE))

    def query(self, query_type):
        if query_type == "update":
            sql = ""
            pincode = self.param_str('PINCODE')
            if pincode == "":
                pincode = "NULL"
            if self.param('KEY') == '-1':
                sql = ("insert into app_consoles "
                       "   (NAME, COMM, TYP, PINCODE) "
                       "values "
                       "   ('%s', '%s', '%s', %s)")

                sql = sql % (self.param_str('NAME'),
                             self.param_str('COMM'),
                             self.param_str('TYP'),
                             pincode)
            else:
                sql = ("update app_consoles "
                       "   set NAME = '%s',"
                       "       COMM = '%s',"
                       "       TYP = '%s',"
                       "       PINCODE = %s"
                       " where ID = %s")
            
                sql = sql % (self.param_str('NAME'),
                             self.param_str('COMM'),
                             self.param_str('TYP'),
                             pincode,
                             self.param_str('KEY'))            

            try:
                self.db.IUD(sql)
                self.db.commit()
                return "OK"
            except Exception as e:
                self.db.rollback()
                if e.args[0] == 1062:
                    return "WARNING: PINCODE уже занят."
                else:
                    return "ERROR: {}".format(e.args)

        elif query_type == "delete":
            try:
                key = self.param("KEY")
                self.db.IUD("delete from app_console_parts where CONSOLE_ID = %s" % (key))
                self.db.IUD("delete from app_consoles where ID = %s" % (key))
                self.db.commit()
                return "OK"
            except Exception as e:
                self.db.rollback()
                return "ERROR: {}".format(e.args)
