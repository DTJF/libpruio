.macro GPIO_Init
//
// wakeup GPIOs and read configuration
//
  LDI  Cntr, 0            // reset counter
GpioLoop:
  LBBO DeAd, Para, 0, 4*2 // load subsystem base & clock address
  ADD  Para, Para, 4*2    // increase pointer
  SBBO DeAd, Targ, 0, 4*2 // save adresses (subsystem & clock)
  QBNE GpioFull, ClAd, 0  // if subsystem enabled -> get full configuration
  LDI  UR, 0              // clear register
  LBBO U1, DeAd, 0, 4     // load subsystem REVISION
  SBBO UR, Targ, 4*2, 4*2 // clear clock value, save REVISION
  ADD  Targ, Targ, 4*4    // increase pointer
  JMP  GpioDone           // skip subsystem

GpioFull:
  LBBO UR, ClAd, 0, 4       // get GPIO clock value
  SBBO UR, Targ, 4*2, 4     // save clock value
  ADD  Targ, Targ, 4*3      // increase pointer
  LDI  U5, 0                // clear timeout counter
  LDI  U2, 2                // load clock demand value
  SBBO U2, ClAd, 0, 4       // set GPIO CLK register
GpioWake:
  LBBO UR, DeAd, 0x00, 4    // load GPIO REVISION register
  QBNE GpioCopy, UR, 0      // if GPIO is up -> copy conf
  ADD  U5, U5, 1            // count timeout
  QBGE GpioWake, U5.b1, 16  // if not timeout -> wait for wake up
  SBBO UR, Targ, 0, 4       // write failure to info block (REVISION)
  ADD  Targ, Targ, 4        // increase pointer
  JMP  GpioDone             // skip to next subsystem

GpioCopy:
  LBBO U1, DeAd, 0x10, 4      // load SYSCONFIG
  LBBO U2, DeAd, 0x20, 4*11   // load EOI to IRQWAKEN_1 block
  SBBO UR, Targ, 0   , 4*13   // save registers

  SET  DeAd, DeAd, 8          // switch to high bank
  LBBO UR, DeAd, 0x14, 4      // load SYSSTATUS
  LBBO U1, DeAd, 0x30, 4*10   // load CTRL to DEBOUNCINGTIME block
  SBBO UR, Targ, 4*13, 4*11   // save registers
  LBBO UR, DeAd, 0x90, 4*2    // load CLEARDATAOUT & SETDATAOUT
  SBBO UR, Targ, 4*24, 4*2    // save registers
  ADD  Targ, Targ, 4*26       // increase pointer

GpioDone:
  ADD  Cntr, Cntr, 1      // increase counter
  QBGE GpioLoop, Cntr, PRUIO_AZ_GPIO // if not last -> do next

  SUB  UR, Para, 4        // pointer to last parameter
  SBBO Targ, UR, 0, 4     // mark end of GPIO arrays
.endm


.macro GPIO_Config
//
// write configuration from data block to subsystem registers
//
  LDI  Cntr, 0            // reset counter
GpioLoop:
  LBBO DeAd, Para, 0, 4*4 // load subsystem parameters DeAd, ClAd, ClVa, REVISION
  ADD  Para, Para, 4*4    // increase pointer

// prepare data array
//
  LSL  U1, Cntr, 4          // calc array pointer (sizeof(GpioArr)=16)
  SET  U2, DeAd, 8          // copy DeAd (high bank)
  QBEQ GpioJump, ClVa, 2    // if subsystem enabled -> don't clear DeAd
  LDI  U2, 0                // clear DeAd
GpioJump:
  ZERO &U3, 4*3             // clear registers
  SBBO U2, U1, PRUIO_DAT_GPIO, 4*4 // prepare array data

// check enabled / dissabled and data block length
//
  QBEQ GpioDone, ClAd, 0    // if subsystem disabled -> don't touch
  QBEQ GpioCopy, ClVa, 2    // if normal operation -> copy
  SBBO ClVa, ClAd, 0, 1     // set clock register
  QBEQ GpioDone, UR, 0      // if empty set -> skip
  ADD  Para, Para, 4*26-4   // increase pointer
  JMP  GpioDone

