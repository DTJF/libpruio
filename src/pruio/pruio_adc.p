.macro ADC_Init
//
// wakeup ADC and read configuration
//
  LBBO DeAd, Para, 0, 4*2 // load subsystem base & clock address
  ADD  Para, Para, 4*2    // increase pointer
  SBBO DeAd, Targ, 0, 4*2 // save adresses (subsystem & clock)
  QBNE AdcFull, ClAd, 0   // if subsystem enabled -> get full configuration
  LDI  UR, 0              // clear clock value
  LBBO U1, DeAd, 0, 4     // load subsystem REVISION
  SBBO UR, Targ, 4*2, 4*2 // store clock value & REVISION
  ADD  Targ, Targ, 4*4    // increase pointer
  JMP  AdcDone            // skip subsystem

AdcFull:
  LBBO UR, ClAd, 0, 4       // get ADC clock value
  SBBO UR, Targ, 4*2, 4     // save ClAd value
  ADD  Targ, Targ, 4*3      // increase pointer

  LDI  U2, 0b10             // load clock demand value
  SBBO U2, ClAd, 0, 1       // set clock register
  LDI  U5, 0                // clear timeout counter
AdcWait:
  LBBO UR, DeAd,  0, 4      // load ADC REVISION
  QBNE AdcCopy, UR, 0       // if ADC is up -> copy config
  ADD  U5, U5, 1            // increase timeout counter
  QBGE AdcWait, U5.b1, 16   // if no timeout -> wait
  SBBO UR, Targ, 0, 4       // write failure to info block (REVISION)
  ADD  Targ, Targ, 4        // increase pointer
  JMP  AdcDone

AdcCopy:
  LBBO U1, DeAd, 0x10, 4      // load SYSCONFIG
  LBBO U2, DeAd, 0x24, 4*16   // load IRQ_STATUS_RAW to TS_CHARGE_DELAY
  SBBO UR, Targ,    0, 4*18   // store in Dram

  LBBO UR, DeAd, 0x64, 4*16   // load steps 1 to 8
  SBBO UR, Targ, 4*18, 4*16   // store in Dram
  LBBO UR, DeAd, 0xA4, 4*16   // load steps 9 to 16
  SBBO UR, Targ, 4*34, 4*16   // store in Dram

  LBBO UR, DeAd, 0xE4, 4*6    // load FIFO0COUNT to DMA1REQ
  SBBO UR, Targ, 4*50, 4*6    // store in Dram
  ADD  Targ, Targ, 4*56       // increase pointer

AdcDone:
  SUB  UR, Para, 4        // pointer to last parameter
  SBBO Targ, UR, 0, 4     // mark end of ADC array
.endm


.macro ADC_Config
//
// write configuration from data block to subsystem registers
//
  LBBO DeAd, Para, 0, 4*4 // load subsystem parameters DeAd, ClAd, ClVa, REVISION
  ADD  Para, Para, 4*4    // increase pointer

// prepare data array
//
  MOV  U2, DeAd           // copy subsystem address
  QBEQ AdcJump, ClVa, 2   // if subsystem enabled -> don't zero
  LDI  U2, 0              // clear subsystem address
AdcJump:
  ZERO &U3, 2*17          // clear registers (for Value array)
  SBCO U2, DRam, PRUIO_DAT_ADC, 4+2*17 // prepare ADC array data

// check enabled / dissabled + data block length
  LDI  FiFo, 0              // reset FiFo-0 address
  QBEQ AdcDone, ClAd, 0     // if subsystem disabled -> don't touch
  QBEQ AdcConf, ClVa, 2     // if normal operation -> configure
  SBBO ClVa.b0, ClAd, 0, 1  // write clock register
  QBEQ AdcZero, UR, 0       // if AdcSet is empty (REVISION = 0) -> skip
  ADD  Para, Para, 4*56-4   // increase pointer to skip parameters
  JMP  AdcZero              // skip config

AdcConf:
  LDI  UR, 0                // clear register
  SBBO UR, DeAd, 0x10, 1    // reset SYSCONFIG register to zero (= idle)
