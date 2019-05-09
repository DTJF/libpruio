.macro PWMSS_Init
//
// wakeup subsystem and read configuration registers to data block
//
  LDI  Cntr, 0            // reset counter
PwmConf:
  LBBO DeAd, Para, 0, 4*2 // load subsystem base & clock address
  ADD  Para, Para, 4*2    // increase pointer
  SBBO DeAd, Targ, 0, 4*2 // save adresses (subsystem & clock)
  QBNE PwmFull, ClAd, 0   // if subsystem enabled -> get full configuration
  LDI  UR, 0              // clear register
  LBBO U1, DeAd, 0, 4     // load IDVER
  SBBO UR, Targ, 4*2, 4*2 // clear clock value, save IDVER
  ADD  Targ, Targ, 4*4    // increase pointer
  JMP  PwmDone            // skip subsystem

PwmFull:
  LBBO UR, ClAd, 0, 4       // get PWMSS clock value
  SBBO UR, Targ, 4*2, 4     // save clock value
  ADD  Targ, Targ, 4*3      // increase pointer
  LDI  U5, 0                // clear timeout counter
  LDI  U2, 2                // load clock demand value
  SBBO U2, ClAd, 0, 4       // write PWMSS CLK register
PwmWait:
  LBBO UR, DeAd, 0x00, 4    // load PWMSS IDVER register
  QBNE PwmCopy, UR, 0       // if PWM is up -> copy conf
  ADD  U5, U5, 1            // count timeout
  QBGE PwmWait, U5.b1, 16   // if not timeout -> wait for wake up
  SBBO UR, Targ, 0, 4       // write failure to info block (IDVER)
  ADD  Targ, Targ, 4        // increase pointer
  JMP  PwmDone              // skip when timeout

PwmCopy:
  LBBO U1, DeAd, 0x04, 4*3    // load IDVER to CLKSTATUS registers
  SBBO UR, Targ, 0, 4*4       // save registers

  SET  DeAd, DeAd, 8          // switch to eCAP registers
  LBBO UR, DeAd, 0x00, 4*6    // load TSCTR to CAP4 registers
  SBBO UR, Targ, 4*4, 4*6     // save registers
  LBBO UR, DeAd, 0x28, 2*6    // load ECCTL1 to ECFRC registers
  SBBO UR, Targ, 4*10, 4*3    // save registers
  LBBO UR, DeAd, 0x5C, 4      // load CAP_REV
  SBBO UR, Targ, 4*13, 4      // save register

  ADD  DeAd, DeAd, 0x80       // switch to QEP registers
  LBBO UR, DeAd, 0x00, 4*9    // load QPOSCNT to QUPRD registers
  SBBO UR, Targ, 4*14, 4*9    // save registers
  LBBO UR, DeAd, 0x24, 2*16   // load QWDTMR to QCPRDLAT registers (+1)
  SBBO UR, Targ, 4*23, 4*8    // save registers
  LBBO UR, DeAd, 0x5C, 4      // load QEP_REV register
  SBBO UR, Targ, 4*31, 4      // save register

  ADD  DeAd, DeAd, 0x80       // switch to ePWM registers
  LBBO UR, DeAd, 0x00, 2*6    // load TB registers
  SBBO UR, Targ, 4*32, 4*3    // save registers
  LBBO UR, DeAd, 0x0E, 2*4    // load CM registers
  SBBO UR, Targ, 4*35, 4*2    // save registers
  LBBO UR, DeAd, 0x16, 2*4    // load AQ registers
  SBBO UR, Targ, 4*37, 4*2    // save registers
  LBBO UR, DeAd, 0x1E, 2*3    // load DB registers
  SBBO UR, Targ, 4*39, 2*3    // save registers
  LBBO UR.w0, DeAd, 0x24, 2   // load TZSEL register
  LBBO UR.w2, DeAd, 0x28, 2   // load TZCTL register
  LBBO U1, DeAd, 0x2A, 2*4    // load TZEINT to TZFRC registers
  SBBO UR, Targ, 162, 2*6     // save registers
  LBBO UR, DeAd, 0x32, 2*5    // load ETSEL to ETFRC registers
  SBBO UR, Targ, 174, 2*5     // save registers
  LBBO UR, DeAd, 0x3C, 2*2    // load PCCTL and HRCTL registers
  SBBO UR, Targ, 184, 2*2     // save registers

  ADD  Targ, Targ, 188+3    // increase pointer and adjust ...
  AND  Targ.b0, Targ.b0, 0xFC // at UInt32 border

PwmDone:
  ADD  Cntr, Cntr, 1      // count
  QBGE PwmConf, Cntr, PRUIO_AZ_PWMSS // if not last -> do next

  SUB  UR, Para, 4        // pointer to last parameter
  SBBO Targ, UR, 0, 4     // mark end of PWM arrays
