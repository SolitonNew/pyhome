import gc
from micropython import mem_info
from timethread import TimeThread
from pyb import Pin
from lcd import LCD
from lcddrv import TriumMars
from pyb import SPI
from onewire import OneWire
from ds18b20 import DS18B20
from image import BMP
from font import Font
from lcdfont import LCDfont
import math

# Global variables

masterTemp = 30 # Set temperature
workMode = 0 # Set work mode
action_names = ['Главный насос', 'Насос ТП']
actions = [[0, 0, 0, 0], [0, 0, 0, 0]]
control_names = ['Подкинуть дров', 'Заело заслонку', 'Перегрев котла', 'Перегрев трубы']
controls = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
temp_names = ['Подача', 'Обратка', 'Дымоход', 'ТП подача', 'ТП обратка']
temp_roms = [bytearray(8), bytearray(8), bytearray(8), bytearray(8), bytearray(8)]
temps = [0, 0, 0, 0, 0] # Current values of temperature
prev_temps = [0, 0, 0, 0, 0] # Previous values of temperature

# -------------------

ver = 5
loaded_props = bytearray(3 + 5 * 8 + 2 * 4 + 4 * 4)

def save_props():
    ba = bytearray(len(loaded_props))
    ba[0] = ver
    ba[1] = masterTemp
    ba[2] = workMode
    i = 3
    for rom in temp_roms:
        for b in rom:
            ba[i] = b
            i += 1

    for a in actions:
        for b in a:
            ba[i] = b
            i += 1

    for c in controls:
        for b in c:
            ba[i] = b
            i += 1

    if loaded_props != ba:
        f = open('props', 'wb')
        f.write(ba)
        f.close()

def load_props():
    global loaded_props
    global masterTemp
    global workMode
    global temp_roms
    global actions
    global controls
    try:
        f = open('props', 'rb')
        loaded_props = f.read()
        if loaded_props[0] == ver:            
            masterTemp = loaded_props[1]
            workMode = loaded_props[2]
            i = 3
            for romI in range(5):
                rom = bytearray(8)
                for bI in range(8):
                    rom[bI] = loaded_props[i]
                    i += 1
                temp_roms[romI] = rom

            for a in range(2):
                for ai in range(4):
                    actions[a][ai] = loaded_props[i]
                    i += 1

            for c in range(4):
                for ci in range(4):
                    controls[c][ci] = loaded_props[i]
                    i += 1
        f.close()
    except:
        pass

load_props()

class ButtonPin(Pin):    
    stateUp = 0
    stateDown = 0

    def is_down(self):
        res = False
        if self.value() == 0:
            if self.stateDown == 0:
                res = True
                self.stateDown = 1
        else:
            self.stateDown = 0
        return res

    def is_up(self):
        res = False
        if self.value() == 0:
            if self.stateUp == 0:
                self.stateUp = 1
        elif self.stateUp == 1:
            res = True            
            self.stateUp = 0
        else:
            self.stateUp = 0
        return res

    def is_down_long(self, andStop = False):
        res = False
        if self.value() == 0:
            self.stateDown += 1
        else:
            self.stateDown = 0
        if self.stateDown > 300 and self.stateUp > -1:
            res = True
            if andStop:
                self.stateDown = 0
                self.stateUp = -1
        return res

    def is_pressed(self):
        return self.value() == 0
        

# Init buttons
btnUp = ButtonPin('X3', Pin.IN, Pin.PULL_UP)
btnDown = ButtonPin('X2', Pin.IN, Pin.PULL_UP)
btnOk = ButtonPin('X1', Pin.IN, Pin.PULL_UP)

# Init relays
rele1 = Pin('Y9', Pin.OUT_PP)
rele2 = Pin('Y10', Pin.OUT_PP)
rele3 = Pin('Y11', Pin.OUT_PP)
rele4 = Pin('Y12', Pin.OUT_PP)

# Init display
spi = SPI(1)
lcd = LCD(TriumMars(spi, 'X5', 'X7'), False)
lcd.contrast(25)

# Init OneWire
ow = OneWire('X4')
ds = DS18B20(ow)

resourses = None

