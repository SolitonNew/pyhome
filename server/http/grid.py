class Grid(object):
    def __init__(self):
        self.columns = []
        self.data = []
    
    def add_column(self, label, width):
        self.columns += [[label, width]]

    def set_data(self, data):
        self.data = data

    def _gen_header(self):
        res = []
        res += "<TABLE class=\"grid\" cellpadding=\"0\" cellspacing=\"0\">"
        res += "<TR class=\"header\">"
        for col in self.columns:            
            res += "<TD style=\"width:%spx;\">" % col[1]
            res += "<DIV style=\"width:%spx;overflow:hidden;\">" % col[1]
            res += col[0]
            res += "</DIV>"
            res += "</TD>"
        res += "</TR>"
        res += "</TABLE>"        
        return "".join(res)

    def _gen_data(self):
        columns = self.columns
        res = []
        res += "<TABLE class=\"grid\" style=\"top:-1px;\" cellpadding=\"0\" cellspacing=\"0\">"
        for row in self.data:
            res += "<TR>"
            i = 0
            for cell in row:
                cw = 1
                if i < len(columns):
                    cw = columns[i][1]
                res += "<TD style=\"width:%spx;\">" % cw
                res += "<DIV style=\"width:%spx;overflow:hidden;\">" % cw
                res += cell
                res += "</DIV>"
                res += "</TD>"
                i += 1
            res += "</TR>"
        
        res += "</TABLE>"
        return "".join(res)

    def html(self, forRefresh = False):
        if forRefresh:
            return self._gen_data()

        res = []
        res += "<TABLE width=\"100%\" height=\"100%\" cellpadding=\"0\" cellspacing=\"0\">"
        res += "<TR><TD bgcolor=\"#eee\">"
        res += self._gen_header()
        res += "</TD></TR><TR><TD height=\"100%\" valign=\"top\">"
        res += "<div id=\"grid_data\" style=\"position:relative;overflow:hidden;overflow-y:auto;width:100%;height:100%;\">"        
        res += self._gen_data()
        res += "</div>"        
        res += "</TD></TR>"
        res += "</TABLE>"
        return "".join(res)
