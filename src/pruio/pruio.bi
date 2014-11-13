/'* \file pruio.bi
\brief FreeBASIC header file for libpruio.

Header file for including libpruio to FreeBASIC programs. It binds the
different components together and provides all declarations.

'/

#IFNDEF __PRUIO_COMPILING__
#INCLIB "pruio"
#ENDIF

'* version string
#DEFINE PRUIO_VERSION "0.2"

TYPE AS   BYTE Int8    '*< 8 bit signed integer data type
TYPE AS  SHORT Int16   '*< 16 bit signed integer data type
TYPE AS   LONG Int32   '*< 32 bit signed integer data type
TYPE AS  UBYTE UInt8   '*< 8 bit unsigned integer data type
TYPE AS USHORT UInt16  '*< 16 bit unsigned integer data type
TYPE AS  ULONG UInt32  '*< 32 bit unsigned integer data type
TYPE AS SINGLE Float_t '*< float data type

'* forward declaration
TYPE AS PruIo Pruio_

'* tell pruss_intc_mapping.bi that we use ARM33xx
#DEFINE AM33XX

' the PRUSS driver library
#INCLUDE ONCE "BBB/prussdrv.bi"
' PRUSS driver interrupt settings
#INCLUDE ONCE "BBB/pruss_intc_mapping.bi"

'* constants for pinmuxing: pullup/-down resistors and GPIO states
ENUM PinMuxing
  PRUIO_NO_PULL   = &b001000 '*< no resistor connected
  PRUIO_PULL_UP   = &b010000 '*< pullup resistor connected
  PRUIO_PULL_DOWN = &b000000 '*< pulldown resistor connected
  PRUIO_RX_ACTIV  = &b100000 '*< input receiver enabled
  PRUIO_GPIO_OUT0 = 7 + PRUIO_NO_PULL                    '*< GPIO output low (no resistor)
  PRUIO_GPIO_OUT1 = 7 + PRUIO_NO_PULL + 128              '*< GPIO output high (no resistor)
  PRUIO_GPIO_IN   = 7 + PRUIO_NO_PULL + PRUIO_RX_ACTIV   '*< GPIO input (no resistor)
  PRUIO_GPIO_IN_0 = 7 + PRUIO_PULL_DOWN + PRUIO_RX_ACTIV '*< GPIO input (pulldown resistor)
  PRUIO_GPIO_IN_1 = 7 + PRUIO_PULL_UP + PRUIO_RX_ACTIV   '*< GPIO input (pullup resistor)
  PRUIO_PIN_RESET = &hFF
END ENUM

' common macros, shared with PRU pasm compiler
#INCLUDE ONCE "pruio.hp"
' header for ADC part
#INCLUDE ONCE "pruio_adc.bi"
' header for GPIO part
#INCLUDE ONCE "pruio_gpio.bi"
' header for PWMSS part, containing modules QEP, CAP and PWM
#INCLUDE ONCE "pruio_pwmss.bi"

'* the channel for PRU messages (must match PRUIO_IRPT)
#DEFINE PRUIO_CHAN CHANNEL5
'* the mask to enable PRU interrupts (must match PRUIO_IRPT)
#DEFINE PRUIO_MASK PRU_EVTOUT5_HOSTEN_MASK
'* the event for PRU messages (mapping, must match PRUIO_IRPT)
#DEFINE PRUIO_EMAP PRU_EVTOUT5
'* the event for PRU messages (must match PRUIO_IRPT)
#DEFINE PRUIO_EVNT PRU_EVTOUT_5

'* Macro to calculate the total size of an array in bytes.
#DEFINE ArrayBytes(_A_) (UBOUND(_A_) + 1) * SIZEOF(_A_)
'* macro to check a CPU ball number (0 to 109 is valid range)
#DEFINE BallCheck(_T_,_R_) IF Ball > PRUIO_AZ_BALL THEN .Errr = @"unknown" _T_ " pin number" : RETURN _R_


/'* \brief Mask to be used in the constructor to choose PRUSS number and enable divices controls.

This enumerators are used in the constructor PruIo::PruIo() to enable
single subsystems. By default all subsystems are enabled. If a device
is not enabled, libpruio wont wake it up nor allocate memory to control
it. It just reads the version information to see if the subsystem is in
operation.

