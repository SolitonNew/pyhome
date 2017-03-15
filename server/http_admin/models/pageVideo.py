from base_form import BaseForm
from widgets import List

class PageVideo(BaseForm):
    ACTION = "pageVideo"
    VIEW = "pageVideo.tpl"

    def create_widgets(self):
        ls = List("CAMERA_LIST", "ID", "NAME", "select ID, NAME from plan_video order by NAME")
        self.add_widget(ls)
