variableList = []

class Variable(object):
    def __init__(self, name, startValue=0):
        global variableList
        variableList += [self]
        self.name = name
        self.startVal = startValue
        self.val = startValue
        self.isUse = False
        self.isChange = False
        self.rom = ""
        self.dev_id = 1
        
    def value(self, val=None, delay=0):
        self.isUse = True
        if val != None:
            self.isChange = True
            self.val = val
        else:
            return self.val

def printInput():
    print("-------------------------------------------------------------------")
    print("* Involved variables and their initial values")
    print("")
    b = True
    for var in variableList:
        if var.isUse:
            print("    %s: %s" % (var.name, float(var.startVal)))
            b = False
    if b:
        print("    No variables are involved")
    print("")

def printChanges():
    print("* Variables modified as a result of the script execution")
    print("")
    b = True
    for var in variableList:
        if var.isChange:
            print("    %s: %s" % (var.name, float(var.val)))
            b = False
    if b:
        print("    No variables are involved")
