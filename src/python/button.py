#!/usr/bin/python
## \file
# \brief Example: get state of a button.
#
# This file contains an example on how to use libpruio to get the state
# of a button connetect to a GPIO pin on the beaglebone board. Here pin 7
# on header P8 is used as input with pullup resistor. Connect the button
# between P8_07 (GPIO input) and P8_01 (GND). Find a functional
# description in section \ref sSecExaButton.
#
# Licence: GPLv3, Copyright 2017-\Year by \Mail
#
# Run by: `python button.py`
#
# \since 0.6.0

from __future__ import print_function
from libpruio import *

## The header pin to watch
PIN = P8_07

## Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
try:
  ## The pointer dereferencing, using contents member
  IO = io.contents
  if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)
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
finally:
  pruio_destroy(io)
