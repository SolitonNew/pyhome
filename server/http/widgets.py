class WidgetBase(object):
    def __init__(self, id):
        self.id = id

    def html(self):
        return "WidgetBase"

class TextField(WidgetBase):
    def __init__(self, id, text):
        super().__init__(id)
        self.text = text

    def html(self):
        return self.text

class ListField(WidgetBase):
    def __init__(self, id, keyIndex, labelIndex, selectedKey, data):
        super().__init__(id)
        self.keyIndex = keyIndex
        self.labelIndex = labelIndex
        self.data = data
        self.selectedKey = selectedKey

    def html(self):
        res = []
        for row in self.data:
            s = row[self.labelIndex]
            if type(s) == bytearray:
                s = str(s, "utf-8")
            sel = ""
            if row[self.keyIndex] == self.selectedKey:
                sel = " selected"
            res += ["<option value=\"%s\"%s>%s</option>" % (row[self.keyIndex], sel, s)]
        return "".join(res)
        return res    


class TabControl(WidgetBase):
    def __init__(self, id, tabClosed = False):
        super().__init__(id)
        self.tabClosed = tabClosed
        self.tabs = []
        self.btnCloseTpl = "<button type=\"button\" onMousedown=\"close_@ID@_tab(@NUM@);stop_mouse_events(event);return false;\">X</button>"

    def add_tab(self, label, url):
        self.tabs += [{'label':label,
                       'url':url}]

    def _gen_tabs(self):
        if not self.tabs:
            return ""
        res = []
        i = 1
        btnClose = ""
        if self.tabClosed:
            btnClose = self.btnCloseTpl
        for tab in self.tabs:
            res += ["<div id=\"%s_tab_%s\" class=\"page_tab\" onClick=\"select_%s_tab(%s)\">" % (self.id, i, self.id, i)]
            res += [tab['label']]
            res += [btnClose.replace("@NUM@", str(i))]
            res += ["</div>"]
            i += 1

        return "".join(res)

    def _gen_pages(self):
        if not self.tabs:
            return ""        
        res = []
        i = 1
        for t in self.tabs:
            res += "<div id=\"%s_page_%s\" class=\"page_data\">" % (self.id, i), "</div>"
            i += 1
        return "".join(res)

    def _gen_js(self):
        js = ("<script type=\"text/javascript\">"
              ""
              "var @ID@_tabs = [''@URLS@];"
              ""
              "var @ID@_btn_close_tpl = '@CLOSE_TPL@';"
              ""
              "function select_@ID@_tab(num) {"              
              "   if ($('#@ID@_tab_' + num).hasClass('page_tab_sel'))"
              "      return ;"
              "   "
              "   for (var i = 1; i < @ID@_tabs.length; i++) {"
              "      $('#@ID@_tab_' + i).removeClass('page_tab_sel');"
              "      $('#@ID@_page_' + i).css('display', 'none');"
              "   }"
              "   "
              "   $('#@ID@_tab_' + num).addClass('page_tab_sel');"
              "   $('#@ID@_page_' + num).fadeIn(300);"
              "   "
              "   if ($('#@ID@_page_' + num).html() == '')"
              "      $.ajax({url:window.@ID@_tabs[num]}).done(function (data) {"
              "         $('#@ID@_page_' + num).html(data);"
              "      })"
              "}"
              ""
              "function append_@ID@_tab(label, url) {"
              "   var i = @ID@_tabs.indexOf(url);"
              "   if (i > 0) {"
              "      select_@ID@_tab(i);"
              "      return;"
              "   }"
              "   i = @ID@_tabs.length;"
              "   @ID@_tabs[i] = url;"
              "   var btn = @ID@_btn_close_tpl.replace('@NUM@', i);"
              "   $('#@ID@_tab_list').append('<div id=\"@ID@_tab_' + i + '\" class=\"page_tab\" onClick=\"select_@ID@_tab(' + i + ')\">' + label + btn + '</div>');"
              "   $('#@ID@_page_list').append('<div id=\"@ID@_page_' + i + '\" class=\"page_data\"></div>');"
              "   "
              "   select_@ID@_tab(i);"
              "}"
              ""
              "function close_@ID@_tab(num) {"              
              "   @ID@_tabs[num] = '';"
              "   if ($('#@ID@_tab_' + num).hasClass('page_tab_sel')) {"
              "      var i;"
              "      for (i = num; i > 0; i--) {"
              "         if (@ID@_tabs[i] != '') {"
              "            select_@ID@_tab(i);"
              "            break;"
              "         }"
              "      }"
              "      for (i = num; i < @ID@_tabs.length; i++) {"
              "         if (@ID@_tabs[i] != '') {"
              "            select_@ID@_tab(i);"
              "            break;"
              "         }"
              "      }"
              "   }"
              "   $('#@ID@_tab_' + num).remove();"              
              "   $('#@ID@_page_' + num).remove();"              
              "}"
              ""
              "$(document).ready(function () {"
              "   select_@ID@_tab(1);"
              "})"
              "</script>")

        urls = []
        try:
            for tab in self.tabs:
                urls += [",'", tab['url'], "'"]
        except:
            pass        
        urls = "".join(urls)        
        
        if self.tabClosed:
            js = js.replace("@CLOSE_TPL@", self.btnCloseTpl)
        else:
            js = js.replace("@CLOSE_TPL@", "")
        js = js.replace("@ID@", str(self.id))
        js = js.replace("@URLS@", urls)            
        
        return js
        
    def html(self):        
        res = ("<table class=\"tab_control\" cellpadding=\"0\" cellspacing=\"0\">"
               "<tr>"
                   "<td id=\"@ID@_tab_list\">@TABS@</td>"
               "</tr>"
               "<tr>"
                   "<td id=\"@ID@_page_list\" height=\"100%\">@PAGES@</td>"
               "</tr>"
               "</table>")

        res = res.replace("@ID@", str(self.id))
        res = res.replace("@TABS@", self._gen_tabs())
        res = res.replace("@PAGES@", self._gen_pages())

        return self._gen_js() + res


