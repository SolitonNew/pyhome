from base_form import BaseForm
import time
from widgets import TextField
from widgets import ListField

class StatPanelDialog(BaseForm):
    ACTION = "stat_panel_dialog"
    VIEW = "stat_panel_dialog.tpl"

    def create_widgets(self):
        KEY = self.param("KEY")
        row = self.db.select(("select NAME, TYP, SERIES_1, SERIES_2, SERIES_3, SERIES_4 "
                              "  from web_stat_panels where ID = %s") % KEY)
        if row:
            row = row[0]
            NAME = str(row[0], "utf-8")
            TYP = row[1]
            SERIES_1 = row[2]
            SERIES_2 = row[3]
            SERIES_3 = row[4]
            SERIES_4 = row[5]
        else:
            NAME, TYP, SERIES_1, SERIES_2, SERIES_3, SERIES_4 = ("", 0, -1, -1, -1, -1)

        var_list = self.db.select("select ID, CONCAT(COMM, ' [', NAME, ']') from core_variables order by 2")

        var_list = [[-1, "-- нет --"]] + var_list

        self.add_widget(TextField("NAME", NAME))
        self.add_widget(TextField("KEY", KEY))
        self.add_widget(ListField("TYPS", 0, 1, TYP, [(0, "Линейная"), (1, "Точечная"), (2, "Столбчатая"), (3, "Линейчастая")]))
        self.add_widget(ListField("SERIES_1", 0, 1, SERIES_1, var_list))
        self.add_widget(ListField("SERIES_2", 0, 1, SERIES_2, var_list))
        self.add_widget(ListField("SERIES_3", 0, 1, SERIES_3, var_list))
        self.add_widget(ListField("SERIES_4", 0, 1, SERIES_4, var_list))

    def query(self, query_type):
        print('QUERY')
        if query_type == "update":
            sql = ("update web_stat_panels "
                   "   set NAME = '%s',"
                   "       TYP = '%s',"
                   "       SERIES_1 = %s,"
                   "       SERIES_2 = %s,"
                   "       SERIES_3 = %s,"
                   "       SERIES_4 = %s "
                   " where ID = %s")
            sql = sql % (self.param_str('NAME'),
                         self.param_str('TYP'),
                         self.param_str('SERIES_1'),                         
                         self.param_str('SERIES_2'),
                         self.param_str('SERIES_3'),
                         self.param_str('SERIES_4'),
                         self.param_str('KEY'))
            try:
                self.db.IUD(sql)
                self.db.commit()
                return "OK"
            except Exception as e:
                return "ERROR: %s" % (e.args, )
