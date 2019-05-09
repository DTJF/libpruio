/'* \file pruio.bas
\brief The main source code of the library.

This is the main source code of the library. You may compile it by `fbc
-dylib pruio.bas` to get a small library file (small, because the C
wrapper functions are not included as in the original version).

\since 0.0
'/


'* Tell the header pruio.bi that we won't include libpruio.so.
#DEFINE __PRUIO_COMPILING__

' uio driver header file
#INCLUDE ONCE "pruio_prussdrv.bi"
' driver header file
#INCLUDE ONCE "pruio.bi"
' Header file with convenience macros.
#INCLUDE ONCE "pruio_pins.bi"
' Header file with Pru_Init instructions.
#INCLUDE ONCE "pasm_init.bi"
' Header file with Pru_Run instructions.
#INCLUDE ONCE "pasm_run.bi"
' FB include
#INCLUDE ONCE "dir.bi"

'* The start of the pinmux-helper folder names in /sys/devices/ocp.*/.
#DEFINE PMUX_NAME "pruio-"
'* The constant number for no pinmux capability.
#DEFINE PMUX_ERRR 258
'* Macro to calculate the total size of an array in bytes.
#DEFINE ArrayBytes(_A_) (UBOUND(_A_) + 1) * SIZEOF(_A_(0))

'* \brief Declaration for C runtime function memcpy().
DECLARE FUNCTION memcpy CDECL ALIAS "memcpy"(BYVAL AS ANY PTR, BYVAL AS ANY PTR, BYVAL AS ULONG /'size_t'/) AS ANY PTR

