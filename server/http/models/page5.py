from base_form import BaseForm
from widgets import TabControl

class Page5(BaseForm):
    ACTION = "page5"
    VIEW = "page5.tpl"

    def create_widgets(self):
        tc = TabControl("STAT_TABS")
        tc.add_tab("График", "page5_1")
        tc.add_tab("Таблица", "page5_2")
        self.add_widget(tc)
