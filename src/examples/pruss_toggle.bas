/'* \file pruss_toggle.bas
\brief Example: PRUSS GPIO toggling measured speed

This file contains an example for parallel usage of the other PRUSS.
The firmware toggles a GPIO pin at reduced speed. (Maximum is 100 MHz
pulse train, we add 4 NOOPs to reduce it to 20 MHz for better
measurments.) Find a functional description in section \ref
sSecExaPruToggle.

Licence: GPLv3, Copyright 2018-\Year by \Mail

Compile by: `fbc -Wall pruss_toggle.bas`

\since 0.6.2
'/

#include ONCE "BBB/pruio.bi" ' the library (for pinmuxing)
#include ONCE "BBB/pruio_pins.bi" ' CPU balls human readable
#include ONCE "BBB/pruio_prussdrv.bi" ' user space part of uio_pruss


/'* \brief load firmware to PRU
\param IRam The IRam ID for the PRU to use
\returns Zero on success, otherwise -1

The instructions are compiled by command

    pasm -V3 -c pruss_toggle.p

from source code (named pruss_toggle.p)

    .origin 0
      LDI  r0, 0
      LBBO r1, r0, 0, 12 // load parameters in r1 (bitnumber), r2 (counter), r3 (interrupt)
      LDI  r0, 1
      LSL  r1, r0, r1.b0 // generate bit mask

    start:
      LOOP finished, r2.w0
      XOR  r30, r30, r1  // togle output, max. 200 MHz toggling
      LDI  r0, 0         // NOOPs here, CAP is only 100 MHz
      LDI  r0, 0         // 1 + 4 x NOOP = 5 cycles
      LDI  r0, 0         // --> 40 MHz toggling frequency
      LDI  r0, 0         // --> 20 MHz pulse train
    finished:

      MOV  r31.b0, r3.b0 // send notification to host
      HALT
      JMP start

\since 0.6.2
'/
FUNCTION load_firmware(BYVAL IRam AS UInt32) AS Int32
  DIM AS CONST UInt32 PRUcode(...) =  { _
    &h240000E0 _
  , &hF100A081 _
  , &h240001E0 _
  , &h0801E0E1 _
  , &h30820006 _
  , &h14E1FEFE _
  , &h240000E0 _
  , &h240000E0 _
  , &h240000E0 _
  , &h240000E0 _
  , &h1003031F _
  , &h2A000000 _
  , &h21000400 }
  VAR l = (UBOUND(PRUcode) + 1) * SIZEOF(PRUcode)
  RETURN 0 >= prussdrv_pru_write_memory(IRam, 0, @PRUcode(0), l)
END FUNCTION


' our configuration is for PUR-0, so PRU-1 for libpruio
VAR io = NEW PruIo(PRUIO_ACT_PRU1 OR PRUIO_ACT_PWM0) '*< create new driver structure
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
  IF prussdrv_open(PRU_EVTOUT_0) THEN _ ' note: PRU_EVTOUT_5 for libpruio
                                       ?"prussdrv_open failed" : EXIT DO
  ' Note: no prussdrv_pruintc_init(), libpruio did it already

  IF load_firmware(pru_iram) < 0 THEN _
                          ?"failed loading PRUSS instructions" : EXIT DO
'
' Pinmuxing (some examples first)
'
  '' set PRU-0-r31 bit 15 input with pull up resistor
  'IF io->setPin(io, P8_15, 6 OR PRUIO_RX_ACTIV OR PRUIO_PULL_UP) THEN _
             '?"P8_15 configuration failed (" & *io->Errr & ")" : EXIT DO

  '' set PRU-0-r31 bit 10 input (mode 6), pull down resistor
  'IF io->setPin(io, SD_08, 6 OR PRUIO_RX_ACTIV OR PRUIO_PULL_DOWN) THEN _
             '?"SD_08 configuration failed (" & *io->Errr & ")" : EXIT DO

  '' set PRU-0-r30 bit 10 output (mode 5)
  'IF io->setPin(io, SD_08, 5 OR PRUIO_NO_PULL) THEN _
             '?"SD_08 configuration failed (" & *io->Errr & ")" : EXIT DO

  ' set PRU-0-r30 bit 15 output (mode 6), pull down resistor
  IF io->setPin(io, P8_11, 6) THEN _
             ?"P8_11 configuration failed (" & *io->Errr & ")" : EXIT DO

  /' ... '/
'
' Prepare libpruio measurement
'
  IF io->Cap->config(P9_42, 2.) THEN _ '         configure CAP input pin
             ?"failed setting input P9_42 (" & *io->Errr & ")" : EXIT DO
  IF io->config(1, 0, 0, 0) THEN _
                          ?"config failed (" & *io->Errr & ")" : EXIT DO
  DIM AS float_t _
    f _ '*< the measured frequency
  , d   '*< the measured duty cycle
'
' Pass parameters to PRU
'
  DIM AS UInt32 PTR dram '*< a pointer to PRU data ram
  prussdrv_map_prumem(pru_dram, CAST(ANY PTR, @dram)) ' get dram pointer
  dram[0] = 15 ' bit number, must match configured pin (P8_11)
  dram[1] = 16 ' loop count (max 16 bit = 65535)
  dram[2] = pru_intr + 16 ' the interrupt we're waiting for
'
' Execute 20 times
'
  ?"instructions loaded, starting PRU-" & pru_num
  FOR i AS UInt32 = 0 TO 20
    prussdrv_pru_enable(pru_num) '                                 start

    prussdrv_pru_wait_event(PRU_EVTOUT_0) '      wait until PRU finished

    IF io->Cap->Value(P9_42, @f, @d) THEN _ '       get last measurement
             ?"failed reading input P9_42 (" & *io->Errr & ")" : EXIT DO

    ?"--> Frequency: " & (f * .000001) & " MHz, Duty:" & (d * 100) & " %" ' results

    prussdrv_pru_clear_event(PRU_EVTOUT_0, pru_intr) '     clr interrupt
  NEXT

  prussdrv_pru_disable(pru_num) '   Disable PRU
  ' note: no prussdrv_exit(), libpruio does it in the destructor
LOOP UNTIL 1

DELETE io ' destroy driver structure

'' help Doxygen to document the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); PruIo::setPin(); PruIo::config(); CapMod::config(); CapMod::Value(); PruIo::~PruIo();}
