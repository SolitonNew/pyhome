def decode_variable_value(typ, val):
    if typ == 'ow':
        return str(val)
    elif typ == 'pyb':
        if val:
            return "ON"
        else:
            return "OFF"
    elif typ == 'variable':
        return str(val)
