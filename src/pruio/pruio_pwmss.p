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
  SBBO U2, ClAd, 0, 4       // set PWMSS CLK register
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
  LBBO UR.w1, DeAd, 0x28, 2   // load TZCTL register
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
  LDI  Cntr, 0            // reset counter
PwmConf:
  LBBO DeAd, Para, 0, 4*4 // load PWMSS base address, clock address, clock value
  ADD  Para, Para, 4*4    // increase pointer

// prepare data array
  LSL  U1, Cntr, 5          // calc array pointer (sizeof(PwmssArr)=32)
  ADD  U1, U1, PRUIO_DAT_PWM// offset array pointer
  SET  U2, DeAd, 8          // copy DeAd +0x100
  QBEQ PwmJump, ClVa, 2     // if subsystem enabled -> don't clear
  LDI  U2, 0                // clear register
PwmJump:
  ZERO &U3, 4*8             // clear registers
  SBBO U2, U1,   0, 4       // prepare subsystem address
  SBBO U3, U1, 4*2, 4*6     // prepare array data (skip CMax)

// check enabled / dissabled and data block length
  QBEQ PwmDone, ClAd, 0     // if subsystem disabled -> don't touch
  QBEQ PwmCopy, ClVa, 2     // if normal operation -> copy
  SBBO ClVa, ClAd, 0, 4     // write clock register
  QBEQ PwmDone, UR, 0       // if PwmssSet empty -> skip
  ADD  Para, Para, 188+3-4  // increase pointer and adjust ...
  AND  Para.b0, Para.b0, 0xFC // at UInt32 border
  JMP  PwmDone

PwmCopy:
  SUB  Para, Para, 4        // decrease pointer (IDVER)

  LBBO UR, Para, 4*1, 4*2   // load SYSCONFIG & CLKCONFIG registers
  SBBO UR, DeAd, 0x04, 4*2  // write registers

  SET  DeAd, DeAd, 9        // switch to ePWM registers (+0x200)
  LBBO UR, Para, 184, 2*2   // load PCCTL and HRCTL registers
  SBBO UR, DeAd, 0x3C, 2*2  // write registers
  LBBO UR, Para, 174, 2*2   // load ETSEL & ETPS registers
  SBBO UR, DeAd, 0x32, 2*2  // write registers
  LBBO UR, Para, 162, 2*6   // load TZSEL to TZFRC registers
  SBBO UR.w0, DeAd, 0x24, 2 // write TZSEL
  SBBO UR.w1, DeAd, 0x28, 2 // write TZCTL
  SBBO U1.w0, DeAd, 0x2A, 2 // write TZEINT
  SBBO U2, DeAd, 0x2E, 2*2  // write TZCLR & TZFRC
  LBBO UR, Para, 4*39, 2*3  // load DB registers
  SBBO UR, DeAd, 0x1E, 2*3  // write registers
  LBBO UR, Para, 4*37, 2*4  // load AQ registers
  SBBO UR, DeAd, 0x16, 2*4  // write registers
  LBBO UR, Para, 4*35, 2*4  // load CM registers
  SBBO UR, DeAd, 0x0E, 2*4  // write registers
  LBBO UR, Para, 4*32, 2*6  // load TB registers
  //SBBO U1, DeAd, 0x04, 2*4  // write registers TBPHSHR to TBPRD
  //SBBO UR, DeAd, 0x00, 2*2  // write register TBCTL
  SBBO UR, DeAd, 0x00, 2*6  // write register TBCTL to TBPRD

  SUB  DeAd, DeAd, 0x80     // switch to eQEP registers (+0x180)
  //LBBO UR, Para, 2*61, 2    // load QCPRDLAT register
  //SBBO UR, DeAd, 0x40, 2    // write register
  //LBBO UR, Para, 4*27, 2*4  // load QCLR to QCPRD registers
  //SBBO UR, DeAd, 0x34, 2*4  // write registers
  //LBBO UR, Para, 4*23, 2*7  // load QWDTMR to QEINT registers
  //SBBO UR, DeAd, 0x24, 2*7  // write registers
  //LBBO UR, Para, 4*21, 4*2  // load QUTMR to QUPRD registers
  //SBBO UR, DeAd, 0x1C, 4*2  // write registers
  //LBBO UR, Para, 4*14, 4*4  // load QPOSCNT to QPOSCMP registers
  //SBBO UR, DeAd, 0x00, 4*4  // write registers

  SUB  DeAd, DeAd, 0x80     // switch to eCAP registers (+0x100)
  LBBO UR, Para, 4*12, 2*2  // load ECCLR & ECFRC registers
  SBBO UR, DeAd, 0x30, 2    // write ECCLR register

  LBBO UR, Para, 4*10, 2*3  // load ECCTL1 to ECEINT registers
  SBBO UR, DeAd, 0x28, 2*3  // write registers
  //SBBO UR, DeAd, 0x28, 2*2  // write registers ECCTL1 & ECCTL2

  LBBO UR, Para, 4*4, 4*6   // load TSCTR to CAP4 registers
  //SBBO UR, DeAd, 0x00, 4*6  // write registers
  SBBO UR, DeAd, 0x00, 4*4  // write registers TSCTR to CAP2


  ADD  Para, Para, 188+3      // increase pointer and adjust ...
  AND  Para.b0, Para.b0, 0xFC // at UInt32 border