class Resourses(object):
    def __init__(self):
        self.mainImage = BMP('images/main.bmp') #self.load_image('images/main.bmp')
        self.btn1Image = BMP('images/btn1.bmp') # self.load_image('images/btn1.bmp')
        self.btn2Image = BMP('images/btn2.bmp') #self.load_image('images/btn2.bmp')
        self.btn3Image = BMP('images/btn3.bmp') #self.load_image('images/btn3.bmp')  
        self.fn_numsmile = Font('fonts/nums_smile', True)
        self.fn_numlarge = LCDfont(20, 40, 4)
        self.fn_smile = Font('fonts/smile', True)
        self.fn_middle = Font('fonts/middle', True)

    def load_image(self, fname):
        bmp = BMP(fname)
        res = bmp.pixels()
        bmp.close()
        return res

th = TimeThread(1, True)
currScreen = False

class BaseScreen(object):
    def show_screen(self, screenClass):
        global currScreen        
        currScreen = screenClass()
    
    def key_up(self): # Event of KEY_UP
        pass
    def key_down(self): # Event of KEY_DOWN
        pass
    def key_ok(self, isLong): # Event of SYSTEM KEY
        pass
    def timer_ping(self): # Time event with delay 500mls
        pass
    def temp_change(self, temp_num): # 
        pass

class SplashScreen(BaseScreen):
    def __init__(self):
        global resourses
        #bmp = BMP('images/mp.bmp')
        #lcd.image((lcd.width() - bmp.width()) // 2, (lcd.height() - bmp.height()) // 2, bmp)
        #bmp.close()
        lcd.show()

        resourses = Resourses()        

class MainScreen(BaseScreen):
    def __init__(self):
        self.state = 0
        self.stateDelay = 0
        self._full_repaint()

    def _full_repaint(self):
        lcd.clear()
        lcd.image(0, 0, resourses.mainImage)
        self._master_temp_repaint()
        self._mode_repaint()
        self._term_1_repaint()
        self._term_2_repaint()
        self._term_3_repaint()
        self._term_4_repaint()
        self._term_5_repaint()
        lcd.show()

    def _mode_repaint(self):
        lcd.image(2, 46, resourses.btn1Image, workMode == 0)
        lcd.image(20, 46, resourses.btn2Image, workMode == 1)
        lcd.image(38, 46, resourses.btn3Image, workMode == 2)

    def _master_temp_repaint(self, empty = False):
        lcd.clear_rect(0, 0, 55, 44)
        if self.state:
            s = '%2.0d' % masterTemp
        else:
            s = '%2.0d' % temps[0]

        if not empty:
            ts = lcd.calc_text_size(s, resourses.fn_numlarge)
            cx = (54 - ts[0]) // 2
            cy = (44 - ts[1]) // 2
            lcd.text(cx, cy, s, resourses.fn_numlarge)

    def _term_1_repaint(self):
        lcd.clear_rect(73, 2, lcd.width() - 1, 10)
        lcd.text(73, -1, '%2.1f' % temps[0], resourses.fn_numsmile)

    def _term_2_repaint(self):
        lcd.clear_rect(73, 13, lcd.width() - 1, 21)
        lcd.text(73, 10, '%2.1f' % temps[1], resourses.fn_numsmile)

    def _term_3_repaint(self):
        lcd.clear_rect(73, 28, lcd.width() - 1, 36)
        lcd.text(73, 25, '%2.1f' % temps[2], resourses.fn_numsmile)

    def _term_4_repaint(self):
        lcd.clear_rect(73, 42, lcd.width() - 1, 50)
        lcd.text(73, 39, '%2.1f' % temps[3], resourses.fn_numsmile)

    def _term_5_repaint(self):
        lcd.clear_rect(73, 53, lcd.width() - 1, 61)
        lcd.text(73, 50, '%2.1f' % temps[4], resourses.fn_numsmile)
        
    def key_up(self):
        if self.set_mastertemp():        
            global masterTemp
            masterTemp += 1
            if masterTemp > 99:
                masterTemp = 99
        self._master_temp_repaint()
        lcd.show()        
        
    def key_down(self):
        if self.set_mastertemp():
            global masterTemp
            masterTemp -= 1
            if masterTemp < 30:
                masterTemp = 30
        self._master_temp_repaint()
        lcd.show()
        
    def key_ok(self, isLong):
        if isLong:
            self.show_screen(PropScreen)
        else:
            global workMode        
            workMode += 1
            if workMode > 2:
                workMode = 0
            self._mode_repaint()
            lcd.show()

    def set_mastertemp(self):        
        res = self.state
        self.state = 1
        self.stateDelay = 11
        return res

    def timer_ping(self):
        if self.stateDelay > 0:
            self.stateDelay -= 1

        if self.stateDelay == 0:
            self.state = 0

        if self.stateDelay < 10:
            if self.state == 1:
                self.state = 2
            elif self.state == 2:
                self.state = 1

        self._master_temp_repaint(self.state == 2)
        lcd.show()

    def temp_change(self, temp_num):        
        paints = (self._term_1_repaint,
                  self._term_2_repaint,
                  self._term_3_repaint,
                  self._term_4_repaint,
                  self._term_5_repaint)
        if self.stateDelay == 0:
            self._master_temp_repaint()
        paints[temp_num]()
        lcd.show()

