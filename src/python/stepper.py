#!/usr/bin/python
## \file
# \brief Example: control a stepper motor.
#
# This file contains an example on how to use libpruio to control a
# 4-wire stepper motor:
#
# - configure 4 pins as output
# - receive user action in loop
# - inform user about the current state
# - change motor direction
# - change motor speed
# - stop holded or in power off mode
# - move a single step (in holded mode)
# - quit
#
# Find a functional description in section \ref sSecExaStepper.
#
# Licence: GPLv3, Copyright 2017-\Year by \Mail
#
# Run by: `python stepper.py`
#
# \since 0.6.0

import curses
from libpruio import *
import time

## The main function
def stepper(stdscr):
  P1 = P8_08 # The first pin of the stepper.
  P2 = P8_10 # The second pin of the stepper.
  P3 = P8_12 # The third pin of the stepper.
  P4 = P8_14 # The fourth pin of the stepper.

  # Create a ctypes pointer to the pruio structure
  io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
  IO = io.contents #  the pointer dereferencing, using contents member

  def PIN_OUT(a, b, c, d):
    if pruio_gpio_setValue(io, P1, a): raise AssertionError("setValue P1 error (%s)" % IO.Errr)
    if pruio_gpio_setValue(io, P2, b): raise AssertionError("setValue P2 error (%s)" % IO.Errr)
    if pruio_gpio_setValue(io, P3, c): raise AssertionError("setValue P3 error (%s)" % IO.Errr)
    if pruio_gpio_setValue(io, P4, d): raise AssertionError("setValue P4 error (%s)" % IO.Errr)

  def move(Rot):
    move.pos += Rot
    if (Rot & 1): move.pos &= 7
    else:         move.pos &= 6

    if   move.pos == 1: PIN_OUT(1,0,0,0)
    elif move.pos == 2: PIN_OUT(1,1,0,0)
    elif move.pos == 3: PIN_OUT(0,1,0,0)
    elif move.pos == 4: PIN_OUT(0,1,1,0)
    elif move.pos == 5: PIN_OUT(0,0,1,0)
    elif move.pos == 6: PIN_OUT(0,0,1,1)
    elif move.pos == 7: PIN_OUT(0,0,0,1)
    else:               PIN_OUT(1,0,0,1)

  move.pos = 0 # initialize func attribute
  # Clear and refresh the screen for a blank canvas
  stdscr.clear()
  stdscr.nodelay(1)
  try:
    if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)

    PIN_OUT(1,0,0,1) #                             initialize pin config

    if pruio_config(io, 1, 0x1FE, 0,     4): #             start IO mode
      raise AssertionError("config failed (%s)" % IO.Errr)

    #                                             print user informations
    stdscr.addstr(0,0, "Controls: (other keys quit, 1 and 3 only when Direction = 0)\n")
    stdscr.addstr(1,0, "                       8 = faster\n")
    stdscr.addstr(2,0, "  4 = rotate CW        5 = stop, hold position   6 = rotate CCW\n")
    stdscr.addstr(3,0, "  1 = single step CW   2 = slower                3 = single step CCW\n")
    stdscr.addstr(4,0, "  0 = stop, power off\n\n")
    stdscr.addstr(6,0, "  Pins    Dir  Sleep")
    w = 128
    d = 1
    stdscr.addstr(7,10, "{:2d}    {:3d}".format(d, w))
    while True:
      if d: move(d)
      stdscr.addstr(7,0, "{:1d}-{:1d}-{:1d}-{:1d}".format(
          pruio_gpio_Value(io, P1)
        , pruio_gpio_Value(io, P2)
        , pruio_gpio_Value(io, P3)
        , pruio_gpio_Value(io, P4))) #                  user information
      stdscr.refresh()

      stdscr.timeout(w)
      c = stdscr.getch()
      if c != -1:
        if c == ord('2'):
          if w < 512: w <<= 1
        elif c == ord('8'):
          if w >   4: w >>= 1 # python is slow
        elif c == ord('4'): d = -1
        elif c == ord('7'): d = -2
        elif c == ord('9'): d =  2
        elif c == ord('6'): d =  1
        elif c == ord('0'): d = 0; PIN_OUT(0,0,0,0)
        elif c == ord('5'): d = 0; move(d)
        elif c == ord('1'):
          if d == 0: move(-1)
        elif c == ord('3'):
          if d == 0: move( 1)
        else: break
        stdscr.addstr(7,10, "{:2d}    {:3d}".format(d, w))
  finally:
    PIN_OUT(0,0,0,0) #                          reset output pins to low
    pruio_destroy(io) #                                       we're done

if __name__ == "__main__":
  curses.wrapper(stepper)
