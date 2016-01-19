from urllib import parse

class BaseForm(object):
    ACTION = "index"
    VIEW = "index.tpl"
    
    def __init__(self):
        self._widgets = []        
        self.data_path = False
        self.url_data = False
        self.db = False        

    def create_widgets(self):
        pass

    def param(self, name):
        try:
            p = parse.parse_qs(self.url_data.query)
            res = p[name][0]
            if type(res) == bytearray:
                res = str(res, "utf-8")
            else:
                res = str(res)
            return res
        except:
            return False

    def param_list(self, name):
        try:
            p = parse.parse_qs(self.url_data.query)
            res = []
            for v in p[name]:
                if type(res) == bytearray:
                    res += [str(v, "utf-8")]
                else:
                    res += [str(v)]
            return res
        except:
            return False
        
    def param_str(self, name):
        v = self.param(name)
        if v:
            return v
        return ""

    def add_widget(self, widget):
        widget.parentForm = self        
        self._widgets += [widget]

    def query(self, query_type):
        return ""

    def get_view(self):
        res = ""
        try:
            for w in self._widgets:
                try:
                    s = w.query()
                    if s: return s
                except:
                    pass
            
            f = open(self.data_path + self.VIEW, 'r')
            res = f.read()
            for w in self._widgets:
                try:
                    res = res.replace("@%s@" % w.id, w.html())
                except Exception as e:
                    return "Ошибка в виджете '%s': %s" % (w.id, e.args)
            f.close()
        except Exception as e:
            res = "Шаблон формы не найден: %s" % e.args
        return res

    def run(self):
        q = self.param('FORM_QUERY')
        if q:
            return self.query(q)
        else:
            return self.get_view()
        
