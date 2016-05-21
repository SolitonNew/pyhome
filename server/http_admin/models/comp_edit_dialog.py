from base_form import BaseForm
import time
from widgets import TextField
from widgets import ListField

class CompEditDialog(BaseForm):
    ACTION = "comp_edit_dialog"
    VIEW = "comp_edit_dialog.tpl"

    def create_widgets(self):
        KEY = self.param("KEY")
        for row in self.db.select("select W, H from app_console_parts where ID = " + KEY):
            WIDTH = str(row[0])
            HEIGHT = str(row[1])
        self.add_widget(TextField("KEY", KEY))
        self.add_widget(TextField("WIDTH", WIDTH))
        self.add_widget(TextField("HEIGHT", HEIGHT))

    def query(self, query_type):
        if query_type == "update":
            sql = ("update app_console_parts "
                    "   set W = '%s',"
                    "       H = '%s'"
                    " where ID = %s")
            sql = sql % (self.param_str('WIDTH'),
                         self.param_str('HEIGHT'),
                         self.param_str('KEY'))
            try:
                self.db.IUD(sql)
                self.db.commit()
                return "OK"
            except Exception as e:
                self.db.rollback()
                return "ERROR: {}".format(e.args)

        elif query_type == "delete":
            try:
                key = self.param("KEY")
                self.db.IUD("delete from app_console_parts where ID = %s" % (key))
                self.db.commit()
                return "OK"
            except Exception as e:
                self.db.rollback()
                return "ERROR: {}".format(e.args)
