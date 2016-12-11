#!/usr/bin/python
from ctypes import *
from pruio import *
from time import sleep

# Create a ctypes *pointer* to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 0, 0, 0)
# Note the *pointer* dereferencing using the contents member
if not io.contents.Errr:
    pruio_config(io, 1, 0, 0, 0)
    for i in range(4):
        print("-----------\n")
        print("Setting to: %i\n" % (i%2))
        pruio_gpio_setValue(io, P8_08, i%2)
        s = pruio_Pin(io, P8_08)
        print("pruio_Pin: %s\n" % s)
        v = pruio_gpio_Value(io, P8_08)
        print("pruio_gpio_Value: %ld\n" % v)
        sleep(1)

pruio_destroy(io)
