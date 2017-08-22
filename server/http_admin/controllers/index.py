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
        tab.add_tab("Переменные", "page1")
        tab.add_tab("Скрипты", "page2")
        tab.add_tab("Локация", "page3")
        tab.add_tab("Статистика", "page5")
        tab.add_tab("Расписание", "page6")
        tab.add_tab("Видеонаблюдение", "pageVideo")
        tab.add_tab("Схема", "page7")
        self.add_widget(tab)
