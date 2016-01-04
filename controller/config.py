from variables import Variable

TERM_1 = Variable(1, 1, 0, [0x28, 0x9b, 0xf3, 0x75, 0x05, 0x00, 0x00, 0xa3], '')
TERM_2 = Variable(2, 1, 0, [0x28, 0x0e, 0x07, 0x76, 0x05, 0x00, 0x00, 0xc8], '')
SWITCH_1_LEFT = Variable(3, 1, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x1a], 'LEFT')
SWITCH_1_RIGHT = Variable(4, 1, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x1a], 'RIGHT')
LIGHT_1_FIRST = Variable(5, 1, 1, 'pyb', 'X5')
LIGHT_1_SECOND = Variable(6, 1, 1, 'pyb', 'X6')
WARMING_1 = Variable(7, 1, 1, 'pyb', 'X7')
WARMING_2 = Variable(8, 1, 1, 'pyb', 'X8')
TEMP_ROOM_1 = Variable(9, 1, 1, 'variable', '')
TEMP_ROOM_2 = Variable(10, 1, 1, 'variable', '')
TERMOSTAT_DELTA = Variable(11, 1, 1, 'variable', '')


def script_1():
    """
    Script N1
    """
    print("TERM_1: ", TERM_1.value())
    if WARMING_1.value():
        if TERM_1.value() > TEMP_ROOM_1.value():
            WARMING_1.value(False)
    else:
        if TERM_1.value() < (TEMP_ROOM_1.value() - TERMOSTAT_DELTA.value()):
            WARMING_1.value(True)

TERM_1.set_change_script(script_1)


def script_2():
    """
    Script N2
    """    
    print("TERM_2: ", TERM_2.value())
    if TERM_2.value() > TEMP_ROOM_2.value():
        WARMING_2.value(True)
    else:
        WARMING_2.value(False)

TERM_2.set_change_script(script_2)


def script_3():
    """
    Script N3
    """
    if SWITCH_1_LEFT.value():
        LIGHT_1_FIRST.value(not LIGHT_1_FIRST.value())

SWITCH_1_LEFT.set_change_script(script_3)

def script_4():
    """
    Script N4
    """
    if SWITCH_1_RIGHT.value():
        LIGHT_1_SECOND.value(not LIGHT_1_SECOND.value())

SWITCH_1_RIGHT.set_change_script(script_4)
