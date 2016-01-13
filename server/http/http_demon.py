#!/usr/bin/python3

from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib import parse
from db_connector import DBConnector
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

        # На случай картинок
        if url_page[len(url_page) - 4:len(url_page)] == ".png":
            self.send_response(200)
            self.send_header('content-type','image/png')
            self.end_headers()            
            try:            
                f = open(self.HTTP_SKINS_PATH + url_page, 'rb')
                self.wfile.write(f.read())
                f.close()
            except:
                pass
            return
        # Если не картинка, то дальше работаем
        else:        
            self.send_response(200)
            self.send_header('content-type','text/html')
            self.end_headers()

        params = parse.parse_qs(url_data.query)
        # Определяем является ли запрос для работы с формами
        form = False
        for frm in forms.forms:
            if url_page == frm.ACTION:
                form = frm(self.db, params)
                self.wfile.write(form.get())
                return

        # Иначе стандартный набор выполнения
        if url_page == "/change_log":
            self.wfile.write(self._change_log(-1).encode("utf-8"))    
        else:
            try:
                f = open(self.HTTP_SKINS_PATH + url_page, 'r')
                page_data = f.read()            
                self.wfile.write(page_data.encode("utf-8"))
                f.close()
            except :
                self.wfile.write("ERROR!!!!!!".encode("utf-8"))

    def _change_log(self, from_id):
        data = self.db.select((" select c.CHANGE_DATE, v.COMM, c.VALUE, v.ROM"
                               "   from core_variable_changes c, core_variables v"
                               "  where c.VARIABLE_ID = v.ID"
                               " order by c.ID desc"
                               " limit 100"))
        res = []
        for row in data:
            d = row[0].time()
            val = forms.decode_variable_value(str(row[3], "utf-8"), row[2])
            res += "<div style=\"color:#fff;padding:3px 15px;\">"
            res += "<span style=\"color:#777;\">[%s]</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'%s'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%s" % (d, str(row[1], "utf-8"), val)
            res += "</div>"

        return "".join(res)

print(
"=============================================================================\n"
"                       МОДУЛЬ HTTP ВЗАИМОДЕЙСТВИЯ v0.1\n"
"\n"
" Хост: %s \n"
" Порт: %s \n"
"=============================================================================\n"
% ("0.0.0.0", 8082)
)

if __name__ == "__main__":
    serv = HTTPServer(("0.0.0.0", 8082), HttpProcessor)    
    serv.serve_forever()