.endm


.macro PWMSS_Config
//
// write configuration from data block to subsystem registers
//
  LDI  PwmC, 0            // reset counter
PwmConf:
  LBBO DeAd, Para, 0, 4*4 // load PWMSS DeAd, ClAd, ClVa, ID
  ADD  Para, Para, 4*4    // increase pointer

// prepare data array
  LSL  U1, PwmC, 5          // calc array pointer (sizeof(PwmssArr)=32)
  ADD  U1, U1, PRUIO_DAT_PWM// offset array pointer
  SET  U2, DeAd, 8          // copy DeAd +0x100
  QBEQ PwmJump, ClVa, 2     // if subsystem enabled -> don't clear
  LDI  U2, 0                // clear register
PwmJump:
  ZERO &U3, 8*4             // clear registers
  SBBO U2, U1,   0, 4       // prepare subsystem address
  SBBO U3, U1, 4*2, 4*6     // prepare array data (skip CMax)

// check enabled / dissabled and data block length
  QBEQ PwmDone, ClAd, 0     // if no CLOCK addr -> don't touch
  QBNE PwmCopy, DeAd, 0     // if normal operation -> copy
  SBBO ClVa, ClAd, 0, 4     // write clock register
  QBEQ PwmDone, UR, 0       // if PwmssSet empty -> skip
  ADD  Para, Para, 188+3-4  // increase pointer and adjust ...
  AND  Para.b0, Para.b0, 0xFC // at UInt32 border
  JMP  PwmDone

PwmCopy:
  SUB  Para, Para, 4        // decrease pointer (IDVER)

  LBBO UR, Para, 4*1, 4*2   // load SYSCONFIG & CLKCONFIG registers
  SBBO UR, DeAd, 0x04, 4*2  // write registers

  SET  DeAd, 9              // switch to ePWM registers (+0x200)
  LBBO UR, Para, 184, 2*2   // load PCCTL and HRCTL registers
  SBBO UR, DeAd, 0x3C, 2*2  // write registers
  LBBO UR, Para, 174, 2*2   // load ETSEL & ETPS registers
  SBBO UR, DeAd, 0x32, 2*2  // write registers
  LBBO UR, Para, 162, 2*6   // load TZSEL to TZFRC registers
  SBBO UR.w0, DeAd, 0x24, 2 // write TZSEL
  SBBO UR.w2, DeAd, 0x28, 2 // write TZCTL
  SBBO U1.w0, DeAd, 0x2A, 2 // write TZEINT
  SBBO U2, DeAd, 0x2E, 2*2  // write TZCLR & TZFRC
  LBBO UR, Para, 4*39, 2*3  // load DB registers
  SBBO UR, DeAd, 0x1E, 2*3  // write registers
  LBBO UR, Para, 4*37, 2*4  // load AQ registers
  SBBO UR, DeAd, 0x16, 2*4  // write registers
  LBBO UR, Para, 4*35, 2*4  // load CM registers
  SBBO UR, DeAd, 0x0E, 2*4  // write registers
  LBBO UR, Para, 4*32, 2*6  // load TB registers
  SBBO UR, DeAd, 0x00, 2*6  // write register TBCTL to TBPRD

  SUB  DeAd, DeAd, 0x80     // switch to eQEP registers (+0x180)
  LBBO UR, Para, 4*29, 2*4  // load QEINT to QFRC registers
  SBBO UR, DeAd, 0x30, 2*4  // write registers
  LBBO UR, Para, 4*23, 2*6  // load QWDTMR to QPOSCTL registers
  SBBO UR, DeAd, 0x24, 2*6  // write registers
  LBBO UR, Para, 4*21, 4*2  // load QUTMR to QUPRD registers
  SBBO UR, DeAd, 0x1C, 4*2  // write registers
  LBBO UR, Para, 4*14, 4*4  // load QPOSCNT to QPOSCMP registers
  SBBO UR, DeAd, 0x00, 4*4  // write registers

  SUB  DeAd, DeAd, 0x80     // switch to eCAP registers (+0x100)
  LBBO UR, Para, 4*12, 2*2  // load ECCLR & ECFRC registers
  SBBO UR, DeAd, 0x30, 2    // write ECCLR register

  LBBO UR, Para, 4*10, 2*3  // load ECCTL1 to ECEINT registers
  SBBO UR, DeAd, 0x28, 2*3  // write registers

  LBBO UR, Para, 4*4, 4*6   // load TSCTR to CAP4 registers
  SBBO UR, DeAd, 0x00, 4*4  // write registers TSCTR to CAP2


  ADD  Para, Para, 188+3      // increase pointer and adjust ...
  AND  Para.b0, Para.b0, 0xFC // at UInt32 border