class Grid(WidgetBase):
    def __init__(self, id, sql):
        super().__init__(id)
        self.columns = []
        self.sql = sql

    def _gen_js(self):
        js = ("<script type=\"text/javascript\">"
              "function @ID@_refresh() {"
              "   $.ajax({url:'@PAGE@?WIDGET_@ID@=true'}).done(function (data) {"
              "      $('#@ID@_data').html(data);"
              "   });"
              "};"
              ""
              "$(document).ready(function () {"
              "   $('#@ID@_header_top').height($('#@ID@_header_table').height());"              
              "   @ID@_refresh();"              
              "});"
              "</script>")

        js = js.replace("@ID@", str(self.id))
        js = js.replace("@PAGE@", self.parentForm.ACTION)
        
        return js

    def add_column(self, title, field, width, visible=True, func=None):
        self.columns += [{'title': title,
                          'field': field,
                          'width': width,
                          'visible': visible,
                          'func': func}]

    def _gen_cell(self, data, width):
        res = ["<td width=\"%s\">" % width]
        res += ["<div style=\"width:%spx;\">" % (width)]
        res += [data]
        res += ["</div>"]
        res += ["</td>"]

        return "".join(res)

    def _gen_header(self):
        res = ["<table id=\"%s_header_table\" class=\"grid_header\" cellpadding=\"0\" cellspacing=\"0\">" % self.id]
        res += "<tr>"
        for col in self.columns:
            if col['visible']:
                res += [self._gen_cell(col['title'], col['width'])]
        res += "</tr>"
        res += "</table>"
        return "".join(res)

    def _gen_data(self):
        res = ["<table class=\"grid_data\" cellpadding=\"0\" cellspacing=\"0\">"]
        q = self.parentForm.db.query(self.sql)
        data = q.fetchall()
        fields = q.column_names
        q.close()
        for row in data:
            res += "<tr>"
            for i in range(len(self.columns)):
                if self.columns[i]['visible']:                    
                    f = self.columns[i]['func']
                    field = fields.index(self.columns[i]["field"])
                    if f:
                        v = f(i, row)
                    else:
                        if type(row[field]) == bytearray:
                            v = str(row[field], "utf-8")
                        else:
                            v = str(row[field])
                    res += [self._gen_cell(v, self.columns[i]['width'])]
            res += "</tr>"
        res += "</table>"
        return "".join(res)

    def query(self):        
        q = self.parentForm.param("WIDGET_%s" % self.id)
        if q:
            return self._gen_data()
    
    def html(self):
        try:
            res = ("<table class=\"grid_control\" cellpadding=\"0\" cellspacing=\"0\">"
                   "<tr>"
                       "<td style=\"position:relative;background-color: #eeeeee;\">"
                           "<div id=\"@ID@_header_top\" style=\"position:relative;width:100%;\">"
                               "<div id=\"@ID@_header\" style=\"position:absolute;width:100%;overflow-x:hidden;\">"
                               "@HEADER@"
                               "</div>"
                           "</div>"
                       "</td>"
                   "</tr>"
                   "<tr>"
                       "<td style=\"position:relative;height:100%;\" valign=\"top\">"
                           "<div style=\"position:relative;width:100%;height:100%;\">"
                               "<div id=\"@ID@_data\" class=\"grid_data_content\" onScroll=\"$('#@ID@_header_table').css('left', -$(this).scrollLeft() + 'px')\">"
                               "</div>"
                           "</div>"
                       "</td>"
                   "</tr>"
                   "</table>")

            res = res.replace("@ID@", self.id)
            res = res.replace("@HEADER@", self._gen_header())
            #res = res.replace("@DATA@", self._gen_data())
        except Exception as e:
            return "Ошибка в виджете Grid: %s" % e.args

        return self._gen_js() + res


