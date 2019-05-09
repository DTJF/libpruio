#!/usr/bin/python
## \file
# \brief Example: minimal code for PRUSS firmware.
#
# This file contains an short and simple example for parallel usage of
# the other PRUSS. Find a functional description in section \ref
# sSecExaPruAdd.
#
# Licence: GPLv3, Copyright 2018-\Year by \Mail
#
# Run by: `python pruss_add.py`
#
# \since 0.6.4

from __future__ import print_function
from libpruio import *

## Load firmware into PRUSS instruction ram
# \param IRam The IRam ID for the PRU to use
# \returns Zero on success, otherwise error raising
#
# The instructions are compiled by command
#
#     pasm -V3 -c pruss_add.p
#
# from source code (named pruss_add.p)
#
#     .origin 0
#       LDI  r0, 0
#     start:
#       LBBO r1, r0, 4, 16 // load parameters in r1 (start value), r2 (add value), r3 (count), r4 (interrupt)
#
#       LOOP finished, r3.w0
#       ADD  r1, r1, r2    // compute result
#     finished:
#
#       SBBO r1, r0, 0, 4  // store result
#       MOV  r31.b0, r4.b0 // send notification to host
#       HALT
#       JMP start
def load_firmware(IRam):
  PRUcode = (c_uint32*8)(
    0x240000e0,
    0xf104e081,
    0x30830002,
    0x00e2e1e1,
    0xe1002081,
    0x1004041f,
    0x2a000000,
    0x21000100
  )
  if(0 >= prussdrv_pru_write_memory(IRam, 0, PRUcode, sizeof(PRUcode))):
                     raise AssertionError("failed loading instructions")
  return 0

## Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
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
# Pass parameters to PRU
#
  ## The pointer to the PRU direct access ram
  dram = pointer(c_uint32(0))
  prussdrv_map_prumem(pru_dram, byref(dram)) # get dram pointer
  dram[1] = 23 # start value
  dram[2] = 7  # value to add
  dram[3] = 67 # loop count (max 16 bit = 65536)
  dram[4] = pru_intr + 16 # the interrupt we're waiting for
#
# Execute
#
  print("instructions loaded, starting PRU-%d" % pru_num)
  prussdrv_pru_enable(pru_num, 0) # start @ address 0
  prussdrv_pru_wait_event(PRU_EVTOUT_0) # wait until finished
  prussdrv_pru_clear_event(PRU_EVTOUT_0, pru_intr) # clear interrupt (optional, useful when starting again)
#
# Check result
#
  if(dram[0] == (dram[1] + (dram[2] * dram[3]))):
    print("Test OK %d == %d + (%d * %d)\n" % (dram[0], dram[1], dram[2], dram[3]))
  else:
    print("Test failed: %d != %d + (%d * %d)\n" % (dram[0], dram[1], dram[2], dram[3]))

  prussdrv_pru_disable(pru_num) # disable PRU
  # note: no prussdrv_exit(), libpruio does it in the destructor

finally:
  pruio_destroy(io)
