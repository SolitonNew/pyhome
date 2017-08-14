from base_form import BaseForm
from widgets import List

class PageVideo(BaseForm):
    ACTION = "pageVideo"
    VIEW = "pageVideo.tpl"

    def create_widgets(self):
        ls = List("CAMERA_LIST", "ID", "NAME", "select ID, NAME from plan_video order by NAME")
        self.add_widget(ls)

    def query(self, query_type):
        if query_type == "URL":
            for rec in self.db.select("select URL from plan_video where ID = %s", [self.param_str('key')]):
                return str(rec[0], "utf-8")
        return ""
