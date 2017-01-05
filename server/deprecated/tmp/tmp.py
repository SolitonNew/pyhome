#!/usr/bin/python3
#-*- coding: utf-8 -*-

import mysql.connector
from db_connector import DBConnector
import time

db = DBConnector()

for rec in db.select("select ID, VALUE from core_variable_changes "
                     " where VARIABLE_ID = 124 "
                     "   and VALUE > 100"):
    b = int(rec[1] * 16)
    if (b & (1<<15)):        
        m = b
        b = 0
        for i in range(16):
            if m & (1<<i) == 0:
                b |= (1<<i)
        b = -b
        b += 1
    print(b / 16)

    db.IUD("update core_variable_changes set VALUE = %s where ID = %s" % ((b / 16), rec[0]))
    db.commit()
