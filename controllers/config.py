from variables import Variable 

# Variables
DATE_TIME = Variable(-100, 100, 0, 'variable', '')
PODVAL_TERM = Variable(1, 1, 0, [0xf3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xe1], 'T')
ATTIC_TERM = Variable(2, 1, 0, [0x28, 0x70, 0x17, 0x75, 0x05, 0x00, 0x00, 0xb7], '')
LIVING_S = Variable(3, 1, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x1a], 'LEFT')
BOILER_S = Variable(5, 1, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xa6], 'LEFT')
BACK_DOOR_S = Variable(6, 1, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xa6], 'RIGHT')
PORTAL_S = Variable(7, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02, 0x53], 'LEFT')
PORCH_S = Variable(8, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02, 0x53], 'RIGHT')
COOK_S = Variable(9, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x25], 'RIGHT')
DINING_S = Variable(10, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x25], 'LEFT')
HALL_1_S = Variable(11, 2, 0, '', 'LEFT')
WC_1_S = Variable(12, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x8e], 'LEFT')
BEDROOM_1_MAIN_S = Variable(13, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xa6], 'LEFT')
BEDROOM_1_SECOND_S = Variable(14, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xa6], 'RIGHT')
BEDROOM_2_MAIN_S = Variable(15, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x7b], 'RIGHT')
BEDROOM_2_SECOND_S = Variable(16, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x7b], 'LEFT')
BEDROOM_3_MAIN_S = Variable(17, 1, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xf8], 'RIGHT')
BEDROOM_3_SECOND_S = Variable(18, 1, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xf8], 'LEFT')
WC_2_S = Variable(19, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x06, 0x32], 'LEFT')
SHOWER_2_S = Variable(20, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x05, 0xd0], 'LEFT')
BEDROOM_3_WC_S = Variable(21, 1, 0, [0xf0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0xb1], 'LEFT')
HALL_2_S = Variable(22, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x03, 0x0d], 'LEFT')
LIVING_R = Variable(23, 1, 1, 'pyb', 'X7')
GAME_ROOM_R = Variable(24, 1, 1, 'pyb', 'Y7')
BOILER_R = Variable(25, 1, 1, 'pyb', 'X6')
BACK_DOOR_R = Variable(26, 1, 1, 'pyb', 'X5')
PORTAL_R = Variable(27, 2, 1, 'pyb', 'Y4')
PORCH_R = Variable(28, 2, 1, 'pyb', 'X12')
COOK_R = Variable(29, 2, 1, 'pyb', 'Y3')
DINING_R = Variable(30, 2, 1, 'pyb', 'Y2')
HALL_1_R = Variable(31, 2, 1, 'pyb', 'X9')
WC_1_R = Variable(32, 2, 1, 'pyb', 'X5')
BEDROOM_1_MAIN_R = Variable(33, 2, 1, 'pyb', 'X11')
BEDROOM_1_SECOND_R = Variable(34, 2, 1, 'pyb', 'X8')
BEDROOM_2_MAIN_R = Variable(35, 2, 1, 'pyb', 'X7')
BEDROOM_2_SECOND_R = Variable(36, 2, 1, 'pyb', 'Y1')
BEDROOM_3_MAIN_R = Variable(37, 1, 1, 'pyb', 'Y8')
BEDROOM_3_SECOND_R = Variable(38, 1, 1, 'pyb', 'Y6')
WC_2_R = Variable(39, 2, 1, 'pyb', 'X1')
SHOWER_2_R = Variable(40, 2, 1, 'pyb', 'X6')
BEDROOM_3_WC_R = Variable(41, 1, 1, 'pyb', 'X8')
HALL_2_R = Variable(42, 2, 1, 'pyb', 'X10')
BEDROOM_1_TERM_S = Variable(43, 2, 0, [0x28, 0xd7, 0x69, 0x76, 0x05, 0x00, 0x00, 0x29], '')
BEDROOM_1_TERM_V = Variable(44, 2, 1, 'variable', '')
BEDROOM_1_TERM_R = Variable(45, 2, 1, '', '')
BEDROOM_2_TERM_S = Variable(46, 2, 0, [0x28, 0x40, 0x11, 0x75, 0x05, 0x00, 0x00, 0xc6], '')
BEDROOM_2_TERM_V = Variable(47, 2, 1, 'variable', '')
BEDROOM_2_TERM_R = Variable(48, 2, 1, '', '')
BEDROOM_3_TERM_S = Variable(49, 1, 0, [0xf3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xbf], 'T')
BEDROOM_3_TERM_V = Variable(50, 1, 1, 'variable', '')
BEDROOM_3_TERM_R = Variable(51, 1, 1, '', '')
HALL_2_TERM_S = Variable(56, 1, 0, '', '')
HALL_2_TERM_V = Variable(57, 2, 1, 'variable', '')
HALL_2_TERM_R = Variable(58, 2, 1, '', '')
LIVING_TERM_S = Variable(59, 1, 0, [0x28, 0xdf, 0x76, 0x75, 0x05, 0x00, 0x00, 0x13], '')
LIVING_TERM_V = Variable(60, 1, 1, 'variable', '')
LIVING_TERM_R = Variable(61, 1, 0, '', '')
GAME_ROOM_TERM_S = Variable(62, 1, 0, '', '')
GAME_ROOM_TERM_V = Variable(63, 1, 1, 'variable', '')
GAME_ROOM_TERM_R = Variable(64, 1, 0, '', '')
DINING_TERM_S = Variable(65, 2, 0, [0x28, 0x4d, 0x0a, 0x76, 0x05, 0x00, 0x00, 0x08], '')
DINING_TERM_V = Variable(66, 2, 1, 'variable', '')
DINING_TERM_R = Variable(67, 2, 0, '', '')
HALL_1_TERM_S = Variable(68, 2, 0, '', '')
HALL_1_TERM_V = Variable(69, 2, 1, 'variable', '')
HALL_1_TERM_R = Variable(70, 2, 1, '', '')
CAM_1 = Variable(75, 1, 0, 'variable', '')
BOILER_SWITCH = Variable(82, 1, 1, 'pyb', 'X9')
PODVAL_R = Variable(89, 1, 1, 'pyb', 'Y5')
GAME_ROOM_S = Variable(90, 1, 0, [0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x1a], 'RIGHT')
BACK_DOOR_TERM_IN_S = Variable(91, 1, 0, [0x28, 0xd7, 0x69, 0x76, 0x05, 0x00, 0x00, 0x29], '')
BEDROOM_3_WC_TERM = Variable(92, 1, 0, [0x28, 0x65, 0xb3, 0x75, 0x05, 0x00, 0x00, 0x2b], '')
HEATING_MAIN_OUT = Variable(93, 1, 0, [0x28, 0x29, 0xc9, 0x75, 0x05, 0x00, 0x00, 0xf3], '')
HEATING_CHIMNEY = Variable(95, 1, 0, [0x28, 0x6e, 0x24, 0x76, 0x05, 0x00, 0x00, 0xbd], '')
DEBUG_RIGHT = Variable(100, 1, 1, 'variable', '')
WC_1_FAN = Variable(103, 1, 1, [0xf1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x27], 'F3')
WC_2_FAN = Variable(104, 1, 1, [0xf1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x27], 'F1')
SHOWER_FAN = Variable(105, 1, 1, [0xf1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x27], 'F2')
BEDROOM_3_WC_FAN = Variable(106, 1, 1, '', '')
MASTER_FAN = Variable(107, 1, 1, [0xf1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x27], 'F4')
COOK_FAN = Variable(108, 2, 1, '', '')
PODVAL_MASTER_FAN = Variable(109, 2, 1, '', '')
PODVAL_COOK_FAN = Variable(110, 2, 1, '', '')
WC_1_PRESENCE = Variable(111, 2, 0, [0xf2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x82], 'P2')
WC_2_PRESENCE = Variable(112, 2, 0, [0xf2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xdc], 'P1')
SHOWER_2_PRESNCE = Variable(113, 2, 0, [0xf2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xdc], 'P4')
STAIRS_PRESENCE = Variable(114, 1, 0, '', 'P1')
STAIRS_R = Variable(115, 1, 1, 'pyb', 'Y1')
DEMO = Variable(116, 1, 1, 'variable', '')
QUIET_TIME = Variable(123, 100, 1, 'variable', '')
BACK_DOOR_TERM_OUT_S = Variable(124, 1, 0, [0x28, 0x9b, 0xf3, 0x75, 0x05, 0x00, 0x00, 0xa3], '')
BOILER_PRESENCE = Variable(125, 1, 0, [0xf2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x60], 'P1')
DAYLIGHT = Variable(126, 100, 1, 'variable', '')
BOILER_PRESENCE_OUT = Variable(127, 1, 0, [0xf2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x60], 'P2')
STAIRS_TEMP = Variable(130, 1, 0, [0xf3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x5d], 'T')
STAIRS_HUMIDITY = Variable(131, 1, 0, [0xf3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x5d], 'H')
BEDROOM_3_HUMIDITY_S2 = Variable(133, 1, 0, [0xf3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xbf], 'H')
PODVAL_HUMIDITY = Variable(134, 1, 0, [0xf3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xe1], 'H')
BOILER_CO = Variable(135, 1, 0, [0xf4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xee], '')
BEDROOM_3_CUPBOARD = Variable(136, 1, 0, [0xf0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0xb1], 'RIGHT')
PODVAL_S = Variable(137, 2, 0, [0xf0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x8e], 'RIGHT')
PORCH_TERM = Variable(138, 2, 0, '', '')
DOORBELL = Variable(139, 2, 0, '', '')
DOORBELL_2 = Variable(140, 2, 0, '', '')
WC_2_FAN_MIN = Variable(141, 100, 1, 'variable', '')
SHOWER_FAN_MIN = Variable(142, 100, 1, 'variable', '')
BEDROOM_3_WC_FAN_MIN = Variable(143, 100, 1, 'variable', '')
WC_1_FAN_MIN = Variable(144, 100, 1, 'variable', '')
WC_1_DOOR = Variable(145, 2, 0, [0xf2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x82], 'P1')
WC_2_DOOR = Variable(146, 2, 0, [0xf2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xdc], 'P2')
SHOWER_2_DOOR = Variable(147, 2, 0, [0xf2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xdc], 'P3')
WC_2_PRESENCE_DELAY = Variable(148, 2, 0, 'variable', '')
WC_1_PRESENCE_DELAY = Variable(149, 2, 0, 'variable', '')
BOILER_TEMP_S = Variable(150, 100, 1, 'variable', '')
BIOLER_ATM_PRESS = Variable(151, 100, 1, 'variable', '')
BOILER_HOT_TEMP = Variable(152, 1, 0, [0x28, 0x86, 0x91, 0x75, 0x05, 0x00, 0x00, 0x20], '')
CURRENT = Variable(153, 2, 0, [0xf5, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xd3], '')

