from base_form import BaseForm
from widgets import TextField
from widgets import Grid

class OWManager(BaseForm):
    ACTION = "ow_manager"
    VIEW = "ow_manager.tpl"

    def create_widgets(self):
        variableSql = ("select w.ID, c.NAME, w.ROM_1, w.ROM_2, w.ROM_3, w.ROM_4, w.ROM_5, w.ROM_6, w.ROM_7, w.ROM_8, t.CHANNELS, w.VALUE, '' F1, '' F2, '' F3 "
                       "  from core_ow_devs w, core_controllers c, core_ow_types t "
                       " where c.ID = w.CONTROLLER_ID"
                       "   and t.CODE = w.ROM_1")

        grid = Grid("OW_MANAGER_GRID", variableSql)
        grid.add_column("ID", "ID", 50, visible=False)
        grid.add_column("Контроллер", "NAME", 150, sort="asc")
        grid.add_column("ROM", "F3", 290, sort="asc", func=self._rom_to_hex)        
        grid.add_column("Каналы", "CHANNELS", 100, sort="on")
        grid.add_column("Связанные переменные", "F1", 190, func=self._vars)        
        grid.add_column("Текущее значение", "VALUE", 70, sort="on")
        grid.add_column("", "F2", 70, func=self._delete_column)
        self.add_widget(grid)

    def _rom_to_hex(self, index, row):
        res = []
        for r in row[2:10]:
            res += [self._to_hex(r)]
            res += [", "]
        return "".join(res[:-1])

    def _to_hex(self, val):
        val = hex(int(val)).upper()
        if len(val) == 3:
            val = val.replace("0X", "0x0")
        else:
            val = val.replace("0X", "0x")
        return val

    def _vars(self, index, row):
        res = []
        for r in self.db.select("select ID, NAME "
                                "  from core_variables "
                                " where OW_ID=%s" % row[0]):
            res += ["<div style=\"padding:2px;\"><a class=\"ow_variable\" href=\"\" onClick=\"show_window('var_edit_dialog?key=", str(r[0]), "', true);return false;\">", str(r[1], "utf-8"), "</a></div>"]

        return "".join(res)

    def _delete_column(self, index, row):
        return "<button onClick=\"del_ow(%s);\">Удалить</button>" % (row[0])

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
