from pyb import UART
from pyb import Pin
from pyb import LED
import ujson

class RS485(object):
    PACK_SYNC = 1
    PACK_REBOOT = 2
    PACK_SET_CONFIG = 3
    
    PACK_SCAN_OW = 5
    PACK_ROMS_OW = 6
    
    def __init__(self, uart_num, pin_rw, dev_id):
        self.uart = UART(uart_num)
        self.uart.init(38400, bits=8, parity=0, timeout=2, read_buf_len=1024)
        self.pin_rw = Pin(pin_rw)
        self.pin_rw.init(Pin.OUT_PP)
        self.pin_rw.value(0)
        self.dev_id = dev_id

    def check_lan(self):
        uart = self.uart;
        
        #if uart.any() == False:
        #    return []
        
        buf = uart.readline().decode("utf-8")

        res = []
        for pack in buf.split(chr(0x0)):
            if pack:
                try:
                    data = ujson.loads(pack)
                    if data[0] == self.dev_id:
                        res += [data]
                        LED(2).toggle()
                except:
                    print("Возникла ошибка при получении пакета")
                    print(pack)
                    LED(4).on()
        return res

    def send_pack(self, pack_type, pack_data):
        self.pin_rw.value(1)
        try:
            buf = [self.dev_id, pack_type, pack_data]
            data = ujson.dumps(buf).encode("utf-8")
            data += bytearray([0x0])
            self.uart.write(data)
        except:
            print("Возникла ошибка при отправке пакета")
            print(data)
        self.pin_rw.value(0)