# Scripts
def script_1():
    if LIVING_S.value() == 1:
        LIVING_R.value(not LIVING_R.value())
    elif LIVING_S.value() == 2:
        LIVING_R.value(LIVING_R.value())
        BOILER_R.value(LIVING_R.value())
        GAME_ROOM_R.value(LIVING_R.value())
        BEDROOM_3_MAIN_R.value(LIVING_R.value())
        BEDROOM_3_SECOND_R.value(LIVING_R.value())

def script_2():
    if GAME_ROOM_S.value() == 1:
        GAME_ROOM_R.value(not GAME_ROOM_R.value())

def script_3():
    if BOILER_S.value() == 1:
        BOILER_R.value(not BOILER_R.value())

def script_4():
    if BEDROOM_3_WC_S.value() == 1:
        BEDROOM_3_WC_R.value(not BEDROOM_3_WC_R.value())

def script_21():
    if WC_2_S.value():
        WC_2_R.value(not WC_2_R.value())
        
        if WC_2_R.value() == 0:
            WC_2_PRESENCE_DELAY.value(1)
            WC_2_PRESENCE_DELAY.value(0, 6)

def script_22():
    if SHOWER_2_S.value():
        SHOWER_2_R.value(not SHOWER_2_R.value())

def script_23():
    if HALL_2_S.value():
        HALL_2_R.value(not HALL_2_R.value())

