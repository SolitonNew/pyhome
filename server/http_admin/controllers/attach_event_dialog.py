from base_form import BaseForm
import time
from widgets import TextField
from widgets import ListField

class AttachEventDialog(BaseForm):
    ACTION = "attach_event_dialog"
    VIEW = "attach_event_dialog.tpl"

    def create_widgets(self):
        self.add_widget(TextField('KEY', self.param('key')))
        data = self.db.select("select ID, NAME from core_variables order by NAME")
        links = []
        for row in self.db.select("select VARIABLE_ID from core_variable_events where SCRIPT_ID = '%s'" % self.param('key')):
            links += [row[0]]
        self.add_widget(ListField('VAR_LIST', 0, 1, links, data))

    def query(self, query_type):
        if query_type == 'attach':
            try:
                key = self.param('VAR_KEY')
                self.db.IUD("delete from core_variable_events where SCRIPT_ID = %s" % key)
                for v in self.param_list('VAR_LIST'):
                    self.db.IUD(("insert into core_variable_events "
                                 " (VARIABLE_ID, SCRIPT_ID, EVENT_TYPE) "
                                 "values"
                                 " (%s, %s, 0)") % (v, key))
                self.db.commit()
                return "OK"
            except Exception as e:
                return "%s" % (e.args,)