class ListBox(object):
    def __init__(self, x, y, w, h, listData, font):
        self.left = x
        self.top = y
        self.width = w
        self.height = h
        self.listData = listData
        self.font = font
        self.scroll = 0
        self.selIndex = 0
        self.itemRenderer = False
        self.itemHeight = font.height()

    def _is_show_scroller(self):
        return len(self.listData) * self.itemHeight > self.height

    def redraw(self):
        left = self.left
        top = self.top
        right = self.left + self.width
        bottom = self.top + self.height
        
        lcd.clear_rect(left, top, right, bottom)

        for i in range(len(self.listData)):
            self._redraw_item(i)

        right -= 5

        if self._is_show_scroller():
            lcd.rect(right, top, right + 5, bottom)            
            dy = (bottom - top - 4) / len(self.listData)
            y = round(self.selIndex * dy) + top + 2
            lcd.line(right + 2, y, right + 2, y + round(dy))
            lcd.line(right + 3, y, right + 3, y + round(dy))
        
    def _redraw_item(self, index):
        if ((index - self.scroll) * self.itemHeight < 0 or
            (index - self.scroll) * self.itemHeight > self.height):
            return
        left = self.left
        top = self.top + (index - self.scroll) * self.itemHeight
        right = self.left + self.width       
        if self._is_show_scroller():
            right -= 6
        bottom = top + self.itemHeight - 1
        if bottom > self.top + self.height:
            bottom = self.top + self.height
        if top > bottom:
            top = bottom
        if self.itemRenderer:
            self.itemRenderer(self, index, left, top, right, bottom)
        else:
            self.paint_item(index, left, top, right, bottom)

    def paint_item(self, index, left, top, right, bottom):
        line = self.listData[index]       
        size = lcd.calc_text_size(line, self.font)
        if self.selIndex == index:
            lcd.rect(left, top, right, bottom, True)
            lcd.clear_rect(left + 5, top, left + 5 + size[0] - 1, top + size[1] - 1)
        lcd.text(left + 5, top, line, self.font, False, self.selIndex == index,
                 [left, top, right, bottom])

    def indexUp(self):
        self.selIndex -= 1
        if self.selIndex < 0:
            self.selIndex = len(self.listData) - 1
        self.check_sel_index()
        self.redraw()
        lcd.show()

    def indexDown(self):
        self.selIndex += 1
        if self.selIndex >= len(self.listData):
            self.selIndex = 0
        self.check_sel_index()
        self.redraw()
        lcd.show()

    def check_sel_index(self):
        c = math.floor(self.height / self.itemHeight)
        if self.selIndex - self.scroll >= c:
            self.scroll = self.selIndex - c + 1
        if self.selIndex < self.scroll:
            self.scroll = self.selIndex

