from pyb import UART
from pyb import Pin
from pyb import LED
from ujson import loads, dumps

class RS485(object):
    PACK_SYNC = 1
    PACK_REBOOT = 2
    PACK_SET_CONFIG = 3
    
    PACK_SCAN_OW = 5
    PACK_ROMS_OW = 6
    
    def __init__(self, uart_num, pin_rw, dev_id):
        self.uart = UART(uart_num)
        self.uart.init(57600, bits=8, parity=0, timeout=10, read_buf_len=64)
        self.pin_rw = Pin(pin_rw)
        self.pin_rw.init(Pin.OUT_PP)
        self.pin_rw.value(0)
        self.dev_id = dev_id

    def check_lan(self):
        res = []
        uart = self.uart;
        file_handler = False

        self.buf_len_of_error = 0
        try:
            file_parts = 0
            file_parts_i = 1
            buf = uart.readline().decode("utf-8")
            if buf:
                LED(2).toggle()
            for pack in buf.split(chr(0x0)):
                if pack:
                    try:
                        data = loads(pack)
                        if data[0] == self.dev_id:
                            if data[2][0] == "SET_CONFIG_FILE":
                                #print(data[2][1], " ", file_parts_i)
                                if data[2][2] == False:
                                    res += [data]
                                    file_parts = data[2][1]
                                    file_handler = open("config.py", "w")
                                else:
                                    if file_handler and file_parts_i == data[2][1]:
                                        file_handler.write(data[2][2])
                                    file_parts_i += 1
                            else:
                                res += [data]
                    except Exception as e:
                        print("{}".format(e.args))
                        LED(4).on()
        except Exception as e:
            res = []
            print("{}".format(e.args))

        if file_handler:
            file_handler.close()
            print("OK")
        
        return res

    def send_pack(self, pack_type, pack_data):
        self.pin_rw.value(1)
        try:
            buf = [self.dev_id, pack_type, pack_data]
            data = dumps(buf).encode("utf-8")
            data += bytearray([0x0])
            self.uart.write(data)
        except:
            print("Возникла ошибка при отправке пакета")
            print(data)
        self.pin_rw.value(0)