GpioCopy:
  SUB  Para, Para, 4        // decrease pointer (REVISION)

  SET  DeAd, 8                // switch to high bank
  //LBBO UR, Para, 4*18, 4*6    // load LEVELDETECT0 to DEBOUNCINGTIME block
  //SBBO UR, DeAd, 0x40, 4*6-3  // set registers (skip DATAOUT, DEBOUNCINGTIME 1 byte)
  LBBO UR, Para, 4*14, 4*2    // load CTRL & OE
  SBBO UR, DeAd, 0x30, 4*2    // set registers
  LBBO UR, Para, 4*24, 4*2    // load CLEARDATAOUT & SETDATAOUT
  SBBO UR, DeAd, 0x90, 4*2    // set registers

  CLR  DeAd, 8                  // switch to low bank
  //LBBO UR, Para, 4*2 , 4*11   // load EOI to IRQWAKEN_1 block
  //SBBO UR, DeAd, 0x20, 4*11   // set block
  //LBBO UR, Para, 4   , 1      // load SYSCONFIG
  //SBBO UR, DeAd, 0x10, 1      // set register


  ADD  Para, Para, 4*26       // increase pointer

GpioDone:
  ADD  Cntr, Cntr, 1      // increase counter
  QBGE GpioLoop, Cntr, PRUIO_AZ_GPIO // if not last -> do next
.endm


.macro GPIO_IO_Data
//
// get subsystem data in IO mode
//
  LSL  UR, GpoC, 4         // calc array pointer
  LBBO U1, UR, PRUIO_DAT_GPIO, 4 // get DeAd (+0x100)
  QBEQ GpioCnt, U1, 0      // if subsystem disabled -> skip
  LBBO U2, U1, 0x38, 4*2   // get DATAIN & DATAOUT
  OR   U4, U2, U3          // OR both together
  SBBO U2, UR, PRUIO_DAT_GPIO+4, 4*3 // store Values

GpioCnt:
  ADD  GpoC, GpoC, 1       // increase counter
  QBGE GpioDEnd, GpoC, PRUIO_AZ_GPIO  // if not last -> skip reset
  LDI  GpoC, 0             // reset counter
GpioDEnd:
.endm


.macro GPIO_IO_Command
//
// handle subsystem command in IO mode
//
  QBNE GpioCOut, Comm.b3, PRUIO_COM_GPIO_CONF // if no GPIO_IN command -> skip
  LBCO U2, DRam, 4*2, 4*4  // get parameters
  SBBO U5, U2, 0x34, 4     // set OE
  JMP  GpioCData           // set data in case of output

GpioCOut:
  QBNE GpioCEnd, Comm.b3, PRUIO_COM_GPIO_OUT // if no GPIO_OUT command -> skip
  LBCO U2, DRam, 4*2, 4*3  // get parameters
GpioCData:
  SBBO U3, U2, 0x90, 4*2   // set CLEARDATAOUT & SETDATAOUT
  JMP  IoCEnd              // finish command

GpioCEnd:
.endm


.macro GPIO_MM_Trg
//
// handle GPIO trigger event in MM mode
//
  QBBC TrgSkip, TrgR.t21   // if no GPIO trigger -> skip
  AND  Tr_x, Tr_v, 0b11111 // extract GPIO bit index
  AND  UR, Tr_v, 0b1100000 // extract GPIO number
  LSR  UR, UR, 1           // calc GPIO array offset (sizeof(GpioArr = 16))
  LBBO UR, UR, PRUIO_DAT_GPIO, 4 // get GPIO base address
  QBEQ TrgPost, UR, 0      // if subsystem disabled -> skip

TrgGet:
  LBBO U1, UR, 0x38, 4*2   // load GPIO states (input / output)
  OR   U3, U1, U2          // mix both together

  QBBS TrgLow, TrgR.t7     // check negative bit
  QBBC TrgGet, U3, Tr_x    // if low -> wait again
  JMP  TrgPost             // continue at post trigger
TrgLow:
  QBBS TrgGet, U3, Tr_x    // if high -> wait again
  JMP  TrgPost             // continue at post trigger

TrgSkip:
.endm
