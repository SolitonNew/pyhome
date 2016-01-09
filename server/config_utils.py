from db_connector import DBConnector

def get_ow_roms(db):
    lst = []
    sql = "select ID, ROM_1, ROM_2, ROM_3, ROM_4, ROM_5, ROM_6, ROM_7, ROM_8 from core_ow_devs"
    q = db.query(sql)
    row = q.fetchone()    
    while row is not None:
        res = ["["]
        for b in range(1, len(row)):
            res += [hex(row[b]), ', ']

        del res[len(res) - 1]
        res += ["]"]
        lst += [[row[0], "".join(res)]]
        row = q.fetchone()
    q.close()
    return lst


def generate_variable_list(db):
    roms = get_ow_roms(db)
    
    templ = "%s = Variable(%d, %d, %d, '%s', '%s')"
    q = db.query("select NAME, ID, CONTROLLER_ID, DIRECTION, ROM, CHANNEL, OW_ID from core_variables order by ID")
    row = q.fetchone()    
    while row is not None:
        name = row[0].decode("utf-8")
        rom = row[4].decode("utf-8")
        if rom == "ow":
            for rrr in roms:
                if rrr[0] == row[6]:
                    rom = rrr[1]
        channel = ''
        if row[5]:
            channel = row[5].decode("utf-8")
        if name == '':
            name = "VAR_%s" % (row[1])
          
        s = templ % (name, row[1], row[2], row[3], rom, channel)
        print(s)
        row = q.fetchone()
    q.close()

def generate_script_list(db):
    pass

def generate_config_file(db):
    return "Config file"


"""
db = DBConnector()
print("from variables import Variable")
print("")
generate_variable_list(db)
"""
