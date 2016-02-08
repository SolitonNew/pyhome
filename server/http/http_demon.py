#!/usr/bin/python3

from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib import parse

class HttpProcessor(BaseHTTPRequestHandler):
    DATA_PATH = "views/"
    sys_libs = ("app.js",)
    media_ext = (".png", ".jpg")
    resources_ext = (".html", ".js", ".css")

    def do_GET(self):
        self._execute_query(parse.urlsplit(self.path))

    def _execute_query(self, url_data):
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

            from db_connector import DBConnector                
            import models.forms            

            try:
                for form in models.forms.FORMS:
                    if form.ACTION == path:
                        f = form()
                        f.data_path = self.DATA_PATH
                        f.url_data = url_data
                        f.db = DBConnector()
                        f.create_widgets()
                        res = f.run()
                        self.send_response(200)
                        self.send_header('content-type', 'text/html')
                        self.send_header('charset', 'UTF8')
                        self.end_headers()
                        self.wfile.write(res.encode("utf-8"))
                        is_empty = True
                        break;
                if not is_empty:
                    self.wfile.write(("Форма %s не найдена..." % path).encode("utf-8"))
            except Exception as e:
                s = "Форма %s ругнулась... %s" % (path, e.args)
                self.wfile.write(s.encode("utf-8"))

            
HTTP_HOST = "0.0.0.0"
HTTP_PORT = 8082

print(
"=============================================================================\n"
"                       МОДУЛЬ HTTP ВЗАИМОДЕЙСТВИЯ v0.2\n"
"\n"
" Хост: %s \n"
" Порт: %s \n"
"=============================================================================\n"
% (HTTP_HOST, HTTP_PORT)
)

if __name__ == "__main__":
    serv = HTTPServer((HTTP_HOST, HTTP_PORT), HttpProcessor)    
    serv.serve_forever()
