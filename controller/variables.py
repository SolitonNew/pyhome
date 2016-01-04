import drivers

driverList = []
variableList = []

def set_variable_drivers(ow, dev_id):
    """
    Создает список драйверов устройств и назначает их переменным.
    """
    global driverList
    for var in variableList:
        if var.dev_id == dev_id:
            driver = False
            if var.rom:
                driver = _find_driver_at_rom(var.rom)

            if driver == False:
                if var.rom == 'variable':
                    driver = False
                if var.rom == 'pyb':
                    driver = drivers.Pyboard()
                else:
                    if var.rom[0] == 0x28:
                        driver = drivers.Termometr(ow, var.rom)
                    elif var.rom[0] == 0xf0:
                        driver = drivers.Switch(ow, var.rom)

                driverList += [driver]            
                
            var.driver = driver

            if var.rom == 'pyb':
                var.driver.declare_channel(var.channel, var.direction)


def _find_driver_at_rom(rom):
    """
    Ищет драйвер по уникальному ключу сети OneWire. Если находит - возвращает
    экземпляр этого драйвера.
    """
    if rom == 'variable':
        return False
    
    for driver in driverList:
        if driver and driver.rom == rom:
            return driver
    return False

def check_driver_value(rom):
    """
    Ищет драйвер по уникальному ключу сети OneWire и если находит дает комманду
    получения данных устройства. Далее передает полученые данные в связанную
    с устройством переменную.
    """
    driver = _find_driver_at_rom(rom)
    if driver:
        value = driver.value()
        for var in variableList:
            if var.driver == driver:
                var._set_driver_value(value)

def get_sync_change_variables():
    """
    Возвращает список переменных для синхронизации по сети RS485. Значения
    отбираются только те, что изменились с момента последней синхронизации.
    """
    res = []
    for var in variableList:
        if var.isChange:
            res += [[var.id, var.val]]
            var.isChange = False
    return res

def set_sync_change_variables(data):
    for var in data:
        for vl in variableList:
            if vl.id == var[0]:
                vl.silent_value(var[1])


class Variable(object):
    """
    Класс переменной. Содержит в себе необходимый набор свойств и методов для
    обслуживания внутренних механизмов контроллера.

    Основная задача этого класса абстрагироваться от низкого уровня составных
    элементов предоставляя разработчику универсальное АПИ для управления любым
    элементом системы.
    """
    def __init__(self, id, dev_id, direction, rom, channel):
        global variableList
        variableList += [self] # Регистрация переменной в глобальном списке
        self.id = id
        self.rom = rom
        if type(self.rom) == list:
            self.rom = bytearray(self.rom)
        self.dev_id = dev_id
        self.direction = direction
        self.channel = channel
        self.val = False
        self.isChange = False
        self.changeScript = False

    def _set_driver_value(self, value):
        if self.channel:
            self.value(value[self.channel])
        else:
            self.value(value)

    def silent_value(self, val):
        self.val = val
        self.driver.value(val, self.channel)

    def value(self, val = None):
        if val == None:
            return self.val
        else:
            if self.val != val:
                self.val = val
                self.driver.value(val, self.channel)
                self.isChange = True
                if self.changeScript:                    
                    self.changeScript()

    def load_value(self):
        b = self.isChange
        return (b, self.val)

    def set_change_script(self, script):
        self.changeScript = script
