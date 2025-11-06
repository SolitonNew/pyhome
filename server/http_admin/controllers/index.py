from base_form import BaseForm
from widgets import TextField
from widgets import TabControl

class Index(BaseForm):
    ACTION = "index"
    VIEW = "index.tpl"
        
    def __init__(self):
        super().__init__()

    def create_widgets(self):
        tf = TextField("VERSION", "%s" % self.app.config['VERSION'])
        self.add_widget(tf)
        
        tab = TabControl("TAB_CONTROL")
        tab.add_tab("Variables", "page1")
        tab.add_tab("Scripts", "page2")
        tab.add_tab("Statistics", "page5")
        tab.add_tab("Schedule", "page6")
        self.add_widget(tab)