PwmDone:
  ADD  PwmC, PwmC, 1                 // increase counter
  QBGE PwmConf, PwmC, PRUIO_AZ_PWMSS // if not last -> do next
.endm


.macro PWMSS_IO_Data
//
// get subsystem data in IO mode
//
  LSL  U3, PwmC, 5         // calc array pointer (sizeof(PwmssArr)=32)
  ADD  UR, U3, PRUIO_DAT_PWM // add array offset
  LBBO U1, UR, 0, 2*4      // get DeAd & CMax
  QBEQ PwmSSCnt, U1, 0     // if subsystem disabled -> skip
  QBLT CapAll, U2, 255     // if module in CAP mode -> skip
  QBEQ QepDat, U2, 0       // no one shot -> skip

  LBBO U3, U1, 0x2E, 2     // get ECFLG register (events)
  QBBC QepDat, U3.t7       // no MATCH -> skip
  SBBO U3, U1, 0x30, 2     // clear events (ECCLR reg)
  QBBC QepDat, U3.t6       // no PRDEQ -> skip
  LBBO U4, U1, 0x2A, 2     // get ECCTL2 register
  QBBC QepDat, U4.t7       // no one shot -> skip

  SUB  U2, U2, 1           // decrease count
  SBBO U2, UR, 4, 4        // write CMax
  QBNE QepDat, U2, 0       // counts left -> skip

  XOR  U4, U4, 0b10010000  // clr counter&marker bit -> stop
  SBBO U4, U1, 0x2A, 2     // write ECCTL2 register
  JMP  QepDat

CapAll:
  LBBO U3, U1, 0x2E, 2     // get ECFLG register
  SBBO U3, U1, 0x30, 2     // reset flags (ECCLR register)
  LBBO U4, U1, 0x00, 4     // get TSCTR register

  QBLE CapDClear, U4, U2   // if timeout -> clear variables
  QBBS CapDClear, U3, 5    // if overflow -> clear variables

  QBBC Cap34, U3, 3        // no CEVT3 -> skip to check CEVT1
  LBBO U4, U1, 0x08, 2*4   // get CAP1/CAP2 registers
  JMP  CapDSet             // write variables

Cap34:
  QBBC QepDat, U3, 1       // no CEVT1 -> skip
  LBBO U4, U1, 0x10, 2*4   // get CAP3/CAP4 registers
  JMP  CapDSet             // write variables

CapDClear:
  ZERO &U4, 8              // clear registers
CapDSet:
  SBBO U4, UR, 2*4, 2*4    // write variables C1 & C2

QepDat:
  ADD  U1, U1, 0x80        // switch to eQEP (0x180)
  LBBO U3, U1, 0x00, 4     // get QPOSCNT register
  SBBO U3, UR, 4*4 , 4     // write variable
  LBBO U5, U1, 0x32, 2     // get QFLG register
  QBBC PwmSSCnt, U5.t11    // if no unit timer event -> skip

  LBBO U4, UR,  5*4, 4     // load old QPOSLAT
  LBBO U3, U1, 0x18, 4     // load new QPOSLAT

  QBBC QepUnder, U5.t6     // if no overflow -> check underflow
  LBBO U2, U1, 0x08, 4     // load QPOSMAX register
  SUC  U4, U4, U2          // adapt old value
  JMP  QepPrd
QepUnder:
  QBBC QepPrd, U5.t5       // if no underflow -> skip
  LBBO U2, U1, 0x08, 4     // load QPOSMAX register
  ADD  U4, U2, 1           // adapt old value

QepPrd:
  LBBO U2, U1, 0x38, 2     // get QEPSTS register
  QBBC QepNoVal, U2.t7     // if no event -> no value
  QBBS QepNoVal, U2.t3     // if CTMR overflow -> no value
  QBBS QepNoVal, U2.t2     // if direction changed -> no value
  LBBO U5.w2, U1, 0x40, 2  // load QCPRDLAT
  JMP  QepSkip             // continue
QepNoVal:
  LDI  U5.w2, 0            // load minimum value
QepSkip:

  LBBO U5.w0, U1, 0x38, 2  // load QCPRDLAT
  LDI  U2, 0b10001100      // bit mask to reset QEPSTS
  SBBO U2, U1, 0x38, 2     // reset sticky QEPSTS flags
  LDI  U2, 0b100001101001  // bit mask to reset QFLG (UTO,PCO,PCU,QDC,INT)

  SBBO U2, U1, 0x34, 2     // clear QCLR
  SBBO U3, UR, 5*4 , 3*4   // write variables

