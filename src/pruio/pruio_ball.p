//
// read BALL configuration
//
.macro BALL_Init
  LDI  Cntr, 0             // reset counter
  LBBO DeAd, Para, 0, 4    // address of Control Module pinmux

  SBBO DeAd, Targ, 0, 4    // save address
  ADD  Targ, Targ, 4
BallCopy:
  LSL  UR, Cntr, 2         // calc pin offset
  LBBO U1, DeAd, UR, 1     // load Ball configuration
  SBBO U1, Targ, Cntr, 1   // save Ball configuration
  ADD  Cntr, Cntr, 1       // increase counter
  QBGE BallCopy, Cntr, PRUIO_AZ_BALL // if not last -> do next

  ADD  UR, Targ, Cntr      // add counter to target and ...
  ADD  Targ, UR, 3         // increase to ...
  AND  Targ.b0, Targ.b0, 0xFC // adjust at UInt32 border

  SBBO Targ, Para, 0, 4    // mark end of Ball array
  ADD  Para, Para, 4
.endm

//
// write BALL configuration
//
.macro BALL_Config
// just skip parameters
  ADD  Para, Para, 4+PRUIO_AZ_BALL+3 // add counter to pointer and ...
  AND  Para.b0, Para.b0, 0xFC // adjust at UInt32 border
BallDone:
.endm


.macro BALL_IO_Command
//
// handle subsystem command in IO mode
//
  QBLT BallEnd, Comm.b3, PRUIO_COM_POKE // if no Ball command -> skip
  LBCO U2, DRam, 4*2, 4    // get adress
  MOV  Para.b0, Comm.b0    // get length
  QBNE BallCIn, Comm.b3, PRUIO_COM_POKE // if no Ball_OUT command -> skip to IN

  LBCO U3, DRam, 4*3, b0  // get context
  SBBO U3, U2,     0, b0  // save context
  JMP  IoCEnd             // finish command

BallCIn:
  LBBO U3, U2,     0, b0  // get context
  SBCO U3, DRam, 4*3, b0  // save context
  JMP  IoCEnd             // finish command

BallEnd:
.endm
