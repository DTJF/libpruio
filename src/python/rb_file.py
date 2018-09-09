#!/usr/bin/python
from __future__ import print_function
from libpruio import *
import time

libc = CDLL("libc.so.6")

tSamp = 123401       # The number of samples in the files (per step).
tmr = 20000          # The sampling rate in ns (20000 -> 50 kHz).
NoStep = 3           # The number of active steps (must match setStep calls and mask).
NoFile = 2           # The number of files to write.
NamFil = "output.%u" # The output file names format.

# Create a ctypes pointer to the pruio structure
io = pruio_new(PRUIO_DEF_ACTIVE, 0, 0, 0)
try:
  IO = io.contents #    the pointer dereferencing, using contents member
  if IO.Errr: raise AssertionError("pruio_new failed (%s)" % IO.Errr)

  if pruio_adc_setStep(io, 9, 0, 0, 0, 0): #               step 9, AIN-0
    raise AssertionError("step 9 configuration failed: (%s)" % IO.Errr)
  if pruio_adc_setStep(io,10, 1, 0, 0, 0): #               step 9, AIN-1
    raise AssertionError("step 10 configuration failed: (%s)" % IO.Errr)
  if pruio_adc_setStep(io,11, 2, 0, 0, 0): #               step 9, AIN-2
    raise AssertionError("step 11 configuration failed: (%s)" % IO.Errr)

  mask = 0b111 << 9 #                         The active steps (9 to 11)
  tInd = tSamp * NoStep #                        The maximum total index
  half = ((IO.ESize >> 2) // NoStep) * NoStep #   index half ring buffer

  if half > tInd: half = tInd #               adapt size for small files
  samp = (half << 1) // NoStep #        The number of samples (per step)

  if pruio_config(io, samp, mask, tmr, 0): #  upload settings, start IO mode
    raise AssertionError("config failed (%s)" % IO.Errr)

  if pruio_rb_start(io):
    raise AssertionError("rb_start failed (%s)" % IO.Errr)

  p0 = IO.Adc.contents.Value # A pointer to the start of the ring buffer
  p1 = cast(byref(p0, half), POINTER(c_ushort)) # pointer to middle of the ring buffer
  for n in range(0, NoFile):
    fName = NamFil % n
    print("Creating file %s" % fName)
    oFile = libc.fopen(fName, "wb")
    i = 0 # Start index
    while i < tInd:
      i += half
      if i > tInd: #             fetch the rest(maybe no complete chunk)
        rest = tInd + half - i
        iEnd = rest if p1 >= p0 else rest + half
        while IO.DRam[0] < iEnd: time.sleep(0.001)
        print("  writing samples %u-%u" % (tInd -rest, tInd-1))
        libc.fwrite(p0, sizeof(UInt16), rest, oFile) #        write data
        p0, p1 = p1, p0 #                           swap buffer pointers
        break
      if p1 > p0:
        while IO.DRam[0] < half: time.sleep(0.001) # wait for completion
      else:
        while IO.DRam[0] > half: time.sleep(0.001) # wait for completion
      print("  writing samples %u-%u" % (i-half, i-1))
      libc.fwrite(p0, sizeof(UInt16), half, oFile) #      write bin data
      p0, p1 = p1, p0 #                             swap buffer pointers
    libc.fclose(oFile)
    print("Finished file %s" % fName)
finally:
  pruio_destroy(io)
