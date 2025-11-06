from db_connector import DBConnector

def generate_variable_list(db):
    res = []
    
    templ = "%s = Variable('%s', %s)"
    q = db.query("select ID, NAME, VALUE from core_variables order by ID")
    row = q.fetchone()    
    while row is not None:
        name = str(row[1], "utf-8")
        if name == '':
            name = "VAR_%s" % (row[0])
        val = row[2]
        if val == None:
            val = 0;
        s = templ % (name, name, val)
        res += [s, "\n"]
        row = q.fetchone()
    q.close()
    return res

def generate_config_file(db):
    res = ["from variables import Variable \n\n"]
    res += ["from variables import printInput \n\n"]
    res += ["from variables import printChanges \n\n"]
    res += ["# Variables\n"]
    res += generate_variable_list(db)
    res += ["\n"]
    return "".join(res)

def generate_report_script():
    return "printInput()\n" + "printChanges()\n"
    

#print(generate_config_file(DBConnector()))

