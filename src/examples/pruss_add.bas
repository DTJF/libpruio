/'* \file pruss_add.bas
\brief Example: minimal code for PRUSS firmware.

This file contains an short and simple example for parallel usage of
the other PRUSS. Find a functional description in section \ref
sSecExaPruAdd.

Licence: GPLv3, Copyright 2018-\Year by \Mail

Compile by: `fbc -Wall pruss_add.bas`

\since 0.6.2
'/

#include ONCE "BBB/pruio.bi" ' the library (for pinmuxing)
#include ONCE "BBB/pruio_pins.bi" ' CPU balls human readable
#include ONCE "BBB/pruio_prussdrv.bi" ' user space part of uio_pruss


/'* \brief load firmware to PRU
\param IRam The IRam ID for the PRU to use
\returns Zero on success, otherwise -1

The instructions are compiled by command

    pasm -V3 -c pruss_add.p

from source code (named pruss_add.p)

    .origin 0
      LDI  r0, 0
    start:
      LBBO r1, r0, 4, 16 // load parameters in r1 (start value), r2 (add value), r3 (count), r4 (interrupt)

      LOOP finished, r3.w0
      ADD  r1, r1, r2    // compute result
    finished:

      SBBO r1, r0, 0, 4  // store result
      MOV  r31.b0, r4.b0 // send notification to host
      HALT
      JMP start

\since 0.6.2
'/
FUNCTION load_firmware(BYVAL IRam AS UInt32) AS Int32
  DIM AS CONST UInt32 PRUcode(...) =  { _
    &h240000E0 _
  , &hF104E081 _
  , &h30830002 _
  , &h00E2E1E1 _
  , &hE1002081 _
  , &h1004041F _
  , &h2A000000 _
  , &h21000100 }
  VAR l = (UBOUND(PRUcode) + 1) * SIZEOF(PRUcode)
  RETURN 0 >= prussdrv_pru_write_memory(IRam, 0, @PRUcode(0), l)
  'IF 0 >= prussdrv_pru_write_memory(IRam, 0, @PRUcode(0), l) THEN _
                              '?"failed loading instructions" : RETURN -1
  'RETURN 0
END FUNCTION


VAR io = NEW PruIo(PRUIO_ACT_PRU1) '*< create new driver structure
DO
  DIM AS UInt32 _
      pru_num _  '*< which pru to use
    , pru_iram _ '*< ID of its instruction ram
    , pru_dram _ '*< ID of its data ram
    , pru_intr   '*< ID of its interrupt
'
' Check init success
'
  IF io->Errr THEN _
                  ?"initialisation failed (" & *io->Errr & ")" : EXIT DO

  IF io->PruNo THEN '                               we use the other PRU
    pru_num = 0
    pru_iram = PRUSS0_PRU0_IRAM
    pru_dram = PRUSS0_PRU0_DRAM
    pru_intr = PRU0_ARM_INTERRUPT
  ELSE
    pru_num = 1
    pru_iram = PRUSS0_PRU1_IRAM
    pru_dram = PRUSS0_PRU1_DRAM
    pru_intr = PRU0_ARM_INTERRUPT ' libpruio uses PRU1_ARM_INTERRUPT!
  END IF
'
' Now prepare the other PRU
'
  IF prussdrv_open(PRU_EVTOUT_0) THEN _ ' note: libpruio uses PRU_EVTOUT_5
                                       ?"prussdrv_open failed" : EXIT DO
  ' Note: no prussdrv_pruintc_init(), libpruio did it already

  IF load_firmware(pru_iram) < 0 THEN _
                          ?"failed loading PRUSS instructions" : EXIT DO
'
' Pass parameters to PRU
'
  DIM AS UInt32 PTR dram '*< a pointer to PRU data ram
  prussdrv_map_prumem(pru_dram, CAST(ANY PTR, @dram)) ' get dram pointer
  dram[1] = 23 ' start value
  dram[2] = 7  ' value to add
  dram[3] = 67 ' loop count (max 16 bit = 65536)
  dram[4] = pru_intr + 16 ' the interrupt we're waiting for
'
' Execute
'
  ?"instructions loaded, starting PRU-" & pru_num
  prussdrv_pru_enable(pru_num) ' start
  prussdrv_pru_wait_event(PRU_EVTOUT_0) ' wait until finished
  prussdrv_pru_clear_event(PRU_EVTOUT_0, pru_intr) ' clear interrupt (optional, useful when starting again)
'
' Check result
'
  IF dram[0] = (dram[1] + (dram[2] * dram[3])) THEN
    ?"Test OK " & dram[0] & " = " & dram[1] & " + (" & dram[2] & " * " & dram[3] & ")"
  ELSE
    ?"Test failed " & dram[0] & " <> " & dram[1] & " + (" & dram[2] & " * " & dram[3] & ")"
  END IF

  prussdrv_pru_disable(pru_num) ' disable PRU
  ' note: no prussdrv_exit(), libpruio does it in the destructor
LOOP UNTIL 1

DELETE io ' destroy driver structure
