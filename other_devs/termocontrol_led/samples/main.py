import pyb
from onewire import OneWire
from drivers import TermoControl
ow = OneWire('X12')

#bytearray(b'\xe0\x00\x00\x00\x00\x00\x01\xe1')

tc = TermoControl(ow, bytearray(b'\xe0\x00\x00\x00\x00\x00\x01\xe1'))


def scan():
    print(ow.search())

def alarm():
    while 1:
        for rom in ow.alarm_search():
            print(tc.value())
        pyb.delay(5)