AdcIdle:
  LBBO UR, DeAd, 0x44, 4    // get ADC status
  QBBS AdcIdle, UR, 5       // if ADC busy -> wait
  LDI  UR, 0b100            // disable ADC (step config writable)
  SBBO UR, DeAd, 0x40, 2    // write CTRL register

// configure subsystem
  SUB  Para, Para, 4         // decrease pointer (REVISION)
  LBBO UR, Para, 4*50, 4*6   // load FIFO0COUNT to DMA1REQ
  SBBO U1, DeAd, 0xE8, 4*2   // write FIFO0THRESHOLD & DMA0REQ
  SBBO U4, DeAd, 0xF4, 4*2   // write FIFO1THRESHOLD & DMA1REQ
  LBBO UR, Para, 4*34, 4*16  // load step config registers 9 - 16
  SBBO UR, DeAd, 0xA4, 4*16  // write registers
  LBBO UR, Para, 4*18, 4*16  // load step config registers 1 - 8
  SBBO UR, DeAd, 0x64, 4*16  // write registers
  LBBO UR, Para, 4*11, 4*7   // load ADCRANGE to IDLECONFIG
  SBBO UR, DeAd, 0x48, 4*7   // write registers
  LBBO UR, Para, 4*2 , 4*8-2 // load IRQSTATUS_RAW to CTRL
  SBBO UR, DeAd, 0x24, 4*8-2 // write registers
  LBBO UR, Para, 4   , 1     // load SYSCONFIG register
  SBBO UR, DeAd, 0x10, 1     // write register
  ADD  Para, Para, 4*56      // increase pointer

AdcZero:
  SET  FiFo, DeAd, 8        // calc FiFo-0 address
AdcFiFo:
  LBBO UR, DeAd, 0xE4, 4    // get FiFo-0 counter
  QBEQ AdcDone, UR, 0       // if FiFo empty -> continue
  LBBO U2, FiFo, 0, 4       // get old pending value
  JMP  AdcFiFo              // check again
AdcDone:
.endm


.macro ADC_IO_Init
//
// initialise subsystem before IO mode
//
  LBCO DeAd, DRam, PRUIO_DAT_ADC, 4 // get subsystem address
  LDI  StpM, 0             // clear step mask
  QBEQ AdcIEnd, DeAd, 0    // if subsystem disabled -> skip
  LBCO StpM, DRam, 4*3, 4  // get real step mask
  SBBO StpM, DeAd, 0x54, 3 // start ADC

AdcIEnd:
  LBCO RegC, DRam, 4*4, 4  // get all counter start values & LSL mode
.endm


.macro ADC_IO_Data
//
// get subsystem data in IO mode
//
  LBCO DeAd, DRam, PRUIO_DAT_ADC, 4 // get devise address
  QBEQ AdcDEnd, DeAd, 0    // if subsystem disabled -> skip
  LBBO UR, DeAd, 0x44, 4   // get ADC status
  QBBS AdcGet, UR, 5       // if ADC busy -> skip restart
  SBBO StpM, DeAd, 0x54, 3 // restart ADC

AdcGet:
  LBBO U4, DeAd, 0xE4, 4   // get FiFo-0 counter
  QBEQ AdcDEnd, U4, 0      // if no value -> skip

  LBBO U2, FiFo, 0, 4      // get ADC value
  LSL  U3, U2.b2, 1        // extract step ID, calc position
  ADD  U4, U2.b2, 1        // calc step number
  LSL  U2, U2.w0, LslM     // shift to 13, 14, 15 or 16 bit
  QBBS AdcSave, StpM, U4   // if step active -> skip zeroing value
  LDI  U2, 0               // zero inactive steps
AdcSave:
  SBBO U2, U3, PRUIO_DAT_ADC +2+4, 2 // store ADC value to DRam

AdcDEnd:
.endm


.macro ADC_IO_Command
//
// handle subsystem command in IO mode
//
  QBNE AdcCEnd, Comm.b3, PRUIO_COM_ADC // if no ADC command -> skip
  MOV  UR, 0x1FFFF         // load bit mask
  AND  StpM, Comm, UR      // set new step mask
  LDI  UR, 16              // number of steps
