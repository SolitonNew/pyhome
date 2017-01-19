#!/usr/bin/python3
#-*- coding: utf-8 -*-

import time
from db_connector import DBConnector


def test():
    db = DBConnector()
    print("start db %s" % (time.strftime("%M:%S")))
    res = db.select("select ID, FILE_NAME "
                    "  from media_lib ")
    for rec in res:
        pass

    

test()
