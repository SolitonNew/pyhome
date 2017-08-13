from base_form import BaseForm
from widgets import TextField
from widgets import Grid
from widgets import Tree

class Page6(BaseForm):
    ACTION = "page6"
    VIEW = "page6.tpl"
        
    def __init__(self):
        super().__init__()

    def create_widgets(self):
        variableSql = ("select s.* "
                       "  from core_scheduler s ")

        grid = Grid("SCHEDULER_LIST", "ID", variableSql)

        grid.add_column("ID", "ID", 50, visible=False)
        grid.add_column("Описание", "COMM", 250, sort="asc")
        grid.add_column("Следующее действие", "ACTION_DATETIME", 90, sort="on")
        grid.add_column("Действие", "ACTION", 300, sort="on")
        grid.add_column("Переодичность", "INTERVAL_TYPE", 500, sort="on", func=self.column_interval_func)
        grid.add_column("Включено", "ENABLE", 100, sort="on", func=self.column_enable_func)
        self.add_widget(grid)
        self.SCHEDULER_LIST = grid;

    def column_interval_func(self, index, row):
        fields = self.SCHEDULER_LIST.func_fields
        t_list = ["Каждый день", "Каждую неделю", "Каждый месяц", "Каждый год"]
        typ = row[fields.index("INTERVAL_TYPE")]
        res = "%s в: <b>%s</b>" % (t_list[typ], str(row[fields.index("INTERVAL_TIME_OF_DAY")], "utf-8"))

        if typ == 0:
            pass
        elif typ in [1, 2, 3]:
            res += " день: <b>%s</b>" % str(row[fields.index("INTERVAL_DAY_OF_TYPE")], "utf-8")
        
        return res

    def column_enable_func(self, index, row):
        fields = self.SCHEDULER_LIST.func_fields
        v_list = ["Не выполнять", "Выполнять"]
        res = v_list[row[fields.index("ENABLE")]]
        return res

    def query(self, query_type):
        if query_type == "set_value":
            self.db.IUD("call CORE_SET_VARIABLE(%s, %s, null)" % (self.param('key'), self.param('value')))
            self.db.commit()
