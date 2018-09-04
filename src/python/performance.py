#!/usr/bin/python
from __future__ import print_function
from libpruio import *
import time

C_IN = P9_42 # The pin to use for CAP input.
GOUT = P8_16 # The pin to use for GPIO output.
G_IN = P8_14 # The pin to use for GPIO input.

desc = [
  "Open loop, direct GPIO"
, "Open loop, function Gpio->Value"
, "Closed loop, direct GPIO to direct GPIO"
, "Closed loop, function Gpio->Value to direct GPIO"
, "Closed loop, function Gpio->Value to function Gpio->setValue"
, "Closed loop, Adc->Value to direct GPIO"
, "Closed loop, Adc->Value to function Gpio->Value"
]

f0 = c_float(0.) #     //!< The current measurement result.
nf = [100e6,100e6,100e6,100e6,100e6,100e6,100e6]
sf = [0.,0.,0.,0.,0.,0.,0.]
xf = [0.,0.,0.,0.,0.,0.,0.]

#r0 = r1 = c_ubyte(0)
r0 = c_ubyte(0)
r1 = c_ubyte(0)

m0 = c_ulong(0)
m1 = c_ulong(0)
md = c_ulong(0)
ad = c_ulong(0)
cd = c_ulong(0)
sd = c_ulong(0)

# Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
IO = io.contents #    the pointer dereferencing, using contents member

# Macro to measure the frequency and compute statistics.
def FREQ(_N_):
  if pruio_cap_Value(io, C_IN, byref(f0), None): #         get CAP input
    raise AssertionError("Cap->Value failed (%s)" % IO.Errr)
  sf[_N_] += f0.value
  if f0.value < nf[_N_]: nf[_N_] = f0.value
  if f0.value > xf[_N_]: xf[_N_] = f0.value
  print("%f" % f0.value, end="\t")

# Macro to set output pin by fast direct PRU command (no error checking).
def DIRECT(_O_):
  if _O_: cd.value &= ~m0.value; sd.value |= m0.value
  else:   sd.value &= ~m0.value; cd.value |= m0.value
  while IO.DRam[1]: pass
  IO.DRam[4] = sd.value
  IO.DRam[3] = cd.value
  IO.DRam[2] = ad.value
  IO.DRam[1] = PRUIO_COM_GPIO_OUT << 24

try:
  if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)

  if pruio_gpio_setValue(io, GOUT, 0): #      configure GPIO output GOUT
    raise AssertionError("GOUT configuration failed (%s)" % IO.Errr)

  if pruio_gpio_config(io, G_IN, PRUIO_GPIO_IN): # conf. GPIO input G_IN
    raise AssertionError("G_IN configuration failed (%s)" % IO.Errr)

  if pruio_cap_config(io, C_IN, 100): #         configure CAP input C_IN
    raise AssertionError("C_IN configuration failed (%s)" % IO.Errr)

  if pruio_adc_setStep(io, 1, 0, 0, 0, 0): #     configure fast Adc step
    raise AssertionError("ADC setStep failed (%s)" % IO.Errr)

  if pruio_config(io, 1, 0b10, 0, 4): #   upload settings, start IO mode
    raise AssertionError("config failed (%s)" % IO.Errr)

  r1.value = IO.BallGpio[G_IN] #  Resulting input GPIO (index and bit number).
  m1.value = 1 << (r1.value & 31)
  r0.value = IO.BallGpio[GOUT] #  Resulting output GPIO (index and bit number).
  m0.value = 1 << (r0.value & 31)
  g1 = r1.value >> 5 #            Index of input GPIO.
  g0 = r0.value >> 5 #            Index of output GPIO.
  ad.value = IO.Gpio.contents.Conf[g0].contents.DeAd + 0x100
  c = 4  # number of cycles for each test
  n = 50 # number of tests
  mi = IO.Gpio.contents.Raw[g1].contents
  Adc = IO.Adc.contents.Value
  for x in range(0, n):
    time.sleep(.001)
    for i in range(0, c):
      DIRECT(1)
      DIRECT(0)
    FREQ(0)

    time.sleep(.001)
    for i in range(0, c):
      if pruio_gpio_setValue(io, GOUT, 1): # set GPIO output
        raise AssertionError("GPIO setValue failed (%s)" % Io.Errr)
      if pruio_gpio_setValue(io, GOUT, 0): # set GPIO output
        raise AssertionError("GPIO setValue failed (%s)" % Io.Errr)
    FREQ(1)

    time.sleep(.001)
    for i in range(0, c):
      DIRECT(1)
      while 0 == (m1.value & mi.Mix): pass

      DIRECT(0)
      while m1 == (m1.value & mi.Mix): pass
    FREQ(2)

    time.sleep(.001)
    for i in range(0, c):
      DIRECT(1)
      while pruio_gpio_Value(io, G_IN) < 1: pass

      DIRECT(0)
      while pruio_gpio_Value(io, G_IN) > 0: pass
    FREQ(3)

    time.sleep(.001)
    for i in range(0, c):
      if pruio_gpio_setValue(io, GOUT, 1): # set GPIO output
        raise AssertionError("GPIO setValue failed (%s)" % Io.Errr)
      while pruio_gpio_Value(io, G_IN) < 1: pass

      if pruio_gpio_setValue(io, GOUT, 0): # set GPIO output
        raise AssertionError("GPIO setValue failed (%s)" % Io.Errr)
      while pruio_gpio_Value(io, G_IN) > 0: pass
    FREQ(4)

    time.sleep(.001)
    for i in range(0, c):
      DIRECT(1)
      while Adc[1] <= 0x7FFF: pass

      DIRECT(0)
      while Adc[1] > 0x7FFF: pass
    FREQ(5)

    time.sleep(.001)
    for i in range(0, c):
      if pruio_gpio_setValue(io, GOUT, 1): # set GPIO output
        raise AssertionError("GPIO setValue failed (%s)" % Io.Errr)
      while Adc[1] <= 0x7FFF: pass

      if pruio_gpio_setValue(io, GOUT, 0): # set GPIO output
        raise AssertionError("GPIO setValue failed (%s)" % Io.Errr)
      while Adc[1] > 0x7FFF: pass
    FREQ(6)
    print("")

  for i in range(0, 7):
    print("%s:" % desc[i])
    print("  Minimum: %s" % nf[i])
    print("  Avarage: %s" % (sf[i] / n))
    print("  Maximum: %s" % xf[i])

finally:
  pruio_destroy(io)
