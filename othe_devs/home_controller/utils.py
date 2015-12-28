def rom_to_string(rom):
    res = []
    for r in rom:
        s = hex(r)        
        if len(s) == 3:
            s = s.replace("x", "x0")
        res += [s]
        res += [" "]
    return "".join(res)
    
