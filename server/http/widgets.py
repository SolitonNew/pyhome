import json

class WidgetBase(object):
    def __init__(self, id):
        self.id = id

    def query(self):
        return False

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

class TreeField(ListField):
    def __init__(self, id, keyIndex, parentIndex, labelIndex, selectedKey, data):
        super().__init__(id, keyIndex, labelIndex, selectedKey, data)
        self.parentIndex = parentIndex
        self.data, self.child_tabs = self._recursive_search(data, 0, None, keyIndex, parentIndex, labelIndex)

        for i in range(len(self.data)):
            row = list(self.data[i])
            s = row[self.labelIndex]
            if type(s) == bytearray:
                s = str(s, "utf-8")

            s = "&nbsp;" * self.child_tabs[i] * 4 + "%s" % s            
            row[self.labelIndex] = s
            self.data[i] = row
            i += 1

    def _recursive_search(self, data, tab, parent, keyIndex, parentIndex, labelIndex):
        res = []
        tabs = []
        level = [row for row in data if row[parentIndex] == parent]
        for row in level:
            tabs += [tab]
            res += [row]
            childs, child_tabs = self._recursive_search(data, tab + 1, row[keyIndex], keyIndex, parentIndex, labelIndex)
            res += childs;
            tabs += child_tabs
            
        return res, tabs    

class TabControl(WidgetBase):
    def __init__(self, id, tabClosed=False, position="top"):
        super().__init__(id)
        self.tabClosed = tabClosed
        self.tabs = []
        self.btnCloseTpl = "<button type=\"button\" onMousedown=\"@ID@_close(@NUM@);stop_mouse_events(event);return false;\">X</button>"
        self.position = position

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
            res += ["<div id=\"%s_tab_%s\" class=\"page_tab_%s\" onMouseDown=\"%s_select(%s); return false;\">" % (self.id, i, self.position, self.id, i)]
            res += [tab['label']]            
            res += ["&nbsp;", btnClose.replace("@NUM@", str(i))]
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
              "var @ID@_selected_url = false;"
              ""
              "var @ID@_btn_close_tpl = '@CLOSE_TPL@';"
              ""
              "function @ID@_select(num) {"              
              "   if ($('#@ID@_tab_' + num).hasClass('page_tab_sel'))"
              "      return ;"
              "   "
              "   @ID@_selected_url = false;"
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
              "      });"
              "   "
              "   if (num) {"
              "      @ID@_selected_url = @ID@_tabs[num];"
              "      window.dispatchEvent(new Event('@ID@_selected'));"
              "      window.dispatchEvent(new Event('layoutResize'));"
              "   }"
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
              "   $('#@ID@_tab_list').append('<div id=\"@ID@_tab_' + i + '\" class=\"page_tab_@POSITION@\" onMouseDown=\"@ID@_select(' + i + '); return false;\"><span id=\"@ID@_tab_title_' + i + '\">' + label + '</span>' + btn + '</div>');"
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
              "            isEmpty = false;"
              "            @ID@_select(i);"
              "            break;"
              "         }"
              "      }"
              "      for (i = num; i < @ID@_tabs.length; i++) {"
              "         if (@ID@_tabs[i] != '') {"
              "            isEmpty = false;"
              "            @ID@_select(i);"
              "            break;"
              "         }"
              "      }"
              "   }"
              "   "
              "   $('#@ID@_tab_' + num).remove();"
              "   $('#@ID@_page_' + num).remove();"
              "   "
              "   if ($('#@ID@_tab_list').html() == '') {"
              "      @ID@_select(-1);"
              "   }"
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
        js = js.replace("@POSITION@", self.position)
        
        return js
        
    def html(self):
        tab_html = ("<tr><td id=\"@ID@_tab_list\" style=\"position:relative;width:100%;\">"
                    "@TABS@"
                    "</td></tr>")
        page_html = "<tr><td id=\"@ID@_page_list\" height=\"100%\">@PAGES@</td></tr>"
        
        res = ("<table class=\"tab_control\" cellpadding=\"0\" cellspacing=\"0\">"
               "%s"
               "%s"               
               "</table>")

        if self.position == "top":
            res = res % (tab_html, page_html)
        else:
            res = res % (page_html, tab_html)

        res = res.replace("@ID@", str(self.id))
        res = res.replace("@TABS@", self._gen_tabs())
        res = res.replace("@PAGES@", self._gen_pages())

        return self._gen_js() + res


