#!/usr/bin/python3
#-*- coding: utf-8 -*-

import random
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib import parse

class HttpProcessor(BaseHTTPRequestHandler):    
    DATA_PATH = "views/"
    sys_libs = ("app.js",)
    media_ext = (".png", ".jpg")
    resources_ext = (".html", ".js", ".css")
    session_cookie_name = "SESSION"
    SESSIONS = []

    def create_session(self, value):
        sess = [str(random.random()), True, value]
        self.SESSIONS += [sess]
        self.out_cookie += [(self.session_cookie_name, sess[0])]

    def isAndroid(self):
        try:
            self.headers['User-Agent'].index("Android")
            return True
        except:
            return False

    def do_GET(self):
        self._execute_query(parse.urlsplit(self.path))

    def _execute_query(self, url_data):
        # Зачитываем куки
        self.out_cookie = []
        cookies = []
        if "Cookie" in self.headers:
            for c in self.headers["Cookie"].split('; '):
                cookies += [c.split("=")]

        # Определяем текущую сессию
        current_session = False
        self.SESSION_VALUE = False
        for cook in cookies:            
            if cook[0] == self.session_cookie_name:
                for sess in self.SESSIONS:
                    if sess[0] == cook[1]:
                        current_session = True
                        self.SESSION_VALUE = sess[2]

        # Работаем по стандартному сценарию
        path = url_data.path[1:]
        ext = path.lower()
        try:
            ext = ext[ext.rindex("."):]
        except:
            pass

        is_empty = True

        if is_empty:
            try:
                self.sys_libs.index(path)
                is_empty = False
                try:
                    f = open(path, 'rb')
                    self.send_response(200)                    
                    self.send_header('content-type','text/html')
                    self.send_header('charset','UTF8')
                    self.end_headers()
                    self.wfile.write(f.read())
                    f.close;
                except:
                    pass
            except:
                pass

        if is_empty:
            try:
                self.media_ext.index(ext)
                is_empty = False
                ext = ext[1:]
                try:
                    f = open(path, 'rb')
                    self.send_response(200)                    
                    self.send_header('content-type','image/%s' % ext)
                    self.send_header('charset','UTF8')
                    self.end_headers()                    
                    self.wfile.write(f.read())
                    f.close;
                except:
                    pass
            except:
                pass            
        
        if is_empty:
            try:
                self.media_ext.index(ext)
                is_empty = False
                ext = ext[1:]
                try:
                    f = open(self.DATA_PATH + path, 'rb')
                    self.send_response(200)                    
                    self.send_header('content-type','image/%s' % ext)
                    self.send_header('charset','UTF8')
                    self.end_headers()                    
                    self.wfile.write(f.read())
                    f.close;
                except:
                    pass
            except:
                pass

        if is_empty:
            try:            
                self.resources_ext.index(ext)
                is_empty = False
                ext = ext[1:]
                try:
                    f = open(self.DATA_PATH + path, 'rb')
                    self.send_response(200)
                    self.send_header('content-type','text/%s' % ext)
                    self.send_header('charset','UTF8')
                    self.end_headers()            
                    self.wfile.write(f.read())
                    f.close;
                except:
                    pass
            except:
                pass

        if is_empty:
            if path == "":
                path = "index"
                    
            # Перенаправление если сессия неавалидна

            if path == "index" and not current_session:
                path = "index_login"

            # --------------------------------------

            from db_connector import DBConnector                
            import models.forms

            try:
                for form in models.forms.FORMS:
                    if form.ACTION == path:
                        f = form()
                        f.owner = self
                        f.data_path = self.DATA_PATH
                        f.url_data = url_data
                        f.db = DBConnector()
                        f.create_widgets()
                        res = f.run()
                        self.send_response(200)

                        # Вставка для сессионного механизма
                        for cook in self.out_cookie:
                            self.send_header("Set-cookie", "%s=%s" % (cook))
                        # ---------------------------------
                        
                        self.send_header('content-type', f.content_type)
                        self.send_header('charset', 'UTF8')
                        self.end_headers()
                            
                        if f.content_type == "text/html":
                            self.wfile.write(res.encode("utf-8"))
                        else:
                            self.wfile.write(res)
                        f.db.disconnect()
                        f.db = False
                        is_empty = False
                        break;
                if is_empty:
                    self.wfile.write(("Форма '%s' не найдена" % path).encode("utf-8"))
            except Exception as e:
                s = "Форма '%s' ругнулась:<br><b>%s</b>" % (path, "{}".format(e.args))
                self.wfile.write(s.encode("utf-8"))
    
"""
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8082
"""
HTTP_HOST = "0.0.0.0"
HTTP_PORT = 8082

print(
"=============================================================================\n"
"                        МОДУЛЬ WEB ПРИЛОЖЕНИЯ v0.1\n"
"\n"
" Хост: %s \n"
" Порт: %s \n"
"=============================================================================\n"
% (HTTP_HOST, HTTP_PORT)
)

if __name__ == "__main__":
    serv = HTTPServer((HTTP_HOST, HTTP_PORT), HttpProcessor)    
    serv.serve_forever()