ClrSteps:
  QBBS SkipStp, StpM, UR   // if step active -> skip
  LSL  U2, UR, 1           // calc step position offset
  SBBO UR.w2, U2, PRUIO_DAT_ADC +4, 2 // clear ADC value in DRam
SkipStp:
  SUB  UR, UR, 1           // decrease counter
  QBNE ClrSteps, UR, 0     // not last step -> again
  JMP  IoCEnd
AdcCEnd:
.endm


.macro ADC_MM_Init
//
// initialize MM
//
  LBCO DeAd, DRam, PRUIO_DAT_ADC, 4 // get subsystem address
  QBNE InitGo, DeAd, 0     // if active -> go
  MOV  UR, PRUIO_MSG_ADC_ERRR // load error message
  SBCO UR, DRam, 0, 4      // set status information
  MOV  r31.b0, IRPT        // send notification to host
  HALT

InitGo:
  LBCO StpM, DRam, 4*3, 4*3// get real step mask, Lsl mode & TimerVal (StpM, RegC, Comm)

  LBCO UR, C26, 0x40, 4    // read IEP timer CMP_CFG register
  OR   UR, UR, 0b111       // CMP0_RST_CNT_EN (count reset) and CMP_EN[0+1]
  LDI  U1, 0b11            // clear CMP_HIT[0+1]
  MOV  U2, Comm            // CMP0 (loop period = TimerVal)
  LSR  U3, Comm, 10        // max. timer for digital IO
  SBCO UR, C26, 0x40, 4*4  // set CMP_CFG, CMP_STATUS, CMP0, CMP1 (config, status, period, pre-period)

  LDI  UR, 0x0551          // enable counter, 5 increments
  SBCO UR, C26, 0, 2       // set IEP GLOBAL_CFG register
.endm


.macro ADC_FIFO_Empty
//
// clear FiFo-0
//
AdcPrep:
  LBBO SmpR, DeAd, 0x44, 4 // get ADC status
  QBBS AdcPrep, SmpR, 5    // ADC busy, wait
FifoClr:
  LBBO Cntr, DeAd, 0xE4, 4 // get FiFo-0 counter
  QBEQ FifoEmpty, Cntr, 0  // if FiFo-0 empty -> start
  LBBO SmpR, FiFo, 0, 4    // drop old pending ADC value
  JMP  FifoClr             // again, until FiFo-0 is empty
FifoEmpty:
.endm


.macro CALC_Trg_Delta
//
// check/compute delta trigger value
//
TrgDelta:
  QBBC DelDone, TrgR.t6      // if no delta trigger -> continue

  CLR  TrgR.t6               // clear delta bit
  QBBS DeltaLt, TrgR.t7      // if negative bit -> check less than

  ADD  Tr_v, Tr_v, SmpR.w0   // new pos. trigger value, based on current sample
  LDI  UR, 0xFF0             // load maximum
  MIN  Tr_v, Tr_v, UR        // limit to 0xFF0
  JMP  DelDone               // continue

DeltaLt:
  QBGE DelFix, SmpR.w0, Tr_v // if overflow -> fix it
  SUB  Tr_v, SmpR.w0, Tr_v   // new neg. trigger value, based on current sample
  QBLE DelDone, Tr_v, 0x10   // if big enough -> continue
DelFix:
  LDI  Tr_v, 0xF             // set minimal trigger value

DelDone:
.endm


.macro ADC_MM_Trg
//
// execute trigger on steps (single or all) in MM mode, or prepare post trigger
//
TrgSamp:
  AND  TrgR.b2, TrgR.b2, 0xF // mask valid sample compare bits (= Tr_v)
  QBBS TrgPre, TrgR.t4       // if pre-trigger bit -> start pre-trigger
  QBBS TrgAll, TrgR.t5       // if all steps -> configure all

// configure single step trigger
  AND  Tr_x, TrgR.b0, 0b1111 // get real step#, only values 0 to 15 are valid
  MOV  U5, CmpR              // duplicate old step mask
  LDI  CmpR, 2               // prepare new trigger step mask
  LSL  CmpR, CmpR, Tr_x      // left shift mask
  QBEQ TrgDelta, CmpR, U5    // if same step -> skip sampling
  JMP  TrgStart              // get new sample

