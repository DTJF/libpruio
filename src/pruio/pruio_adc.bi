/'* \file pruio_adc.bi
\brief FreeBASIC header file for ADC component of libpruio.

Header file for including in to libpruio. It contains the declarations
for the ADC part of the library.

'/


'* The default setting for avaraging.
#DEFINE PRUIO_DEF_AVRAGE 4
'* The default value for open delay in channel settings.
#DEFINE PRUIO_DEF_ODELAY 183
'* The default value for sample delay in channel settings.
#DEFINE PRUIO_DEF_SDELAY 0
'* The default number of samples to use (configures single mode).
#DEFINE PRUIO_DEF_SAMPLS 1
'* The default step mask (steps 1 to 8 for AIN-0 to AIN-7, no charge step).
#DEFINE PRUIO_DEF_STPMSK &b111111110
'* The default timer value (sampling rate).
#DEFINE PRUIO_DEF_TIMERV 0
'* The default bit mode (4 = 16 bit encoding).
#DEFINE PRUIO_DEF_LSLMOD 4
'* The default clock divisor (0 = full speed AFE = 2.4 MHz).
#DEFINE PRUIO_DEF_CLKDIV 0

/'* \brief Structure for a single ADC step configuration, containing
config and delay registers context.

This UDT contains the configuration of a single step. Up to 16 steps
can get configured for a measurement (index 1 to 16). A further step
(index 0) can get configured to charge a touch screen.

Find further details in \ArmRef{12.5.1.17 ff.}.

'/
TYPE AdcSteps
  AS UInt32 _
    Confg _ '*< Context for configuration register.
  , Delay   '*< Context for delay register.
END TYPE

/'* \brief Structure for ADC subsystem registers.

This UDT contains a set of all ADC subsystem registers. It's used to
store the initial configuration of the subsystem and to hold current
configuration for the next call to function PruIo::config().

\since 0.2
'/
TYPE AdcSet
  AS UInt32 _
    DeAd _ '*< Device address.
  , ClAd _ '*< Clock address.
  , ClVa   '*< Clock value (defaults to 2 = enabled, set to 0 = disabled).

  AS UInt32 _
    REVISION _       '*< Register at offset 00h (see \ArmRef{12.5.1.1} ).
  , SYSCONFIG _      '*< Register at offset 10h (see \ArmRef{12.5.1.2} ).
  , IRQSTATUS_RAW _  '*< Register at offset 24h (see \ArmRef{12.5.1.3} ).
  , IRQSTATUS _      '*< Register at offset 28h (see \ArmRef{12.5.1.4} ).
  , IRQENABLE_SET _  '*< Register at offset 2Ch (see \ArmRef{12.5.1.5} ).
  , IRQENABLE_CLR _  '*< Register at offset 30h (see \ArmRef{12.5.1.6} ).
  , IRQWAKEUP _      '*< Register at offset 34h (see \ArmRef{12.5.1.7} ).
  , DMAENABLE_SET _  '*< Register at offset 38h (see \ArmRef{12.5.1.8} ).
  , DMAENABLE_CLR _  '*< Register at offset 3Ch (see \ArmRef{12.5.1.9} ).
  , CTRL _           '*< Register at offset 40h (see \ArmRef{12.5.1.10} ).
  , ADCSTAT _        '*< Register at offset 44h (see \ArmRef{12.5.1.11} ).
  , ADCRANGE _       '*< Register at offset 48h (see \ArmRef{12.5.1.12} ).
  , ADC_CLKDIV _     '*< Register at offset 4Ch (see \ArmRef{12.5.1.13} ).
  , ADC_MISC _       '*< Register at offset 50h (see \ArmRef{12.5.1.14} ).
  , STEPENABLE _     '*< Register at offset 54h (see \ArmRef{12.5.1.15} ).
  , IDLECONFIG _     '*< Register at offset 58h (see \ArmRef{12.5.1.16} ).

  '* step configuration (see \ArmRef{12.5.1.17 ff}, charge step + 16 steps, by default steps 1 to 8 are used for AIN-0 to AIN-7).
  AS AdcSteps St_p(16)

  AS UInt32 _
    FIFO0COUNT _     '*< Register at offset E4h (see \ArmRef{12.5.1.51} ).
  , FIFO0THRESHOLD _ '*< Register at offset E8h (see \ArmRef{12.5.1.52} ).
  , DMA0REQ _        '*< Register at offset ECh (see \ArmRef{12.5.1.53} ).
  , FIFO1COUNT _     '*< Register at offset F0h (see \ArmRef{12.5.1.54} ).
  , FIFO1THRESHOLD _ '*< Register at offset F4h (see \ArmRef{12.5.1.55} ).
  , DMA1REQ          '*< Register at offset F8h (see \ArmRef{12.5.1.56} ).
