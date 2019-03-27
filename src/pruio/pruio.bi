/'* \file pruio.bi
\brief FreeBASIC header file for libpruio.

Header file for including libpruio to FreeBASIC programs. It binds the
different components together and provides all declarations.

\since 0.0
'/

#IFNDEF __PRUIO_COMPILING__
#INCLIB "pruio"
#ENDIF
' PruIo global declarations.
#INCLUDE ONCE "pruio_globals.bi"
' Header for ADC part.
#INCLUDE ONCE "pruio_adc.bi"
' Header for GPIO part.
#INCLUDE ONCE "pruio_gpio.bi"
' Header for PWMSS part, containing modules QEP, CAP and PWM.
#INCLUDE ONCE "pruio_pwmss.bi"
' Header for TIMER part.
#INCLUDE ONCE "pruio_timer.bi"
' Header for interrupt controller.
#INCLUDE ONCE "pruio_intc.bi"

'* The channel for PRU messages (must match PRUIO_IRPT).
#DEFINE PRUIO_CHAN CHANNEL5
'* The mask to enable PRU interrupts (must match PRUIO_IRPT).
#DEFINE PRUIO_MASK PRU_EVTOUT5_HOSTEN_MASK
'* The event for PRU messages (mapping, must match PRUIO_IRPT).
#DEFINE PRUIO_EMAP PRU_EVTOUT5
'* The event for PRU messages (must match PRUIO_IRPT).
#DEFINE PRUIO_EVNT PRU_EVTOUT_5

'* Macro to check a CPU ball number (0 to 109 is valid range).
#DEFINE BallCheck(_T_,_R_) IF Ball > PRUIO_AZ_BALL THEN .Errr = @"unknown" _T_ " pin number" : RETURN _R_


/'* \brief Mask for ADC step enabling.

This enumerators are for use in function PruIo::config() to enable
single steps for the ADC sampling sequence. By default steps 1 to 8 are
configured to measure AIN 0 to 7, using the values of Averaging,
OpenDelay and SampleDelay passed as parameters to the constructor
PruIo::PruIo().

Example:

    Io->config(AIN0 + AIN3 + AIN4, ...)

\note A function call to AdcUdt::setStep() for steps 1 to 8 will
      override the default configuration. Those masks get invalid when
      you change the step channel.

\since 0.6.4
'/
ENUM AdcStepMask
  AIN0 = &b000000010 '*< Activate Step 1 (default config: AIN0)
  AIN1 = &b000000100 '*< Activate Step 2 (default config: AIN1)
  AIN2 = &b000001000 '*< Activate Step 3 (default config: AIN2)
  AIN3 = &b000010000 '*< Activate Step 4 (default config: AIN3)
  AIN4 = &b000100000 '*< Activate Step 5 (default config: AIN4)
  AIN5 = &b001000000 '*< Activate Step 6 (default config: AIN5)
  AIN6 = &b010000000 '*< Activate Step 7 (default config: AIN6)
  AIN7 = &b100000000 '*< Activate Step 8 (default config: AIN7)
END ENUM


/'* \brief Mask for PRUSS number and divice enabling.

This enumerators are used in the constructor PruIo::PruIo() to enable
single subsystems. By default all subsystems are enabled. If a device
is not enabled, libpruio wont wake it up nor allocate memory to control
it. It just reads the version information to see if the subsystem is in
operation.

An enabled subsystem will get activated in the constructor
PruIo::PruIo() and libpruio will set its configuration. When done, the
destructor PruIo::~PruIo() either disables it (when previously disabled)
or resets the initial configuration.

The first enumerator PRUIO_ACT_PRU1 is used to specify the PRU
subsystem to execute libpruio. By default the bit is set and libpruio
runs on PRU-1. See PruIo::PruIo() for further information.

