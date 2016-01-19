variableList = []

class Variable(object):
    def __init__(self, name, startValue = 0):
        global variableList
        variableList += [self]
        self.name = name
        self.startVal = startValue
        self.val = startValue
        self.isUse = False
        self.isChange = False
        
    def value(self, val = None):
        self.isUse = True
        if val != None:
            self.isChange = True
            self.val = val
        else:
            return self.val


def printInput():
    print("-------------------------------------------------------------------")
    print("* Задействованные переменные и их начальные значения")
    print("")
    b = True
    for var in variableList:
        if var.isUse:
            print("    %s: %s" % (var.name, float(var.startVal)))
            b = False
    if b:
        print("    переменные не задействованы")
    print("")

def printChanges():
    print("* Измененные переменные в результате работы скрипта")
    print("")
    b = True
    for var in variableList:
        if var.isChange:
            print("    %s: %s" % (var.name, float(var.val)))
            b = False
    if b:
        print("    переменные не изменялись")
