from base_form import BaseForm
from widgets import TextField
from widgets import Grid

class OWManager(BaseForm):
    ACTION = "ow_manager"
    VIEW = "ow_manager.tpl"

    def create_widgets(self):
        #variableSql = ("select w.ID, c.NAME, HEX(w.ROM_1, w.ROM_2, w.ROM_3, w.ROM_4, w.ROM_5, w.ROM_6, w.ROM_7, w.ROM_8, t.CHANNELS, w.VALUE, '' F1, '' F2 "
        variableSql = ("select w.ID, c.NAME, CONCAT(HEX(w.ROM_1), ' ', HEX(w.ROM_2), ' ', HEX(w.ROM_3), ' ', HEX(w.ROM_4), ' ', HEX(w.ROM_5), ' ', HEX(w.ROM_6), ' ', HEX(w.ROM_7), ' ', HEX(w.ROM_8)) ROM, t.CHANNELS, w.VALUE, '' F1 "
                       "  from core_controllers c, "
                       "       core_ow_devs w LEFT JOIN core_ow_types t ON t.CODE = w.ROM_1 "
                       " where c.ID = w.CONTROLLER_ID")

        grid = Grid("OW_MANAGER_GRID", "ID", variableSql)
        grid.add_column("ID", "ID", 50, visible=False)
        grid.add_column("Controller", "NAME", 150, sort="asc")
        grid.add_column("ROM", "ROM", 290, sort="asc", func=self._rom_to_hex)
        grid.add_column("Channels", "CHANNELS", 100, sort="on")
        grid.add_column("Joined Variables", "F1", 190, func=self._vars)        
        self.add_widget(grid)        

    def _rom_to_hex(self, index, row):
        res = []
        for r in row[index].split(' '):
            res += [self._to_hex(r)]
            res += [" "]
        return "".join(res[:-1])

    def _to_hex(self, val):
        val = val.upper()
        if len(val) == 1:
            val = "0x0%s" % val
        else:
            val = "0x%s" % val
        return val

    def _vars(self, index, row):
        res = []
        for r in self.db.select("select ID, NAME "
                                "  from core_variables "
                                " where OW_ID=%s" % row[0]):
            res += ["<div style=\"padding:2px;\"><a class=\"ow_variable\" href=\"\" onClick=\"show_window('var_edit_dialog?key=", str(r[0]), "', true);return false;\">", str(r[1], "utf-8"), "</a></div>"]

        return "".join(res)

    def _check_or_add_var(self, ow_id, channel, controller_id):
        for row in self.db.select(("select v.ID "
                                   "  from core_variables v"
                                   " where v.ROM = 'ow'"
                                   "   and v.OW_ID = %s"
                                   "   and v.CHANNEL = '%s'") % (ow_id, channel)):
            return

        self.db.IUD("insert into core_variables"
                    "  (CONTROLLER_ID, ROM, NAME, OW_ID, CHANNEL) "
                    "values"
                    "  (%s, 'ow', 'OW_%s_%s', %s, '%s')" % (controller_id, ow_id, channel, ow_id, channel))
        self.db.commit()

    def query(self, query_type):
        if query_type == "create_vars_for_free":
            for row in self.db.select("select d.ID, t.CHANNELS, d.CONTROLLER_ID "
                                      "  from core_ow_devs d, core_ow_types t"
                                      " where d.ROM_1 = t.CODE"):
                channels = str(row[1], "utf-8")
                if channels == "":
                    self._check_or_add_var(row[0], '', row[2])
                else:
                    for chan in channels.split(","):
                        self._check_or_add_var(row[0], chan, row[2])
            return "OK"
        elif query_type == "delete":
            try:
                key = self.param('key')            
                self.db.IUD("update core_variables set OW_ID = -1 where OW_ID = %s" % (key))
                self.db.IUD("delete from core_ow_devs where ID = %s" % (key))
                self.db.commit()
                return "OK"
            except Exception as e:
                return "ERROR: %s" % (e.args)
