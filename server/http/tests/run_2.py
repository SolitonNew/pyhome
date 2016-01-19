from variables import Variable 

# Variables
TERM_1 = Variable()
TERM_2 = Variable()
SWITCH_1_LEFT = Variable()
SWITCH_1_RIGHT = Variable()
LIGHT_1_FIRST = Variable()
LIGHT_1_SECOND = Variable()
WARMING_1 = Variable()
WARMING_2 = Variable()
TEMP_ROOM_1 = Variable()
TEMP_ROOM_2 = Variable()
TERMOSTAT_DELTA = Variable()
VAR_12 = Variable()
VAR_13 = Variable()
VAR_14 = Variable()
VAR_15 = Variable()
VAR_16 = Variable()
VAR_17 = Variable()
VAR_18 = Variable()
VAR_19 = Variable()
VAR_20 = Variable()
VAR_21 = Variable()
VAR_22 = Variable()
VAR_23 = Variable()
VAR_24 = Variable()
VAR_25 = Variable()
VAR_26 = Variable()
VAR_27 = Variable()
VAR_28 = Variable()
VAR_29 = Variable()
VAR_30 = Variable()
VAR_31 = Variable()
VAR_32 = Variable()
VAR_33 = Variable()
VAR_34 = Variable()
VAR_35 = Variable()
VAR_36 = Variable()
VAR_37 = Variable()
VAR_38 = Variable()
VAR_39 = Variable()
VAR_40 = Variable()

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