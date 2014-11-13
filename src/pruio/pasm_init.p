// \file pruio_init.p
// \brief Source code for init instructions, read subsystems configurations.
// Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)
// Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net

//  compile for .bi output
//    pasm -V3 -y -CPru_Init pruio__init.p

#include "pruio.hp"
#define IRPT PRUIO_IRPT + 16

#define CTBIR      0x22020
#define CONST_PRUCFG C4

#define DRam C24
#define Targ r1
#define Cntr r2
#define Para r3
#define DeAd r4
#define ClAd r5

#define UR r6
#define U1 r7
#define U2 r8
#define U3 r9
#define U4 r10
#define U5 r11

#include "pruio_adc.p"
#include "pruio_gpio.p"
#include "pruio_ball.p"
#include "pruio_pwmss.p"

.origin 0
  // send message that we're starting
  MOV  UR, PRUIO_MSG_INIT_RUN // load msg
  SBCO UR, DRam, 0, 4   // store msg

// Enable OCP master port (clear SYSCFG[STANDBY_INIT])
  LBCO r0, CONST_PRUCFG, 4, 4
  CLR  r0, r0, 4
  SBCO r0, CONST_PRUCFG, 4, 4

  ZERO &r0, 4           // clear register R0
  MOV  UR, CTBIR        // load address
  SBBO r0, UR, 0, 4     // make C24 point to 0x0 (PRU-0 DRAM) and C25 point to 0x2000 (PRU-1 DRAM).


  LBCO Targ, DRam, 4, 4 // get start of transfer block
  LDI  Para, 8          // set Para to start of parameters

// order must match the order in constructor PruiIo::PruIo() and pruio_run.p xxx_Config macro calls
  ADC_Init
  GPIO_Init
  BALL_Init
  PWMSS_Init

// report to host and halt
  MOV  UR, PRUIO_MSG_INIT_OK
  SBCO UR, DRam, 0, 4    // set status information
  MOV  r31.b0, IRPT      // send notification to host
  HALT