// configure all steps trigger
TrgAll:
  MOV  CmpR, StpM            // set trigger step mask
  CLR  TrgR.t6               // clear delta bit (not allowed here)
  QBNE TrgTest, Tr_i, 0      // if not first trigger -> skip sampling

// get ADC sample(s)
TrgStart:
  SBBO CmpR, DeAd, 0x54, 3   // enable ADC steps, go for trigger samples

TrgBusy:
  LBBO SmpR, DeAd, 0x44, 4   // get ADC status
  QBBS TrgBusy, SmpR, 5      // if ADC busy -> wait
TrgGet:
  LBBO SmpR, DeAd, 0xE4, 4   // get FiFo-0 counter
  QBEQ TrgStart, SmpR, 0     // if no value -> start again
  LBBO SmpR, FiFo, 0, 4      // get ADC value (32 bit)

// compute delta trigger value, check value
TrgDelta:
  CALC_Trg_Delta

// test sample
TrgTest:
  QBBS TrgLt, TrgR.t7        // if negative bit -> check less
  QBGT TrgGet, SmpR.w0, Tr_v // if not greater -> get next sample
  JMP  TrgDone               // trigger done
TrgLt:
  QBLT TrgGet, SmpR.w0, Tr_v // if not less -> get next sample

// empty FiFo-0
TrgDone:
  LBBO SmpR, DeAd, 0x44, 4   // get ADC status
  QBBS TrgDone, SmpR, 5      // if ADC busy -> wait
TrgDone2:
  LBBO UR, DeAd, 0xE4, 4     // get FiFo-0 counter
  QBEQ TrgPost, UR, 0        // if no value -> continue at post trigger
  LBBO U2, FiFo, 0, 4        // drop old pending sample
  JMP  TrgDone2              // test again


//
// pre-trigger setup, initialize ring buffer (zero)
//
TrgPre:
  QBNE TrgMmDRam, Tr_c, 0    // if pre-values -> configure DRam ring buffer

// configure ERam ring buffer (RB mode)
  ADD  Samp, Samp, 255       // add some values to samples to run endless
  JMP  MmData                // start measurement

// clear ring buffer in DRam (MM mode)
TrgMmDRam:
  LDI  Ch__, ChMx            // start with max chunk size
  ZERO &UR, ChMx             // clear data registers
  LDI  TarR, PRUIO_DAT_ADC   // load start position
  LBCO LUpR, DRam, 4*3, 4    // read ring buffer size
  SUB  I___, LUpR, ChMx - 32 // initialize index (32 = 2 byte * 16 max steps)

Check0:
  QBGE Store0, I___, LUpR    // if complete chunk in range -> go
  ADD  Ch__, I___, ChMx      // chunk size = rest
  LDI  I___, 0               // index = zero

Store0:
  SBBO UR, TarR, I___, b0    // save chunk to memory
  QBEQ InitEnd, I___, 0      // if index reached ground -> jump out
  SUB  I___, I___, Ch__      // calc index for next chunk
  JMP  Check0                // go again

InitEnd:
  LSR  Tr_c, LUpR, 1         // pre-trigger samples counter (any value <> 0)
  LDI  Tr_s, TChC            // initialize b3 (step offset)
  JMP  MmData2               // start sampling to ring buffer
.endm


.macro ADC_MM_Data
//
// get data in MM mode
//
  LDI  UR, 1                 // value to reset timer
  SBBO StpM, DeAd, 0x54, 3   // enable ADC steps, go for samples
  SBCO UR, C26, 0x0C, 4      // reset timer
  LDI  UR, 0b11              // value to clear
  SBCO UR, C26, 0x44, 1      // clear timer CMP_HIT[0+1]
  LDI  Cntr, 0               // reset counter
  LDI  PtrR, 0               // reset index

DataLoop:
  QBLE DataDone, Cntr, Samp  // if last Samp reached -> jump out of loop
  QBNE DataAdc, Tr_c, 0      // if pre-trigger -> skip IO

DigiIoLoop:
  LBCO CmpR, C26,  0x44, 1   // load CMP_STATUS bits
  QBBS DataAdc, CmpR, 1      // if timer CMP_HIT[1] -> handle ADC
  CALL IoData                // get digital IO and execute commands
  JMP  DigiIoLoop            // next loop

