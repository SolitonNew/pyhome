from db_connector import DBConnector

def generate_variable_list(db):
    res = []
    
    templ = "%s = Variable()"
    q = db.query("select ID, NAME from core_variables order by ID")
    row = q.fetchone()    
    while row is not None:
        name = row[1].decode("utf-8")
        if name == '':
            name = "VAR_%s" % (row[0])
          
        s = templ % (name)
        res += [s, "\n"]
        row = q.fetchone()
    q.close()
    return res

def generate_config_file(db):
    res = ["from variables import Variable \n\n"]    
    res += ["# Variables\n"]
    res += generate_variable_list(db)
    res += ["\n"]
    return "".join(res)

#print(generate_config_file(DBConnector()))

