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
        
        variableSql = ("select v.ID, c.NAME C_NAME, v.ROM, v.DIRECTION, v.NAME, v.COMM, v.APP_CONTROL, v.VALUE, v.CHANNEL "
                       "  from core_variables v, core_controllers c "
                       " where c.ID = v.CONTROLLER_ID ")

        grid = Grid("VARIABLE_LIST", "ID", variableSql)

        grid.add_column("ID", "ID", 50, visible=False)
        grid.add_column("Controller", "C_NAME", 150, sort="asc")
        grid.add_column("Type", "ROM", 70, sort="on")
        grid.add_column("Readonly", "DIRECTION", 60, sort="on", func=self.column_ro_func)
        grid.add_column("Name", "NAME", 200, sort="asc")
        grid.add_column("Comment", "COMM", 200, sort="on")
        grid.add_column("Device", "APP_CONTROL", 100, sort="on", func=self.column_control_func)
        grid.add_column("Value", "VALUE", 100, sort="on", func=self.column_val_func)
        grid.add_column("Channel", "CHANNEL", 100, sort="on")
        self.add_widget(grid)

        self.controls = [(0, b"--//--")] + self.db.select("select ID, NAME from core_variable_controls order by ID")

    def column_ro_func(self, index, row):
        return ["YES", "NO"][row[3]]

    def column_control_func(self, index, row):
        try:
            return "<div style=\"padding:3px;\">%s</div>" % (self.controls[row[index]][1].decode("utf-8"))
        except:
            return "<div style=\"padding:3px;\">%s</div>" % (row[index])        

    def column_val_func(self, index, row):
        try:
            r_2 = str(row[2], "utf-8")
        except:
            r_2 = row[2]
        
        if r_2 == "pyb" and row[3] == 1:
            if row[index]:
                lab = "ON"
                v = 0
            else:
                lab = "OFF"
                v = 1

            click = "$.ajax({url:'page1?FORM_QUERY=set_value&key=%s&value=%s'})" % (row[0], v)
            return "<button onMousedown=\"%s\">%s</button>" % (click, lab)
        else:
            if row[index] != None:
                return "<div style=\"padding:3px;\">%s</div>" % (row[index])
            else:
                return "<div style=\"padding:3px;\"></div>"
    
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