END TYPE

/'* \brief Structure for ADC subsystem features, containing all
functions and variables to handle the subsystem.

This UDT contains the member function to control the ADC features and
the related variables.

\since 0.2
'/
TYPE AdcUdt
  AS Pruio_ PTR Top  '*< Pointer to the calling PruIo instance.
  AS AdcSet PTR _
    Init _     '*< Initial subsystem configuration, used in the destructor PruIo::~PruIo.
  , Conf       '*< Current subsystem configuration, used in PruIo::config().
  AS UInt32 _
    Samples _  '*< Number of samples (specifies run mode: 0 = config, 1 = IO mode, >1 = MM mode).
  , TimerVal _ '*< Timer value in [ns].
  , InitParA   '*< Offset to read data block offset.
  AS UInt16 _
    LslMode _  '*< Bit shift modus (0 to 4, for 12 to 16 bits).
  , ChAz       '*< The number of active steps.
  AS UInt16 PTR _
    Value      '*< Fetched ADC samples.
  AS ZSTRING PTR _
    E0 = @"step number too big" _         '*< Common error message.
  , E1 = @"channel number too big" _      '*< Common error message.
  , E2 = @"too much values to skip" _     '*< Common error message.
  , E3 = @"trigger step not configured" _ '*< Common error message.
  , E4 = @"invalid step number" _         '*< Common error message.
  , E5 = @!"ADC not enabled"               '*< Common error message.

  DECLARE CONSTRUCTOR (BYVAL AS Pruio_ PTR )
  DECLARE FUNCTION initialize CDECL( _
    BYVAL AS UInt8  = PRUIO_DEF_AVRAGE _
  , BYVAL AS UInt32 = PRUIO_DEF_ODELAY _
  , BYVAL AS UInt8  = PRUIO_DEF_SDELAY) AS ZSTRING PTR
  DECLARE FUNCTION configure CDECL( _
    BYVAL AS UInt32 = PRUIO_DEF_SAMPLS _
  , BYVAL AS UInt32 = PRUIO_DEF_STPMSK _
  , BYVAL AS UInt32 = PRUIO_DEF_TIMERV _
  , BYVAL AS UInt16 = PRUIO_DEF_LSLMOD) AS ZSTRING PTR
  DECLARE FUNCTION setStep CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS UInt8 _
  , BYVAL AS UInt8  = PRUIO_DEF_AVRAGE _
  , BYVAL AS UInt8  = PRUIO_DEF_SDELAY _
  , BYVAL AS UInt32 = PRUIO_DEF_ODELAY) AS ZSTRING PTR
  DECLARE FUNCTION mm_trg_pin CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS UInt8 = 0 _
  , BYVAL AS UInt16 = 0) AS UInt32
  DECLARE FUNCTION mm_trg_ain CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Int32 _
  , BYVAL AS UInt8 = 0 _
  , BYVAL AS UInt16 = 0) AS UInt32
  DECLARE FUNCTION mm_trg_pre CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Int32 _
  , BYVAL AS UInt16 = 0 _
  , BYVAL AS UInt8 = 0) AS UInt32
END TYPE
