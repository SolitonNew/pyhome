from base_form import BaseForm
from widgets import TextField
from cairo import ImageSurface, Context, FontOptions, FORMAT_ARGB32
import math
import datetime
from io import BytesIO

class Page5_1(BaseForm):
    ACTION = "page5_1"
    VIEW = "page5_1.tpl"

    def create_widgets(self):
        panels_data = []
        for row in self.db.select("select ID, NAME, HEIGHT from web_stat_panels order by ID"):
            panels_data += [self._create_panel(str(row[0]), str(row[1], "utf-8"), str(row[2]))]

        tf = TextField("STATISTIC_PANELS", "".join(panels_data))
        self.add_widget(tf)

        tf = TextField("START_TIME", str(round(datetime.datetime.now().timestamp())))
        self.add_widget(tf)

    def _create_panel(self, key, name, height):
        lb1, lb2, lb3, lb4 = ["-- нет --"] * 4
        for row in self.db.select("select v.ID, CONCAT(v.COMM, ' [', v.NAME, ']'), p.SERIES_1, p.SERIES_2, p.SERIES_3, p.SERIES_4 "
                                  "  from web_stat_panels p, core_variables v "
                                  " where (p.SERIES_1 = v.ID "
                                  "     or p.SERIES_2 = v.ID "
                                  "     or p.SERIES_3 = v.ID "
                                  "     or p.SERIES_4 = v.ID)"
                                  "    and p.ID = %s" % (key)):
            sers = row[2:6]
            lab = str(row[1], "utf-8")
            if row[0] == sers[0]:
                lb1 = lab
            elif row[0] == sers[1]:
                lb2 = lab
            elif row[0] == sers[2]:
                lb3 = lab
            elif row[0] == sers[3]:
                lb4 = lab
        
        f = open("views/stat_panel.tpl", "r")
        tmpl = f.read()
        f.close()        
        tmpl = tmpl.replace("@ID@", key)
        tmpl = tmpl.replace("@LABEL@", name)
        tmpl = tmpl.replace("@HEIGHT@", height)
        tmpl = tmpl.replace("@LABEL_1@", lb1)
        tmpl = tmpl.replace("@LABEL_2@", lb2)
        tmpl = tmpl.replace("@LABEL_3@", lb3)
        tmpl = tmpl.replace("@LABEL_4@", lb4)
        return tmpl

    def query(self, query_type):
        if query_type == "append_panel":
            self.db.IUD("insert into web_stat_panels (NAME) values ('%s')" % ("Новая панель"))
            self.db.commit()            
            return self._create_panel(str(self.db.lastID()), "Новая панель", "200")
        elif query_type == "del_panel":
            self.db.IUD("delete from web_stat_panels where ID = %s" % (self.param("key")))
            self.db.commit()
            return "OK"        
        elif query_type == "panel_img":
            self.content_type = "image/png"
            return self._paint_panel(self.param('key'), self.param('width'), self.param('height'), self.param('panel_h'))
    
    def _get_one_val(self, series, min_x, max_x):
        res = [[], [], [], []]   
        sql = []
        for i in range(4):
            if series[i] > 0:            
                sql_prev = ("select a.* from ("
                            "select UNIX_TIMESTAMP(CHANGE_DATE) D, VALUE, VARIABLE_ID, ID, 1 "
                            "  from core_variable_changes "
                            " where VARIABLE_ID = %s "
                            "   and CHANGE_DATE < FROM_UNIXTIME(%s) "
                            "order by CHANGE_DATE desc limit 1) a" % (series[i], min_x))

                sql_next = ("select a.* from ("
                            "select UNIX_TIMESTAMP(CHANGE_DATE) D, VALUE, VARIABLE_ID, ID, 2 "
                            "  from core_variable_changes "
                            " where VARIABLE_ID = %s "
                            "   and CHANGE_DATE > FROM_UNIXTIME(%s) "
                            "order by CHANGE_DATE limit 1) a" % (series[i], max_x))
            if len(sql) > 0:
                sql += [" union "]
            sql += ["%s union %s" % (sql_prev, sql_next)]
            
        for row in self.db.select("".join(sql)):
            try:
                i = series.index(row[2])
                res[i] += [row]
            except:
                pass
        return res

    def _paint_panel(self, key, width, height, panel_h):
        self.db.IUD("update web_stat_panels set HEIGHT = %s where ID = %s" % (panel_h, key))
        self.db.commit()        
        
        color_x_line = (0.7, 0.7, 0.7)
        color_x_line_2 = (0.9, 0.9, 0.9)
        color_y_line = (0.7, 0.7, 0.7)
        color_border = (0.5, 0.5, 0.5)
        
        left = 40
        right = 10;
        bottom = 15

        var_ids = "0";
        series = [0, 0, 0, 0]
        typ = 0
        for row in self.db.select("select SERIES_1, SERIES_2, SERIES_3, SERIES_4, TYP "
                                  "  from web_stat_panels "
                                  " where ID = " + str(key)):
            series = row
            var_ids = "%s, %s, %s, %s" % row[0:4]
            typ = row[4]

        width, height = int(width), int(height)
        if width <= 0:
            width = 300
        if height <= 0:
            height = 150

        interval = self.param('range')

        delta_x = 1
        if interval == "-12 hour":
            delta_x = 12 * 3600
        elif interval == "-1 day":
            delta_x = 24 * 3600
        elif interval == "-3 day":
            delta_x = 3 * 24 * 3600
        elif interval == "-7 day":
            delta_x = 7 * 24 * 3600
        elif interval == "-14 day":
            delta_x = 14 * 24 * 3600            
        else:
            delta_x = 30 * 24 * 3600

        min_x = int(self.param('start')) - delta_x // 2
        max_x = min_x + delta_x

        min_x_q = min_x - delta_x // 20
        max_x_q = max_x + delta_x // 20
        
        max_y = -9999
        min_y = 9999

        # Делаем полную выборку данных. Выкидываем подозрительные точки и
        # собираем статистику.
        prev_vals = [-9999] * 4
        chart_data = [[], [], [], []]

        """
        for row in self.db.select("select UNIX_TIMESTAMP(CHANGE_DATE) D, VALUE, VARIABLE_ID, ID "
                                  "  from core_variable_changes "
                                  " where VARIABLE_ID in (" + var_ids + ") "
                                  "   and CHANGE_DATE >= FROM_UNIXTIME(%s) "
                                  "   and CHANGE_DATE <= FROM_UNIXTIME(%s) "
                                  "order by CHANGE_DATE " % (min_x_q, max_x_q)):
        """
        try:
            self.db.IUD("set @rn := 0")

            sql = ("select UNIX_TIMESTAMP(CHANGE_DATE) D, VALUE, VARIABLE_ID, ID "
                   "  from core_variable_changes "
                   " where VARIABLE_ID in (" + var_ids + ") "
                   "   and CHANGE_DATE >= FROM_UNIXTIME(%s) "
                   "   and CHANGE_DATE <= FROM_UNIXTIME(%s) "
                   "order by CHANGE_DATE " % (min_x_q, max_x_q))

            for c in self.db.select("select count(*) c "
                                    "  from core_variable_changes "
                                    " where VARIABLE_ID in (" + var_ids + ") "
                                    "   and CHANGE_DATE >= FROM_UNIXTIME(%s) "
                                    "   and CHANGE_DATE <= FROM_UNIXTIME(%s) " % (min_x_q, max_x_q)):
                cou = c[0]
                ccc = 500 * 4
                if cou > ccc:
                    sql = ("select UNIX_TIMESTAMP(CHANGE_DATE) D, VALUE, VARIABLE_ID, ID, @rn := @rn + 1 rownum "
                           "  from core_variable_changes "
                           " where VARIABLE_ID in (" + var_ids + ") "
                           "   and CHANGE_DATE >= FROM_UNIXTIME(%s) "
                           "   and CHANGE_DATE <= FROM_UNIXTIME(%s) "
                           "having mod(rownum, %s) = 0 "
                           "order by VARIABLE_ID, CHANGE_DATE " % (min_x_q, max_x_q, math.ceil(cou / ccc)))
            
            for row in self.db.select(sql):
                ind = series.index(row[2])
                prev_vals[ind] = row[1]

                if abs(prev_vals[ind] - row[1]) < 10:
                    chart_data[ind] += [row]
                    if row[0] > min_x and row[0] < max_x:
                        max_y = max(max_y, row[1])
                        min_y = min(min_y, row[1])
                prev_vals[ind] = row[1]
        except:
            pass
            
        
        if min_y is None or max_y is None or min_y == 9999 or max_y == -9999 or min_y == max_y:
            max_y = 1
            min_y = 0

        min_y = math.floor(min_y)
        max_y = math.ceil(max_y)

        if typ == 2:
            if min_y < 0 and max_y < 0:
                max_y = 0
            elif min_y > 0 and max_y > 0:
                min_y = 0

        # Определяем цвета
        colors = [[1, 0, 0], [0, 0.65, 0.31], [0, 0, 1], [1, 0, 1]]
        
        off_y = (max_y - min_y) / 10        
        min_y -= off_y
        max_y += off_y        

        try:
            kx = ((max_x - min_x) / (width - left - right))
            ky = ((max_y - min_y) / (height - bottom))
            if ky == 0:
                ky = 1
        except:
            kx, ky = 1, 1

        img = ImageSurface(FORMAT_ARGB32, width, height)
        ctx = Context(img)

        width -= right
        ctx.set_line_width(1)

        # Рисуем сетку        

        ctx.set_font_size(12)
        try:
            b_w, b_h = ctx.text_extents("00-00-0000")[2:4]
            
            # Метки на оси Y
            count = math.ceil(max_y) - math.ceil(min_y)
            space_count = math.ceil(count / ((height - bottom) / (b_h * 1.5)))
            sc = 0
            for i in range(math.ceil(min_y), math.ceil(max_y)):
                if sc == 0:
                    y = height - bottom + (min_y - i) / ky
                    ctx.set_source_rgb(*(color_x_line))
                    ctx.move_to(left, y)
                    ctx.line_to(width, y)
                    ctx.stroke()
                    ctx.set_source_rgb(0, 0, 0)
                    num = str(i)
                    tw, th = ctx.text_extents(num)[2:4]
                    ctx.move_to(left - 5 - tw, y + th // 2)
                    ctx.show_text(num)
                    sc = space_count
                sc -= 1                    

            # Метки на оси Х

            x_step = 3600
            if (interval == "-12 hour" or
                interval == "-1 day"):
                # Дополнительно метки часов
                x_step = 3600
                for i in range(math.ceil(min_x / x_step), math.ceil(max_x / x_step)):
                    x = (i * x_step - min_x) / kx + left
                    ctx.set_source_rgb(*(color_x_line_2))
                    ctx.move_to(x, 0)
                    ctx.line_to(x, height - bottom)
                    ctx.stroke()
                    num = datetime.datetime.fromtimestamp(i * x_step).strftime('%H')
                    tw, th = ctx.text_extents(num)[2:4]
                    ctx.move_to(x + 2, height - bottom - 3)
                    ctx.set_source_rgb(*(color_x_line))
                    ctx.show_text(num)
            
            x_step = 3600 * 24

            space_count = 1
            count = math.ceil(max_x / x_step) - math.ceil(min_x / x_step)
            try:
                if (width / count) < b_w:
                    space_count = 2
            except:
                pass

            sc = 0
            tz = 3600 * 2
            for i in range(math.ceil(min_x / x_step), math.ceil(max_x / x_step) + 1):
                if sc == 0:
                    x = (i * x_step - min_x - tz) / kx + left
                    if x >= left and x < width:
                        ctx.set_source_rgb(*(color_y_line))
                        ctx.move_to(x, 0)
                        ctx.line_to(x, height - bottom)
                        ctx.stroke()
                    ctx.set_source_rgb(0, 0, 0)
                    num = datetime.datetime.fromtimestamp(i * x_step).strftime('%d-%m-%Y')
                    tw, th = ctx.text_extents(num)[2:4]
                    ctx.move_to(x - tw // 2, height - bottom + th + 5)
                    ctx.show_text(num)
                    sc = space_count
                sc -= 1
        except Exception as e:
            pass

        # Рисуем верхний и правый бордер

        ctx.set_source_rgb(*color_border)
        ctx.move_to(left, 0)
        ctx.line_to(width, 0)
        ctx.line_to(width, height - bottom)        
        ctx.stroke()                        

        #Рисуем сами графики

        ctx.rectangle(left, 0, width - left, height)
        ctx.clip()        
        
        is_first = True
        currVarID = -1
        prevX = -1;

        if typ == 0: # Линейная
            for ind in range(4):
                """
                if len(chart_data[ind]) > 0:
                    for i in range(len(chart_data[ind]) - 1):
                        chart_data[ind][i] = list(chart_data[ind][i])
                        r1 = chart_data[ind][i]
                        r2 = chart_data[ind][i + 1]
                        chart_data[ind][i][0] += (r2[0] - r1[0]) / 2
                        chart_data[ind][i][1] += (r2[1] - r1[1]) / 2
                """
                ctx.set_source_rgb(*colors[ind])
                is_first = True
                for row in chart_data[ind]:
                    x = (row[0] - min_x) / kx + left
                    y = height - bottom - (row[1] - min_y) / ky
                    
                    if is_first:
                        ctx.move_to(x, y)
                    else:
                        if row[0] - prevX > 10000:
                            ctx.move_to(x, y)
                        else:
                            ctx.line_to(x, y)

                    prevX = row[0]
                    is_first = False
                ctx.stroke()
            
        elif typ == 1: # Точечная
            for ind in range(4):
                if chart_data[ind]:
                    ctx.set_source_rgb(*colors[ind])
                    for row in chart_data[ind]:
                        x = (row[0] - min_x) / kx + left
                        y = height - bottom - (row[1] - min_y) / ky                
                        ctx.rectangle(x - 3, y - 3, 6, 6)
                    ctx.fill()
        elif typ == 2: # Столбчатая
            cy = height - bottom - (-min_y) / ky
            for ind in range(4):
                for row in chart_data[ind]:
                    if currVarID != row[2]:
                        ctx.fill()
                        for i in range(4):
                            if series[i] == row[2]:
                                ctx.set_source_rgb(*colors[i])
                    x = (row[0] - min_x) / kx + left
                    y = height - bottom - (row[1] - min_y) / ky
                    ctx.rectangle(x - 5, y, 10, cy - y)

                    currVarID = row[2]
                ctx.fill()
        else: # Линейчастая
            one_vals = self._get_one_val(series, min_x_q, max_x_q)
            for ind in range(4):
                if series[ind]:
                    is_now = True
                    for r in one_vals[ind]:
                        if r[4] == 1:
                            chart_data[ind].insert(0, r)
                        else:
                            chart_data[ind] += [r]
                            is_now = False

                    if is_now:
                        if len(chart_data[ind]) > 0:
                            r = list(chart_data[ind][len(chart_data[ind]) - 1])
                            r[0] = datetime.datetime.now().timestamp()
                            chart_data[ind] += [r]

                color = colors[ind]
                color_fill = color.copy()
                color_fill += [0.3]
                is_first = True
                y0 = height - bottom + min_y / ky
                for row in chart_data[ind]:
                    x = (row[0] - min_x) / kx + left
                    y = height - bottom - (row[1] - min_y) / ky
                    
                    if is_first:                    
                        is_first = False
                    else:
                        ctx.set_source_rgb(*color)
                        ctx.move_to(prevX, prevY)
                        ctx.line_to(x, prevY)
                        ctx.line_to(x, y)
                        ctx.stroke()
                        ctx.set_source_rgba(*color_fill)
                        rx, ry, rw, rh = prevX, y0, x - prevX, prevY - y0
                        ctx.rectangle(rx, ry, rw, rh)
                        ctx.fill()

                    prevX, prevY = x, y
                        
        # Рисуем оси

        ctx.set_source_rgb(0, 0, 0)
        ctx.move_to(left, 0)
        ctx.line_to(left, height - bottom)
        ctx.line_to(width, height - bottom)
        ctx.stroke()
        
        # ---------------------------        
        
        del ctx

        byt = BytesIO()
        img.write_to_png(byt)
        byt.seek(0)
        return byt.read()
