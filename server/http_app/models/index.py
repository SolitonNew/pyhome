from base_form import BaseForm
from widgets import TextField

class Index(BaseForm):
    ACTION = "index"
    VIEW = "index.tpl"
        
    def __init__(self):        
        super().__init__()

    def create_widgets(self):
        self.add_widget(TextField("IS_MOBILE", str(self.owner.isAndroid()).lower()))
        
        self.control_tpls = []
        for i in range(1, 8):
            self.control_tpls += [self._load_control_tpl(i)]

        rot = "true"
        if self.owner.SESSION_VALUE[1] == 0:
            col_count = 10
            row_count = 6
            rot = "false"
        elif self.owner.SESSION_VALUE[1] == 1:
            col_count = 4
            row_count = 6
        elif self.owner.SESSION_VALUE[1] == 2:
            col_count = 6
            row_count = 8

        tf = TextField("ROTATE", rot)
        self.add_widget(tf)                
        tf = TextField("CONTENT", self._gen_controls())
        self.add_widget(tf)
        tf = TextField("COLS", str(col_count))
        self.add_widget(tf)
        tf = TextField("ROWS", str(row_count))
        self.add_widget(tf)
        tf = TextField("CONTROL_META", str(self.control_meta))
        self.add_widget(tf)

        if (self.param('FORM_QUERY') == False):
            for rec in self.db.select("select MAX(ID) from core_variable_changes"):
                tf = TextField("CHANGE_MAX_ID", str(rec[0]))
                self.add_widget(tf)

    def _load_control_tpl(self, num):
        try:
            f = open("views/app/control_%s.tpl" % (num), "r")
            res = f.read()
            f.close()
        except:
            res = ''
        return res

    def _gen_controls(self):
        self.control_meta = []
        num = 1
        res = []
        for rec in self.db.select("select p.X, p.Y, p.W, p.H, v.ID, v.APP_CONTROL, v.COMM, v.VALUE, p.ORIENTATION "
                                  "  from app_console_parts p, core_variables v "
                                  " where p.CONSOLE_ID = %s "
                                  "   and p.VARIABLE_ID = v.ID" % (self.owner.SESSION_VALUE[0])):
            r = list(rec[:5])
            r += [rec[8]]
            self.control_meta += [r]

            tpl = self.control_tpls[rec[5] - 1]
            tpl = tpl.replace("@NUM@", str(num))
            tpl = tpl.replace("@CONTROL@", str(rec[5]))
            tpl = tpl.replace("@LABEL@", str(rec[6], "utf-8"))
            val = rec[7]
            if val == None:
                val = 0
            tpl = tpl.replace("@VALUE@", str(val))
            tpl = tpl.replace("@ID@", str(rec[4]))
            res += [tpl]
            num += 1
        
        return "".join(res)

    def query(self, query_type):
        if query_type in ["1", "3", "5", "7"]:
            self.db.IUD("call CORE_SET_VARIABLE(%s, %s, null)" % (self.param('key'), self.param('value')))
            self.db.commit()
            return self.param('value')
        if query_type == "changes":
            res = []
            res += ["@CHANGE_LOG@"]
            for rec in self.db.select("select ID, VARIABLE_ID, VALUE from core_variable_changes_mem where ID > %s" % (self.param('key'))):
                res += [str(rec[0]), ";"]
                res += [str(rec[1]), ";"]
                res += [str(rec[2])]
                res += ["#"]
            return "".join(res)
        return ""
