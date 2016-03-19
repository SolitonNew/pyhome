import pyb
import math
from lcd import LCD
from lcddrv import N3210
from font import Font

l = LCD(N3210(pyb.SPI(1), 'Y10', 'Y9'))
f = Font("Ubuntu_28", True)

timer_value = 0

def timer_handler(timer):
    global timer_value
    timer_value += 1

t = pyb.Timer(1, freq=1)
t.callback(timer_handler)

def start(set_time):
    global timer_value
    if set_time:
        a = set_time.split(":")
        timer_value = int(a[0]) * 3600 + int(a[1]) * 60 + int(a[2])
        
    while 1:    
        l.clear()
        h = timer_value // 3600
        hs = h * 3600
        m = (timer_value - hs) // 60
        s = timer_value - hs - m * 60

        kh = math.trunc(h / 24)
        h = h - kh * 24

        h = "%s" % h
        if len(h) == 1:
            h = "0" + h
        m = "%s" % m
        if len(m) == 1:
            m = "0" + m
        s = "%s" % s
        if len(s) == 1:
            s = "0" + s
        
        l.text(1, 1, "%s:%s:%s" % (h, m, s), f)
        l.show()
