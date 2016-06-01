#!/usr/bin/python3

import time
import curses
from subprocess import Popen, PIPE, STDOUT

SCREENS = [["Меню 1", "zzz.py", None, []],
           ["Меню 2", "", None, []],
           ["Меню 3", "", None, []],
           ["Меню 4", "", None, []],
           ["Меню 5", "", None, []]]

CURRENT_SCREEN = 0

def startProc(ind):
    global SCREENS
    if SCREENS[ind][1]:
        SCREENS[ind][2] = Popen(["/usr/bin/python3", "-u", SCREENS[ind][1]], shell=False, stdout=PIPE)


for i in range(len(SCREENS)):
    startProc(i)

scr = curses.initscr()
while True:    
    scr.erase()
    x = 0
    for i in range(len(SCREENS)):
        proc = SCREENS[i][2]
        if proc:
            while True:
                proc.stdout.flush()
                s = proc.stdout.read()
                SCREENS[i][3] += [s]
                print(s)

        btn = " %s " % SCREENS[i][0]
        if CURRENT_SCREEN == i:
            scr.addstr(0, x, btn, curses.A_REVERSE)
        else:
            scr.addstr(0, x, btn, curses.A_NORMAL)
        x += len(btn)

    scr.refresh()
    time.sleep(5)
    
#myscreen.getch()
curses.endwin()