PwmSSCnt:
  ADD  PwmC, PwmC, 1         // increase counter
  QBGE PwmSSDEnd, PwmC, PRUIO_AZ_PWMSS // if not last -> do next
  LDI  PwmC, 0               // reset counter
PwmSSDEnd:
.endm


.macro PWMSS_IO_Command
//
// handle subsystem command in IO mode
//
  QBLT PwmCEnd, Comm.b3, PRUIO_COM_PWM // if no PWM command -> skip

  QBNE TimComm, Comm.b3, PRUIO_COM_CAP_PWM // if no PWM command for CAP module -> skip
  LBCO U2, DRam, 4*2, 4*3   // get parameters (DeAd, period, duty)
  QBEQ PwmCapNI, Comm.w0, 0 // if no re-config -> skip
  SBBO Comm.w0, U2, 0x2A, 2 // write ECCTL2 register
PwmCapNI:
  SBBO U3, U2, 0x10, 4*2    // write new period & duty values
  JMP  IoCEnd               // finish command

TimComm:
  QBNE CapComm, Comm.b3, PRUIO_COM_CAP_TIM // if no TIMER command for CAP module -> skip
  LBCO U2, DRam, 2*4, 4*4   // get parameters (DeAd, CAP1, CAP2, TSCTR)
  CLR  Comm.w0.t4           // clr RUN bit
  SBBO Comm.w0, U2, 0x2A, 2 // write ECCTL2 register -> stop
  SBBO U3, U2, 0x08, 2*4    // write CAP1 & CAP2 regs
  SBBO U5, U2, 0x00,   4    // write counter reg
  SET  Comm.w0.t4           // set RUN bit
  SBBO Comm.w0, U2, 0x2A, 2 // write ECCTL2 register -> start
  LDI  U6, 0b11111110       // mask to clear flags
  SBBO U6, U2, 0x30, 2      // write ECCLR flags -> clear
  JMP  IoCEnd               // finish command

CapComm:
  QBNE PwmCCon, Comm.b3, PRUIO_COM_CAP // if no CAP command -> skip
  LBCO U2, DRam, 2*4, 4     // get parameter (DeAd)
  ZERO &U3, 4*4             // clear registers
  SBBO U3, U2, 0x2A, 2      // write ECCTL2 register -> stop
  SBBO U3, U2, 0x08, 4*4    // reset capture (CAP1-4)
  SBBO U3, U2, 0x00, 4      // reset counter (TSCTR)
  LDI  U6, 0b11111110       // mask to clear flags
  SBBO U6, U2, 0x30, 2      // clear flags
  SBBO Comm.w0, U2, 0x2A, 2 // write ECCTL2 register -> start
  JMP  IoCEnd               // finish command

PwmCCon:
  QBNE QepCom, Comm.b3, PRUIO_COM_PWM // if no PWM command -> skip
  LBCO U2, DRam, 2*4, 3*4  // get parameters (DeAd, CMPA & CMPB, AQCTLA & AQCTLB)
  SBBO U3, U2, 0x12, 2*4   // write new AQCTLA & AQCTLB & CMPA & CMPB values
  QBEQ IoCEnd, Comm.w0, 0  // if no frequency change -> skip
  LBCO U5, DRam, 5*4, 4    // get parameters (TBCNT & TBPRD)
  SBBO U5, U2, 0x08, 2*2   // write new TBCNT & TBPRD values
  SBBO Comm.w0, U2, 0, 2   // write new TBCTL value
  JMP  IoCEnd              // finish command

QepCom:
  QBNE IoCEnd, Comm.b3, PRUIO_COM_QEP // if no QEP command -> skip, invalid
  LBCO U2, DRam, 2*4, 5*4  // get parameters (DeAd, QPOSMAX, QUPRD, QDECCTL, QEPCTL & QCAPCTL)
  SBBO U3, U2, 0x08, 4     // write new QPOSMAX value
  SBBO U4, U2, 0x20, 4     // write new QUPRD value

  SBBO U6.w2, U2, 0x2C, 2  // disable QCAPCTL
  SBBO U5, U2, 0x28, 3*2   // write new QDECCTL & QEPCTL & QCAPCTL values

  LDI  U4, 0b100001101001  // bit mask to reset QFLG (UTO,PCO,PCU,QDC,INT)
  SBBO U4, U2, 0x34, 2     // clear QCLR

  LBBO U4, U2, 0x00, 4     // load QPOSCNT register
  QBLT IoCEnd, U3, U4      // if counter in range -> skip
  SBBO U3, U2, 0x00, 4     // write QPOSCNT register
  JMP  IoCEnd              // finish command

PwmCEnd:
.endm
