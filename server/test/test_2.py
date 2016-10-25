#!/usr/bin/python3.4
#-*- coding: utf-8 -*-

from db_connector import DBConnector
import datetime

db = DBConnector()

vals = []
i = 1
min_y = 9999999
max_y = -9999999

for rec in db.select("select UNIX_TIMESTAMP(CHANGE_DATE) - 1461412404, VALUE * 50 "
                     "  from core_variable_changes "
                     " where VARIABLE_ID = 59 "
                     " order by 1 "):
    vals += [str(rec[0] / 10000), ",", str(round(rec[1])), " "]
    min_y = min(min_y, rec[1])
    max_y = max(max_y, rec[1])

size = "%s %s %s %s" % (vals[0], round(min_y), vals[-4], round(max_y))
print(size)

s = ('<svg width="100%" height="100%" viewBox="' + size + '"><polyline stroke="#979797" fill="none" stroke-width="1" '
     'points="' + "".join(vals[:-1]) + '"/>'
     '</svg>')

f = open("data.html", "w")
f.write(s)
f.close()