An enabled subsystem will get activated in the constructor
PruIo::PruIo() and libpruio will set its configuration.

'/
ENUM ActivateDevice
  PRUIO_ACT_PRU1   = &b000000000001 '*< activate PRU-1 (= default, instead of PRU-0)
  PRUIO_ACT_ADC    = &b000000000010 '*< activate ADC
  PRUIO_ACT_GPIO0  = &b000000000100 '*< activate GPIO-0
  PRUIO_ACT_GPIO1  = &b000000001000 '*< activate GPIO-1
  PRUIO_ACT_GPIO2  = &b000000010000 '*< activate GPIO-2
  PRUIO_ACT_GPIO3  = &b000000100000 '*< activate GPIO-3
  PRUIO_ACT_PWM0   = &b000001000000 '*< activate PWMSS-0 (including eCAP, eQEP, ePWM)
  PRUIO_ACT_PWM1   = &b000010000000 '*< activate PWMSS-1 (including eCAP, eQEP, ePWM)
  PRUIO_ACT_PWM2   = &b000100000000 '*< activate PWMSS-2 (including eCAP, eQEP, ePWM)
  PRUIO_DEF_ACTIVE = &b111111111111 '*< activate all subsystems
END ENUM


/'* \brief Structure for Control Module, containing pad configurations.

This UDT contains a set of all pad control registers. This is the
muxing between CPU balls and the internal subsystem targets, the pullup
or pulldown configuration and the receiver activation.

'/
TYPE BallSet
  AS UInt32 DeAd                 '*< Base address of Control Module subsystem.
  AS  UInt8 Value(PRUIO_AZ_BALL) '*< The values of the pad control registers.
END TYPE

/'* \brief Main structure, binding all components together.

This UDT glues all together. It downloads and start software on the
PRUSS, controls the initialisation and configuration processes and
reads or writes the pinmux configurations.

'/
TYPE PruIo
  AS AdcUdt PTR Adc     '*< Pointer to ADC subsystem structure.
  AS GpioUdt PTR Gpio   '*< Pointer to GPIO subsystems structure.
  AS PwmssUdt PTR PwmSS '*< Pointer to PWMSS subsystems structure.
  AS PwmMod PTR Pwm     '*< Pointer to the ePWM module structure (in PWMSS subsystems).
  AS CapMod PTR Cap     '*< Pointer to the eCAP module structure (in PWMSS subsystems).
  'AS QepMod PTR Qep     '*< Pointer to the eQEP module structure (in PWMSS subsystems).

  AS ZSTRING PTR _
    Errr = 0    '*< Pointer for error messages.
  AS  UInt32 PTR DRam '*< Pointer to access PRU DRam.
  AS BallSet PTR _
    Init _      '*< The subsystems register data at start-up (to restore when finished).
  , Conf        '*< The subsystems register data used by libpruio (current local data to be uploaded by PruIo::Config() ).
  AS ANY PTR _
    ERam _      '*< Pointer to read PRU external ram.
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
  , PruEvtOut _ '*< The interrupt channel to send commands to PRU.
  , PruIRam   _ '*< The PRU instruction ram to load.
  , PruDRam     '*< The PRU data ram.
  AS INT16 _
    ArmPruInt _ '*< The interrupt to send.
  , ParOffs _   '*< The offset for the parameters of a module.
  , DevAct      '*< Active subsystems.
  AS STRING _
    MuxAcc      '*< Path for pinmuxing.

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
  , BYVAL AS UInt32 = 0) AS ZSTRING PTR
  DECLARE FUNCTION setPin CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR
  DECLARE FUNCTION nameBall CDECL( _
    BYVAL AS UInt8) AS ZSTRING PTR
  DECLARE FUNCTION rb_start CDECL() AS ZSTRING PTR
  DECLARE FUNCTION mm_start CDECL( _
    BYVAL AS UInt32 = 0 _
  , BYVAL AS UInt32 = 0 _
  , BYVAL AS UInt32 = 0 _
  , BYVAL AS UInt32 = 0) AS ZSTRING PTR
END TYPE

