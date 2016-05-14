from base_form import BaseForm
from widgets import TextField
import sys

class SystemDialog(BaseForm):
    ACTION = "system_dialog"
    VIEW = "system_dialog.tpl"

    def create_widgets(self):
        self.add_widget(TextField("SYNC_STATUS", self.db.get_property("SYNC_STATE")))

    def query(self, query_type):
        try:
            sys.path.index('/home/administrator/pyhome/server')
        except:
            sys.path += ['/home/administrator/pyhome/server']
        from config_utils import generate_config_file
        
        try:
            if query_type == "load_terminal":
                return self.db.get_property("RS485_COMMAND_INFO")
            elif query_type == "SYNC_TOGGLE":
                v = "RUN"
                if self.db.get_property("SYNC_STATE") == v:
                    v = "STOP"
                self.db.set_property("SYNC_STATE", v)                
                return self.db.get_property("SYNC_STATE")
            elif (query_type == "SCAN_OW" or
                  query_type == "CONFIG_UPDATE" or
                  query_type == "REBOOT_CONTROLLERS"):
                self.db.set_property("RS485_COMMAND_INFO", "")
                self.db.set_property("RS485_COMMAND", query_type)
                if query_type == "CONFIG_UPDATE":
                    self.db.set_property("SYNC_HASH", str(hash(generate_config_file(self.db))))
                return "START_TERMINAL"
            elif query_type == "SYNC_CHECK":
                if str(hash(generate_config_file(self.db))) != self.db.get_property("SYNC_HASH"):
                    return "NOT SYNC"
                else:
                    return "OK"
        except Exception as e:
            return "ERROR: %s" % e.args
