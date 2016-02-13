import json

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
            if type(self.selectedKey) == list:
                try:
                    self.selectedKey.index(row[self.keyIndex])
                    sel = " selected"
                except:
                    pass
            else:    
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
        self.btnCloseTpl = "<button type=\"button\" onMousedown=\"@ID@_close(@NUM@);stop_mouse_events(event);return false;\">X</button>"

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
            res += ["<div id=\"%s_tab_%s\" class=\"page_tab\" onClick=\"%s_select(%s)\">" % (self.id, i, self.id, i)]
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
              "function @ID@_select(num) {"              
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
              "function @ID@_append(label, url) {"
              "   var i = @ID@_tabs.indexOf(url);"
              "   if (i > 0) {"
              "      @ID@_select(i);"
              "      return;"
              "   }"
              "   i = @ID@_tabs.length;"
              "   @ID@_tabs[i] = url;"
              "   var btn = @ID@_btn_close_tpl.replace('@NUM@', i);"
              "   $('#@ID@_tab_list').append('<div id=\"@ID@_tab_' + i + '\" class=\"page_tab\" onClick=\"@ID@_select(' + i + ')\"><span id=\"@ID@_tab_title_' + i + '\">' + label + '</span>' + btn + '</div>');"
              "   $('#@ID@_page_list').append('<div id=\"@ID@_page_' + i + '\" class=\"page_data\"></div>');"
              "   "
              "   @ID@_select(i);"
              "}"
              ""
              "function @ID@_rename(label, url) {"
              "   var i = @ID@_tabs.indexOf(url);"
              "   $('#@ID@_tab_title_' + i).html(label);"
              "}"
              ""
              "function @ID@_num(url) {"
              "   return @ID@_tabs.indexOf(url);"
              "}"
              ""              
              "function @ID@_close(num) {"              
              "   @ID@_tabs[num] = '';"
              "   if ($('#@ID@_tab_' + num).hasClass('page_tab_sel')) {"
              "      var i;"
              "      for (i = num; i > 0; i--) {"
              "         if (@ID@_tabs[i] != '') {"
              "            @ID@_select(i);"
              "            break;"
              "         }"
              "      }"
              "      for (i = num; i < @ID@_tabs.length; i++) {"
              "         if (@ID@_tabs[i] != '') {"
              "            @ID@_select(i);"
              "            break;"
              "         }"
              "      }"
              "   }"
              "   $('#@ID@_tab_' + num).remove();"              
              "   $('#@ID@_page_' + num).remove();"              
              "}"
              ""
              "$(document).ready(function () {"
              "   @ID@_select(1);"
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
              ""
              "var @ID@_sorts = [@SORTS@];"
              "var @ID@_prev_data = '';"
              ""              
              "function @ID@_refresh() {"
              "   sorts = @ID@_sorts.join(',');"
              "   $.ajax({url:'@PAGE@?WIDGET_@ID@=true&sorts=' + sorts}).done(function (data) {"
              "      if (@ID@_prev_data != data) { "
              "         @ID@_prev_data = data; "
              "         $('#@ID@_data').html(data);"
              "      }"
              "   });"
              "}"
              ""
              "function @ID@_sort(num) {"
              "   var col_sort = @ID@_sorts[num];"
              "   if (col_sort) {"              
              "      col_sort++;"
              "      if (col_sort > 2) {"
              "         col_sort = 0;"
              "      }"
              "   } else {"
              "      col_sort = 1;"
              "   }"
              "   @ID@_sorts[num] = col_sort;"
              "   "
              "   if (col_sort == 2) {"
              "      $('#@ID@_' + num + '_up').css('display', 'block');"
              "   } else {"
              "      $('#@ID@_' + num + '_up').css('display', 'none');"
              "   }"
              "   "
              "   if (col_sort == 1) {"
              "      $('#@ID@_' + num + '_down').css('display', 'block');"
              "   } else {"
              "      $('#@ID@_' + num + '_down').css('display', 'none');"
              "   }"
              "   "
              "   @ID@_refresh();"
              "}"
              ""              
              "$(document).ready(function () {"
              "   $('#@ID@_header_top').height($('#@ID@_header_table').height());"
              "   @ID@_refresh();"              
              "});"
              "</script>")

        js = js.replace("@ID@", str(self.id))
        js = js.replace("@PAGE@", self.parentForm.ACTION)

        sorts = []
        for col in self.columns:
            if col['sort'] == "asc":
                sorts += ["1,"]
            elif col['sort'] == "desc":
                sorts += ["2,"]
            else:
                sorts += [","]
        js = js.replace("@SORTS@", "".join(sorts))
        
        return js

    def add_column(self, title, field, width, visible=True, sort = "off", func=None):
        self.columns += [{'title': title,
                          'field': field,
                          'width': width,                          
                          'visible': visible,
                          'sort': sort,
                          'func': func}]

    def _gen_cell_header(self, data, width, index):
        if self.columns[index]["sort"] != "off":
            res = ["<td width=\"%s\" onClick=\"%s_sort(%s);\">" % (width, self.id, index)]
        else:
            res = ["<td width=\"%s\">" % width]
        res += ["<div style=\"width:%spx;\">" % (width)]
        res += ["<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">"]
        res += ["<tr>"]
        res += ["<td width=\"100%\" style=\"border: none;\">"]
        res += [data]
        res += ["</td>"]
        res += ["<td style=\"border: none;\">"]
        style_up = "none";
        style_down = "none";
        if self.columns[index]["sort"] == "desc":
            style_up = "block";
        if self.columns[index]["sort"] == "asc":
            style_down = "block";
        res += ["<img id=\"%s_%s_up\" src=\"widget_resources/sort_up.png\" style=\"display:%s;\">" % (self.id, index, style_up)]
        res += ["<img id=\"%s_%s_down\" src=\"widget_resources/sort_down.png\" style=\"display:%s;\">" % (self.id, index, style_down)]
        res += ["</td>"]
        res += ["</tr>"]
        res += ["</table>"]
        res += ["</div>"]
        res += ["</td>"]

        return "".join(res)

    def _gen_header(self):
        res = ["<table id=\"%s_header_table\" class=\"grid_header\" cellpadding=\"0\" cellspacing=\"0\">" % self.id]
        res += "<tr>"
        i = 0
        for col in self.columns:
            if col['visible']:
                res += [self._gen_cell_header(col['title'], col['width'], i)]
            i += 1
        res += "</tr>"
        res += "</table>"
        return "".join(res)

    def _gen_cell_data(self, data, width):
        res = ["<td width=\"%s\">" % width]
        res += ["<div style=\"width:%spx;\">" % (width)]
        res += [data]
        res += ["</div>"]
        res += ["</td>"]

        return "".join(res)    

    def _gen_data(self, sorts = ""):
        res = ["<table class=\"grid_data\" cellpadding=\"0\" cellspacing=\"0\">"]
        orders = []
        if sorts:
            i = 1
            for sort in sorts.split(","):
                if sort == '1':
                    orders += ["%s asc, " % i]
                elif sort == '2':
                    orders += ["%s desc, " % i]
                i += 1
        orders = "".join(orders)
        if orders:
            orders = "order by " + orders[:-2]            
            
        q = self.parentForm.db.query(self.sql + orders)
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
                    res += [self._gen_cell_data(v, self.columns[i]['width'])]
            res += "</tr>"
        res += "</table>"
        return "".join(res)

    def query(self):        
        q = self.parentForm.param("WIDGET_%s" % self.id)
        if q:
            return self._gen_data(self.parentForm.param("sorts"))
    
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
    def __init__(self, id, keyField, labelField, sql, func=None):
        super().__init__(id)
        self.keyField = keyField
        self.labelField = labelField
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
              "function @ID@_del(key) {"
              "   $('#@ID@_row_' + key).remove();"
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
        keyField = fields.index(self.keyField)
        labelField = fields.index(self.labelField)
        
        for row in data:
            res += "<tr id=\"%s_row_%s\">" % (self.id, row[keyField])
            if self.func:
                v = self.func(row)
            else:
                if type(row[labelField]) == bytearray:
                    v = str(row[labelField], "utf-8")
                else:
                    v = str(row[labelField])
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


class Chart(WidgetBase):
    def __init__(self, id, fieldX, fieldY, sql):
        super().__init__(id)
        self.fieldX = fieldX
        self.fieldY = fieldY
        self.sql = sql

    def _gen_js(self):
        js = ("<script type=\"text/javascript\">"
              "var @ID@_values = false; "
              ""
              "function @ID@_refresh() {"
              "   /*$('#@ID@_view').html('');*/"
              "   $.ajax({url:'@PAGE@?WIDGET_@ID@=true'}).done(function (data) {"
              "      @ID@_values = JSON.parse(data);"
              "      @ID@_build();"
              "   });"
              "}"
              ""
              "function @ID@_calc_bounds() {"              
              "   var vals = @ID@_values;"
              "   var s = [999999999999, 999999999999, -999999999999, -999999999999];"
              "   for (var i = 0; i < vals.length; i++) {"
              "      if (vals[i][0] < s[0]) s[0] = vals[i][0];"
              "      if (vals[i][1] < s[1]) s[1] = vals[i][1];"
              "      if (vals[i][0] > s[2]) s[2] = vals[i][0];"
              "      if (vals[i][1] > s[3]) s[3] = vals[i][1];"
              "   }"
              "   return s;"
              "}"
              ""
              "function @ID@_build() {"              
              "   var vals = @ID@_values;"
              "   var view = $('#@ID@_view');"
              "   view.html('');"
              "   var h = view.height() - 5;"
              "   var s = @ID@_calc_bounds();"
              "   var minX = s[0];"
              "   var minY = s[1];"
              "   var maxX = s[2];"
              "   var maxY = s[3];"
              "   var kX = view.width() / (maxX - minX);"
              "   var kY = (view.height() - 10) / (maxY - minY);"
              "   for (var i = 0; i < vals.length; i++) {"
              "      var o = $('<div/>');"
              "      view.append(o);"
              "      var x = Math.round((vals[i][0] - minX) * kX);"
              "      var y = h - Math.round((vals[i][1] - minY) * kY);"
              "      o.css('left', x + 'px');"
              "      o.css('top', y + 'px');"
              "   }"
              "}"
              ""
              "var @ID@_size = [0, 0];"
              ""
              "function @ID@_view_timer() {"
              "   var view = $('#@ID@_view');"
              "   if ((@ID@_size[0] != view.width()) || (@ID@_size[1] != view.height())) {"
              "      @ID@_size[0] = view.width();"
              "      @ID@_size[1] = view.height();"
              "      @ID@_build();"
              "   }"
              "   setTimeout(@ID@_view_timer, 500);"
              "}"
              ""
              "$(document).ready(function () {"
              "   @ID@_view_timer();"
              "   @ID@_refresh();"              
              "});"
              "</script>")
        
        js = js.replace("@ID@", str(self.id))
        js = js.replace("@PAGE@", self.parentForm.ACTION)
        
        return js

    def _gen_data(self):
        try:
            q = self.parentForm.db.query(self.sql)
            data = q.fetchall()
            fields = q.column_names
            q.close()        
            fieldX = fields.index(self.fieldX)
            fieldY = fields.index(self.fieldY)
            res = []
            for row in data:
                if row[fieldY] < 80:
                    res += [[row[fieldX], row[fieldY]]]
            return json.dumps(res)
        except Exception as e:
            return "%s" % (e.args,)

    def query(self):
        q = self.parentForm.param("WIDGET_%s" % self.id)
        if q:
            return self._gen_data()

    def html(self):
        try:
            res = ("<div id=\"@ID@_view\" class=\"chart_control\">"
                   "</div>")

            res = res.replace("@ID@", self.id)
        except Exception as e:
            return "Ошибка в виджете Chart: %s" % e.args

        return self._gen_js() + res
