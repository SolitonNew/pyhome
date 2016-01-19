from variables import Variable 

from variables import printInput 

from variables import printChanges 

# Variables
TERM_1 = Variable('TERM_1', 22.6875)
TERM_2 = Variable('TERM_2', 22.5)
SWITCH_1_LEFT = Variable('SWITCH_1_LEFT', 0.0)
SWITCH_1_RIGHT = Variable('SWITCH_1_RIGHT', 0.0)
LIGHT_1_FIRST = Variable('LIGHT_1_FIRST', 1.0)
LIGHT_1_SECOND = Variable('LIGHT_1_SECOND', 1.0)
WARMING_1 = Variable('WARMING_1', 0.0)
WARMING_2 = Variable('WARMING_2', 1.0)
TEMP_ROOM_1 = Variable('TEMP_ROOM_1', 20.0)
TEMP_ROOM_2 = Variable('TEMP_ROOM_2', 20.0)
TERMOSTAT_DELTA = Variable('TERMOSTAT_DELTA', 0.5)
var_1 = Variable('var_1', 0.0)
var_2 = Variable('var_2', 0.0)
var_3 = Variable('var_3', 0.0)
var_4 = Variable('var_4', 0.0)
var_5 = Variable('var_5', 0.0)
var_6 = Variable('var_6', 0.0)
var_7 = Variable('var_7', 0.0)
var_8 = Variable('var_8', 0.0)
var_9 = Variable('var_9', 0.0)
var_10 = Variable('var_10', 0.0)
var_11 = Variable('var_11', 0.0)
var_12 = Variable('var_12', 0.0)
var_13 = Variable('var_13', 0.0)
var_14 = Variable('var_14', 0.0)
var_15 = Variable('var_15', 0.0)
var_16 = Variable('var_16', 0.0)
var_17 = Variable('var_17', 0.0)
var_18 = Variable('var_18', 0.0)
var_19 = Variable('var_19', 0)
var_20 = Variable('var_20', 0)
var_21 = Variable('var_21', 0)
var_22 = Variable('var_22', 0)
var_23 = Variable('var_23', 0)
var_24 = Variable('var_24', 0)
var_25 = Variable('var_25', 0)
var_26 = Variable('var_26', 0)
var_27 = Variable('var_27', 0)
var_28 = Variable('var_28', 0)
var_29 = Variable('var_29', 0)

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
printInput()
printChanges()
