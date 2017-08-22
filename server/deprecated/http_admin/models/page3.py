from base_form import BaseForm
from widgets import Tree

class Page3(BaseForm):
    ACTION = "page3"
    VIEW = "page3.tpl"

    def create_widgets(self):
        ls = Tree("PLAN_LIST", "ID", "PARENT_ID", "NAME", "select ID, PARENT_ID, NAME from plan_parts order by ORDER_NUM")
        self.add_widget(ls)
