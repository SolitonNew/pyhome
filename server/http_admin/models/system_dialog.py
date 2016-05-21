from base_form import BaseForm
from widgets import TextField
import sys
import hashlib

try:
    sys.path.index('/home/administrator/pyhome/server')
except:
    sys.path += ['/home/administrator/pyhome/server']        
from config_utils import generate_config_file

class SystemDialog(BaseForm):
    ACTION = "system_dialog"
    VIEW = "system_dialog.tpl"

    def create_widgets(self):
        self.add_widget(TextField("SYNC_STATUS", self.db.get_property("SYNC_STATE")))

    def query(self, query_type):
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
                    self.db.set_property("SYNC_HASH", self.get_config_hash())
                return "START_TERMINAL"
            elif query_type == "SYNC_CHECK":
                if self.get_config_hash() != self.db.get_property("SYNC_HASH"):
                    return "NOT SYNC"
                else:
                    return "OK"
        except Exception as e:
            return "ERROR: %s" % e.args

    def get_config_hash(self):
        m = hashlib.md5()
        m.update(generate_config_file(self.db).encode("utf-8"))
        return m.hexdigest()
