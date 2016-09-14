#!/usr/bin/python3.4
#-*- coding: utf-8 -*-

from db_connector import DBConnector
import datetime

db = DBConnector()

print(datetime.datetime.now())
n = (12 * 30 * 24 * 3600) / 1545
q = db.query(" select 1, MIN(VALUE), MAX(VALUE) "
             "   from core_variable_changes "
             "  where VARIABLE_ID = 59 "
             " group by ROUND(UNIX_TIMESTAMP(CHANGE_DATE) / %s) " % n, [])
row = q.fetchone()
c = 0
while row:
    row = q.fetchone()
    c += 1
q.close()
print(datetime.datetime.now())
print(c)
