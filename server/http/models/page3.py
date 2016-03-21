from base_form import BaseForm
from widgets import Tree

class Page3(BaseForm):
    ACTION = "page3"
    VIEW = "page3.tpl"

    def create_widgets(self):
        ls = Tree("PLAN_LIST", "ID", "PARENT_ID", "NAME", "select ID, PARENT_ID, NAME from plan_parts order by ORDER_NUM")
        self.add_widget(ls)

    def row_handler(self, row):
        label = str(row[1], "utf-8")
        id = str(row[0])
        res = ["<div style=\"width:100%;\" onMousedown=\"SCRIPT_VIEW_TABS_append('" + label + "', 'scripteditor?key=" + id + "')\">"]
        res += [label]
        res += ["</div>"]
        return "".join(res)