class List(WidgetBase):
    def __init__(self, id, field, sql, func=None):
        super().__init__(id)
        self.field = field
        self.sql = sql
        self.func = func

    def _gen_js(self):
        js = ("<script type=\"text/javascript\">"
              "function @ID@_refresh() {"
              "   $.ajax({url:'@PAGE@?WIDGET_@ID@=true'}).done(function (data) {"
              "      $('#@ID@_data').html(data);"
              "   });"
              "};"
              ""
              "$(document).ready(function () {"
              "   $('#@ID@_header_top').height($('#@ID@_header_table').height());"              
              "   @ID@_refresh();"              
              "});"
              "</script>")

        js = js.replace("@ID@", str(self.id))
        js = js.replace("@PAGE@", self.parentForm.ACTION)
        
        return js

    def _gen_cell(self, data, is_func):
        res = ["<td width=\"100%\">"]
        if not is_func:
            res += ["<div style=\"width:100%;\">"]
        res += [data]
        if not is_func:
            res += ["</div>"]
        res += ["</td>"]

        return "".join(res)

    def _gen_data(self):
        res = ["<table class=\"list_data\" cellpadding=\"0\" cellspacing=\"0\">"]
        q = self.parentForm.db.query(self.sql)
        data = q.fetchall()
        fields = q.column_names
        q.close()
        field = fields.index(self.field)
        
        for row in data:
            res += "<tr>"
            if self.func:
                v = self.func(row)
            else:
                if type(row[field]) == bytearray:
                    v = str(row[field], "utf-8")
                else:
                    v = str(row[field])
            res += [self._gen_cell(v, self.func)]
            res += "</tr>"
        res += "</table>"
        return "".join(res)

    def query(self):        
        q = self.parentForm.param("WIDGET_%s" % self.id)
        if q:
            return self._gen_data()
    
    def html(self):
        try:
            res = ("<div id=\"@ID@_data\" class=\"list_control\">"
                   "</div>")

            res = res.replace("@ID@", self.id)
        except Exception as e:
            return "Ошибка в виджете List: %s" % e.args

        return self._gen_js() + res