class BasePropScreen(BaseScreen):
    def __init__(self, caption, items):
        self.caption = caption
        self.popupList = False        
        try:
            l, t, r, b = self.listBoxBounds
        except:
            l, t, r, b = 0, 10, lcd.width() - 1, lcd.height() - 11

        try:
            self.font
        except:
            self.font = resourses.fn_middle
            
        self.listBox = ListBox(l, t, r, b, items, self.font)
        try:
            self.listBox.itemRenderer = self.itemRenderer
        except:
            pass

        try:
            self.listBox.itemHeight = self.itemHeight
        except:
            pass

        try:
            self.listBox.selIndex = self.selIndex
        except:
            pass
        
        self.redraw()

    def redraw(self, show = True):
        lcd.clear()
        size = lcd.calc_text_size(self.caption, resourses.fn_smile)
        fx = (self.listBox.width - size[0]) // 2
        lcd.text(fx, -1, self.caption, resourses.fn_smile)
        lcd.line(0, 4, fx - 2, 4)
        lcd.line(fx + size[0] + 2, 4, lcd.width() - 1, 4)
        lcd.line(0, 6, fx - 2, 6)
        lcd.line(fx + size[0] + 2, 6, lcd.width() - 1, 6)
        self.listBox.redraw()
        if show:
            lcd.show()

    def key_up(self):
        if not self.popupList:
            self.listBox.indexUp()
        else:
            self.popupList.indexUp()

    def key_down(self):
        if not self.popupList:
            self.listBox.indexDown()
        else:
            self.popupList.indexDown()

    def show_popup_list(self, x, y, w, h, items, selIndex):
        lcd.rect(x - 1, y - 1, x + w + 3, y + h + 3)
        lcd.clear_rect(x - 1, y - 1, x + w + 1, y + h + 1)
        lcd.rect(x - 2, y - 2, x + w + 2, y + h + 2)
        self.popupList = ListBox(x, y, w, h, items, resourses.fn_smile)
        self.popupList.selIndex = selIndex
        self.popupList.check_sel_index()
        self.popupList.redraw()
        lcd.show()

    def hide_popup_list(self):
        self.popupList = False
        self.redraw()

propScreenIndex = 0
        
class PropScreen(BasePropScreen):
    def __init__(self):
        self.selIndex = propScreenIndex
        super().__init__('Настройки', ['Термометры', 'Управление', 'Контроль'])

    def key_ok(self, isLong):
        if isLong:
            self.show_screen(MainScreen)
        else:
            global propScreenIndex
            
            if self.listBox.selIndex == 0:
                self.show_screen(TermPropScreen)
                propScreenIndex = 0
            elif self.listBox.selIndex == 1:
                self.show_screen(ActionsPropScreen)
                propScreenIndex = 1
            else:
                self.show_screen(ControlPropScreen)
                propScreenIndex = 2

class TermPropScreen(BasePropScreen):
    def __init__(self):
        scan_terms()
        
        lst = []
        for i in range(len(temps)):
            s = '%s: %2.1f' % (temp_names[i], temps[i])
            lst += [s]
        self.itemRenderer = self._itemRenderer
        super().__init__('Термометры', lst)

    def _itemRenderer(self, sender, index, left, top, right, bottom):
        label = temp_names[index]
        value = '%2.1f' % temps[index]
        
        sizeLabel = lcd.calc_text_size(label, sender.font)
        sizeValue = lcd.calc_text_size(value, sender.font)
        
        if sender.selIndex == index:
            lcd.rect(left, top, right, bottom, True)
            lcd.clear_rect(left + 5, top, left + 5 + sizeLabel[0] - 1, bottom)
            lcd.clear_rect(right - 5 - sizeValue[0], top,
                           right - 5 - 1, bottom)
            
        lcd.text(left + 5, top, label, sender.font,
                 False, sender.selIndex == index, [left, top, right, bottom])
        lcd.text(right - sizeValue[0] - 5, top, value, sender.font,
                 False, sender.selIndex == index, [left, top, right, bottom])

    def _get_temp_s(self):        
        ts = []
        for t in temps:
            ts += ['%2.1f' % t]
        return ts

    def key_ok(self, isLong):
        if isLong:
            save_props()
            self.show_screen(PropScreen)
        else:
            if not self.popupList:
                r = self.listBox.left + self.listBox.width
                self.show_popup_list(r - 45, 15, 40, self.listBox.height - 10,
                                     self._get_temp_s(), self.listBox.selIndex)
            else:
                change_terms_items(self.listBox.selIndex, self.popupList.selIndex)
                self.hide_popup_list()

    def temp_change(self, temp_num):
        if not self.popupList:
            self.redraw()
        else:
            self.popupList.listData = self._get_temp_s()
            self.popupList.redraw()
            lcd.show()

