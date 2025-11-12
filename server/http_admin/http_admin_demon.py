#!/usr/bin/python3.6
#-*- coding: utf-8 -*-

from dotenv import load_dotenv
import os
import traceback
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
            s = "Form '%s' error:<br><b>%s</b>" % (name, e.args)
            traceback.print_exc()
        except Exception as e:
            print("Connection closed %s" % e.args)
    return res

try:
    load_dotenv()
    app.config['ADMIN_LOGIN'] = os.getenv("HTTP_ADMIN_USER")
    app.config['ADMIN_PASS'] = os.getenv("HTTP_ADMIN_PASSWORD")
    app.config['SECRET_KEY'] = os.getenv("HTTP_ADMIN_SECURE_KEY")
except:
    traceback.print_exc()

app.config['VERSION'] = "0.7"

if __name__ == '__main__':
    app.run("0.0.0.0", 8083, debug=True)
