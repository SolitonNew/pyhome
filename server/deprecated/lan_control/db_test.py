#!/usr/bin/python3
#-*- coding: utf-8 -*-

import time
from db_connector import DBConnector


def test():
    db = DBConnector()
    print("start db %s" % (time.strftime("%M:%S")))
    res = db.select("select ID, APP_CONTROL_ID, TITLE, FILE_NAME "
                    "  from media_lib "
                    " order by ID")
    print("stop db")

    print("start pack %s" % time.strftime("%M:%S"))
    cols = 0
    pack = []
    for rec in res:
        cols = 0
        for cell in rec:
            if type(cell) == bytes:
                pack += [cell.decode("utf-8").encode("cp1251")]
            else:
                pack += [str(cell).encode("cp1251")]
            pack += [b'\x01']
            cols += 1
    pack = b''.join(pack)
    print("stop pack %s" % (time.strftime("%M:%S")))
    print("")
    print(pack)
    

test()
