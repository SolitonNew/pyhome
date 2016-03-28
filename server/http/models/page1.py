from base_form import BaseForm
from widgets import TextField
from widgets import Grid
from widgets import Tree

class Page1(BaseForm):
    ACTION = "page1"
    VIEW = "page1.tpl"
        
    def __init__(self):
        super().__init__()

    def create_widgets(self):
        ls = Tree("VARIABLE_GROUPS", "ID", "PARENT_ID", "NAME", "select ID, PARENT_ID, NAME from plan_parts order by ORDER_NUM", self.varGroupAddAttr)
        self.add_widget(ls)
        
        variableSql = ("select v.ID, c.NAME C_NAME, v.ROM, v.DIRECTION, v.NAME, v.COMM, v.VALUE, v.CHANNEL"
                       "  from core_variables v, core_controllers c "
                       " where c.ID = v.CONTROLLER_ID ")

        grid = Grid("VARIABLE_LIST", "ID", variableSql)

        grid.add_column("ID", "ID", 50, visible=False)
        grid.add_column("Контроллер", "C_NAME", 150, sort="asc")
        grid.add_column("Тип", "ROM", 70, sort="on")
        grid.add_column("Только чтение", "DIRECTION", 60, sort="on", func=self.column_ro_func)
        grid.add_column("Идентификатор", "NAME", 200, sort="on")
        grid.add_column("Описание", "COMM", 200, sort="on")
        grid.add_column("Значение", "VALUE", 100, sort="on", func=self.column_val_func)
        grid.add_column("Канал", "CHANNEL", 100, sort="on")
        self.add_widget(grid)

    def column_ro_func(self, index, row):
        return ["ДА", "НЕТ"][row[3]]

    def column_val_func(self, index, row):
        if str(row[2], "utf-8") == "pyb" and row[3] == 1:
            if row[index]:
                lab = "ВКЛ."
                v = 0
            else:
                lab = "ВЫКЛ."
                v = 1

            click = "$.ajax({url:'page1?FORM_QUERY=set_value&key=%s&value=%s'})" % (row[0], v)
            return "<button onMousedown=\"%s\">%s</button>" % (click, lab)
        else:
            return "<div style=\"padding:3px;\">%s</div>" % (row[index])

    def _treeRecursive(self, parentNode):
        res = str(parentNode.id) + ','
        for node in parentNode.childs:
            res += self._treeRecursive(node)
        return res

    def varGroupAddAttr(self, tree, key):
        for node in tree.treeNodes:
            if node.id == key:
                return self._treeRecursive(node) + "0"
        return '0'

    def query(self, query_type):
        if query_type == "set_value":
            self.db.IUD("call CORE_SET_VARIABLE(%s, %s, null)" % (self.param('key'), self.param('value')))
            self.db.commit()
