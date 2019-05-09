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
  LDI  TimC, 0            // reset counter
TimerLoop:
  LBBO DeAd, Para, 0, 4*4 // load subsystem parameters DeAd, ClAd, ClVa, TIDR
  ADD  Para, Para, 4*4    // increase pointer

// prepare data array
//
  LSL  U1, TimC, 4          // calc array pointer (sizeof(TimerArr)=16)
  MOV  U2, DeAd             // copy subsystem address
  QBEQ TimerJump, ClVa, 2   // if subsystem enabled -> don't clear DeAd
  LDI  U2, 0                // clear DeAd
TimerJump:
  ZERO &U3, 3*4             // clear registers
  SBBO U2, U1, PRUIO_DAT_TIMER, 4*4 // prepare array data

// check enabled / dissabled and data block length
//
  QBEQ TimerDone, ClAd, 0   // if no CLOCK addr -> don't touch
  QBNE TimerCopy, DeAd, 0   // if normal operation -> copy
  SBBO ClVa, ClAd, 0, 4     // write clock register
  QBEQ TimerDone, UR, 0     // if no ID (empty segment) -> skip
  ADD  Para, Para, 4*17-4   // increase pointer
  JMP  TimerDone

TimerCopy:
  SUB  Para, Para, 4        // decrease pointer (TIDR)

  LDI  UR, 0                // reset value for TCLR
  SBBO UR, DeAd, 0x38, 4    // write TCLR

  LBBO UR, Para, 2* 4, 6*4  // load IRQ_EOI to IRQWAKEN block
  SBBO UR, DeAd, 0x20, 6*4  // write IRQ_EOI to IRQWAKEN block
  LBBO UR, Para, 9* 4, 2*4  // load TCRR & TLDR
  SBBO UR, DeAd, 0x3C, 2*4  // write TCRR & TLDR
  LBBO UR, Para, 12*4, 5*4  // load TWPS to TCAR2
  SBBO UR, DeAd, 0x48, 5*4  // write TWPS to TCAR2
  LBBO UR, Para,    4, 4    // load TIOCP_CFG
  SBBO UR, DeAd, 0x10, 4    // write TIOCP_CFG
  LBBO UR, Para, 8* 4, 4    // load TCLR
  SBBO UR, DeAd, 0x38, 4    // write TCLR

  ADD  Para, Para, 4*17     // increase pointer

TimerDone:
  ADD  TimC, TimC, 1      // increase counter
  QBGE TimerLoop, TimC, PRUIO_AZ_TIMER // if not last -> do next
.endm


.macro TIMER_IO_Data
//
// get subsystem data in IO mode
//
  LSL  UR, TimC, 4         // calc array pointer
  LBBO U1, UR, PRUIO_DAT_TIMER, 2*4 // get DeAd & CMax
  QBEQ TimerCnt, U1, 0     // if subsystem disabled -> skip
  QBLT TimerCap, U2, 255   // if module in CAP mode -> skip
  QBEQ TimerCnt, U2, 0     // if no one shot mode -> skip

  LBBO U3, U1, 0x24, 4     // load IRQSTATUS_RAW
  QBBC TimerCnt, U3.t0     // no match -> skip
  SBBO U3, U1, 0x28, 4     // write IRQSTATUS to clear events
  LBBO U4, U1, 0x38, 4     // load TCLR
  QBBC TimerCnt, U4.t8     // no oneshot -> skip

  SUB  U2, U2, 1           // decrease count
  SBBO U2, UR, PRUIO_DAT_TIMER+4, 4 // write CMax
  QBNE TimerCnt, U2, 0     // counts left -> skip

  CLR  U4.t0               // clear ST bit
  SBBO U4, U1, 0x38, 4     // write TCLR
  JMP  TimerCnt

TimerCap:
  LBBO U2, U1, 0x50, 4     // get TCAR1
  LBBO U3, U1, 0x58, 4     // get TCAR2
  SBBO U2, UR, PRUIO_DAT_TIMER+2*4, 2*4 // store Values

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
  QBLT TimerCEnd, Comm.b3, PRUIO_COM_TIM_PWM // if no TIMER command -> skip

  QBNE TimerCTim, Comm.b3, PRUIO_COM_TIM_PWM // if no PWM command -> skip
  LBCO U2, DRam, 2*4, 4*4  // get parameters (DeAd, TLDR, TMAR, TCCR)
  SBBO U3, U2, 0x40, 4     // write TLDR
  SBBO U4, U2, 0x4C, 4     // write TMAR

  QBEQ TimerCSkip, Comm.w0, 0 // if no TCLR reconfiguration -> skip
  LDI  U3, 0               // reset value for TCLR
  SBBO U3, U2, 0x38, 4     // write TCLR (stop timer)
  SBBO U5, U2, 0x3C, 4     // write TCRR
  LDI  Comm.w2, 0          // clear command byte
  SBBO Comm, U2, 0x38, 4   // write new TCLR
  JMP  IoCEnd              // finish command

TimerCTim:
  QBNE TimerCSkip, Comm.b3, PRUIO_COM_TIM_TIM // if no TIMER command -> skip
  LBCO U2, DRam, 2*4, 4*4  // get parameters (DeAd, TCRR, TLDR, TMAR)
  LDI  Comm.w2, 0          // clear command byte
  SBBO Comm, U2, 0x38, 4   // write TCLR (cleared ST bit)
  QBBC IoCEnd, Comm.t1     // no reload=stopped -> done
  SBBO U3, U2, 0x3C, 2*4   // write TCRR & TLDR
  SBBO U5, U2, 0x4C, 4     // write TMAR
  SET  Comm.t0             // set ST bit
  SBBO Comm, U2, 0x38, 4   // write TCLR (set ST bit)
  LDI  U6, 0b111           // load MAT_IT_FLAG & OVF_IT_FLAG & TCAR_IT_FLAG
  SBBO U6, U2, 0x28, 4     // write IRQSTATUS -> clear events

TimerCSkip:
  JMP  IoCEnd              // finish command

TimerCEnd:
.endm
