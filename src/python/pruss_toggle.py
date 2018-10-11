#!/usr/bin/python
## \file
# \brief Example: PRUSS GPIO toggling measured speed
#
# This file contains an example for parallel usage of the other PRUSS.
# The firmware toggles a GPIO pin at reduced speed. (Maximum is 100 MHz
# pulse train, we add 4 NOOPs to reduce it to 20 MHz for better
# measurments.) Find a functional description in section \ref
# sSecExaPruToggle.
#
# Licence: GPLv3, Copyright 2018-\Year by \Mail
#
# Run by: `python pruss_toggle.py`
#
# \since 0.6.4

from __future__ import print_function
from libpruio import *

## Load firmware into PRUSS instruction ram
def load_firmware(IRam):
  PRUcode = (c_uint32*13)(
    0x240000e0,
    0xf100a081,
    0x240001e0,
    0x0801e0e1,
    0x30820006,
    0x14e1fefe,
    0x240000e0,
    0x240000e0,
    0x240000e0,
    0x240000e0,
    0x1003031f,
    0x2a000000,
    0x21000400
  )
  if(0 >= prussdrv_pru_write_memory(IRam, 0, PRUcode, sizeof(PRUcode))):
                     raise AssertionError("failed loading instructions")
  return 0

## Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
#io = pruio_new(PRUIO_DEF_ACTIVE | PRUIO_ACT_FREMUX, 4, 0x98, 0)
try:
  ## The pointer dereferencing, using contents member
  IO = io.contents
  if IO.Errr:    raise AssertionError("pruio_new failed (%s)" % IO.Errr)
#
# Check init success
#
  if(IO.PruNo): #                                   we use the other PRU
    ## The PRU subsystem we use
    pru_num = 0
    ## The instruction ram ID of PRU subsystem
    pru_iram = PRUSS0_PRU0_IRAM
    ## The direct access ram ID of PRU subsystem
    pru_dram = PRUSS0_PRU0_DRAM
    ## The interrupt we use
    pru_intr = PRU0_ARM_INTERRUPT
  else:
    pru_num = 1
    pru_iram = PRUSS0_PRU1_IRAM
    pru_dram = PRUSS0_PRU1_DRAM
    pru_intr = PRU0_ARM_INTERRUPT # libpruio uses PRU1_ARM_INTERRUPT!
#
# Now prepare the other PRU
#
  if(prussdrv_open(PRU_EVTOUT_0)): #  note: libpruio uses PRU_EVTOUT_5
             raise AssertionError("prussdrv_open failed (%s)" % IO.Errr)
    # Note: no prussdrv_pruintc_init(), libpruio did it already

  load_firmware(pru_iram)
#
# Pinmuxing (some examples first)
#
  ## set PRU-0-r31 bit 15 input with pull up resistor
  #if (IO.setPin(io, P8_15, 6 | PRUIO_PULL_UP)) {
       #raise AssertionError("P8_15 configuration failed (%s)" % IO.Errr)

  ## set PRU-0-r31 bit 10 input (mode 6), no resistor
  #if (IO.setPin(io, SD_08, 6)) {
       #raise AssertionError("SD_08 configuration failed (%s)" % IO.Errr)

  ## set PRU-0-r30 bit 10 output (mode 5)
  #if (IO.setPin(io, SD_08, 5)) {
       #raise AssertionError("SD_08 configuration failed (%s)" % IO.Errr)

  # set PRU-0-r30 bit 15 output (mode 6)
  if (IO.setPin(io, P8_11, 6)):
       raise AssertionError("P8_11 configuration failed (%s)" % IO.Errr)

  # ... #
#
# Pprepare libpruio measurement
#
  if (pruio_cap_config(io, P9_42, 2.)): #        configure CAP input pin
       raise AssertionError("failed setting input P9_42 (%s)" % IO.Errr)
  if (pruio_config(io, 1, 0, 0, 0)):
                    raise AssertionError("config failed (%s)" % IO.Errr)
  ## The measured frequency.
  f = c_float(0)
  ## The measured duty cycle.
  d = c_float(0)
#
# Pass parameters to PRU
#
  ## The pointer to the PRU direct access ram
  dram = pointer(c_uint32(0))
  prussdrv_map_prumem(pru_dram, byref(dram)) # get dram pointer
  dram[0] = 15 # bit number, must match configured pin (P8_11)
  dram[1] = 16 # loop count (max 16 bit = 65535)
  dram[2] = pru_intr + 16 # the interrupt we're waiting for
#
# Execute 20 times
#
  print("instructions loaded, starting PRU-%d" % pru_num)
  for i in range(0, 20):
    prussdrv_pru_enable(pru_num) #                                 start

    prussdrv_pru_wait_event(PRU_EVTOUT_0) #      wait until PRU finished

    if(pruio_cap_Value(io, P9_42, byref(f), byref(d))): # get last measurement
      raise AssertionError("failed reading input P9_42 (%s)" % IO.Errr)

    print("--> Frequency: %3.0f MHz, Duty:%3.0f %c" %
              ((f.value * .000001), (d.value * 100), '%')) #     results

    prussdrv_pru_clear_event(PRU_EVTOUT_0, pru_intr) #     clr interrupt

  prussdrv_pru_disable(pru_num) # disable PRU
  # note: no prussdrv_exit(), libpruio does it in the destructor

finally:

  pruio_destroy(io)
