from base_form import BaseForm
from widgets import List
from widgets import TabControl

class Page2(BaseForm):
    ACTION = "page2"
    VIEW = "page2.tpl"

    def create_widgets(self):
        ls = List("SCRIPT_LIST", "ID", "COMM", "select ID, COMM from core_scripts order by COMM", self.row_handler)
        self.add_widget(ls)

        self.add_widget(TabControl("SCRIPT_VIEW_TABS", True))

    def row_handler(self, row):
        label = str(row[1], "utf-8")
        id = str(row[0])
        res = ["<div style=\"width:100%;\" onMousedown=\"SCRIPT_VIEW_TABS_append('" + label + "', 'scripteditor?key=" + id + "')\">"]
        res += [label]
        res += ["</div>"]
        return "".join(res)

    def query(self, query_type):
        if query_type == "create_script":
            label = "Новый скрипт"
            self.db.IUD("insert into core_scripts (COMM) values ('%s')" % (label))
            self.db.commit()
            return "%s;%s;" % (label, self.db.lastID())