\since 0.2
'/
ENUM ActivateDevice
  PRUIO_ACT_PRU1   = &b0000000000001 '*< Activate PRU-1 (= default, instead of PRU-0)
  PRUIO_ACT_ADC    = &b0000000000010 '*< Activate ADC
  PRUIO_ACT_GPIO0  = &b0000000000100 '*< Activate GPIO-0
  PRUIO_ACT_GPIO1  = &b0000000001000 '*< Activate GPIO-1
  PRUIO_ACT_GPIO2  = &b0000000010000 '*< Activate GPIO-2
  PRUIO_ACT_GPIO3  = &b0000000100000 '*< Activate GPIO-3
  PRUIO_ACT_PWM0   = &b0000001000000 '*< Activate PWMSS-0 (including eCAP, eQEP, ePWM)
  PRUIO_ACT_PWM1   = &b0000010000000 '*< Activate PWMSS-1 (including eCAP, eQEP, ePWM)
  PRUIO_ACT_PWM2   = &b0000100000000 '*< Activate PWMSS-2 (including eCAP, eQEP, ePWM)
  PRUIO_ACT_TIM4   = &b0001000000000 '*< Activate TIMER-4
  PRUIO_ACT_TIM5   = &b0010000000000 '*< Activate TIMER-5
  PRUIO_ACT_TIM6   = &b0100000000000 '*< Activate TIMER-6
  PRUIO_ACT_TIM7   = &b1000000000000 '*< Activate TIMER-7
  PRUIO_DEF_ACTIVE = &b1111111111111 '*< Activate all subsystems
  PRUIO_ACT_FREMUX = &b1000000000000000 '*< Activate free LKM muxing, no kernel claims
END ENUM


/'* \brief Structure for Control Module, containing pad configurations.

This UDT contains a set of all pad control registers. This is the
muxing between CPU balls and the internal subsystem targets, the pullup
or pulldown configuration and the receiver activation.

\since 0.2
'/
TYPE BallSet
  AS UInt32 DeAd                 '*< Base address of Control Module subsystem.
  AS UInt8  Value(PRUIO_AZ_BALL) '*< The values of the pad control registers.
END TYPE


'* \brief Alias for pinmuxing signature
TYPE setPinFunc AS FUNCTION CDECL( _
    BYVAL Top AS Pruio_ PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Mo AS UInt8) AS ZSTRING PTR


/'* \brief Main structure, binding all components together.

This UDT glues all together. It downloads and start software on the
PRUSS, controls the initialisation and configuration processes and
reads or writes the pinmux configurations.

