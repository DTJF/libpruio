#!/usr/bin/python
## \file
# \brief Example: minimal code for ADC input.
#
# This file contains an short and simple example for text output of the
# analog input lines. It's designed for the description pages and shows
# the basic usage of libpruio with a minimum of source code. Find a
# functional description in section \ref sSecExaSimple.
#
# Licence: GPLv3, Copyright 2017-\Year by \Mail
#
# Run by: `python 1.py`
#
# \since 0.0


from __future__ import print_function
from libpruio import *

## Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
try:
  ## The pointer dereferencing, using contents member
  IO = io.contents
  if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)
  if pruio_config(io, 1, 0x1FE, 0, 4): #  upload settings, start IO mode
    raise AssertionError("config failed (%s)" % IO.Errr)
  ## Array pointer
  AdcV = IO.Adc.contents.Value
  for n in range(13): #                                 print some lines
    for i in range(1, 9): #                                    all steps
      print("%4X" % AdcV[i], end=" ") #        output one channel in hex
    print() #                                                  next line
finally:
  pruio_destroy(io)
