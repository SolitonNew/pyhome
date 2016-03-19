from base_form import BaseForm
from widgets import TextField
from cairo import ImageSurface, Context, FontOptions, FORMAT_ARGB32
import math
import datetime

class Page5(BaseForm):
    ACTION = "page5"
    VIEW = "page5.tpl"

    def create_widgets(self):
        panels_data = []
        for row in self.db.select("select ID, NAME, HEIGHT from web_stat_panels order by ID"):
            panels_data += [self._create_panel(str(row[0]), str(row[1], "utf-8"), str(row[2]))]

        tf = TextField("STATISTIC_PANELS", "".join(panels_data))
        self.add_widget(tf)

    def _create_panel(self, key, name, height):
        f = open("views/stat_panel.tpl", "r")
        tmpl = f.read()
        f.close()        
        tmpl = tmpl.replace("@ID@", key)
        tmpl = tmpl.replace("@LABEL@", name)
        tmpl = tmpl.replace("@HEIGHT@", height)
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

    def _paint_panel(self, key, width, height, panel_h):
        self.db.IUD("update web_stat_panels set HEIGHT = %s where ID = %s" % (panel_h, key))
        self.db.commit()        
        
        color_x_line = (0.7, 0.7, 0.7)
        color_x_line_2 = (0.9, 0.9, 0.9)
        color_y_line = (0.7, 0.7, 0.7)
        color_border = (0.5, 0.5, 0.5)
        
        left = 40
        right = 10;
        bottom = 30

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
            

        max_x = datetime.datetime.now().timestamp()
        min_x = max_x - delta_x
        max_y = 1
        min_y = 1
        # Собираем статистику по графикам
        for row in self.db.select("select max(VALUE) v_max, "
                                  "       min(VALUE) v_min "
                                  "  from core_variable_changes "
                                  " where VARIABLE_ID in (" + var_ids + ") "
                                  "   and UNIX_TIMESTAMP(CHANGE_DATE) >= %s"
                                  "   and UNIX_TIMESTAMP(CHANGE_DATE) <= %s" % (min_x, max_x)):
            max_y = row[0]
            min_y = row[1]

        if typ == 2:
            if min_y < 0 and max_y < 0:
                max_y = 0
            elif min_y > 0 and max_y > 0:
                min_y = 0

        # Определяем цвета
        colors = [(1, 0, 0), (0, 0.65, 0.31), (0, 0, 1), (1, 1, 0)]

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
            for i in range(math.ceil(min_x / x_step), math.ceil(max_x / x_step)):
                if sc == 0:
                    x = (i * x_step - min_x - tz) / kx + left
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
            #print("ERROR %s" % (e.args))

        # Рисуем верхний и правый бордер

        ctx.set_source_rgb(*color_border)
        ctx.move_to(left, 0)
        ctx.line_to(width, 0)
        ctx.line_to(width, height - bottom)        
        ctx.stroke()                        

        #Рисуем сами графики
        
        is_first = True
        currVarID = -1
        prevX = -1;

        chart_data = self.db.select("select UNIX_TIMESTAMP(CHANGE_DATE) D, VALUE, VARIABLE_ID from core_variable_changes "
                                    " where VARIABLE_ID in (" + var_ids + ") "
                                    "   and UNIX_TIMESTAMP(CHANGE_DATE) >= %s"
                                    "   and UNIX_TIMESTAMP(CHANGE_DATE) <= %s"
                                    "order by VARIABLE_ID, CHANGE_DATE " % (min_x, max_x))

        if typ == 0: # Линейная
            for row in chart_data:
                if currVarID != row[2]:
                    ctx.stroke()
                    for i in range(4):
                        if series[i] == row[2]:
                            ctx.set_source_rgb(*colors[i])
                    is_first = True

                x = (row[0] - min_x) / kx + left
                y = height - bottom - (row[1] - min_y) / ky
                
                if is_first:
                    ctx.move_to(x, y)
                    is_first = False
                else:
                    if row[0] - prevX > 1000:
                        ctx.move_to(x, y)
                    else:
                        ctx.line_to(x, y)

                currVarID = row[2]
                prevX = row[0]
            ctx.stroke()
        elif typ == 1: # Точечная
            for row in chart_data:
                if currVarID != row[2]:
                    ctx.fill()
                    for i in range(4):
                        if series[i] == row[2]:
                            ctx.set_source_rgb(*colors[i])
                x = (row[0] - min_x) / kx + left
                y = height - bottom - (row[1] - min_y) / ky                
                ctx.rectangle(x - 3, y - 3, 6, 6)

                currVarID = row[2]
            ctx.fill()
        elif typ == 2: # Столбчатая
            cy = height - bottom - (-min_y) / ky
            for row in chart_data:
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
            for row in chart_data:
                if currVarID != row[2]:
                    ctx.stroke()
                    for i in range(4):
                        if series[i] == row[2]:
                            ctx.set_source_rgb(*colors[i])
                    is_first = True

                x = (row[0] - min_x) / kx + left
                y = height - bottom - (row[1] - min_y) / ky
                
                if is_first:
                    ctx.move_to(x, y)
                    is_first = False
                else:
                    ctx.line_to(x, prevY)
                    ctx.line_to(x, y)

                currVarID = row[2]
                prevX, prevY = x, y
            ctx.stroke()

        # Рисуем оси

        ctx.set_source_rgb(0, 0, 0)
        ctx.move_to(left, 0)
        ctx.line_to(left, height - bottom)
        ctx.line_to(width, height - bottom)
        ctx.stroke()
        
        # ---------------------------
        
        del ctx
        img.write_to_png("chart.png")

        f = open("chart.png", "rb")
        buf = f.read()
        f.close()        
        return buf
