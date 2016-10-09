from base_form import BaseForm
import time
from widgets import TextField
from widgets import ListField

class SchedulerEditDialog(BaseForm):
    ACTION = "scheduler_edit_dialog"
    VIEW = "scheduler_edit_dialog.tpl"

    def create_widgets(self):
        KEY = self.param_str("key")
        COMM, ACTION, INTERVAL_TYPE, INTERVAL_TIME_OF_DAY, INTERVAL_DAY_OF_TYPE = ("", "", 0, "", "")

        for row in self.db.select("select COMM, ACTION, INTERVAL_TYPE, INTERVAL_TIME_OF_DAY, INTERVAL_DAY_OF_TYPE "
                                  "  from core_scheduler where ID = '%s'" % KEY):
            COMM = str(row[0], "utf-8")
            ACTION = str(row[1], "utf-8")
            INTERVAL_TYPE = row[2]
            INTERVAL_TIME_OF_DAY = str(row[3], "utf-8")
            INTERVAL_DAY_OF_TYPE = str(row[4], "utf-8")
    
        self.add_widget(TextField("KEY", KEY))
        self.add_widget(TextField("COMM", COMM))
        self.add_widget(TextField("ACTION", ACTION))
        self.add_widget(ListField("INTERVAL_TYPE_LIST", 0, 1, INTERVAL_TYPE, [[0, "Каждый день"], [1, "Каждую неделю"], [2, "Каждый месяц"], [3, "Каждый год"]]))
        self.add_widget(TextField("INTERVAL_TIME_OF_DAY", INTERVAL_TIME_OF_DAY))
        self.add_widget(TextField("INTERVAL_DAY_OF_TYPE", INTERVAL_DAY_OF_TYPE))
                                                                                                                                
    def query(self, query_type):
        if query_type == "update":
            sql = ""
            if self.param_str('SCHEDULER_KEY') == '-1':
                sql = ("insert into core_scheduler "
                       "   (COMM, ACTION, INTERVAL_TYPE, INTERVAL_TIME_OF_DAY, INTERVAL_DAY_OF_TYPE) "
                       "values "
                       "   ('%s', '%s', %s, '%s', '%s')")

                sql = sql % (self.param_str('SCHEDULER_COMM'),
                             self.param_str('SCHEDULER_ACTION'),
                             self.param_str('SCHEDULER_INTERVAL_TYPE'),
                             self.param_str('SCHEDULER_INTERVAL_TIME_OF_DAY'),
                             self.param_str('SCHEDULER_INTERVAL_DAY_OF_TYPE'))
            else:
                sql = ("update core_scheduler "
                       "   set COMM = '%s',"
                       "       ACTION = '%s',"
                       "       INTERVAL_TYPE = %s,"
                       "       INTERVAL_TIME_OF_DAY = '%s',"
                       "       INTERVAL_DAY_OF_TYPE = '%s', "
                       "       ACTION_DATETIME = NULL "
                       " where ID = %s")
            
                sql = sql % (self.param_str('SCHEDULER_COMM'),
                             self.param_str('SCHEDULER_ACTION'),
                             self.param_str('SCHEDULER_INTERVAL_TYPE'),
                             self.param_str('SCHEDULER_INTERVAL_TIME_OF_DAY'),
                             self.param_str('SCHEDULER_INTERVAL_DAY_OF_TYPE'),
                             self.param_str('SCHEDULER_KEY'))
            try:
                self.db.IUD(sql)
                self.db.commit()
                return "OK"
            except Exception as e:
                self.db.rollback()
                return "ERROR: {}".format(e.args)
            
        elif query_type == "delete":
            try:
                key = self.param("SCHEDULER_KEY")
                self.db.IUD("delete from core_scheduler where ID = %s" % (key))
                self.db.commit()
                return "OK"
            except Exception as e:
                self.db.rollback()
                return "ERROR: {}".format(e.args)
            
        elif query_type == "test":
            self.db.IUD("insert into core_execute (COMMAND) values ('%s')" % (self.param_str("SCHEDULER_ACTION")))
            self.db.commit()
            return "OK"
