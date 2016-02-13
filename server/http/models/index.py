from base_form import BaseForm
from widgets import TabControl

class Index(BaseForm):

    def __init__(self):
        super().__init__()
        self.ACTION = "index"
        self.VIEW = "index.tpl"

    def create_widgets(self):
        tab = TabControl("TAB_CONTROL")
        tab.add_tab("Переменные", "page1")
        tab.add_tab("Скрипты", "page2")
        tab.add_tab("Локация", "page3")
        tab.add_tab("Консоли", "page4")
        tab.add_tab("Статистика", "page5")
        self.add_widget(tab)
        
