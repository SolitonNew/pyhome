from pyb import UART
from pyb import Pin
from pyb import LED

class RS485(object):
    PACK_PING = 1
    PACK_REBOOT = 2
    PACK_SET_CONFIG = 3
    
    PACK_SCAN_OW = 5
    PACK_ROMS_OW = 6
    
    def __init__(self, uart_num, pin_rw, dev_id):
        self.uart = UART(uart_num)
        self.uart.init(921600, bits=8, timeout=5)
        self.pin_rw = Pin(pin_rw)
        self.pin_rw.init(Pin.OUT_PP)
        self.pin_rw.value(0)
        self.dev_id = dev_id

    def check_wire(self):
        uart = self.uart;
        if uart.any():
            try:
                buf = uart.readall()
            
                if buf[0] != self.dev_id:
                    #print("Пакет чужой")
                    return False
                if self.crc8(buf) != 0:
                    print("Не совпала CRC")
                    return False;

                LED(2).toggle()

                return buf
            except:
                print("Возникла ошибка")
                return False        
        return False

    def send(self, pack_type, pack_data):
        self.pin_rw.value(1)
        buff = [self.dev_id, pack_type]
        if pack_data:
            buff += pack_data
        buff += [self.crc8(buff)]
        self.uart.write(bytearray(buff))
        self.pin_rw.value(0)

    def crc8(self, data):
        """
        Check CRC.
        """
        crc = 0
        for i in range(len(data)):
            byte = data[i]
            for b in range(8):
                fb_bit = (crc ^ byte) & 0x01
                if fb_bit == 0x01:
                    crc = crc ^ 0x18
                crc = (crc >> 1) & 0x7f
                if fb_bit == 0x01:
                    crc = crc | 0x80
                byte = byte >> 1                
        return crc
