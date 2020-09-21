from flask import render_template, request
from urllib import parse

class BaseForm(object):
    ACTION = "index"
    VIEW = "index.tpl"
    
    def __init__(self):
        self._widgets = []
        self.db = False

    def create_widgets(self):
        pass

    def param(self, name):
        try:
            if request.method == 'POST':
                return request.form[name]
            else:
                return request.args.get(name, '')
        except:
            return ""

    def param_list(self, name):
        try:
            if request.method == "POST":
                p = request.form.getlist(name)
            else:
                p = request.args.getlist(name)
            res = []
            for v in p:
                if type(res) == bytearray:
                    res += [str(v, "utf-8")]
                else:
                    res += [str(v)]
            return res
        except:
            return False
        
    def param_str(self, name):
        return self.param(name)

    def add_widget(self, widget):
        widget.parentForm = self        
        self._widgets += [widget]

    def query(self, query_type):
        return ""

    def _widget_data(self, name):
        for w in self._widgets:
            if w.id == name:
                return w.html()
        return ""

    def get_view(self):
        try:
            for w in self._widgets:
                try:
                    s = w.query()
                    if s: return s
                except Exception as e:
                    print("ERROR in widget %s %s " % (w.id, e.args,))
            return render_template(self.VIEW, widget=self._widget_data)
        except Exception as e:
            return "Шаблон формы не найден: %s" % e.args

    def run(self):
        q = self.param('FORM_QUERY')
        if q:
            return self.query(q)
        else:
            return self.get_view()        
