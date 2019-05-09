/*! \file pruss_toggle.c
\brief Example: PRUSS GPIO toggling measured speed

This file contains an example for parallel usage of the other PRUSS.
The firmware toggles a GPIO pin at reduced speed. (Maximum is 100 MHz
pulse train, we add 4 NOOPs to reduce it to 20 MHz for better
measurments.) Find a functional description in section \ref
sSecExaPruToggle.

Licence: GPLv3, Copyright 2018-\Year by \Mail

Compile by: `gcc -Wall -o pruss_toggle pruss_toggle.c -lpruio`

\since 0.6.2
*/

#include "stdio.h"
#include "string.h"
#include "libpruio/pruio.h" // the library (for pinmuxing)
#include "libpruio/pruio_pins.h" // CPU balls human readable
#include "libpruio/pruio_prussdrv.h" // user space part of uio_pruss


/*! \brief load firmware to PRU
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
*/
int32 load_firmware(uint32 IRam)
{
  const uint32 PRUcode[] =  {
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
    0x21000400 };

  if(0 >= prussdrv_pru_write_memory(IRam, 0, PRUcode, sizeof(PRUcode)))
                   {printf("failed loading instructions\n"); return -1;}
  return 0;
}


//! The main function.
int main(int argc, char **argv)
{
  // our configuration is for PUR-0, so PRU-1 for libpruio
  uint16 act = PRUIO_ACT_PRU1 | PRUIO_ACT_PWM0;
  pruIo *io = pruio_new(act, 0, 0, 0); //    create new driver structure
  do {
    uint32 pru_num, pru_iram, pru_dram, pru_intr, i;
//
// Check libpruio init success
//
    if(io->Errr) {
               printf("initialisation failed (%s)\n", io->Errr); break;}

    if(io->PruNo) { //                              we use the other PRU
      pru_num = 0;
      pru_iram = PRUSS0_PRU0_IRAM;
      pru_dram = PRUSS0_PRU0_DRAM;
      pru_intr = PRU0_ARM_INTERRUPT; }
    else {
      pru_num = 1;
      pru_iram = PRUSS0_PRU1_IRAM;
      pru_dram = PRUSS0_PRU1_DRAM;
      pru_intr = PRU0_ARM_INTERRUPT; } // libpruio uses PRU1_ARM_INTERRUPT!
//
// Now prepare the other PRU
//
    if(prussdrv_open(PRU_EVTOUT_0)) { // note: libpruio uses PRU_EVTOUT_5
                               printf("prussdrv_open failed\n"); break;}
    //Note: no prussdrv_pruintc_init(), libpruio did it already

    if(load_firmware(pru_iram) < 0)                               break;
//
// Pinmuxing (some examples first)
//
    //// set PRU-0-r31 bit 15 input with pull up resistor
    //if (io->setPin(io, P8_15, 6 | PRUIO_RX_ACTIV | PRUIO_PULL_UP)) {
          //printf("P8_15 configuration failed (%s)\n", io->Errr); break;}

    //// set PRU-0-r31 bit 10 input (mode 6), pull down resistor
    //if (io->setPin(io, SD_08, 6 | PRUIO_RX_ACTIV | PRUIO_PULL_DOWN)) {
          //printf("SD_08 configuration failed (%s)\n", io->Errr); break;}

    //// set PRU-0-r30 bit 10 output (mode 5), no resistor
    //if (io->setPin(io, SD_08, 5 | PRUIO_NO_PULL)) {
          //printf("SD_08 configuration failed (%s)\n", io->Errr); break;}

    // set PRU-0-r30 bit 15 output (mode 6), pull down resistor
    if (io->setPin(io, P8_11, 6)) {
          printf("P8_11 configuration failed (%s)\n", io->Errr); break;}

    /* ... */
//
// Pprepare libpruio measurement
//
    if (pruio_cap_config(io, P9_42, 2.)) { //    configure CAP input pin
          printf("failed setting input P9_42 (%s)\n", io->Errr); break;}
    if (pruio_config(io, 1, 0, 0, 0)) {
                       printf("config failed (%s)\n", io->Errr); break;}
    float_t
      f, // the measured frequency.
      d; // the measured duty cycle.
//
// Pass parameters to PRU
//
    uint32 *dram;
    prussdrv_map_prumem(pru_dram, (void *) &dram); // get dram pointer
    dram[0] = 15; // bit number, must match configured pin (P8_11)
    dram[1] = 16; // loop count (max 16 bit = 65535)
    dram[2] = pru_intr + 16; // the interrupt we're waiting for
//
// Execute 20 times
//
    printf("instructions loaded, starting PRU-%d\n", pru_num);
    prussdrv_pru_enable(pru_num); //                               start
    for (i = 0; i < 20; i++)
    {
      prussdrv_pru_wait_event(PRU_EVTOUT_0); //  wait until PRU finished
      prussdrv_pru_clear_event(PRU_EVTOUT_0, pru_intr); // clr interrupt

      if(pruio_cap_Value(io, P9_42, &f, &d)) { //   get last measurement
          printf("failed reading input P9_42 (%s)\n", io->Errr); break;}

      printf("--> Frequency: %3.0f MHz, Duty:%3.0f %c \n",
                            (f * .000001), (d * 100), '%'); //   results

      prussdrv_pru_resume(pru_num); //               continue after HALT
    }

    prussdrv_pru_disable(pru_num); //   Disable PRU
    // note: no prussdrv_exit(), libpruio does it in the destructor
  } while (0);

  pruio_destroy(io);        /* destroy driver structure */
	return 0;
}
