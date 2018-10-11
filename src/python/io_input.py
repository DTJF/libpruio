#!/usr/bin/python
## \file
# \brief Example: print digital and analog inputs.
#
# This file contains an example on how to use libpruio to print out the
# state of the digital GPIOs and the analog input lines. Find a functional
# description in section \ref sSecExaIoInput.
#
# Licence: GPLv3, Copyright 2017-\Year by \Mail
#
# Run by: `python io_input.py`
#
# \since 0.6.0

import curses
from libpruio import *

## The main function
def io_input(stdscr):
  # Clear and refresh the screen for a blank canvas
  stdscr.clear()
  stdscr.nodelay(1)

  ## Create a ctypes pointer to the pruio structure
  io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
  try:
    ## The pointer dereferencing, using contents member
    IO = io.contents
    if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)
    if pruio_config(io, 1, 0x1FE, 0, 4): #  upload config, start IO mode
      raise AssertionError("config failed (%s)" % IO.Errr)
    # IO mode is running, you can control digital output, read digital or analog input
    ## Adc array pointer
    AdcV = IO.Adc.contents.Value
    ## Gpio array pointer
    GpiV = IO.Gpio.contents.Raw
    ## A character
    c = -1
    stdscr.addstr(5,0, "Press any key to quit")
    while c == -1:
      for i in range(0, 4): #                                 all GpioSS
        stdscr.addstr(i,0, "{:032b}".format(GpiV[i].contents.Mix))
      for i in range(1, 9): #                              all ADC steps
        stdscr.addstr(4,(i-1)*5, "{:04X}".format(AdcV[i])) #  AIN in hex
      c = stdscr.getch()
  finally:
    pruio_destroy(io) #                                       we're done

if __name__ == "__main__":
  curses.wrapper(io_input)
