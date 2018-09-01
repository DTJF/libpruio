#!/usr/bin/python
import curses
from libpruio import *
import time

def qep(stdscr):
  ## Clear and refresh the screen for a blank canvas
  stdscr.clear()
  stdscr.nodelay(1)

  PMX = 4095 #//! Default PMax value.
  VHz = 25 #//! The frequency for speed measurement.
  PINS = (P8_12, P8_11, P8_16) #//! The header pins to use for input (PWMSS-1).

  # Create a ctypes pointer to the pruio structure
  io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
  try:
    IO = io.contents #  the pointer dereferencing, using contents member
    if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)

    #// configure PWM-1 for symetric output duty 50% and phase shift 1 / 4
    IO.Pwm.contents.ForceUpDown = 1 << 1
    AqCtl = IO.Pwm.contents.AqCtl
    AqC_A = 3+1 #     offset index [0][1][1]
    AqC_B = 3*3+3+1 # offset index [1][1][1]
    AqCtl[AqC_A] = 0b000000000110
    AqCtl[AqC_B] = 0b011000000000

    realfreq = c_float(0.0)
    freq = 50.
    if pruio_pwm_setValue(io, P9_14, freq, .00):
      raise AssertionError("failed setting P9_14 (%s)" % IO.Errr)

    if pruio_pwm_setValue(io, P9_16, freq, .25):
      raise AssertionError("failed setting P9_16 (%s)" % IO.Errr)

    if pruio_pwm_setValue(io, P9_42, .5, .00000005):
      raise AssertionError("failed setting P9_42 (%s)" % IO.Errr)

    if pruio_pwm_Value(io, P9_14, byref(realfreq), None):
      raise AssertionError("failed getting PWM value (%s)" % IO.Errr)

    pmax = PMX
    if pruio_qep_config(io, PINS[0], pmax, VHz, 1., 0):
      raise AssertionError("QEP pin configuration failed (%s)" % IO.Errr)
    if pruio_config(io, 1, 0, 0, 4): #             start IO mode
      raise AssertionError("config failed (%s)" % IO.Errr)

    t = ("       A", "   A & B", "A, B & I")
    posi = c_uint(0)
    velo = c_float(0)
    m = -1
    p = 0

    stdscr.addstr(0,0, "  p=%u" % p)
    stdscr.addstr(1,0, "  m=%i" % m)
    stdscr.addstr(2,0, "  %s input" % t[p])
    stdscr.addstr(3,0, "  %s input" % t[0])
    stdscr.addstr(4,0, "  %s input" % t[1])
    stdscr.addstr(5,0, "  %s input" % t[2])
    while True:
      if pruio_qep_Value(io, PINS[p], byref(posi), byref(velo)): #// get new input
        raise AssertionError("failed getting QEP Value (%s)" % IO.Errr)
      stdscr.addstr(7,0, "Position: %8X , Speed: %7.2f" % (posi.value, velo.value)) # // info
      stdscr.timeout(200)
      c = stdscr.getch()
      if c != -1:
        if   c == ord('a') or c == ord('A'): m = 0
        elif c == ord('b') or c == ord('B'): m = 1
        elif c == ord('i') or c == ord('I'): m = 2
        elif c == ord('p') or c == ord('P'): m = 3; freq = 500000. if freq >= 499995. else freq + 5.
        elif c == ord('m') or c == ord('M'): m = 3; freq =     25. if freq <=     30. else freq - 5.
        elif c == ord('*'):                  m = 3; freq = 500000. if freq >= 250000. else freq * 5.
        elif c == ord('/'):                  m = 3; freq =     25. if freq <=     50. else freq / 5.
        elif c == ord('0'): m = p; pmax = 0
        elif c == ord('1'): m = p; pmax = 1023
        elif c == ord('4'): m = p; pmax = 4095
        elif c == ord('5'): m = p; pmax = 511
        elif c == ord('8'): m = p; pmax = 8191
        elif c == ord('+'): m = 3; AqCtl[AqC_A] = 0x6
        elif c == ord('-'): m = 3; AqCtl[AqC_B] = 0x9
        elif c == 10:
          m = 3; freq = 50.
          if pruio_pwm_setValue(io, P9_14, freq, -1.):
            raise AssertionError("failed setting PWM value (%s)" % IO.Errr)
          if pruio_pwm_Value(io, P9_14, byref(realfreq), None):
            raise AssertionError("failed getting PWM value (%s)" % IO.Errr)
        else:
          break

        if m == 3:
          if pruio_pwm_setValue(io, P9_14, freq, -1.):
            raise AssertionError("failed setting PWM value (%s)" % IO.Errr)
          if pruio_pwm_Value(io, P9_14, byref(realfreq), None):
            raise AssertionError("failed getting PWM value (%s)" % IO.Errr)
        else:
          p = m
          if pruio_qep_config(io, PINS[p], pmax, VHz, 1., 0): # { //reconfigure QEP pins
            raise AssertionError("QEP pin reconfiguration failed (%s)" % IO.Errr)
        stdscr.addstr(7,50, "%s input, %10f Hz (%10f), PMax=%u" % (t[p], freq, realfreq.value, pmax))
  finally:
    pruio_destroy(io) #                                       we're done

if __name__ == "__main__":
  curses.wrapper(qep)
