from base_form import BaseForm
from widgets import TextField
from subprocess import Popen, PIPE, STDOUT
from tests.config_utils import generate_config_file
from tests.config_utils import generate_report_script

class ScriptEditor(BaseForm):
    ACTION = "scripteditor"
    VIEW = "scripteditor.tpl"

    def create_widgets(self):
        text = ""
        name = ""
        for row in self.db.select("select DATA, COMM from core_scripts where ID = %s" % self.param('key')):
            text = str(row[0], "utf-8")
            name = str(row[1], "utf-8")

        self.add_widget(TextField("NAME", name))
        self.add_widget(TextField("TEXT", text))
        self.add_widget(TextField("ID", str(self.param('key'))))

    def query(self, query_type):
        if query_type == "save":
            try:
                data = self.param('text')
                if not data:
                    data = 'pass'
                comm = self.param('NAME')
                self.db.IUD("update core_scripts set DATA = %s, COMM = %s where ID=%s", (data, comm, self.param('key')))
                self.db.commit()
            except Exception as e:
                return "%s" % (e.args)
        elif query_type == "execute":
            return self._execute()
        return "OK"

    def _execute(self):
        try:
            f_name = "tests/run_%s.py" % self.param('key')
            f = open(f_name, "w")
            data = self.param('text')
            cf = generate_config_file(self.db)
            cf_nums = len(cf.split("\n"))
            f.write(cf)
            f.write(data)
            f.write("\n")
            f.write(generate_report_script())
            f.close()
            res = Popen("/usr/bin/python3 %s" % (f_name), shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT).stdout.read()
            res = str(res, "utf-8")

            tmp = 'File "tests/run_%s.py", line ' % self.param('key')
            try:
                i_s = res.index(tmp) + len(tmp)
                try:
                    i_e = res.index(",", i_s)
                except:
                    i_e = res.index("\n", i_s)
                res_s = res[0:i_s]
                res_e = res[i_e:]
                num = int(res[i_s:i_e]) - cf_nums + 1
                return "".join([res_s, str(num), res_e])
            except:
                pass
            return res
        except Exception as e:
            return "%s" % (e.args,)
