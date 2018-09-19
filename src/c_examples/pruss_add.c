/*! \file pruss_add.c
\brief Example: minimal code for PRUSS firmware.

This file contains an short and simple example for parallel usage of
the other PRUSS. Find a functional description in section \ref
sSecExaPruAdd.

Licence: GPLv3, Copyright 2018-\Year by \Mail

Compile by: `gcc -Wall -o pruss_add pruss_add.c -lpruio`

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
*/
int32 load_firmware(uint32 IRam)
{
  const uint32 PRUcode[] =  {
    0x240000e0,
    0xf104e081,
    0x30830002,
    0x00e2e1e1,
    0xe1002081,
    0x1004041f,
    0x2a000000,
    0x21000100 };

  if(0 >= prussdrv_pru_write_memory(IRam, 0, PRUcode, sizeof(PRUcode)))
                   {printf("failed loading instructions\n"); return -1;}
  return 0;
}


//! The main function.
int main(int argc, char **argv)
{
  pruIo *io = pruio_new(PRUIO_ACT_PRU1, 0, 0, 0); //! create new driver structure
  do {
    uint32 pru_num, pru_iram, pru_dram, pru_intr;
//
// Check init success
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
      pru_intr = PRU1_ARM_INTERRUPT; }
//
// Now prepare the other PRU
//
    if(prussdrv_open(PRU_EVTOUT_0)) { // note: libpruio uses PRU_EVTOUT_5
                               printf("prussdrv_open failed\n"); break;}
    //Note: no prussdrv_pruintc_init(), libpruio did it already

    load_firmware(pru_iram);
//
// Pass parameters to PRU
//
    uint32 *dram;
    prussdrv_map_prumem(pru_dram, (void *) &dram); // get dram pointer
    dram[1] = 23; // start value
    dram[2] = 7;  // value to add
    dram[3] = 67; // loop count (max 16 bit = 65536)
    dram[4] = pru_intr + 16; // the interrupt we're waiting for
//
// Execute
//
    printf("instructions loaded, starting PRU-%d\n", pru_num);
    prussdrv_pru_enable(pru_num); // start
    prussdrv_pru_wait_event(PRU_EVTOUT_0); // wait until finished
    prussdrv_pru_clear_event(PRU_EVTOUT_0, pru_intr); // clear interrupt (optional, useful when starting again)
//
// Check result
//
    if(dram[0] == (dram[1] + (dram[2] * dram[3])))
      {printf("Test OK %d == %d + (%d * %d)\n", dram[0], dram[1], dram[2], dram[3]);}
    else
      {printf("Test failed: %d != %d + (%d * %d)\n", dram[0], dram[1], dram[2], dram[3]);}

    prussdrv_pru_disable(pru_num); // disable PRU
    // note: no prussdrv_exit(), libpruio does it in the destructor
  } while (0);

  pruio_destroy(io);        /* destroy driver structure */
	return 0;
}
