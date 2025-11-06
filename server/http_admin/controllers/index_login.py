from base_form import BaseForm
from flask import session, request

FAILED_CONNECTS = []

class IndexLogin(BaseForm):
    ACTION = "index_login"
    VIEW = "index_login.tpl"
        
    def __init__(self):
        super().__init__()

    def create_widgets(self):
        pass

    def query(self, query_type):
        if query_type == "login":
            adm_log = self.app.config['ADMIN_LOGIN']
            adm_pass = self.app.config['ADMIN_PASS']
            global FAILED_CONNECTS
            ip = request.remote_addr
            ind = self._find_ip_index(ip)
            if ind > -1 and FAILED_CONNECTS[ind][1] > 5:
                print(ip, " blocked")
            else:
                if self.param("wh_login") == adm_log and self.param("wh_pass") == adm_pass:
                    if ind > -1:
                        del FAILED_CONNECTS[ind]
                    session['is_logon'] = True;
                    print("Connected")
                else:
                    ind = self._find_ip_index(ip)
                    if ind > -1:
                        FAILED_CONNECTS[ind][1] += 1
                    else:
                        FAILED_CONNECTS += [[ip, 1]]
        elif query_type == "logout":
            session['is_logon'] = False
        return "<script language=\"javascript\">window.location.href = \"/\";</script>"

    def _find_ip_index(self, ip):
        global FAILED_CONNECTS
        for i in range(len(FAILED_CONNECTS)):
            if FAILED_CONNECTS[i][0] == ip:
                return i
        return -1
