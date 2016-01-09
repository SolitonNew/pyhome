#!/usr/bin/python3

from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib import parse
from db_connector import DBConnector
from grid import Grid
import forms

class HttpProcessor(BaseHTTPRequestHandler):
    HTTP_SKINS_PATH = "skins"

    def do_GET(self):
        self.db = DBConnector()

        self.controllers = self.db.select("select ID, NAME from core_controllers order by NAME")
        
        url_data = parse.urlsplit(self.path)
        url_page = url_data.path
        if url_page == "/":
            url_page = "/index.html"
        
        self.send_response(200)
        self.send_header('content-type','text/html')
        self.end_headers()

        params = parse.parse_qs(url_data.query)
        # Определяем является ли запрос для работы с формами
        form = False
        if url_page == forms.VariableSettings.ACTION:
            form = forms.VariableSettings(self.db, params)
        elif url_page == forms.SystemUtilites.ACTION:
            form = forms.SystemUtilites(self.db, params)                        

        # Если форма - обрабатываем
        if form:
            self.wfile.write(form.get())

        # Иначе стандартный набор выполнения
        elif url_page == "/variable_data":
            self.wfile.write(self._get_variable_list(True).encode("utf-8"))
        elif url_page == "/change_log":
            self.wfile.write(self._change_log(-1).encode("utf-8"))
        elif url_page == "/set_variable_value":
            h = parse.parse_qs(url_data.query)
            q = self.db.query("call CORE_SET_VARIABLE(%s, %s, null)" % (h['id'][0], h['val'][0]))
            self.db.commit()
            q.close()
        else:
            try:
                f = open(self.HTTP_SKINS_PATH + url_page, 'r')
                page_data = f.read()
            
                if url_page == "/index.html":
                    page_data = page_data.replace("@VARIABLE_LIST@", self._get_variable_list())
                    page_data = page_data.replace("@STATISTICS@", "")
                
                self.wfile.write(page_data.encode("utf-8"))
                f.close()
            except :
                self.wfile.write("ERROR!!!!!!".encode("utf-8"))


    def _get_variable_list(self, forRefresh = False):
        grid = Grid()
        grid.add_column("ID", 50)
        grid.add_column("Контроллер", 150)
        grid.add_column("Тип", 70)
        grid.add_column("Только чтение", 60)
        grid.add_column("Название", 200)
        grid.add_column("Описание", 200)
        grid.add_column("Значение", 100)
        grid.add_column("Канал", 100)
        grid.add_column("", 100)
        
        data = []
        q = self.db.query("select v.ID, c.NAME C_NAME, v.ROM, v.DIRECTION, v.NAME, v.COMM, v.VALUE, v.CHANNEL "
                          "  from core_variables v, core_controllers c "
                          " where c.ID = v.CONTROLLER_ID "
                          "order by v.ID")
        row = q.fetchone()
        while row:
            data_row = []
            data_row += [str(row[0])]
            data_row += [str(row[1], "utf_8")]
            
            data_row += [str(row[2], "utf-8")]
            if row[3] == 0:
                data_row += ["ДА"]
            else:
                data_row += ["НЕТ"]

            data_row += [str(row[4], "utf-8")]
            data_row += [str(row[5], "utf-8")]
                        
            rom = str(row[2], "utf-8")
            val_label = self._decode_variable_value(rom, row[6])
            if rom == "pyb":
                if row[6]:
                    new_val = 0
                else:
                    new_val = 1                
                data_row += ["<button onMouseDown=\"set_variable_value(%s, %s);\">%s</button>" % (row[0], new_val, val_label)]
            else:
                data_row += [val_label]

            data_row += [str(row[7], "utf-8")]
            data_row += ["<button onMouseDown='variable_settings(%s)'>Свойства...</button> " % row[0]]

            data += [data_row]
            
            row = q.fetchone()
        q.close()
        grid.set_data(data)
        
        return grid.html(forRefresh)

    def _change_log(self, from_id):
        data = self.db.select((" select c.CHANGE_DATE, v.COMM, c.VALUE, v.ROM"
                               "   from core_variable_changes c, core_variables v"
                               "  where c.VARIABLE_ID = v.ID"
                               " order by c.ID desc"
                               " limit 100"))
        res = []
        for row in data:
            val = self._decode_variable_value(str(row[3], "utf-8"), row[2])
            res += "<div style=\"color:#fff;padding:3px 15px;\">"
            res += "<span style=\"color:#777;\">[%s]</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'%s'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s" % (row[0], str(row[1], "utf-8"), val)
            res += "</div>"

        return "".join(res)

    def _decode_variable_value(self, typ, val):
        if typ == 'ow':
            return str(val)
        elif typ == 'pyb':
            if val:
                return "ВКЛ."
            else:
                return "ВЫКЛ."
        elif typ == 'variable':
            return str(val)


if __name__ == "__main__":
    serv = HTTPServer(("localhost", 8082), HttpProcessor)
    serv.serve_forever()