actionsPropScreenIndex = 0
class ActionsPropScreen(BasePropScreen):
    def __init__(self):
        self.selIndex = actionsPropScreenIndex
        self.itemRenderer = self._itemRenderer
        self.itemHeight = 26
        self.labels = ['авто...', 'вкл.', 'откл.']
        super().__init__('Управление', action_names)

    def key_ok(self, isLong):
        if isLong:
            save_props()
            self.show_screen(PropScreen)
        else:
            if not self.popupList:
                listHeight = len(self.labels) * resourses.fn_smile.height()
                l = self.listBox.left + self.listBox.width - 45
                t = self.listBox.top + 11
                self.show_popup_list(l, t, 40, listHeight, self.labels,
                                     actions[self.listBox.selIndex][0])
            else:
                actions[self.listBox.selIndex][0] = self.popupList.selIndex
                if self.popupList.selIndex == 0:
                    global actionsPropScreenIndex
                    actionsPropScreenIndex = self.listBox.selIndex
                    self.show_screen(ActionQueryPropScreen)
                else:
                    self.hide_popup_list()

    def _itemRenderer(self, sender, index, left, top, right, bottom):
        font2 = sender.font
        top2 = top + 11
        line = sender.listData[index]
        line2 = self.labels[actions[index][0]]
        size = lcd.calc_text_size(line, sender.font)
        size2 = lcd.calc_text_size(line2, font2)
        if sender.selIndex == index:
            lcd.rect(left, top, right, bottom, True)
            lcd.clear_rect(left + 5, top, left + 5 + size[0] - 1, top + size[1] - 1)
        lcd.text(left + 5, top, line, sender.font, False, sender.selIndex == index,
                 [left, top, right, bottom])

        if sender.selIndex == index:
            lcd.clear_rect(right - 5 - size2[0], top2 + 2, right - 5 - 1, top2 + size[1] - 1)
        lcd.text(right - 5 - size2[0], top2, line2, font2, False, sender.selIndex == index,
                 [left, top2 + 2, right, bottom])

controlPropScreenIndex = 0
class ControlPropScreen(BasePropScreen):
    def __init__(self):
        self.selIndex = controlPropScreenIndex
        self.itemRenderer = self._itemRenderer
        self.itemHeight = 26
        self.labels = ['вкл.', 'откл.']
        super().__init__('Контроль', control_names)

    def key_ok(self, isLong):
        if isLong:
            save_props()
            self.show_screen(PropScreen)
        else:
            if not self.popupList:
                listHeight = len(self.labels) * resourses.fn_smile.height()
                l = self.listBox.left + self.listBox.width - 45
                t = self.listBox.top + 11
                self.show_popup_list(l, t, 40, listHeight, self.labels,
                                     controls[self.listBox.selIndex][0])
            else:
                controls[self.listBox.selIndex][0] = self.popupList.selIndex
                if self.popupList.selIndex == 0:
                    global controlPropScreenIndex
                    controlPropScreenIndex = self.listBox.selIndex
                    self.show_screen(ControlQueryPropScreen)
                else:
                    self.hide_popup_list()

    def _itemRenderer(self, sender, index, left, top, right, bottom):
        font2 = sender.font
        top2 = top + 11
        line = sender.listData[index]
        line2 = self.labels[controls[index][0]]
        size = lcd.calc_text_size(line, sender.font)
        size2 = lcd.calc_text_size(line2, font2)
        if sender.selIndex == index:
            lcd.rect(left, top, right, bottom, True)
            lcd.clear_rect(left + 5, top, left + 5 + size[0] - 1, top + size[1] - 1)
        lcd.text(left + 5, top, line, sender.font, False, sender.selIndex == index,
                 [left, top, right, bottom])

        if sender.selIndex == index:
            lcd.clear_rect(right - 5 - size2[0], top2 + 4, right - 5 - 1, top2 + size[1] - 1)
        lcd.text(right - 5 - size2[0], top2, line2, font2, False, sender.selIndex == index,
                 [left, top2 + 4, right, bottom])

class QueryPropScreen(BasePropScreen):
    def key_ok(self, isLong):
        if isLong:
            save_props()
            self.show_screen(PropScreen)
        else:
            pass

