#!/usr/bin/python3.4
#-*- coding: utf-8 -*-

from flask import Flask, session
app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
@app.route('/<name>', methods=['GET', 'POST'])
def index(name=None):   
    if name == None:
        name = "index"

    try:
        if session['is_logon'] != True:
            name = "index_login"
    except:
        name = "index_login"
        
    from db_connector import DBConnector
    import controllers.forms
    res = ''
    try:
        for form in controllers.forms.FORMS:
            if form.ACTION == name:
                f = form()
                f.app = app
                f.db = DBConnector()
                f.create_widgets()
                res = f.run()
                f.db.disconnect()
                f.db = None
                break
    except Exception as e:
        try:
            s = "Форма '%s' ругнулась:<br><b>%s</b>" % (path, e.args)
            self.wfile.write(s.encode("utf-8"))
        except Exception as e:
            print("Вероятно закрылось соединение и %s" % e.args)
    return res

try:
    # Логин/Пароль/Ключ в отдельном файле, который не синхронится в гите
    f = open('pass', 'r')
    app.config['ADMIN_LOGIN'] = f.readline().replace("\n", "")
    app.config['ADMIN_PASS'] = f.readline().replace("\n", "")
    app.config['SECRET_KEY'] = f.readline().replace("\n", "")
    f.close()
except:
    pass

app.config['VERSION'] = "0.6"

if __name__ == '__main__':
    app.run("0.0.0.0", 8083)