PwmDone:
  ADD  Cntr, Cntr, 1                 // increase counter
  QBGE PwmConf, Cntr, PRUIO_AZ_PWMSS // if not last -> do next
.endm


.macro PWMSS_IO_Data
//
// get subsystem data in IO mode
//
  LSL  U3, PwmC, 5         // calc array pointer (sizeof(PwmssArr)=32)
  ADD  UR, U3, PRUIO_DAT_PWM // add array offset
  LBBO U1, UR, 0, 4*2      // get address & maximum period
  QBEQ PwmCnt, U1, 0       // if subsystem disabled -> skip
  QBEQ PwmQep, U2, 0       // if CAP in PWM mode -> skip

  LBBO U3, U1, 0x2E, 2     // get ECFLG register
  SBBO U3, U1, 0x30, 2     // reset flags (ECCLR register)
  LBBO U4, U1, 0x00, 4     // get TSCTR register

  QBLE PwmDClear, U4, U2   // if timeout -> clear variables
  QBBS PwmDClear, U3, 5    // if overflow -> clear variables

  QBBC PwmCap34, U3, 3     // no CEVT3 -> check CEVT1
  LBBO U4, U1, 0x08, 4*2   // get CAP1/CAP2 registers
  ADD  U5, U5, 1           // adjust counter
  JMP  PwmDSet             // write variables

PwmCap34:
  QBBC PwmQep, U3, 1       // no CEVT1 -> skip
  LBBO U4, U1, 0x10, 4*2   // get CAP3/CAP4 registers
  ADD  U5, U5, 1           // adjust counter
  JMP  PwmDSet             // set variables

PwmDClear:
  ZERO &U4, 8              // clear registers
PwmDSet:
  SBBO U4, UR, 4*2, 4*2    // set variables C1 & C2

PwmQep:
  //ADD  U1, U1, 0x80        // switch to eQEP (0x180)
  //LBBO U3, U1, 0x00, 4     // get QPOSCNT register
  //SBBO U3, UR, 4*4, 4*4    // set variables

PwmCnt:
  ADD  PwmC, PwmC, 1       // increase counter
  QBGE PwmDEnd, PwmC, PRUIO_AZ_PWMSS // if not last -> do next
  LDI  PwmC, 0             // reset counter
PwmDEnd:
.endm


.macro PWMSS_IO_Command
//
// handle subsystem command in IO mode
//
  QBNE PwmCapComm, Comm.b3, PRUIO_COM_PWM // if no PWM command -> skip
  LBCO U2, DRam, 4*2, 4*3   // get parameters (subsystem address, CMPA & CMPB, AQCTLA & AQCTLB)
  SBBO U3, U2, 0x12, 2*4    // set new AQCTLA & AQCTLB & CMPA & CMPB values
  QBEQ IoCEnd, Comm.w0, 0   // if no frequency change -> skip
  LBCO U4, DRam, 4*5, 4     // get parameters (TBCNT & TBPRD)
  SBBO U4, U2, 0x08, 2*2    // set new TBCNT & TBPRD values
  SBBO Comm.w0, U2, 0, 2    // set new TBCTL values
  JMP  IoCEnd               // finish command

PwmCapComm:
  QBNE CapComm, Comm.b3, PRUIO_COM_PWM_CAP // if no PWM_CAP command -> skip
  LBCO U2, DRam, 4*2, 4*3   // get parameters (subsystem address, period, duty)
  QBEQ PwmCapNI, Comm.w0, 0 // if no re-config -> skip
  SBBO Comm.w0, U2, 0x2A, 2 // set ECCTL2 register
PwmCapNI:
  SBBO U3, U2, 0x10, 4*2    // set new period & duty values
  JMP  IoCEnd               // finish command

CapComm:
  QBNE PwmCEnd, Comm.b3, PRUIO_COM_CAP // if no CAP command -> skip
  LBCO U2, DRam, 4*2, 4     // get parameter (subsystem address)
  SBBO Comm.w0, U2, 0x2A, 2 // set ECCTL2 register
  ZERO &U3, 4*4             // clear registers
  SBBO U3, U2, 0x08, 4*4    // reset capture (CAP1-4)
  LDI  U3, 0b11111111       // mask to clear flags
  SBBO U3, U2, 0x30, 1      // clear flags
  SBBO U4, U2, 0x00, 4      // reset counter (TSCTR)
  JMP  IoCEnd               // finish command

PwmCEnd:
.endm
