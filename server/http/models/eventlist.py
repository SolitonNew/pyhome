from base_form import BaseForm
from models import utils

class EventList(BaseForm):
    ACTION = "eventlist"
    VIEW = ""

    def get_view(self):
        data = self.db.select((" select c.CHANGE_DATE, v.COMM, c.VALUE, v.ROM"
                               "   from core_variable_changes c, core_variables v"
                               "  where c.VARIABLE_ID = v.ID"
                               " order by c.ID desc"
                               " limit 100"))
        res = []
        for row in data:
            d = row[0].time()
            val = utils.decode_variable_value(str(row[3], "utf-8"), row[2])
            res += "<div style=\"color:#fff;padding:3px 15px;\">"
            res += "<span style=\"color:#777;\">[%s]</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'%s'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s" % (d, str(row[1], "utf-8"), val)
            res += "</div>"

        return "".join(res)
