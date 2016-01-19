class Variable(object):
    def __init__(self):
        self.val = 0;
        
    def value(self, val = None):
        if val != None:
            self.val = val
        else:
            return self.val
