from base_form import BaseForm
from widgets import TextField

class AppLogin(BaseForm):
    ACTION = "app_login"
    VIEW = "app_login.tpl"
        
    def __init__(self):
        super().__init__()

    def create_widgets(self):
        self.add_widget(TextField("IS_MOBILE", str(self.owner.isAndroid()).lower()))

    def query(self, query_type):
        for rec in self.db.select("select ID, TYP from app_consoles where PINCODE = %s" % (query_type)):            
            self.owner.create_session(rec)
            return "OK"
        return ""
