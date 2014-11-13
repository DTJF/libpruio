// \file pruio__run.p
// \brief Source code for exit instructions, restore subsystem configurations.
// Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)
// Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net

//  compile for .bi output
//    pasm -V3 -y -CPru_Run pruio__run.p

#include "pruio.hp"
#define IRPT PRUIO_IRPT + 16

#define CTBIR      0x22020
#define CONST_PRUCFG C4
#define DRam C24

//
// register aliases
//
#define Para r0    // the offset to load parameters from (Init & Conf)
#define Ch__ r0.b0 // real chunk size (must be r0.b0) (copy & clear)    (in Para)
#define I___ r0.w2 // bytes index                     (copy & clear)    (in Para)

#define Samp r1    // number of samples (must follow Para)
#define StpM r2    // the step mask for ADC steps

#define RegC r3    // counter register (used byte-wise, must follow StpM)
#define LslM r3.b0 // the LSL mode (12 to 16 bit samples, IO & MM)      (in RegC)
#define GpoC r3.b1 // counter for current Gpio (IO)                     (in RegC)
#define PwmC r3.b2 // counter for current PWMSS (IO)                    (in RegC)

#define Comm r4    // the command, sent by host (IO) or timer value (MM) (must follow RegC)

#define TrgR r5    // trigger setup register
#define Tr_v r5.w1 // the value to compare                              (in TrgR)
#define Tr_s r5.b3 // the step number for pre triggers                  (in TrgR)
#define Tr_p r5.w0 // the pointer at trg event (pre-trigger only)       (in TrgR)
#define Tr_u r5.w2 // the size of ring buffer  (pre-trigger only)       (in TrgR)

#define TrgC r6    // trigger control register
#define Tr_i r6.b0 // trigger index (0 to 3)                            (in TrgC)
#define Tr_x r6.b1 // index of trigger step or GPIO                     (in TrgC)
#define Tr_c r6.w2 // counter for pre- / post-values                    (in TrgC)

#define FiFo r7    // pointer for fast access to ADC FiFo-0

#define S___ r8    // source (pointer)
#define LUpR r8    // buffer size (upper limit)

#define TarR r9    // pointer to result buffer (must follow LUpR)
#define Cntr r10   // a counter (size in bytes for clear/copy)
#define DeAd r11   // the adress of the current subsystem (Init/Conf) or ADC subsystem (IO,RB,MM)
#define ClAd r12   // clock address (must follow DeAd)
#define CmpR r12   // compare register (only for ADC_MM_Trg & ADC_MM_Data)
#define ClVa r13   // clock value (must follow ClAd)
#define SmpR r13   // sample register  (only for ADC_MM_Data)
//
// universal register names (must not be used in MM)
//
#define UR r14   // universal register (must follow ClVa, <= r14)
#define U1 r15
#define U2 r16
#define U3 r17
#define U4 r18
#define U5 r19

#define PtrR r29   // pointer register (only for ADC_MM_Data)

#define ChMx 64    // chunk size limit (depends on free data registers)
#define TChC 0xFF  // start value for trigger step#

#include "pruio_adc.p"
#include "pruio_gpio.p"
#include "pruio_ball.p"
#include "pruio_pwmss.p"


.origin 0
  // send message that we're starting
  MOV  UR, PRUIO_MSG_CONF_RUN // load msg
  SBCO UR, DRam, 0, 4   // store msg

  // Enable OCP master port (clear SYSCFG[STANDBY_INIT])
  LBCO r0, CONST_PRUCFG, 4, 4
  CLR  r0, r0, 4
  SBCO r0, CONST_PRUCFG, 4, 4

  ZERO &r0, 4           // clear register R0
  MOV  UR, CTBIR        // load address
  SBBO r0, UR, 0, 4     // make C24 point to 0x0 (PRU-0 DRAM) and C25 point to 0x2000 (PRU-1 DRAM).

  LBCO Para, DRam, 4, 4*2 // get Para & Samp (start of transfer block & # of Samples)

// Init macros (order must match the order in constructor PruiIo::PruIo() and pruio_init.p)
  ADC_Config
  GPIO_Config
  BALL_Config
  PWMSS_Config

// start mode: IO | [RB, MM]
  QBLT MmStart, Samp, 1   // if MM or RB required -> start
  QBEQ IoStart, Samp, 1   // if IO required -> start

//
// NO mode, report to host and halt
//
  MOV  UR, PRUIO_MSG_CONF_OK
  SBCO UR, DRam, 0, 4     // set status information
  MOV  r31.b0, IRPT       // send notification to host
  HALT