DataAdc:
  LBBO CmpR, DeAd, 0x44, 4   // get ADC status
  QBBS DataAdc, CmpR, 5      // if ADC busy -> wait

DataTime:
  LBCO CmpR, C26,  0x44, 1   // load CMP_STATUS bits
  QBBC DataTime, CmpR, 0     // if timer counting -> wait

  SBBO StpM, DeAd, 0x54, 3   // enable ADC steps, go for next sample
  SBCO CmpR, C26,  0x44, 1   // clear timer CMP_STATUS bits

  //CALL IoData                // get digital IO and execute commands
DataGet:
  LBBO UR, DeAd, 0xE4, 4     // get FiFo-0 counter
  QBEQ DataLoop, UR, 0       // if no value -> start ADC again
  LBBO SmpR, FiFo, 0, 4      // get one 32-bit ADC value

  QBEQ DataLsl, Tr_c, 0      // if trigger done -> save sample

//QBLT PreTrgDone, PtrR, 0xFF

  QBBS TrgTest, TrgR.t5      // if trigger all steps -> check sample
  QBNE TrgNoT, Tr_x, SmpR.b2 // if other trigger step -> skip
  QBNE TrgTest, Tr_s, TChC   // if trigger step position already known -> test value
  MOV  Tr_s, Cntr            // store trigger step position
  ADD  LUpR, LUpR, PtrR      // more room for samples before trigger step
  CALC_Trg_Delta

TrgTest:

//JMP PreTrgDone

  QBBS TrgLt, TrgR.t7        // if lower check -> skip greater check

  QBGT TrgNoT, SmpR.w0, Tr_v // if not greater -> continue trigger
  JMP  PreTrgDone            // start normal measurement

TrgLt:
  QBLT TrgNoT, SmpR.w0, Tr_v // if not less -> continue trigger

PreTrgDone:
  LDI  TrgC, 0               // got the trigger, clear control register
  MOV  Tr_p, PtrR            // save ring buffer pointer (TrgR)
  MOV  Tr_u, LUpR            // save ring buffer size    (TrgR)
  MOV  PtrR, LUpR            // initialize pointer behind last ring buffer position
  LSR  Cntr, LUpR, 1         // initialize counter behind ring buffer
  LBCO LUpR, DRam, 4, 4*2    // get size of & pointer to ERam (LUpR & TarR)
  SBCO Cntr, DRam, 4, 4      // reset command parameter
  JMP  DataLsl

TrgNoT:
  MIN  Cntr, Cntr, Tr_s      // hold down counter while waiting for trigger

DataLsl:
  LSL  SmpR, SmpR, LslM      // shift to 13, 14, 15 or 16 bit
  QBGT DataOut, PtrR, LUpR   // if PtrR not reached limit -> no overflow, skip reset
  LDI  PtrR, 0               // reset pointer
  LDI  Cntr, 0               // reset counter
DataOut:
  SBBO SmpR, TarR, PtrR, 2   // write lower 16 bit to memory
  SBCO Cntr, DRam, 0, 4      // write status information
  ADD  Cntr, Cntr, 1         // increase samples counter
  ADD  PtrR, PtrR, 2         // increase pointer value
  JMP  DataGet               // next loop

DataDone:
.endm


.macro ADC_MM_Sort
//
// sort data from ring buffer in ERam (MM mode)
//
  QBEQ SortDone, TrgR, 0     // if no ring buffer -> skip

// copy lower part to upper end
  SUB  Cntr, Tr_u, Tr_p      // calc byte size to copy
  ADD  S___, Tr_p, PRUIO_DAT_ADC // calc source pointer
  CALL Copy                  // and copy block

  QBEQ SortDone, Tr_p, 0     // if trigger at buffer start -> skip
// copy upper part to start
  ADD  TarR, TarR, Cntr      // calc new target pointer
  LDI  S___, PRUIO_DAT_ADC   // load source pointer (DRam)
  MOV  Cntr, Tr_p            // load byte size to copy
  CALL Copy                  // and copy block
SortDone:
.endm