' private functions from pruio_prussdrv.bas
DECLARE FUNCTION setPin_save CDECL( _
    BYVAL AS Pruio_ PTR _
  , BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR
DECLARE FUNCTION setPin_lkm_bb CDECL( _
    BYVAL AS Pruio_ PTR _
  , BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR
DECLARE FUNCTION setPin_lkm CDECL( _
    BYVAL AS Pruio_ PTR _
  , BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR
DECLARE FUNCTION setPin_dtbo CDECL( _
    BYVAL AS Pruio_ PTR _
  , BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR
DECLARE FUNCTION setPin_nogo CDECL( _
    BYVAL AS Pruio_ PTR _
  , BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR

/'* \brief Constructor, initialize subsystems, create default configuration.
\param Act Mask to specify active subsystems (defaults to all active).
\param Av Avaraging for default steps (0 to 16, defaults to 0).
\param OpD Open delay for default steps (0 to 0x3FFFF, defaults to 0x98)
\param SaD Sample delay for default steps (0 to 255, defaults to 0).

The constructor tries to

- open the PRUSS interrupt (/dev/uio5),
- load the pasm_init.p instructions to the PRU and executes them, and
- call the initialize functions of the subsystem UDTs.

It reports a failure by setting the member variable PruIo::Errr to an
appropriate text (the destructor PruIo::~PruIo() should be called in that
case).

Otherwise (PruIo::Errr = 0) the constructor tries to enable the
subsystems and read their configurations. This gets done for the active
subsystems only. Use bitmask parameter `Act` to specify active systems
and the PRU number to run the software. For convenience, use
enumerators defined in ActivateDevice:

| Bit | Function                         | Enum default     |
| --: | :------------------------------- | :--------------- |
|   0 | 0 = PRU-0, 1 = PRU-1             | PRUIO_ACT_PRU1   |
|   1 | ADC: 0 = inactiv, 1 = active     | PRUIO_ACT_ADC    |
|   2 | GPIO-0: 0 = inactiv, 1 = active  | PRUIO_ACT_GPIO0  |
|   3 | GPIO-1: 0 = inactiv, 1 = active  | PRUIO_ACT_GPIO1  |
|   4 | GPIO-2: 0 = inactiv, 1 = active  | PRUIO_ACT_GPIO2  |
|   5 | GPIO-3: 0 = inactiv, 1 = active  | PRUIO_ACT_GPIO3  |
|   6 | PWMSS-0: 0 = inactiv, 1 = active | PRUIO_ACT_PWM0   |
|   7 | PWMSS-1: 0 = inactiv, 1 = active | PRUIO_ACT_PWM1   |
|   8 | PWMSS-2: 0 = inactiv, 1 = active | PRUIO_ACT_PWM2   |
|   9 | TIMER-4: 0 = inactiv, 1 = active | PRUIO_ACT_TIM4   |
|  10 | TIMER-5: 0 = inactiv, 1 = active | PRUIO_ACT_TIM5   |
|  11 | TIMER-6: 0 = inactiv, 1 = active | PRUIO_ACT_TIM6   |
|  12 | TIMER-7: 0 = inactiv, 1 = active | PRUIO_ACT_TIM7   |
|  15 | free pinmuxing active            | PRUIO_ACT_FREMUX |

By default all subsystems are activated (a subsystem has to be active
before it can get disabled), and free pinmuxing is disabled.

The first bit desides which PRU to use. By default PRU-1 is used, so
that PRU-0 is free for other software.

\note libpruio always uses ARM_PRU1_INTERRUPT on channel PRU_EVTOUT_5
      to trigger a measurement in RB or MM mode, even if it's running
      on PRU-0. So when you execute further software on the other PRU,
      you should use ARM_PRU0_INTERRUPT on any other channel (ie.
      PRU_EVTOUT_0) to notify this code, and test for R31.t30.

The other parameters `Av`, `OpD` and `SaD` are used to create a default
step configuration for analog input. They get passed to function
AdcUdt::initialize() to generate default step configuration data for
all analog lines (AIN-0 to AIN-7) in the steps 1 to 8. For these steps,
the default values can get customized using the (optional) parameter
list:

- parameter `Av` sets avaraging in a certain number of steps. Options
  are 1, 2, 4, 8 or 16. (A non-matching parameter get increased either
  to the next higher or to the last option.)

- parameter `OpD` sets the open delay, which is the number of clock
  cycles the ADC waits between setting the step configuration and
  sending the start of conversion signal.

- parameter `SaD` sets the sample delay, which is the number of clock
  cycles the ADC waits before starting (the width of the start of
  conversion signal). It specifies the number of clock cycles between
  the single conversion processes.

See \ArmRef{12} for details on step configuration.

These step configurations can get customized or extended later on by
calling function AdcUdt::setStep().

Wrapper function (C or Python): pruio_new().

\since 0.0
'/
CONSTRUCTOR PruIo( _
    BYVAL Act AS UInt16 = PRUIO_DEF_ACTIVE _
  , BYVAL  Av AS UInt8  = PRUIO_DEF_AVRAGE _
  , BYVAL OpD AS UInt32 = PRUIO_DEF_ODELAY _
  , BYVAL SaD AS UInt8  = PRUIO_DEF_SDELAY)
  VAR fnr = FREEFILE '                             test interrupt access
  IF OPEN("/dev/uio5" FOR OUTPUT AS fnr) THEN _
                      Errr = @"cannot open /dev/uio5" : EXIT CONSTRUCTOR
  CLOSE #fnr

  STATIC AS STRING mux, bbb '   check for BB type and pinmuxing features
  IF 0 = OPEN("/proc/device-tree/model" FOR INPUT AS fnr) THEN
    LINE INPUT #fnr, bbb
    'IF bbb = "TI_AM335x_PocketBeagle" THEN BbType = 1
    'IF bbb = "TI AM335x BeagleBone Blue" THEN BbType = 2
    IF INSTR(bbb, "Pocket") THEN BbType = 1
    IF INSTR(bbb, "Blue") THEN BbType = 2
    CLOSE #fnr
  END IF

  IF 0 = OPEN("/sys/devices/platform/libpruio/state" FOR OUTPUT AS fnr) THEN
    IF Act AND PRUIO_ACT_FREMUX THEN
      setPin = IIF(BbType, @setPin_lkm(), @setPin_lkm_bb())
    ELSE
      setPin = @setPin_save()
      Errr = setPin(@THIS, 255, 0)
      IF Errr THEN CLOSE #fnr : setPin = @setPin_nogo() : fnr = 0
    END IF : MuxFnr = fnr
  END IF
  IF 0 = MuxFnr THEN '       no LKM, test old style device tree overlays
    VAR p = "/sys/devices/" _
      , n = DIR(p & "ocp.*", fbDirectory)
    IF LEN(n) THEN ' old kernel 3.x
      mux = p & n & "/" & PMUX_NAME : MuxFnr = 256
    ELSE ' new kernel 4.x
      p &= "platform/ocp/ocp:"
      IF LEN(DIR(p & "pruio-*", fbDirectory)) THEN mux = p & PMUX_NAME : MuxFnr = 257
    END IF
    IF MuxFnr THEN setPin = @setPin_dtbo() : MuxAcc = SADD(mux) : Errr = 0 _
              ELSE setPin = @setPin_nogo()
  END IF

  IF Act AND PRUIO_ACT_PRU1 THEN
    PruIntNo = ARM_PRU1_INTERRUPT
     PruIRam = PRUSS0_PRU1_IRAM
     PruDRam = PRUSS0_PRU1_DRAM
       PruNo = PRU1
  ELSE
    PruIntNo = ARM_PRU1_INTERRUPT
     PruIRam = PRUSS0_PRU0_IRAM
     PruDRam = PRUSS0_PRU0_DRAM
       PruNo = PRU0
  END IF
  IF prussdrv_open(PRUIO_EVNT) THEN _  '              open PRU Interrupt
            Errr = @"failed opening prussdrv library" : EXIT CONSTRUCTOR

  prussdrv_map_prumem(PruDRam, CAST(ANY PTR, @DRam))
  prussdrv_map_extmem(@ERam)
  ESize = prussdrv_extmem_sIze()
  EAddr = prussdrv_get_phys_addr(ERam)

  prussdrv_pru_disable(PruNo) '          disable PRU (if running before)
  DRam[0] = 0
  DRam[1] = PRUIO_DAT_ALL '                          start of data block
  ParOffs = 1
  DevAct = Act

' order must match the order in
'   pruio_init.p xxx_Init and in
'   pruio_run.p  xxx_Config macro calls
'& AdcUdt::AdcUdt(); GpioUdt::GpioUdt(); PwmssUdt::PwmssUdt(); TimerUdt::TimerUdt(); /*
  Adc = NEW AdcUdt(@THIS)
  Gpio = NEW GpioUdt(@THIS)

  VAR offs = ParOffs
  ParOffs += 1 : DRam[ParOffs] = &h44E10800 '           pinmux registers

  PwmSS = NEW PwmssUdt(@THIS)
  TimSS = NEW TimerUdt(@THIS)

  ASSERT(ParOffs < DRam[1] SHR 4)
  VAR l = ArrayBytes(Pru_Init)
  IF 0 >= prussdrv_pru_write_memory(PruIRam, 0, @Pru_Init(0), l) THEN _
       Errr = @"failed loading Pru_Init instructions" : EXIT CONSTRUCTOR
  prussdrv_pruintc_init(@IntcInit) '          get interrupts initialized
  prussdrv_pru_enable(PruNo)

  Pwm = NEW PwmMod(@THIS)
  Cap = NEW CapMod(@THIS)
  Qep = NEW QepMod(@THIS)
'& */ PwmMod::PwmMod(); CapMod::CapMod(); QepMod::QepMod();
  Tim = TimSS ' redundant, but consistent API for the user

  prussdrv_pru_wait_event(PRUIO_EVNT)
  IF DRam[0] <> PRUIO_MSG_INIT_OK THEN _
     Errr = @"failed executing Pru_Init instructions" : EXIT CONSTRUCTOR

  DSize = DRam[ParOffs] - DRam[1]
  DInit = ALLOCATE(DSize * 2)
  IF 0 = DInit THEN           Errr = @"out of memory" : EXIT CONSTRUCTOR

  MOffs = DInit - DRam[1]
  DConf = DInit + DSize
  VAR p0 = CAST(ANY PTR, DRam) + DRam[1]
  memcpy(DInit, p0, DSize)
  memcpy(DConf, p0, DSize)

  Init = MOffs + DRam[offs]
  Conf = CAST(ANY PTR, Init) + DSize
  BallInit = CAST(ANY PTR, Init) + OFFSETOF(BallSet, Value(0))
  BallConf = BallInit + DSize ' initialize invalid:
  FOR b AS INTEGER = 0 TO PRUIO_AZ_BALL : BallConf[b] OR= &b11000 : NEXT

  IF Adc->initialize(Av, OpD, SaD) THEN                 EXIT CONSTRUCTOR
  IF Gpio->initialize() THEN                            EXIT CONSTRUCTOR
  IF PwmSS->initialize() THEN                           EXIT CONSTRUCTOR
  IF TimSS->initialize() THEN                           EXIT CONSTRUCTOR
  '& AdcUdt::initialize(); GpioUdt::initialize(); PwmssUdt::initialize(); TimerUdt::initialize();
END CONSTRUCTOR


/'* \brief Destructor to restore configurations and clear memory.

The destructor copies the original configuration to DRam (if any),
loads new instructions to the PRU and start them. This PRU code
restores the subsystems GPIOs, Control Module and ADC to their original
configurations. Finaly the PRU gets powered off and the memory of the
PruIo instance get freed.

The destructor cannot report error messages in member variable
PruIo::Errr. Messages (if any) get sent directly to the ERROUT pipe of
the operating system instead.

Wrapper function (C or Python): pruio_destroy().

\since 0.0
'/
DESTRUCTOR PruIo()
  VAR mux = "" : Errr = 0
  IF DRam THEN
    IF DInit THEN
      IF MuxFnr THEN '                                  pinmuxing active
        IF BallInit <> BallConf THEN '                   reset pinmuxing
          FOR i AS INTEGER = 0 TO PRUIO_AZ_BALL
            IF (BallConf[i] AND &b11000) = &b11000 THEN CONTINUE FOR ' untouched
            IF (BallConf[i] XOR BallInit[i]) AND &b1111111 THEN _ '    re-mux
              IF setPin(@THIS, i, BallInit[i]) THEN mux &= _ '         error
                  !"\nre-mux " _
                & BIN(BallConf[i], 7) & " -> " & BIN(BallInit[i], 7) _
                & " failed (" & *Errr & ")"
          NEXT
        END IF : Errr = 0
        IF MuxFnr < 256 THEN CLOSE #MuxFnr '               close MuxFile
      END IF
      prussdrv_pru_disable(PruNo)

      DRam[2] = 0
      DRam[1] = PRUIO_DAT_ALL '           reset subsystems configuration
      memcpy(CAST(ANY PTR, DRam) + DRam[1], DInit, DSize)
      DEALLOCATE(DInit)

      VAR l = ArrayBytes(Pru_Run)
      IF 0 >= prussdrv_pru_write_memory(PruIRam, 0, @Pru_Run(0), l) THEN
                          Errr = @"failed loading Pru_Exit instructions"
      ELSE
        prussdrv_pruintc_init(@IntcInit) '     get interrupt initialized
        prussdrv_pru_enable(PruNo)
        prussdrv_pru_wait_event(PRUIO_EVNT)
        IF DRam[0] <> PRUIO_MSG_CONF_OK THEN _
                        Errr = @"failed executing Pru_Exit instructions"
      END IF
    ELSE
               Errr = @"destructor warning: subsystems are NOT restored"
    END IF
    prussdrv_pru_disable(PruNo)
    prussdrv_exit() '                                     power down PRU
  ELSE
                        Errr = @"destructor warning: constructor failed"
  END IF

  IF Errr THEN mux &= !"\n" & *Errr
  IF LEN(mux) THEN _
    VAR fnr = FREEFILE : OPEN ERR AS fnr : PRINT #fnr, MID(mux, 2) : CLOSE #fnr
END DESTRUCTOR


/'* \brief Load configuration from host (ARM) to driver (PRU).
\param Samp Number of samples to fetch (defaults to 1).
\param Mask Mask for active ADC steps (defaults to all 8 channels active in steps 1 to 8).
\param Tmr Timer value in [ns] to specify the sampling rate (defaults to zero, MM and RB mode only).
\param Mds Modus for output (defaults to 4 = 16 bit).
\returns Zero on success (otherwise a string with an error message).

This function is used to download the configuration from the host (ARM)
to the driver (PRU). The PRU gets stopped (if running) and the new
configurations get loaded. Also the Pru_Run instructions get
re-initialized.

In case of an error the PRU will be disabled after this call. Otherwise
it

- is running and waits for a call to PruIo::mm_start() or PruIo::rb_start() (in case of `Samp > 1`), or
- it starts sampling immediately and feads values to AdcUdt::Value otherwise (`Samp = 1`).
- it halts after loading the local configuration to the subsystem registers (`Samp = 0`).

The `Samp` parameter specifies the run mode (IO, RB or MM) and the
number of samples to convert for each step. In IO mode (`Samp = 1`,
default) sampling starts immediately and the index in the array
AdcUdt::Value[] is equal to the step number. Inactive steps return 0
(zero) in this case.

| field     | result of   | defaults to   |
| --------: | :---------: | :------------ |
| Value[0]  | charge step | allways zero  |
| Value[1]  | step 1      | AIN-0         |
| Value[2]  | step 2      | AIN-1         |
| ...       | ...         | ...           |
| Value[8]  | step 8      | AIN-7         |
| Value[9]  | step 9      | undefined     |
| ...       | ...         | ...           |
| Value[16] | step 16     | undefined     |

In MM (`Samp` > 1) the array AdcUdt::Value[] contains no zero values.
Instead only values from active steps get collected. The charge step
(step 0) returns no value. So when 3 steps are active in the Mask and
`Samp` is set to 5, a total of 3 times 5 = 15 values get available in the
array AdcUdt::Value[] (after the call to function PruIo::mm_start() ).
The array contains the active steps, so when ie. steps 3, 6 and 7 are
active in the Mask, the array contains:

| field    | Mask = &b110010000 |
| -------: | :----------------- |
| Value[0] | 1. sample AIN-3    |
| Value[1] | 1. sample AIN-6    |
| Value[2] | 1. sample AIN-7    |
| Value[3] | 2. sample AIN-3    |
| Value[4] | 2. sample AIN-6    |
| Value[5] | 2. sample AIN-7    |
| Value[6] | 3. sample AIN-3    |
| Value[7] | 3. sample AIN-6    |
| Value[8] | ...                |

Currently the number of samples is limited by the external memory
allocated by the kernel PRUSS driver. This is 256 kByte by default (=
128 kSamples, see next table). Find informations on how to extend this
memory block in section \ref SecERam.

| number of active Steps | max. Samples |
| ---------------------: | :----------- |
|                      1 | 131072       |
|                      2 | 65536        |
|                      3 | 43690        |
|                      4 | 32768        |
|                      5 | 26214        |
|                      6 | 21845        |
|                      7 | 18724        |
|                      8 | 16384        |
|                    ... |   ...        |

The `Mask` parameter specifies the active steps. Setting a bit in the
Mask activates a step defined by the step configuration (by default
bits 1 = AIN-0, 2 = AIN-1, ... up to 8 = AIN-7 are set, use function
AdcUdt::setStep() to customize steps).

\note Bit 0 controls the charge step (see \ArmRef{12}, ADC STEPENABLE
      register).

The highest bit 31 has a special meaning for customizing the idle step.
By default the idle configuration is set like the configuration of the
first active step, so that (in MM) the open delay can get
reduced to a minimum for that step (if there's enough time left before
restarting the ADC). By setting bit 31 the configuration from
AdcUdt::Conf->St_p`[0]` is used instead.

The `Tmr` parameter specifies the sampling rate. It's the number of
nano seconds between the starts of the ADC sampling process. The IEP
timer gets used. It is configured to increase by steps of 5 (it counts
in GHz, but runs at 200 MHz), so values like 22676 or 22679 results to
the same frequency. Some examples

| Tmr [ns] | Sampling rate [Hz] |
| -------: | :----------------- |
| 1e9      | 1                  |
| 1e6      | 1000               |
| 22675    | ~44100             |

\note This value has no effect in IO mode (when `Samp` = 1).

The `Mds` parameter specifies the bit encoding (range) of the samples.
By default (Mds = 4) the samples from the ADC (12 bit) get left shifted
by 4, so that they actually are 16 bit values and can get compared with
samples from other ADC devices (like 16 bit audio data). Examples

| Mds   | samples |
| ----: | :------ |
| 0     | 12 bit  |
| 1     | 13 bit  |
| 2     | 14 bit  |
| 3     | 15 bit  |
| >= 4  | 16 bit  |

Wrapper function (C or Python): pruio_config().

\since 0.0
'/
FUNCTION PruIo.config CDECL( _
    BYVAL Samp AS UInt32 = PRUIO_DEF_SAMPLS _
  , BYVAL Mask AS UInt32 = PRUIO_DEF_STPMSK _
  , BYVAL  Tmr AS UInt32 = PRUIO_DEF_TIMERV _
  , BYVAL  Mds AS UInt16 = PRUIO_DEF_LSLMOD) AS ZSTRING PTR

  prussdrv_pru_disable(PruNo) '                              disable PRU
  IF Adc->configure(Samp, Mask, Tmr, Mds)                    THEN RETURN Errr

  DRam[1] = PRUIO_DAT_ALL
  memcpy(CAST(ANY PTR, DRam) + DRam[1], DConf, DSize)

  VAR l = ArrayBytes(Pru_Run)
  IF 0 >= prussdrv_pru_write_memory(PruIRam, 0, @Pru_Run(0), l) THEN _
                  Errr = @"failed loading Pru_Run instructions" : RETURN Errr
  prussdrv_pruintc_init(@IntcInit) '           get interrupt initialized
  prussdrv_pru_enable(PruNo)
  prussdrv_pru_wait_event(PRUIO_EVNT)
  SELECT CASE AS CONST Samp
  CASE 0    : l = DRam[0] <> PRUIO_MSG_CONF_OK
  CASE 1    : l = DRam[0] <> PRUIO_MSG_IO_OK
  CASE ELSE : l = DRam[0] <> PRUIO_MSG_MM_WAIT
  END SELECT
  IF l THEN     Errr = @"failed executing Pru_Run instructions" : RETURN Errr
  IF Samp < 2                                                THEN RETURN 0

  prussdrv_pru_clear_event(PRUIO_EVNT, PRUIO_IRPT)
  prussdrv_pru_send_event(PruIntNo) '              prepare fast MM start
                                                                  RETURN 0
END FUNCTION


/'* \brief Create a text description for a CPU ball configuration.
\param Ball The CPU ball number to describe.
\param Mo The configuration to read (0 = Init, else Conf = default).
\returns A human-readable text string (internal string, never free it).

This function is used to create a text description for the current
state of a CPU ball (named pin when connected to one of the Beaglebone
headers P8 or P9).

The description contains the pin name and its mode. Header pin names
start with a capital 'P', CPU ball names start with a lower case 'b'.
The detailed pinmux setting is only described for pins in mode 7 (GPIO
mode). Otherwise only the mode number gets shown.

\note The returned string pointer points to an internal string buffer.
      Never free it. The string gets overwritten on further calls to
      this function, so make local copies if you need several
      descriptions at a time. The string may contain an error message
      if the ball number is too big.

\since 0.2
'/
FUNCTION PruIo.Pin CDECL( _
  BYVAL Ball AS UInt8, _
  BYVAL Mo AS UInt8 = 1) AS ZSTRING PTR
  STATIC AS STRING*50 t

  VAR x = nameBall(Ball)
  IF x THEN
    t = *x
  ELSE
    IF Ball > PRUIO_AZ_BALL THEN   Errr = @"unknown pin number" : RETURN Errr
    t = "b " & RIGHT("00" & Ball, 3)
  END IF

  VAR r = IIF(Mo, BallConf[Ball], BallInit[Ball]) _
    , m = r AND &b111
  IF m = 7 THEN
    VAR i = BallGpio(Ball) SHR 5 _
      , n = BallGpio(Ball) AND 31 _
      , m = 1 SHL n
    t &= ", GPIO " & i & "/" & RIGHT("0" & n, 2)
    IF BIT(r, 5) THEN
      t &= ": input"
    ELSE
      WITH *IIF(Mo, Gpio->Conf(i), Gpio->Init(i))
        t &= ": output-" & *IIF((.DATAOUT OR .SETDATAOUT) AND m, @"1", @"0")
      END WITH
    END IF
  ELSE
    t &= ", mode " & m _
      & ": input " & *IIF(BIT(r, 5), @"enabled", @"disabled")
  END IF

  IF BIT(r, 3) THEN
    t &= ", nopull"
  ELSE
    IF BIT(r, 4) THEN t &= ", pullup" ELSE t &= ", pulldown"
  END IF                                                        : RETURN SADD(t)
END FUNCTION


/'* \brief Get header pin connected to CPU ball.
\param Ball The CPU ball number.
\returns A string pointer (don't free it) on success (otherwise zero).

This function creates a text description of the header pin connected to
a CPU ball. The returned string is owned by this function and must not
be freed.

When the CPU ball is not connected to a header pin, this function
returns 0 (zero).

\since 0.2
'/
FUNCTION PruIo.nameBall CDECL(BYVAL Ball AS UInt8) AS ZSTRING PTR
  SELECT CASE AS CONST Ball '                                  find name
  CASE P8_03 : RETURN @"P8_03"
  CASE P8_04 : RETURN @"P8_04"
  CASE P8_05 : RETURN @"P8_05"
  CASE P8_06 : RETURN @"P8_06"
  CASE P8_07 : RETURN @"P8_07"
  CASE P8_08 : RETURN @"P8_08"
  CASE P8_09 : RETURN @"P8_09"
  CASE P8_10 : RETURN @"P8_10"
  CASE P8_11 : RETURN @"P8_11"
  CASE P8_12 : RETURN @"P8_12"
  CASE P8_13 : RETURN @"P8_13"
  CASE P8_14 : RETURN @"P8_14"
  CASE P8_15 : RETURN @"P8_15"
  CASE P8_16 : RETURN @"P8_16"
  CASE P8_17 : RETURN @"P8_17"
  CASE P8_18 : RETURN @"P8_18"
  CASE P8_19 : RETURN @"P8_19"
  CASE P8_20 : RETURN @"P8_20"
  CASE P8_21 : RETURN @"P8_21"
  CASE P8_22 : RETURN @"P8_22"
  CASE P8_23 : RETURN @"P8_23"
  CASE P8_24 : RETURN @"P8_24"
  CASE P8_25 : RETURN @"P8_25"
  CASE P8_26 : RETURN @"P8_26"
  CASE P8_27 : RETURN @"P8_27"
  CASE P8_28 : RETURN @"P8_28"
  CASE P8_29 : RETURN @"P8_29"
  CASE P8_30 : RETURN @"P8_30"
  CASE P8_31 : RETURN @"P8_31"
  CASE P8_32 : RETURN @"P8_32"
  CASE P8_33 : RETURN @"P8_33"
  CASE P8_34 : RETURN @"P8_34"
  CASE P8_35 : RETURN @"P8_35"
  CASE P8_36 : RETURN @"P8_36"
  CASE P8_37 : RETURN @"P8_37"
  CASE P8_38 : RETURN @"P8_38"
  CASE P8_39 : RETURN @"P8_39"
  CASE P8_40 : RETURN @"P8_40"
  CASE P8_41 : RETURN @"P8_41"
  CASE P8_42 : RETURN @"P8_42"
  CASE P8_43 : RETURN @"P8_43"
  CASE P8_44 : RETURN @"P8_44"
  CASE P8_45 : RETURN @"P8_45"
  CASE P8_46 : RETURN @"P8_46"
  CASE P9_11 : RETURN @"P9_11"
  CASE P9_12 : RETURN @"P9_12"
  CASE P9_13 : RETURN @"P9_13"
  CASE P9_14 : RETURN @"P9_14"
  CASE P9_15 : RETURN @"P9_15"
  CASE P9_16 : RETURN @"P9_16"
  CASE P9_17 : RETURN @"P9_17"
  CASE P9_18 : RETURN @"P9_18"
  CASE P9_19 : RETURN @"P9_19"
  CASE P9_20 : RETURN @"P9_20"
  CASE P9_21 : RETURN @"P9_21"
  CASE P9_22 : RETURN @"P9_22"
  CASE P9_23 : RETURN @"P9_23"
  CASE P9_24 : RETURN @"P9_24"
  CASE P9_25 : RETURN @"P9_25"
  CASE P9_26 : RETURN @"P9_26"
  CASE P9_27 : RETURN @"P9_27"
  CASE P9_28 : RETURN @"P9_28"
  CASE P9_29 : RETURN @"P9_29"
  CASE P9_30 : RETURN @"P9_30"
  CASE P9_31 : RETURN @"P9_31"
  CASE P9_41 : RETURN @"P9_41"
  CASE  106  : RETURN @"P9_41"
  CASE P9_42 : RETURN @"P9_42"
  CASE  104  : RETURN @"P9_42"
  CASE JT_04 : RETURN @"JT_04"
  CASE JT_05 : RETURN @"JT_05"
  CASE SD_01 : RETURN @"SD_01"
  CASE SD_02 : RETURN @"SD_02"
  CASE SD_03 : RETURN @"SD_03"
  CASE SD_05 : RETURN @"SD_05"
  CASE SD_07 : RETURN @"SD_07"
  CASE SD_08 : RETURN @"SD_08"
  CASE SD_10 : RETURN @"SD_10"
  END SELECT : RETURN 0
END FUNCTION


/'* \brief Start ring buffer mode.
\returns Zero on success (otherwise a string with an error message).

Start endless measuremnt in ring buffer mode. The active steps defined
in the last call to function PruIo::config() get sampled at the
specified sampling rate. The fetched values are stored in a ring buffer
and the index of the currently stored value gets reported in DRam[0].

Inactive steps get no entry in the ring buffer, it only contains values
from the active steps (as in MM mode). Use AdcUdt::Value[index] to
read the samples.

RB mode runs endless. Stop it by up-loading a new configuration (by
calling function PruIo::config() ).

Wrapper function (C or Python): pruio_rb_start().

\since 0.2
'/
FUNCTION PruIo.rb_start CDECL() AS ZSTRING PTR
  IF DRam[0] <> PRUIO_MSG_MM_WAIT THEN _
                      Errr = @"ring buffer mode not ready" : RETURN Errr

  DRam[1] = Adc->Samples SHL 1 ' size of ring buffer
  DRam[2] = EAddr
  DRam[3] = 0
  DRam[4] = 1 SHL 4

  prussdrv_pru_clear_event(PRUIO_EVNT, PruIntNo) '             off we go
  RETURN 0
END FUNCTION


/'* \brief Start a measurement in MM.
\param Trg1 Specification for first trigger (default = no trigger).
\param Trg2 Specification for second trigger (default = no trigger).
\param Trg3 Specification for third trigger (default = no trigger).
\param Trg4 Specification for fourth trigger (default = no trigger).
\returns Zero on success (otherwise a string with an error message).

This function starts a measurement in MM mode. The ADC configuration
from the previous call to function PruIo::config() are used. The
measurement either starts immediately or the start gets controlled by
one (or up to four) trigger event(s).

Function are available to create trigger specifications:

- AdcUdt::mm_trg_pin() for digital lines
- AdcUdt::mm_trg_ain() for analog lines
- AdcUdt::mm_trg_pre() for pre-triggers on analog lines

\note The created analog trigger specifications may get invalid by
      changing the ADC settings in a further call to function
      PruIo::config() with different parameters (ie. when the trigger
      step gets cleared). To be on the save side, re-create your
      trigger specifications after each call to function
      PruIo::config().

MM mode runs endless. Stop it by up-loading a new configuration (by
calling function PruIo::config() ).

Wrapper function (C or Python): pruio_mm_start().

\since 0.2
'/
FUNCTION PruIo.mm_start CDECL( _
    BYVAL Trg1 AS UInt32 = 0 _
  , BYVAL Trg2 AS UInt32 = 0 _
  , BYVAL Trg3 AS UInt32 = 0 _
  , BYVAL Trg4 AS UInt32 = 0) AS ZSTRING PTR

    IF DRam[0] <> PRUIO_MSG_MM_WAIT THEN _
                           Errr = @"measurement mode not ready" : RETURN Errr

    STATIC AS UInt32 tmin = (1 SHL 22), t_pin
    DRam[3] = 0

#DEFINE PRUIO_PRE_TRIG(_T_) Trg##_T_ >= tmin ANDALSO (Trg##_T_ AND (1 SHL 4)) THEN : _
  IF BIT(Trg##_T_, 5) ORELSE BIT(Adc->Conf->STEPENABLE, (Trg##_T_ AND &b1111) + 1) THEN : _
    VAR n = (Trg##_T_ SHR 22) * Adc->ChAz : _
    IF n < Adc->Samples THEN : DRam[3] = n SHL 1 : _
    ELSE :  Errr = @"Trg" #_T_ ": too much pre-trigger samples" : RETURN Errr : _
    END IF : _
  ELSE : Errr = @"Trg" #_T_ ": pre-trigger step must be active" : RETURN Errr : _
  END IF

#DEFINE PRUIO_GPIO_TRIG(_T_) BIT(Trg##_T_, 21) THEN : _
    t_pin = (Trg##_T_ SHR 8) AND &b1111111 : _
    IF t_pin > PRUIO_AZ_BALL THEN _
              Errr = @"Trg" #_T_ ": unknown trigger pin number" : RETURN Errr : _
    END IF : _
    IF &b111 <> (BallConf[t_pin] AND &b111) THEN _
    Errr = @"Trg" #_T_ ": trigger pin must be in mode 7 (GPIO)" : RETURN Errr : _
    ELSE Trg##_T_ AND= &b11111111111100000000000011111111uL : _
         Trg##_T_  OR= BallGpio(t_pin) SHL 8 : _
    END IF : _
  END IF

  IF Trg1 THEN
    IF PRUIO_PRE_TRIG(1)
    ELSE
      IF PRUIO_GPIO_TRIG(1)
      IF Trg2 THEN
        IF PRUIO_PRE_TRIG(2)
        ELSE
          IF PRUIO_GPIO_TRIG(2)
          IF Trg3 THEN
            IF PRUIO_PRE_TRIG(3)
            ELSE
              IF PRUIO_GPIO_TRIG(3)
              IF Trg4 THEN
                IF PRUIO_PRE_TRIG(4)
                ELSE
                  IF PRUIO_GPIO_TRIG(4)
                END IF
              END IF
            END IF
          END IF
        END IF
      END IF
    END IF
  END IF

  DRam[1] = ESize
  DRam[2] = EAddr
  DRam[4] = Trg1
  DRam[5] = Trg2
  DRam[6] = Trg3
  DRam[7] = Trg4

  prussdrv_pru_clear_event(PRUIO_EVNT, PruIntNo) '           off we go

  prussdrv_pru_wait_event(PRUIO_EVNT) '      wait for end of measurement
  prussdrv_pru_clear_event(PRUIO_EVNT, PRUIO_IRPT) '     clear interrupt
  prussdrv_pru_send_event(PruIntNo) '                 prepare next start
  RETURN 0
END FUNCTION