//
// IO mode
//
IoStart:
  ADC_IO_Init

  MOV  UR, PRUIO_MSG_IO_OK
  LDI  U1, 0              // value to reset command
  SBCO UR, DRam, 0, 4*2   // set status information & command
  MOV  r31.b0, IRPT       // send notification to host and start

IoLoop:
// get data
  ADC_IO_Data

  CALL IoData             // get digital IO and execute commands
  JMP  IoLoop


IoData:
  GPIO_IO_Data
  PWMSS_IO_Data

// re-configuration commands
  LBCO Comm, DRam, 4, 4   // get command
  QBNE IoComm, Comm, 0    // if command -> handle
  RET

IoComm:
  //BALL_IO_Command         // (must start before GPIO_IO_Command)
  GPIO_IO_Command
  PWMSS_IO_Command
  QBLT IoCEnd, Samp, 1    // if not IO mode -> skip ADC mask setting
  ADC_IO_Command

// clean up after command executions
IoCEnd:
  LDI  Comm, 0            // reset command
  SBCO Comm, DRam, 4, 4   // clear parameter
  RET                     // jump back (r30.w0)


//
// MM or RB mode
//
MmStart:
  ADC_MM_Init
MmLoop:
  ADC_FIFO_Empty // clear FiFo-0

// send message to host and wait
  MOV  UR, PRUIO_MSG_MM_WAIT
  SBCO UR, DRam, 0, 4      // set status information
  MOV  r31.b0, IRPT        // send notification to host
  LDI  CmpR, 0             // reset compare register (for ADC single step triggers)
  LDI  TrgC, 0             // reset trigger control register
  WBS  r31.t31             // wait for restart
  WBC  r31.t31             // go

// do triggers, if any
TrgLoop:
  LSL  TrgR, Tr_i, 2       // calc parameter offset
  LBBO TrgR, TrgR, 4*4, 4  // load trigger setup
  QBEQ MmData, TrgR, 0     // no trigger -> start measurement

  MOV  UR, PRUIO_MSG_MM_TRG1 // load trigger message
  SUB  UR, UR, Tr_i        // adapt message
  SBCO UR, DRam, 0, 4      // set status information

  LSR  Tr_c, TrgR.w2, 6    // get number of Pre-/post values

  GPIO_MM_Trg  // do GPIO trigger (if any)
  ADC_MM_Trg   // else do ADC trigger (or prepare pre-trigger)

// perform a post-trigger, in any
TrgPost:
  QBEQ TrgNext, Tr_c, 0    // if no post-trigger -> skip
  LDI  UR, 1               // value to clear counter
  SBCO UR, C26, 0x0C, 4    // reset IEP tiner COUNT register
  SBCO UR, C26, 0x44, 1    // clear timer CMP_HIT[0]
TrgTimer:
  LBCO UR, C26, 0x44, 1    // load CMP_STATUS bits
  QBBC TrgTimer, UR, 0     // if not finised -> wait
  SBCO UR, C26,  0x44, 1   // clear timer CMP_STATUS bits
  SUB  Tr_c, Tr_c, 1       // decrease counter
  QBNE TrgTimer, Tr_c, 0   // if not done -> next loop

// perform next trigger event
TrgNext:
  ADD  Tr_i, Tr_i, 1       // increase trigger counter
  QBGE TrgLoop, Tr_i, 3    // if not last trigger -> do next
  LDI  TrgR, 0             // reset trigger specification

// start measurement
MmData:    // default entry
  LDI  TrgC, 0             // reset trigger control regiser
  LBCO LUpR, DRam, 4, 4*2  // get size of & pointer to ERam (LUpR & TarR)
  SBCO TrgC, DRam, 4, 4    // reset command parameter
MmData2:   // entry for pre-trigger

  ADC_MM_Data  // get samples
  ADC_MM_Sort  // sort ring buffer (if any)

  JMP  MmLoop  // loop again


//
// copy a block (Si___ bytes - max 2^16) of data from S___ to TarR
//
Copy:
  MOV  Ch__, ChMx           // start with max chunck size
  SUB  I___, Cntr, Ch__     // initialize index

CopySize:
  QBGE CopyCopy, I___, Cntr // if complete chunk in range -> copy all
  ADD  Ch__, I___, ChMx     // calc chunk size = rest
  LDI  I___, 0              // index = zero

CopyCopy:
  LBBO UR, S___, I___, b0   // load a data chunk
  SBBO UR, TarR, I___, b0   // save it

  QBNE CopyNext, I___, 0    // if data left -> continue
  RET

CopyNext:
  SUB  I___, I___, Ch__     // set index for next chunk
  JMP  CopySize             // go again