class ActionQueryPropScreen(BasePropScreen):
    def __init__(self):
        self.condition = ('больше', 'меньше')
        self.font = resourses.fn_smile
        self.listBoxBounds = [0, 25, lcd.width() - 1, lcd.height() - 11]
        super().__init__(action_names[actionsPropScreenIndex], ['', '', ''])
        self._recalcListLabels()

    def _recalcListLabels(self):        
        self.listBox.listData[0] = action_names[actions[1]]
        self.listBox.listData[1] = self.condition[actions[2]]
        self.listBox.listData[2] = str(actions[3])

    def redraw(self, show = True):
        super().redraw(False)
        lcd.text(5, 10, 'включить если:', resourses.fn_middle)
        lcd.show()

    def key_ok(self, isLong):
        if isLong:
            save_props()
            self.show_screen(ActionsPropScreen)
        else:
            pass
        
class ControlQueryPropScreen(BasePropScreen):
    def __init__(self):        
        super().__init__('Контроль', ['Оповестить если:', 'Темп.подачи', 'больше', '45'])

def scan_terms():
    finds = []
    ow.search()
    ls = ow.dev_list(0x28)

    for i in range(len(ls) - 1, -1, -1):
        rom = ls[i]
        try:
            finds += [temp_roms.index(rom)]
            del ls[i]
        except:
            pass
    
    for i in range(len(temp_roms)):
        try:
            finds.index(i)            
        except:
            if len(ls) > 0:
                temp_roms[i] = ls[0]
                del ls[0]
            else:
                temp_roms[i] = bytearray(8)
    
ds.start_measure()

currScreen = SplashScreen()
timer_ping_lock = False
sleep_delay = -1
sleep_delay_max = 15

def buttonsLoop():
    global sleep_delay
    
    if btnUp.is_down() or btnUp.is_down_long():
        sleep_delay = sleep_delay_max
        currScreen.key_up()        

    if btnDown.is_down() or btnDown.is_down_long():
        sleep_delay = sleep_delay_max
        currScreen.key_down()

    global timer_ping_lock
    timer_ping_lock = btnUp.is_pressed() or btnDown.is_pressed()
    
    if btnOk.is_down_long(True):
        sleep_delay = sleep_delay_max
        currScreen.key_ok(True)
    elif btnOk.is_up():
        sleep_delay = sleep_delay_max
        currScreen.key_ok(False)

    th.set_time_out(1, buttonsLoop)

def start():
    currScreen.show_screen(MainScreen)
    buttonsLoop()
    timer_ping()

def timer_ping():
    global sleep_delay
    if not timer_ping_lock:
        currScreen.timer_ping()
        if sleep_delay > -1:
            if sleep_delay == 0 and type(currScreen) == MainScreen:
                save_props()
            sleep_delay -= 1
    th.set_time_out(400, timer_ping)

sel_temp = 0

def calculate():
    relays = (rele1, rele2)

    # Actions
    if type(currScreen) != ActionQueryPropScreen:
        for i in range(len(actions)):
            act = actions[i]
            if act[0] == 0: # automat
                dt = 3
                t = temps[act[1]]
                q = act[2]
                v = act[3]
                if q == 0: # more
                    if relays[i].value():
                        relays[i].value((t - dt) > v)
                    else:
                        relays[i].value(t > v)
                else: # less
                    if relays[i].value():
                        relays[i].value((t + dt) < v)
                    else:
                        relays[i].value(t < v)
            elif act[0] == 1: # allwase on
                relays[i].value(1)
            else:  # allwase off
                relays[i].value(0)

    # Controls

def tempsLoop():
    global sel_temp
    if temp_roms[sel_temp]:
        temps[sel_temp] = ds.get_temp(temp_roms[sel_temp])
        ds.start_measure(temp_roms[sel_temp])

        if temps[sel_temp] != prev_temps[sel_temp]:
            currScreen.temp_change(sel_temp)
            calculate()
        
    sel_temp += 1
    if sel_temp > 4:
        sel_temp = 0

    th.set_time_out(750, tempsLoop)

def change_terms_items(i1, i2):
    temp_roms[i1], temp_roms[i2] = temp_roms[i2], temp_roms[i1]
    temps[i1], temps[i2] = temps[i2], temps[i1]

th.set_time_out(4000, start)
tempsLoop()
th.run()
