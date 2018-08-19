#!/usr/bin/python
from __future__ import print_function
from libpruio import *

PIN = P8_07 # the header pin to watch

# Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
try:
  IO = io.contents #    the pointer dereferencing, using contents member
  if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)
  if pruio_gpio_config(io, PIN, PRUIO_GPIO_IN_0): #  configure input pin
    raise AssertionError("GPIO configuration failed (%s)" % IO.Errr)
  if pruio_config(io, 1, 0x1FE, 0, 4): #  upload settings, start IO mode
    raise AssertionError("config failed (%s)" % IO.Errr)
  # IO mode is running, you can control digital output, read digital or analog input
  print("Press <Crtl>-C to stop")
  try:
    while True:
      print("\r%1X" % pruio_gpio_Value(io, PIN), end="");
    print(end="\r") #                                          next line
  except KeyboardInterrupt:
    print("") #                                           clear terminal
# The following line is optional, the DESTRUCTOR does the job by default
  if pruio_gpio_config(io, PIN, PRUIO_PIN_RESET): #     re-configure pin
    raise AssertionError("GPIO re-configuration failed (%s)" % IO.Errr)
finally:
  pruio_destroy(io)
