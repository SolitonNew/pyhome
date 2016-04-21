from base_form import BaseForm
from widgets import List
from widgets import TabControl

class Page4(BaseForm):
    ACTION = "page4"
    VIEW = "page4.tpl"

    def create_widgets(self):
        ls = List("CONSOLE_LIST", "ID", "NAME", "select ID, NAME from app_consoles order by NAME")
        self.add_widget(ls)

        tab = TabControl("CONSOLE_PALETTE")
        tab.add_tab("Управление", "page4?FORM_QUERY=1")
        tab.add_tab("Контроль", "page4?FORM_QUERY=2")
        self.add_widget(tab)

    def query(self, query_type):
        if query_type == "DESIGN":
            key = self.param_str('key')
            for row in self.db.select("select TYP from app_consoles where ID = %s" % (key)):
                f = open("views/designs/design_%s.tpl" % (row[0] + 1), "r")
                res = f.read()
                f.close()
                
                if row[0] == 0:
                    res = res.replace("@DESIGN_TABLE@", self._gen_design_table(0, 10, 6, key))
                elif row[0] == 1:
                    res = res.replace("@DESIGN_TABLE_1@", self._gen_design_table(0, 4, 6, key))
                    res = res.replace("@DESIGN_TABLE_2@", self._gen_design_table(1, 6, 4, key))
                elif row[0] == 2:
                    res = res.replace("@DESIGN_TABLE_1@", self._gen_design_table(0, 6, 8, key))
                    res = res.replace("@DESIGN_TABLE_2@", self._gen_design_table(1, 8, 6, key))
                return res
            return ""
        elif (query_type == "insert_comp") or (query_type == "move_comp"):
            var = self.param_str('var')
            row = self.param_str('row')
            col = self.param_str('col')
            console = self.param_str('console')
            orientation = self.param_str('orientation')
            try:
                if query_type == "insert_comp":
                    self.db.IUD(("insert into app_console_parts "
                                 " (CONSOLE_ID, ORIENTATION, X, Y, W, H, VARIABLE_ID)"
                                 "values"
                                 " ('%s', '%s', '%s', '%s', '%s', '%s', '%s')") %
                                 (console, orientation, col, row, 1, 1, var))
                else:
                    if (self.param_str("copy") == "0"):
                        self.db.IUD(("update app_console_parts "
                                     "   set ORIENTATION = '%s', "
                                     "       X = '%s', "
                                     "       Y = '%s' "
                                     " where ID = '%s' ") %
                                     (orientation, col, row, var))
                    else:
                        for rec in self.db.select("select CONSOLE_ID, W, H, VARIABLE_ID from app_console_parts where ID = %s" % (var)):
                            console = rec[0]
                            w = rec[1]
                            h = rec[2]
                            var_id = rec[3]                            
                            self.db.IUD(("insert into app_console_parts "
                                         " (CONSOLE_ID, ORIENTATION, X, Y, W, H, VARIABLE_ID)"
                                         "values"
                                         " ('%s', '%s', '%s', '%s', '%s', '%s', '%s')") %
                                         (console, orientation, col, row, w, h, var_id))
                self.db.commit()
                return "OK"
            except Exception as e:
                self.db.rollback()
                return "ERROR: {}".format(e.args)
        elif query_type == "1":
            return self._comp_list("select ID, COMM, APP_CONTROL "
                                   "  from core_variables "
                                   " where APP_CONTROL in (1, 3, 5)"
                                   " order by COMM")
        elif query_type == "2":
            return self._comp_list("select ID, COMM, APP_CONTROL "
                                   "  from core_variables "
                                   " where APP_CONTROL in (4, 6)"
                                   " order by COMM")
        else:
            return "DUMY"
        
    def _comp_list(self, sql):
        res = ["<div style=\"position:absolute;left:0px;top:0px;width:100%;height:100%;overflow:auto;cursor:default;line-height:0;\">"]
        for row in self.db.select(sql):           
            res += ["<div class=\"CONSOLE_PALETTE_cell\" onMouseDown=\"start_comp_drag(event, %s, $(this).html());return false;\">" % (row[0])]
            res += ["<img src=\"views/images/control_%s.png\" style=\"padding-top:10px;\"><br>" % (row[2])]
            res += [str(row[1], "utf-8"), "<br>"]
            res += ["</div>"]
        res += ["</div>"]
        return "".join(res)

    def _gen_design_table(self, orientation, cols, rows, consol):
        res = ["<div style=\"position:relative;\">"]
        res += ["<table class=\"design_table\" cellspacing=\"1\" cellpadding=\"0\">"]
        for r in range(rows):
            res += ["<tr>"]
            for c in range(cols):
                res += ["<td><div id=\"comp_%s_%s_%s\"></div></td>" % (orientation, r, c)]
            res += ["</tr>"]
        res += ["</table>"]

        comp_size = 81;
        res += ["<div style=\"position:absolute;left:0px;top:0px;width:100%;height:100%;\">"]
        for rec in self.db.select(("select p.ID, p.X, p.Y, p.W, p.H, v.COMM, v.APP_CONTROL "
                                   "  from app_console_parts p, core_variables v "
                                   " where p.VARIABLE_ID = v.ID"
                                   "   and p.CONSOLE_ID = %s"
                                   "   and p.ORIENTATION = %s") % (consol, orientation)):
            x = rec[1] * comp_size + 1
            y = rec[2] * comp_size + 1
            w = rec[3] * comp_size - 1
            h = rec[4] * comp_size - 1
            
            label = str(rec[5], "utf-8")

            if rec[6] > 0:
                label = "<img src=\"views/images/control_%s.png\" style=\"padding-top:10px;\"><br>%s" % (rec[6], label)
            
            res += ["<div class=\"comp_item\" style=\"left:%spx;top:%spx;width:%spx;height:%spx;\"" % (x, y, w, h)]
            res += [" onMouseDown=\"comp_mouse_down(event, %s);return false;\" " % (rec[0])]
            res += [" onMouseMove=\"comp_mouse_move(this, event, %s, '%s');return false;\" " % (rec[0], str(rec[5], "utf-8"))]
            res += [" onMouseUp=\"comp_mouse_up(event, %s);return false;\" " % (rec[0])]
            res += [">%s</div>" % (label)]
        res += ["</div>"]
        res += ["</div>"]
        
        return "".join(res)
