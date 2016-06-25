from base_form import BaseForm
from widgets import TextField
import sys
import hashlib

try:
    sys.path.index('/home/pyhome/server')
except:
    sys.path += ['/home/pyhome/server']        
from config_utils import generate_config_file

class SystemDialog(BaseForm):
    ACTION = "system_dialog"
    VIEW = "system_dialog.tpl"

    def create_widgets(self):
        self.add_widget(TextField("SYNC_STATUS", self.db.get_property("SYNC_STATE")))

        # Прикинем потребление системы для единого БП
        i = self.calc_currently()
        self.add_widget(TextField("CURRENTLY", "%sА (%sВт)" % (i, i * 12)))

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

    def calc_currently(self):        
        I = 0.09 * 2 # Две платы pyb 90mA
        I += 2.5 * 5 / 12 / 0.8 # Orange Pi (I * 5V / 12V / KPD 80%)
        
        # Релюхи 12VDC-SL-S  30mA
        for row in self.db.select("select count(1) from core_variables where ROM = 'pyb'"):
            I += row[0] * 0.03

        for row in self.db.select("select sum(t.CONSUMING) "
                                  "  from core_ow_devs d, core_ow_types t "
                                  " where d.ROM_1 = t.CODE"):
            I += row[0] / 1000 # Переводим в амперы
            
        return round(I, 3)
