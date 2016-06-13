import drivers

driverList = []
variableList = []

DATE_TIME = 0

def set_variable_drivers(ow, dev_id):
    """
    Создает список драйверов устройств и назначает их переменным.
    """
    global driverList
    for var in variableList:
        var.curr_dev_id = dev_id
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
                    elif var.rom[0] == 0xf1:
                        driver = drivers.Fan(ow, var.rom)

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
            try:
                if var.driver == driver:
                    var._set_driver_value(value)
            except:
                pass

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
    global DATE_TIME
    
    for var in data:
        for vl in variableList:
            if vl.id == var[0]:
                try:
                    if vl.dev_id == 100:
                        vl.system_value(var[1])
                        if vl.id == -100:
                            if DATE_TIME != vl.value():
                                DATE_TIME = vl.value()
                                check_delays()
                    else:
                        vl.silent_value(var[1])
                except:
                    pass

def check_delays():
    """
    Функция вызывается всякий раз, как приходит сигнал изменения времени.
    При вызове выполняет проверку всех переменных с отложенным исполнением и
    если время выполнения истекло, то назначает отложенное значение переменной.
    """
    global DATE_TIME
    
    for vl in variableList:
        if vl.delayTime:
            if vl.delayTime <= DATE_TIME:
                vl.value(vl.delayValue)

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
        self.curr_dev_id = False
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
        self.delayTime = False
        self.delayValue = None

    def _set_driver_value(self, value):
        if self.channel:
            self.value(value[self.channel])
        else:
            self.value(value)

    def silent_value(self, val):
        if val == None:
            return
        self.val = val
        try:
            self.driver.value(val, self.channel)
        except:
            pass

    def system_value(self, val):
        if val == None:
            return
        if self.val != val:
            self.val = val
            if self.changeScript:
                self.changeScript()

    def value(self, val=None, delay=0):
        """
        Метод назначения/получения данных переменной.
        Параметры:
           val - значение переменной для установки. Если None, то метод вернет
                 текущее значение переменной.
           delay - время в секундах на которое отложено изменение переменной.
                   Если метод вызван с этим параметров большим 0 то изменения
                   переменной будет отложено до указанного времени. Повторный
                   вызов метода с этим параметром обновит значение времени
                   выполнения. Если значение равно 0, то предыдущие задержки
                   будут анулированы до их истечения и присваивание нового
                   значения будет выполнено немедленно.
        """
        if val == None:
            return self.val
        else:
            # Если изменение отложено, то выполнять сразу не станем, а укажем
            # переменной время изменения и нужный новый статус.
            # Повторная попытка изменения значения обновит время или немедленно
            # изменит статус.
            if delay > 0:
                global DATE_TIME
                self.delayValue = val
                self.delayTime = DATE_TIME + delay
                return
            else:
                self.delayTime = False
            
            # Убеждаемся, что переменная принадлежит текущему контроллеру
            # или является системной
            if self.dev_id == self.curr_dev_id or self.dev_id == 100:
                if self.val != val:
                    self.val = val
                    if self.driver:
                        self.driver.value(val, self.channel)
                    self.isChange = True
                    if self.changeScript:
                        self.changeScript()

    def load_value(self):
        b = self.isChange
        return (b, self.val)

    def set_change_script(self, script):
        self.changeScript = script