class Grid(WidgetBase):
    def __init__(self, id, keyField, sql, detail=False):
        super().__init__(id)
        self.columns = []
        self.sql = sql
        self.keyField = keyField
        self.detail = detail

    def _gen_js(self):
        js = ("<script type=\"text/javascript\">"
              ""
              "var @ID@_filter = '';"
              "var @ID@_sorts = [@SORTS@];"
              "var @ID@_prev_data = '';"
              "var _@ID@_selected_key = false;"
              ""
              "function @ID@_selected(key) {"
              "   var prev_key = _@ID@_selected_key;"
              "   if (prev_key)"
              "      $('#@ID@_row_' + prev_key).removeClass('grid_data_selected');"              
              "   $('#@ID@_row_' + key).addClass('grid_data_selected');"
              "   _@ID@_selected_key = key;"
              "   window.dispatchEvent(new Event('@ID@_selected'));"
              "}"
              ""              
              "function @ID@_refresh() {"
              "   sorts = @ID@_sorts.join(',');"
              "   filter = @ID@_filter;"
              "   $.ajax({url:'@PAGE@?WIDGET_@ID@=true&sorts=' + sorts + '&filter=' + filter}).done(function (data) {"
              "      if (@ID@_prev_data != data) {"
              "         @ID@_prev_data = data;"
              "         $('#@ID@_data').html(data);"
              "         var key = _@ID@_selected_key;"
              "         if (key)"
              "            $('#@ID@_row_' + key).addClass('grid_data_selected');"
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
              "function @ID@_recalc_header() {"
              "   var h = $('#@ID@_header_table').height();"
              "   if (h == 0) {"
              "      setTimeout(@ID@_recalc_header, 100);"
              "   } else {"              
              "      $('#@ID@_header_top').height(h);"
              "   }"
              "}"
              ""              
              "$(document).ready(function () {"              
              "   @ID@_recalc_header();"
              "   @ID@_refresh();"
              "});"
              ""
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

    def _gen_data(self, sorts = "", filt = ""):
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
            orders = " order by " + orders[:-2]

        det = ""
        filter_data = ""
        if filt:
            try:
                self.sql.index("where ")
                filter_data = " and %s" % filt
            except:
                filter_data = " where %s" % filt
        elif self.detail:
            det = " limit 0"

        if det == "":
            det = " limit 1000"
            
        q = self.parentForm.db.query(self.sql + filter_data + orders + det)
        data = q.fetchall()
        fields = q.column_names
        keyIndex = fields.index(self.keyField)
        q.close()
        for row in data:
            res += "<tr id=\"%s_row_%s\" onClick=\"%s_selected('%s')\">" % (self.id, row[keyIndex], self.id, row[keyIndex])
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
            return self._gen_data(self.parentForm.param("sorts"), self.parentForm.param("filter"))
    
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
        except Exception as e:
            return "Ошибка в виджете Grid: {}".format(e.args)

        return self._gen_js() + res


class List(WidgetBase):
    def __init__(self, id, keyField, labelField, sql, addAttrFunc=None, toolTipField=""):
        super().__init__(id)
        self.keyField = keyField
        self.labelField = labelField
        self.sql = sql
        self.addAttrFunc = addAttrFunc
        self.toolTipField = toolTipField

    def _gen_js(self):
        js = ("<script type=\"text/javascript\">"
              ""
              "var _@ID@_selected_key = false;"
              "var _@ID@_selected_addAttr = false;"
              ""
              "function @ID@_selected(key, addAttr) {"              
              "   var prev_key = _@ID@_selected_key;"
              "   _@ID@_selected_addAttr = addAttr;"
              "   if (prev_key)"
              "      $('#@ID@_row_' + prev_key).removeClass('list_control_selected');"
              "   $('#@ID@_row_' + key).addClass('list_control_selected');"
              "   _@ID@_selected_key = key;"
              "   window.dispatchEvent(new Event('@ID@_selected'));"
              "}"
              ""
              "function @ID@_refresh() {"
              "   $.ajax({url:'@PAGE@?WIDGET_@ID@=true'}).done(function (data) {"
              "      $('#@ID@_data').html(data);"
              "      @ID@_selected(_@ID@_selected_key);"
              "   });"
              "};"
              ""              
              "function @ID@_del(key) {"
              "   $('#@ID@_row_' + key).remove();"
              "};"
              ""
              "function @ID@_get_label(key) {"
              "   return $('#@ID@_row_' + key + '_label').html();"
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

    def _gen_cell(self, data, key):
        add_attr = ''
        if self.addAttrFunc:
            add_attr = self.addAttrFunc(self, key)
        res = ["<td width=\"100%\" onClick=\"", self.id, "_selected('", ("%s" % key), "','", add_attr, "');\">"]
        res += ["<div id=\"", self.id, "_row_", "%s" % key, "_label\" style=\"width:100%;\">"]
        res += [data]
        res += ["</div>"]
        res += ["</td>"]

        return "".join(res)

    def _fetch_data(self):
        q = self.parentForm.db.query(self.sql)
        data, fields = q.fetchall(), q.column_names
        q.close()
        return (data, fields)

    def _gen_data(self):
        res = ["<table id=\"%s_list_data\" class=\"list_data\" cellpadding=\"0\" cellspacing=\"0\">" % (self.id)]
        data, fields = self._fetch_data()
        keyField = fields.index(self.keyField)
        labelField = fields.index(self.labelField)
        toolTipField = False
        if self.toolTipField:
            toolTipField = fields.index(self.toolTipField)
    
        toolTip = ""
        if toolTipField:
            toolTip = "onMouseMove=\"showToolTip(event, '%s');\" onMouseOut=\"hideToolTip();\""
        
        for row in data:
            v = ""
            if toolTipField:
                if type(row[toolTipField]) == bytearray:
                    v = str(row[toolTipField], "utf-8")
                else:
                    v = str(row[toolTipField])
                v = toolTip % (v)
            
            res += "<tr id=\"%s_row_%s\" %s>" % (self.id, row[keyField], v)
            if type(row[labelField]) == bytearray:
                v = str(row[labelField], "utf-8")
            else:
                v = str(row[labelField])
            res += [self._gen_cell(v, row[keyField])]
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

class TreeNode:
    def __init__(self, id):
        self.id = id
        self.childs = []

class Tree(List):
    def __init__(self, id, keyField, parentField, labelField, sql, addAttrFunc=None, toolTipField=""):
        super().__init__(id, keyField, labelField, sql, addAttrFunc, toolTipField)
        self.parentField = parentField
        self.nodes = TreeNode(None)
        self.treeNodes = []

    def _recursive_search(self, data, tab, parent, keyIndex, parentIndex, labelIndex, parentNode):
        if parentIndex == -1 and tab > 0:
            return [], []
        res = []
        tabs = []
        if parentIndex == -1:
            level = data
        else:
            level = [row for row in data if row[parentIndex] == parent]
        for row in level:
            node = TreeNode(row[keyIndex])
            parentNode.childs += [node]
            self.treeNodes += [node]
            tabs += [tab]
            res += [row]
            childs, child_tabs = self._recursive_search(data, tab + 1, row[keyIndex], keyIndex, parentIndex, labelIndex, node)
            res += childs;
            tabs += child_tabs

        return res, tabs

    def _fetch_data(self):
        q = self.parentForm.db.query(self.sql)
        data, fields = q.fetchall(), q.column_names
        q.close()

        keyIndex = fields.index(self.keyField)
        try:
            parentIndex = fields.index(self.parentField)
        except:
            parentIndex = -1
            
        labelIndex = fields.index(self.labelField)
        tree, self.child_tabs = self._recursive_search(data, 0, None, keyIndex, parentIndex, labelIndex, self.nodes)
        
        return (tree, fields)

    def _gen_data(self):
        res = ["<table class=\"list_data\" cellpadding=\"0\" cellspacing=\"0\">"]
        data, fields = self._fetch_data()
        keyField = fields.index(self.keyField)
        labelField = fields.index(self.labelField)

        i = 0
        for row in data:
            res += "<tr id=\"%s_row_%s\">" % (self.id, row[keyField])
            if type(row[labelField]) == bytearray:
                v = str(row[labelField], "utf-8")
            else:
                v = str(row[labelField])
            v = "&nbsp;" * 6 * self.child_tabs[i] + v
            i += 1
            res += [self._gen_cell(v, row[keyField])]
            res += "</tr>"
        res += "</table>"
        return "".join(res)

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
