from base_form import BaseForm
from widgets import TextField

class Page7(BaseForm):
    ACTION = "page7"
    VIEW = "page7.tpl"
        
    def __init__(self):
        super().__init__()

    def create_widgets(self):
        pass
