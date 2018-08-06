#!/usr/bin/python
from __future__ import print_function
from libpruio import *

# Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
try:
  IO = io.contents #    the pointer dereferencing, using contents member
  if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)
  if pruio_config(io, 1, 0x1FE, 0, 4): #  upload settings, start IO mode
    raise AssertionError("config failed (%s)" % IO.Errr)
  AdcV = IO.Adc.contents.Value #                           array pointer
  for n in range(13): #                                 print some lines
    for i in range(1, 9): #                                    all steps
      print("%4X" % AdcV[i], end=" ") #        output one channel in hex
    print() #                                                  next line
finally:
  pruio_destroy(io)
