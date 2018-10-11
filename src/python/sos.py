#!/usr/bin/python
## \file
# \brief Example: blink user LED 3.
#
# This file contains an example on how to use libpruio to control the
# user LED 3 (near ethernet connector) on the beaglebone board. It shows
# how to unlock a CPU ball that is used by the system. And it shows how
# to control the unlocked ball. Find a functional description in
# section \ref sSecExaSos.
#
# Licence: GPLv3, Copyright 2017-\Year by \Mail
#
# Run by: `python sos.py`
#
# \since 0.6.0

from libpruio import *
import time

## CPU ball number in use (LED3)
PIN = 24
## gloabal variable
pinmode = 0
## Time for short Morse code
Kurz = 0.15
## Time for long Morse code
Lang = 0.35

## Morse code output, parameter is duration
def MCode(dur):
  pruio_gpio_setValue(io, PIN, 128 + pinmode) # set on
  time.sleep(dur)
  pruio_gpio_setValue(io, PIN, pinmode) # set off
  time.sleep(.15)

## Output character 'S'
def out_S():
  MCode(Kurz)
  MCode(Kurz)
  MCode(Kurz)

## Output character 'O'
def out_O():
  MCode(Lang)
  MCode(Lang)
  MCode(Lang)

## Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
try:
  ## The pointer dereferencing, using contents member
  IO = io.contents
  if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)
  ## The current pin mode
  pinmode = IO.BallConf[PIN]
  if pruio_config(io, 1, 0x1FE, 0, 4): #  upload settings, start IO mode
    raise AssertionError("config failed (%s)" % IO.Errr)
  print("watch SOS code on user LED 3 (near ethernet connector)")
  print("execute the following command to get rid of mmc1 triggers")
  print("  sudo su && echo none > /sys/class/leds/beaglebone:green:usr3/trigger && echo 0 > /sys/class/leds/beaglebone:green:usr3/brightness && exit")
  print("press <Ctrl>-C to quit")
  try:
    while True:
      out_S()
      out_O()
      out_S()
      time.sleep(1.5)
  except KeyboardInterrupt:
    pass
  pruio_gpio_setValue(io, PIN, pinmode) #                      reset LED
finally:
  pruio_destroy(io)