def script_24():
    if BEDROOM_3_MAIN_S.value() == 1:
        BEDROOM_3_MAIN_R.value(not BEDROOM_3_MAIN_R.value())

def script_25():
    import variables
    
    for var in variables.variableList:
        var.value()

def script_26():
    if BEDROOM_3_SECOND_S.value() == 1:
        BEDROOM_3_SECOND_R.value(not BEDROOM_3_SECOND_R.value())

def script_27():
    import time
    
    #System Time of system
    sys_time = time.localtime(DATE_TIME.value())
    
    tm = sys_time[3] + sys_time[4] / 60
    
    #BOILER_SWITCH.value(tm >= BOILER_ON_HOUR.value() and tm <= BOILER_OFF_HOUR.value())

def script_28():
    if BEDROOM_1_MAIN_S.value():
        BEDROOM_1_MAIN_R.value(not BEDROOM_1_MAIN_R.value())

def script_29():
    if BEDROOM_2_MAIN_S.value():
        BEDROOM_2_MAIN_R.value(not BEDROOM_2_MAIN_R.value())

def script_30():
    if BACK_DOOR_S.value():
        BACK_DOOR_R.value(not BACK_DOOR_R.value())

def script_31():
    if PORTAL_S.value():
        PORTAL_R.value(not PORTAL_R.value())

def script_32():
    if PORCH_S.value():
        PORCH_R.value(not PORCH_R.value())

def script_33():
    if COOK_S.value():
        COOK_R.value(not COOK_R.value())

def script_34():
    if DINING_S.value():
        DINING_R.value(not DINING_R.value())
    
    HALL_1_R.value(DINING_R.value())

def script_35():
    if HALL_1_S.value():
        HALL_1_R.value(not HALL_1_R.value())

def script_36():
    if WC_1_S.value():
        WC_1_R.value(not WC_1_R.value())
        
        if WC_1_R.value() == 0:
            WC_1_PRESENCE_DELAY.value(1)
            WC_1_PRESENCE_DELAY.value(0, 6)

