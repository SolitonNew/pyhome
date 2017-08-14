from base_form import BaseForm
import utils

class EventList(BaseForm):
    ACTION = "eventlist"
    VIEW = ""

    def get_view(self):
        return ""

    def query(self, query_type):
        if query_type == "last_id":
            for row in self.db.select("select CORE_GET_LAST_CHANGE_ID()"):
                return str(row[0])
        elif query_type == "list":
            data = self.db.select((" select c.CHANGE_DATE, v.COMM, c.VALUE, v.ROM, cc.LOG_LABEL, cc.DIM_LABEL"
                                   "   from core_variable_changes_mem c, core_variables v, core_variable_controls cc"
                                   "  where c.VARIABLE_ID = v.ID"
                                   "    and cc.ID = v.APP_CONTROL"
                                   " order by c.ID desc"
                                   " limit 50"))
            res = []
            for row in data:
                d = row[0].time()
                lab = "%s %s" % (str(row[4], "utf-8"), str(row[1], "utf-8"))
                val = utils.decode_variable_value(str(row[3], "utf-8"), round(row[2], 1))
                dim = str(row[5], "utf-8")
                res += "<div style=\"color:#fff;padding:3px 15px;\">"
                res += "<span style=\"color:#777;\">[%s]</span>&nbsp;&nbsp;'%s'&nbsp;&nbsp;%s&nbsp;%s" % (d, lab, val, dim)
                res += "</div>"

            return "".join(res)
            
        return ""        
