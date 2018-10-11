#!/usr/bin/python
## \file
# \brief Example: PWM output and CAP input.
#
# This file contains an example on how to measure the frequency and duty
# cycle of a pulse train with a eCAP module input. The program sets
# another pin as eHRPWM output to generate a pulse width modulated signal
# as source for the measurement. The output can be changed by some keys,
# the frequency and duty cycle of the input is shown continuously in the
# terminal output. Find a functional description in section \ref
# sSecExaPwmCap.
#
# Licence: GPLv3, Copyright 2017-\Year by \Mail
#
# Run by: `python pwm_cap.py`
#
# \since 0.6.0

import curses
from libpruio import *

## The main function
def pwm_cap(stdscr):
  ## Clear and refresh the screen for a blank canvas
  stdscr.clear()
  stdscr.nodelay(1)

  ## Header pin for pwm output
  POUT = P9_21
  #POUT = P8_07 # alternate header pin for pwm output
  ## Header pin for cap input
  P_IN = P9_42

  ## Create a ctypes pointer to the pruio structure
  io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
  try:
    IO = io.contents #  the pointer dereferencing, using contents member
    if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)
    if pruio_cap_config(io, P_IN, 2.): #             configure input pin
      raise AssertionError("failed setting input @P_IN (%s)" % IO.Errr)
    f1 = c_float(0.) #                 Variable for calculated frequency
    d1 = c_float(0.) #                Variable for calculated duty cycle
    f0 = c_float(31250) #                         The required frequency
    d0 = c_float(.5) #                           The required duty cycle
    if pruio_pwm_setValue(io, POUT, f0, d0): #     configure output pin
      raise AssertionError("failed setting output @POUT (%s)" % IO.Errr)
    #          pin config passed, now transfer local settings to PRU and
    if pruio_config(io, 1, 0x1FE, 0,     4): #             start IO mode
      raise AssertionError("config failed (%s)" % IO.Errr)
    c = -1 #                             variable for keyboard character
    form = "Frequency: %10.2f , Duty: %2.8f" #    common format variable
    stdscr.addstr(0,0, "--> " + form % (f0.value, d0.value)); # show initial demand
    while True:
      if pruio_cap_Value(io, P_IN, byref(f1), byref(d1)): # get current input
        raise AssertionError("failed reading input @P_IN (%s)" % IO.Errr)
      stdscr.addstr(1,4, form % (f1.value, d1.value)) #         and show
      c = stdscr.getch()
      if c != -1: #                             react on user keystrokes
        if c == ord('-'): f0.value = 0.5
        elif c == ord('+'): f0.value = 1000000.
        elif c == ord('m'):
          if f0.value > 5.5: f0.value -= 5.
          else: f0.value = .5
        elif c == ord('p'):
          if f0.value < 999995.: f0.value += 5.
          else: f0.value = 1000000.
        elif c == ord('*'):
          if f0.value < 500000.: f0.value *= 2
          else: f0.value = 1000000.
        elif c == ord('/'):
          if f0.value > 1.: f0.value /= 2
          else: f0.value = .5
        elif c == ord('0'): d0.value = 0.0
        elif c == ord('1'): d0.value = 0.1
        elif c == ord('2'): d0.value = 0.2
        elif c == ord('3'): d0.value = 0.3
        elif c == ord('4'): d0.value = 0.4
        elif c == ord('5'): d0.value = 0.5
        elif c == ord('6'): d0.value = 0.6
        elif c == ord('7'): d0.value = 0.7
        elif c == ord('8'): d0.value = 0.8
        elif c == ord('9'): d0.value = 0.9
        elif c == ord(','): d0.value = 1.
        elif c == ord('.'): d0.value = 1.
        else: break
        if pruio_pwm_setValue(io, POUT, f0.value, d0.value): # update output
          raise AssertionError("failed setting PWM output (%s)" % IO.Errr)
        stdscr.addstr(0,4, form % (f0.value, d0.value)) # show new demand
  finally:
    pruio_destroy(io) #                                       we're done

if __name__ == "__main__":
  curses.wrapper(pwm_cap)
