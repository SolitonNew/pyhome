from variables import Variable 

from variables import printInput 

from variables import printChanges 

# Variables
TERM_1 = Variable('TERM_1', 22.1875)
TERM_2 = Variable('TERM_2', 21.75)
LIVING_S = Variable('LIVING_S', 0.0)
WINTER_GARDEN_S = Variable('WINTER_GARDEN_S', 0.0)
BOILER_S = Variable('BOILER_S', 0.0)
BACK_DOOR_S = Variable('BACK_DOOR_S', 0.0)
PORTAL_S = Variable('PORTAL_S', 0.0)
PORCH_S = Variable('PORCH_S', 0.0)
COOK_S = Variable('COOK_S', 0.0)
DINING_S = Variable('DINING_S', 0.0)
HALL_1_S = Variable('HALL_1_S', 0.0)
WC_1_S = Variable('WC_1_S', 0.0)
BEDROOM_1_MAIN_S = Variable('BEDROOM_1_MAIN_S', 0.0)
BEDROOM_1_SECOND_S = Variable('BEDROOM_1_SECOND_S', 0.0)
BEDROOM_2_MAIN_S = Variable('BEDROOM_2_MAIN_S', 0.0)
BEDROOM_2_SECOND_S = Variable('BEDROOM_2_SECOND_S', 0.0)
BEDROOM_3_MAIN_S = Variable('BEDROOM_3_MAIN_S', 0.0)
BEDROOM_3_SECOND_S = Variable('BEDROOM_3_SECOND_S', 0.0)
WC_2_S = Variable('WC_2_S', 0.0)
SHOWER_2_S = Variable('SHOWER_2_S', 0.0)
BEDROOM_3_WC_S = Variable('BEDROOM_3_WC_S', 0.0)
HALL_2_S = Variable('HALL_2_S', 0.0)
LIVING_R = Variable('LIVING_R', 0.0)
WINTER_GARDEN_R = Variable('WINTER_GARDEN_R', 0.0)
BOILER_R = Variable('BOILER_R', 0.0)
BACK_DOOR_R = Variable('BACK_DOOR_R', 0.0)
PORTAL_R = Variable('PORTAL_R', 1.0)
PORCH_R = Variable('PORCH_R', 1.0)
COOK_R = Variable('COOK_R', 1.0)
DINING_R = Variable('DINING_R', 1.0)
HALL_1_R = Variable('HALL_1_R', 1.0)
WC_1_R = Variable('WC_1_R', 1.0)
BEDROOM_1_MAIN_R = Variable('BEDROOM_1_MAIN_R', 1.0)
BEDROOM_1_SECOND_R = Variable('BEDROOM_1_SECOND_R', 1.0)
BEDROOM_2_MAIN_R = Variable('BEDROOM_2_MAIN_R', 1.0)
BEDROOM_2_SECOND_R = Variable('BEDROOM_2_SECOND_R', 1.0)
BEDROOM_3_MAIN_R = Variable('BEDROOM_3_MAIN_R', 0.0)
BEDROOM_3_SECOND_R = Variable('BEDROOM_3_SECOND_R', 0.0)
WC_2_R = Variable('WC_2_R', 1.0)
SHOWER_2_R = Variable('SHOWER_2_R', 1.0)
BEDROOM_3_WC_R = Variable('BEDROOM_3_WC_R', 0.0)
HALL_2_R = Variable('HALL_2_R', 1.0)

import variables

for var in variables.variableList:
    var.value()
printInput()
printChanges()
