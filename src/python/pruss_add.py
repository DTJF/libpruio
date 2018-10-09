#!/usr/bin/python
from __future__ import print_function
from libpruio import *

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

# Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0)
try:
  IO = io.contents #    the pointer dereferencing, using contents member
  if IO.Errr:    raise AssertionError("pruio_new failed (%s)" % IO.Errr)
#
# Check init success
#
  if(IO.PruNo): #                                   we use the other PRU
    pru_num = 0
    pru_iram = PRUSS0_PRU0_IRAM
    pru_dram = PRUSS0_PRU0_DRAM
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
  prussdrv_pru_enable(pru_num) # start
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
