.macro TIMER_Init
//
// wakeup TIMERs and read configuration
//
  LDI  Cntr, 0            // reset counter
TimerLoop:
  LBBO DeAd, Para, 0, 4*2 // load subsystem base & clock address
  ADD  Para, Para, 4*2    // increase pointer
  SBBO DeAd, Targ, 0, 4*2 // save adresses (subsystem & clock)
  QBNE TimerFull, ClAd, 0 // if subsystem enabled -> get full configuration
  LDI  UR, 0              // clear register
  LBBO U1, DeAd, 0, 4     // load subsystem TIDR
  SBBO UR, Targ, 4*2, 4*2 // clear clock value, save TIDR
  ADD  Targ, Targ, 4*4    // increase pointer
  JMP  TimerDone          // skip subsystem

TimerFull:
  LBBO UR, ClAd, 0, 4       // get TIMER clock value
  SBBO UR, Targ, 4*2, 4     // save clock value
  ADD  Targ, Targ, 4*3      // increase pointer
  LDI  U5, 0                // clear timeout counter
  LDI  U2, 2                // load clock demand value
  SBBO U2, ClAd, 0, 4       // write TIMER CLK register
TimerWake:
  LBBO UR, DeAd, 0x00, 4    // load TIMER TIDR register
  QBNE TimerCopy, UR, 0     // if TIMER is up -> copy conf
  ADD  U5, U5, 1            // count timeout
  QBGE TimerWake, U5.b1, 16 // if not timeout -> wait for wake up
  SBBO UR, Targ, 0, 4       // write failure to info block (TIDR)
  ADD  Targ, Targ, 4        // increase pointer
  JMP  TimerDone            // skip to next subsystem

TimerCopy:
  LBBO U1, DeAd, 0x10, 4     // load TIOCP_CFG
  SBBO UR, Targ, 0   , 4*2   // save registers
  LBBO UR, DeAd, 0x20, 4*15  // load IRQ_EOI to TCAR2 block
  SBBO UR, Targ, 4*2 , 4*15  // save registers
  ADD  Targ, Targ, 4*17      // increase pointer

TimerDone:
  ADD  Cntr, Cntr, 1      // increase counter
  QBGE TimerLoop, Cntr, PRUIO_AZ_TIMER // if not last -> do next

  SUB  UR, Para, 4        // pointer to last parameter
  SBBO Targ, UR, 0, 4     // mark end of TIMER arrays
.endm


.macro TIMER_Config
//
// write configuration from data block to subsystem registers
//
  LDI  Cntr, 0            // reset counter
TimerLoop:
  LBBO DeAd, Para, 0, 4*4 // load subsystem parameters DeAd, ClAd, ClVa, TIDR
  ADD  Para, Para, 4*4    // increase pointer

// prepare data array
//
  LSL  U1, Cntr, 4          // calc array pointer (sizeof(TimerArr)=16)
  MOV  U2, DeAd             // copy subsystem address
  QBEQ TimerJump, ClVa, 2   // if subsystem enabled -> don't clear DeAd
  LDI  U2, 0                // clear DeAd
TimerJump:
  ZERO &U3, 4*3             // clear registers
  SBBO U2, U1, PRUIO_DAT_TIMER, 4*4 // prepare array data

// check enabled / dissabled and data block length
//
  QBEQ TimerDone, ClAd, 0   // if subsystem disabled -> don't touch
  QBEQ TimerCopy, ClVa, 2   // if normal operation -> copy
  SBBO ClVa, ClAd, 0, 1     // write clock register
  QBEQ TimerDone, UR, 0     // if empty segment -> skip
  ADD  Para, Para, 4*17-4   // increase pointer
  JMP  TimerDone

TimerCopy:
  SUB  Para, Para, 4        // decrease pointer (TIDR)

  LDI  UR, 0                // reset value for TCLR
  SBBO UR, DeAd, 0x38, 4    // write TCLR

  LBBO UR, Para, 4*2 , 4*6  // load IRQ_EOI to IRQWAKEN block
  SBBO UR, DeAd, 0x20, 4*6  // write IRQ_EOI to IRQWAKEN block
  LBBO UR, Para, 4*9 , 4*2  // load TCRR & TLDR
  SBBO UR, DeAd, 0x3C, 4*2  // write TCRR & TLDR
  LBBO UR, Para, 4*12, 4*5  // load TWPS to TCAR2
  SBBO UR, DeAd, 0x48, 4*5  // write TWPS to TCAR2
  LBBO UR, Para, 4*1 , 4    // load TIOCP_CFG
  SBBO UR, DeAd, 0x10, 4    // write TIOCP_CFG
  LBBO UR, Para, 4*8 , 4    // load TCLR
  SBBO UR, DeAd, 0x38, 4    // write TCLR

  ADD  Para, Para, 4*17     // increase pointer

TimerDone:
  ADD  Cntr, Cntr, 1      // increase counter
  QBGE TimerLoop, Cntr, PRUIO_AZ_TIMER // if not last -> do next
.endm


.macro TIMER_IO_Data
//
// get subsystem data in IO mode
//
  LSL  UR, TimC, 4         // calc array pointer
  LBBO U1, UR, PRUIO_DAT_TIMER, 4 // get DeAd
  QBEQ TimerCnt, U1, 0     // if subsystem disabled -> skip
  LBBO U2, U1, 0x50, 4     // get TCAR1
  LBBO U3, U1, 0x58, 4     // get TCAR2
  SBBO U2, UR, PRUIO_DAT_TIMER+4*2, 4*2 // store Values

TimerCnt:
  ADD  TimC, TimC, 1       // increase counter
  QBGE TimerDEnd, TimC, PRUIO_AZ_TIMER  // if not last -> skip reset
  LDI  TimC, 0             // reset counter
TimerDEnd:
.endm


.macro TIMER_IO_Command
//
// handle subsystem command in IO mode
//
  QBNE TimerCEnd, Comm.b3, PRUIO_COM_TIM_PWM // if no TIMER PWM command -> skip
  LBCO U2, DRam, 4*2, 4*3  // get parameters (DeAd, TLDR, TMAR)
  SBBO U3, U2, 0x40, 4     // write TLDR
  SBBO U4, U2, 0x4C, 4     // write TMAR

  QBEQ TimerCSkip, Comm.w0, 0 // if no TCLR reconfiguration -> skip
  SBBO Comm.w0, U2, 0x38, 2   // write TCLR
  SBBO Comm, U2, 0x44, 4      // write TTRR to start new period

TimerCSkip:
  JMP  IoCEnd              // finish command

TimerCEnd:
.endm