\since 0.0
'/
TYPE PruIo
  AS ZSTRING PTR _
    Errr = 0    '*< Pointer for error messages, see chapter \ref ChaMessages.

  AS AdcUdt PTR Adc     '*< Pointer to ::AdcUdt class.
  AS GpioUdt PTR Gpio   '*< Pointer to ::GpioUdt class.
  AS PwmssUdt PTR PwmSS '*< Pointer to ::PwmssUdt class.
  AS TimerUdt PTR TimSS '*< Pointer to ::TimerUdt class.
  AS PwmMod PTR Pwm     '*< Pointer to ::PwmMod class for PWM features (in PWMSS subsystems).
  AS CapMod PTR Cap     '*< Pointer to ::CapMod class for CAP features (in PWMSS subsystems).
  AS QepMod PTR Qep     '*< Pointer to ::QepMod class for QEP features (in PWMSS subsystems).
  AS TimerUdt PTR Tim   '*< Pointer to ::TimerUdt class for TIMER features (for homogenous API).

  AS  UInt32 PTR DRam '*< Pointer to access PRU DRam, see chapter \ref ChaMemory.
  AS BallSet PTR _
    Init _      '*< The subsystems register data at start-up (to restore when finished).
  , Conf        '*< The subsystems register data used by libpruio (current local data to be uploaded by PruIo::Config() ).
  AS ANY PTR _
    ERam _      '*< Pointer to read PRU external ram, see chapter \ref ChaMemory.
  , DInit _     '*< Pointer to block of subsystems initial data.
  , DConf _     '*< Pointer to block of subsystems configuration data.
  , MOffs       '*< Configuration offset for modules.
  AS UInt8 PTR _
    BallInit _  '*< Pointer for original Ball configuration.
  , BallConf    '*< Pointer to ball configuration (CPU pin muxing).
  AS UInt32 _
    EAddr     _ '*< The address of the external memory (PRUSS-DDR).
  , ESize     _ '*< The size of the external memory (PRUSS-DDR).
  , DSize     _ '*< The size of a data block (DInit or DConf).
  , PruNo     _ '*< The PRU number to use (defaults to 1).
  , PruIRam   _ '*< The PRU instruction ram to load.
  , PruDRam   _ '*< The PRU data ram.
  , PruIntNo    '*< The PRU interrupt number.
  AS Int16 _
    ParOffs _   '*< The offset for the parameters of a module.
  , DevAct      '*< Active subsystems.

  AS UInt32 _
    BbType _ '*< Type of Beaglebone board (2 = Blue, 1 = Pocket, 0 = others)
  , MuxFnr   '*< Pinmuxing file number, if any
  AS ZSTRING PTR MuxAcc '*< Pinmuxing ocp path, if no LKM

  /'* \brief Interface for pinmuxing function (internal).
  \param Top The toplevel PruIo instance.
  \param Ball The CPU ball number (use macros from pruio_pins.bi).
  \param Mo The new modus to set.
  \returns Zero on success (otherwise a string with an error message).

  This is an internal function. It tries to set a new mode for a header
  pin (or CPU ball number) configuration. Each digital header pin is
  connected to a CPU ball. The CPU ball can get muxed to

  - several internal features (like GPIO, CAP, PWM, ...),
  - internal pullup or pulldown resistors, as well as
  - an internal receiver module for input pins.

  The function changes pinmuxing, and will fail if (depending on system
  setup):

  - the libpruio loadable kernel module isn't loaded, or
  - the libpruio device tree overlays isn't loaded, or
  - the required pin isn't defined in that overlay (ie HDMI), or
  - the user has no write access to the state configuration files (see
    section \ref SecPinmuxing for details), or
  - the required mode isn't available in the overlay.

  The function returns an error message in case of a failure, otherwise
  0 (zero). The callback function gets connected in the constructor
  PruIo::PruIo(), depending on the system setup and current write
  privileges. The prefered method is the LKM method, which is used when
  the SysFs entry from the LKM is present, and \Proj has write access
  (needs administrator privileges = `sudo ...` or membership in user
  group 'pruio'). Otherwise the old-style device tree pinmuxing gets
  used, if present.

  In case of LKM pinmuxing there're no restriction. Each CPU ball in
  the range zero to PRUIO_AZ_BALL can get set to any mode. Even claimed
  pins or CPU balls can get set to defined or undefined modes. The
  function executes faster than device tree pinmuxing (no `OPEN ...
  CLOSE`), boot-time is shorter (no overlay loading) and less memory is
  used.

  \note Don't use this function to set a pin for a libpruio feature.
        Instead, call for input pins the feature config function (ie.
        GpioUdt::config() or CapMod::config() ), and for output pins
        just set the desired value (ie. PwmMod::setValue()). But you
        can use the function to set pins in modes that are not
        supported by libpruio (ie. like SPI or UART). In this case you
        have to care about loading the matching driver by yourself.

  \note In case of digital double pins (like P9_41 or P9_42 on
        BeagleBone) this function sets the muxmodes of boths pins.
        First the unused pin gets configured to Gpio input mode without
        resistor. Then the related pin gets configured as specified.

  \since 0.6
  '/ '& FUNCTION_CDECL_AS_ZSTRING_PTR (setPin) (BYVAL_AS_Pruio__PTR Top, BYVAL_AS_UInt8 Ball, BYVAL_AS_UInt8 Mo); /*
  setPin AS setPinFunc '& */

  '* list of GPIO numbers, corresponding to ball index
  AS UInt8 BallGpio(PRUIO_AZ_BALL) = { _
     32,  33,  34,  35,  36,   37,  38,  39,  22,  23 _
  ,  26,  27,  44,  45,  46,   47,  48,  49,  50,  51 _ ' 10
  ,  52,  53,  54,  55,  56,   57,  58,  59,  30,  31 _
  ,  60,  61,  62,  63,  64,   65,  66,  67,  68,  69 _ ' 30
  ,  70,  71,  72,  73,  74,   75,  76,  77,  78,  79 _
  ,  80,  81,   8,   9,  10,   11,  86,  87,  88,  89 _ ' 50
  ,  90,  91,  92,  93,  94,   95,  96,  97,  98,  99 _
  , 100,  16,  17,  21,  28,  105, 106,  82,  83,  84 _ ' 70
  ,  85,  29,   0,   1,   2,    3,   4,   5,   6,   7 _
  ,  40,  41,  42,  43,  12,   13,  14,  15, 101, 102 _ ' 90
  , 110, 111, 112, 113, 114,  115, 116, 117,  19,  20}

  '* interrupt settings (we also set default interrupts, so that the other PRUSS can be used in parallel)
  AS tpruss_intc_initdata IntcInit = _
    TYPE<tpruss_intc_initdata>( _
      { PRU0_PRU1_INTERRUPT _
      , PRU1_PRU0_INTERRUPT _
      , PRU0_ARM_INTERRUPT _
      , PRU1_ARM_INTERRUPT _
      , ARM_PRU0_INTERRUPT _
      , ARM_PRU1_INTERRUPT _
      , PRUIO_IRPT _
      , CAST(BYTE, -1) }, _
      { TYPE<tsysevt_to_channel_map>(PRU0_PRU1_INTERRUPT, CHANNEL1) _
      , TYPE<tsysevt_to_channel_map>(PRU1_PRU0_INTERRUPT, CHANNEL0) _
      , TYPE<tsysevt_to_channel_map>(PRU0_ARM_INTERRUPT, CHANNEL2) _
      , TYPE<tsysevt_to_channel_map>(PRU1_ARM_INTERRUPT, CHANNEL3) _
      , TYPE<tsysevt_to_channel_map>(ARM_PRU0_INTERRUPT, CHANNEL0) _
      , TYPE<tsysevt_to_channel_map>(ARM_PRU1_INTERRUPT, CHANNEL1) _
      , TYPE<tsysevt_to_channel_map>(PRUIO_IRPT, PRUIO_CHAN) _
      , TYPE<tsysevt_to_channel_map>(-1, -1)}, _
      { TYPE<tchannel_to_host_map>(CHANNEL0, PRU0) _
      , TYPE<tchannel_to_host_map>(CHANNEL1, PRU1) _
      , TYPE<tchannel_to_host_map>(CHANNEL2, PRU_EVTOUT0) _
      , TYPE<tchannel_to_host_map>(CHANNEL3, PRU_EVTOUT1) _
      , TYPE<tchannel_to_host_map>(PRUIO_CHAN, PRUIO_EMAP) _
      , TYPE<tchannel_to_host_map>(-1, -1) }, _
      (PRU0_HOSTEN_MASK OR PRU1_HOSTEN_MASK OR _
       PRU_EVTOUT0_HOSTEN_MASK OR PRU_EVTOUT1_HOSTEN_MASK OR PRUIO_MASK) _
      )

  AS UInt32 WaitCycles '*< Counter: ARM waiting for PRU

  DECLARE CONSTRUCTOR( _
    BYVAL AS UInt16 = PRUIO_DEF_ACTIVE _
  , BYVAL AS UInt8  = PRUIO_DEF_AVRAGE _
  , BYVAL AS UInt32 = PRUIO_DEF_ODELAY _
  , BYVAL AS UInt8  = PRUIO_DEF_SDELAY)
  DECLARE DESTRUCTOR()
  DECLARE FUNCTION config CDECL( _
    BYVAL AS UInt32 = PRUIO_DEF_SAMPLS _
  , BYVAL AS UInt32 = PRUIO_DEF_STPMSK _
  , BYVAL AS UInt32 = PRUIO_DEF_TIMERV _
  , BYVAL AS UInt16 = PRUIO_DEF_LSLMOD) AS ZSTRING PTR
  DECLARE FUNCTION Pin CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS UInt8 = 1) AS ZSTRING PTR
  DECLARE FUNCTION nameBall CDECL( _
    BYVAL AS UInt8) AS ZSTRING PTR
  DECLARE FUNCTION rb_start CDECL() AS ZSTRING PTR
  DECLARE FUNCTION mm_start CDECL( _
    BYVAL AS UInt32 = 0 _
  , BYVAL AS UInt32 = 0 _
  , BYVAL AS UInt32 = 0 _
  , BYVAL AS UInt32 = 0) AS ZSTRING PTR
END TYPE

