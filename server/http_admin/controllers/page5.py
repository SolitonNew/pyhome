from base_form import BaseForm
from widgets import TabControl

class Page5(BaseForm):
    ACTION = "page5"
    VIEW = "page5.tpl"

    def create_widgets(self):
        tc = TabControl("STAT_TABS", position="bottom")
        tc.add_tab("Chart", "page5_1")
        tc.add_tab("Table", "page5_2")
        tc.add_tab("Summary", "page5_3")
        self.add_widget(tc)
