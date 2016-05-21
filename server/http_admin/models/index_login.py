from base_form import BaseForm

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
            # Логин/Пароль в отдельном файле, который не синхронится в гите
            f = open("models/pass", "r")            
            a = f.read().split(";")
            adm_log = a[0]
            adm_pass = a[1]
            f.close()
            # -------------------------------------------------------------

            print("'" + adm_log + adm_pass + "'")
            
            global FAILED_CONNECTS
            ip = self.owner.client_address[0]

            ind = self._find_ip_index(ip)
            if ind > -1 and FAILED_CONNECTS[ind][1] > 5:
                print(ip, " заблокирован")
            else:
                if self.param_str("wh_login") == adm_log and self.param_str("wh_pass") == adm_pass:
                    if ind > -1:
                        del FAILED_CONNECTS[ind]
                    self.owner.create_session(True)
                else:
                    ind = self._find_ip_index(ip)
                    if ind > -1:
                        FAILED_CONNECTS[ind][1] += 1
                    else:
                        FAILED_CONNECTS += [[ip, 1]]
        elif query_type == "logout":
            self.owner.remove_session()
        return "<script language=\"javascript\">window.location.href = \"index\";</script>"

    def _find_ip_index(self, ip):
        global FAILED_CONNECTS
        for i in range(len(FAILED_CONNECTS)):
            if FAILED_CONNECTS[i][0] == ip:
                return i
        return -1