def script_39():
    if BEDROOM_2_SECOND_S.value():
        BEDROOM_2_SECOND_R.value(not BEDROOM_2_SECOND_R.value())

def script_40():
    if BEDROOM_1_SECOND_S.value():
        BEDROOM_1_SECOND_R.value(not BEDROOM_1_SECOND_R.value())

def script_43():
    if WC_2_R.value() and WC_2_DOOR.value():
        WC_2_FAN.value(6, 180)
    else:
        WC_2_FAN.value(WC_2_FAN_MIN.value(), 180)

def script_44():
    if WC_1_R.value() and WC_1_DOOR.value():
        WC_1_FAN.value(6, 180)
    else:
        WC_1_FAN.value(WC_1_FAN_MIN.value(), 180)

def script_45():
    c = 2
    
    if WC_1_FAN.value() > WC_1_FAN_MIN.value():
        c += 2
    
    if WC_2_FAN.value() > WC_2_FAN_MIN.value():
        c += 2
    
    if BEDROOM_3_WC_FAN.value() > BEDROOM_3_WC_FAN_MIN.value():
        c += 2
    
    if SHOWER_FAN.value() > SHOWER_FAN_MIN.value():
        c += 2
    
    if c > 4:
        MASTER_FAN.value(c)
    else:
        MASTER_FAN.value(c, 2)

def script_46():
    if BEDROOM_3_WC_R.value():
        BEDROOM_3_WC_FAN.value(10, 120)
    else:
        BEDROOM_3_WC_FAN.value(BEDROOM_3_WC_FAN_MIN.value(), 180)

def script_47():
    """
    if SHOWER_2_R.value():
        SHOWER_FAN.value(6)
    else:
        SHOWER_FAN.value(SHOWER_FAN_MIN.value(), 60)
    """

def script_48():
    if WC_1_PRESENCE_DELAY.value() == 0:
        if WC_1_PRESENCE.value():
            WC_1_R.value(1)
        else:
            WC_1_R.value(0, 180)

def script_49():
    pass

def script_50():
    import variables
    
    for var in variables.variableList:
        var.value()

def script_51():
    if BOILER_PRESENCE.value() or BOILER_PRESENCE_OUT.value():
        if not DAYLIGHT.value():
            BOILER_R.value(1)
    else:
        BOILER_R.value(0, 200)

def script_52():
    if PODVAL_S.value() == 2:
        PODVAL_R.value(not PODVAL_R.value())

def script_54():
    if WC_2_PRESENCE_DELAY.value() == 0:
        if WC_2_PRESENCE.value():
            WC_2_R.value(1)
        else:
            WC_2_R.value(0, 180)


# Links
LIVING_S.set_change_script(script_1)
GAME_ROOM_S.set_change_script(script_2)
BOILER_S.set_change_script(script_3)
BEDROOM_3_WC_S.set_change_script(script_4)
WC_2_S.set_change_script(script_21)
SHOWER_2_S.set_change_script(script_22)
HALL_2_S.set_change_script(script_23)
BEDROOM_3_MAIN_S.set_change_script(script_24)
BEDROOM_3_SECOND_S.set_change_script(script_26)
DATE_TIME.set_change_script(script_27)
BEDROOM_1_MAIN_S.set_change_script(script_28)
BEDROOM_2_MAIN_S.set_change_script(script_29)
BACK_DOOR_S.set_change_script(script_30)
PORTAL_S.set_change_script(script_31)
PORCH_S.set_change_script(script_32)
COOK_S.set_change_script(script_33)
DINING_S.set_change_script(script_34)
HALL_1_S.set_change_script(script_35)
WC_1_S.set_change_script(script_36)
BEDROOM_2_SECOND_S.set_change_script(script_39)
BEDROOM_1_SECOND_S.set_change_script(script_40)
WC_2_DOOR.set_change_script(script_43)
WC_2_R.set_change_script(script_43)
WC_1_DOOR.set_change_script(script_44)
WC_1_R.set_change_script(script_44)
BEDROOM_3_WC_FAN.set_change_script(script_45)
SHOWER_FAN.set_change_script(script_45)
WC_1_FAN.set_change_script(script_45)
WC_2_FAN.set_change_script(script_45)
BEDROOM_3_WC_R.set_change_script(script_46)
SHOWER_2_R.set_change_script(script_47)
WC_1_PRESENCE.set_change_script(script_48)
STAIRS_PRESENCE.set_change_script(script_49)
BOILER_PRESENCE.set_change_script(script_51)
BOILER_PRESENCE_OUT.set_change_script(script_51)
PODVAL_S.set_change_script(script_52)
WC_2_PRESENCE.set_change_script(script_54)
