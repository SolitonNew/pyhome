from variables import Variable 

from variables import printInput 

from variables import printChanges 

# Variables
TERM_1 = Variable('TERM_1', 19.5625)
TERM_2 = Variable('TERM_2', 19.375)
SWITCH_1_LEFT = Variable('SWITCH_1_LEFT', 0.0)
SWITCH_1_RIGHT = Variable('SWITCH_1_RIGHT', 0.0)
LIGHT_1_FIRST = Variable('LIGHT_1_FIRST', 1.0)
LIGHT_1_SECOND = Variable('LIGHT_1_SECOND', 1.0)
WARMING_1 = Variable('WARMING_1', 1.0)
WARMING_2 = Variable('WARMING_2', 0.0)
TEMP_ROOM_1 = Variable('TEMP_ROOM_1', 20.0)
TEMP_ROOM_2 = Variable('TEMP_ROOM_2', 20.0)
TERMOSTAT_DELTA = Variable('TERMOSTAT_DELTA', 0.5)
var_1 = Variable('var_1', 0.0)
var_2 = Variable('var_2', 0.0)
var_3 = Variable('var_3', 0.0)
var_4 = Variable('var_4', 0.0)
var_5 = Variable('var_5', 0.0)
var_6 = Variable('var_6', 0.0)
var_7 = Variable('var_7', 0.0)
var_8 = Variable('var_8', 0.0)
var_9 = Variable('var_9', 0.0)
var_10 = Variable('var_10', 0.0)
var_11 = Variable('var_11', 0.0)
var_12 = Variable('var_12', 0.0)
var_13 = Variable('var_13', 0.0)
var_14 = Variable('var_14', 0.0)
var_15 = Variable('var_15', 0.0)
var_16 = Variable('var_16', 0.0)
var_17 = Variable('var_17', 0.0)
var_18 = Variable('var_18', 0.0)
var_19 = Variable('var_19', 0)
var_20 = Variable('var_20', 0)
var_21 = Variable('var_21', 0)
var_22 = Variable('var_22', 0)
var_23 = Variable('var_23', 0)
var_24 = Variable('var_24', 0)
var_25 = Variable('var_25', 0)
var_26 = Variable('var_26', 0)
var_27 = Variable('var_27', 0)
var_28 = Variable('var_28', 0)
var_29 = Variable('var_29', 0)

print("TERM_1: ", TERM_1.value())
if WARMING_1.value():
    if TERM_1.value() > TEMP_ROOM_1.value():
        WARMING_1.value(False)
else:
    if TERM_1.value() < (TEMP_ROOM_1.value() - TERMOSTAT_DELTA.value()):
        WARMING_1.value(True)
printInput()
printChanges()
