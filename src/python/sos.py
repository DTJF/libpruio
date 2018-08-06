#!/usr/bin/python
from libpruio import *
import time

PIN = 24    # CPU ball number in use
pinmode = 0 # gloabal variable
Kurz = 0.15 # time for short Morse code
Lang = 0.35 # time for long Morse code

def MCode(dur):
  pruio_gpio_setValue(io, PIN, 128 + pinmode) # set on
  time.sleep(dur)
  pruio_gpio_setValue(io, PIN, pinmode) # set off
  time.sleep(.15)

def out_S():
  MCode(Kurz)
  MCode(Kurz)
  MCode(Kurz)

def out_O():
  MCode(Lang)
  MCode(Lang)
  MCode(Lang)

# Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
try:
  IO = io.contents #    the pointer dereferencing, using contents member
  if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)
  pinmode = IO.BallConf[PIN] #                      The current pin mode
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
