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
        res += "<TABLE id=\"grid_head_scroll\" class=\"grid\" height=\"100%\" cellpadding=\"0\" cellspacing=\"0\">"
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
        res += "<TABLE id=\"grid_data_scroll\" class=\"grid\" style=\"top:-1px;\" cellpadding=\"0\" cellspacing=\"0\">"
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
        res += "<TABLE style=\"position:relative;width:100%;height:100%;\" cellpadding=\"0\" cellspacing=\"0\">"
        res += "<TR><TD height=\"50\" style=\"position:relative;\" bgcolor=\"#eee\">"
        res += "<div style=\"position:absolute;width:100%;height:100%;top:0px;left:0px;overflow-x:hidden;\">"                
        res += self._gen_header()
        res += "</div>"
        res += "</TD></TR><TR><TD style=\"position:relative;\" height=\"100%\" valign=\"top\">"
        res += "<div style=\"position:absolute;width:100%;height:100%;overflow:hidden;\">"        
        res += "<div id=\"grid_data\" style=\"position:relative;overflow:auto;width:100%;height:100%;\" onScroll=\"$('#grid_head_scroll').css('left', $('#grid_data_scroll').position().left + 'px');\">"
        res += self._gen_data()
        res += "</div>"
        res += "</div>"        
        res += "</TD></TR>"
        res += "</TABLE>"
        return "".join(res)
