from base_form import BaseForm

from widgets import List
from widgets import Grid

class Page5_2(BaseForm):
    ACTION = "page5_2"
    VIEW = "page5_2.tpl"

    def create_widgets(self):
        ls = List("STAT_VAR_LIST", "ID", "TITLE", "select ID, CONCAT(COMM, ' [', NAME, ']') TITLE from core_variables order by COMM")
        self.add_widget(ls)

        gr = Grid("STAT_VAR_DATA", "ID", "select ID, CHANGE_DATE, VALUE from core_variable_changes", detail=True)
        gr.add_column("ID", "ID", 60, False)
        gr.add_column("CHANGE_DATE", "CHANGE_DATE", 130, sort="asc")
        gr.add_column("VALUE", "VALUE", 100)
        self.add_widget(gr)

    def query(self, query_type):
        if query_type == "delete":
            self.db.IUD("delete from core_variable_changes where ID = %s" % (self.param("key")))
            self.db.commit()
            return "OK"
