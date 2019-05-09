/'* \file pruio_timer.bi
\brief FreeBASIC header file for TIMER component of libpruio.

Header file for including in to libpruio. It contains the declarations
for the TIMER component of the library.

\since 0.4
'/


/'* \brief Structure for TIMER subsystem registers.

This UDT contains a set of all TIMER subsystem registers. It's used to
store the initial configuration of the four subsystems in the AM33xx
CPU, and to hold their current configurations for the next call to
function PruIo::config().

\since 0.4
'/
TYPE TimerSet
  AS UInt32 _
    DeAd _ '*< Device address.
  , ClAd _ '*< Clock address.
  , ClVa   '*< Clock value (defaults to 2 = enabled, set to 0 = disabled).

  AS UInt32 _
    TIDR _         '*< Register at offset  00h (see \ArmRef{20.1.5.1} ).
  , TIOCP_CFG _    '*< Timer OCP Configuration Register (offset 10h, see \ArmRef{20.1.5.2} ).
  , IRQ_EOI _      '*< Timer IRQ End-of-Interrupt Register (offset 20h, see \ArmRef{20.1.5.3} ).
  , IRQSTATUS_RAW _'*< Timer Status Raw Register (offset 24h, see \ArmRef{20.1.5.4} ).
  , IRQSTATUS _    '*< Timer Status Register (offset 28h, see \ArmRef{20.1.5.5} ).
  , IRQENABLE_SET _'*< Timer Interrupt Enable Set Register (offset 2Ch, see \ArmRef{20.1.5.6} ).
  , IRQENABLE_CLR _'*< Timer Interrupt Enable Clear Register (offset 30h, see \ArmRef{20.1.5.7} ).
  , IRQWAKEEN _    '*< Timer IRQ Wakeup Enable Register (offset 34h, see \ArmRef{20.1.5.8} ).
  , TCLR _  '*< Timer Control Register (offset 38h, see \ArmRef{20.1.5.9} ).
  , TCRR _  '*< Timer Counter Register (offset 3Ch, see \ArmRef{20.1.5.10} ).
  , TLDR _  '*< Timer Load Register (offset 40h, see \ArmRef{20.1.5.11} ).
  , TTGR _  '*< Timer Trigger Register (offset 44h, see \ArmRef{20.1.5.12} ).
  , TWPS _  '*< Timer Write Posting Bits Register (offset 48h, see \ArmRef{20.1.5.13} ).
  , TMAR _  '*< Timer Match Register (offset 4Ch, see \ArmRef{20.1.5.14} ).
  , TCAR1 _ '*< Timer Capture Register (offset 50h, see \ArmRef{20.1.5.15} ).
  , TSICR _ '*< Timer Synchronous Interface Control Register (offset 54h, see \ArmRef{20.1.5.16} ).
  , TCAR2   '*< Timer Capture Register (offset 58h, see \ArmRef{20.1.5.17} ).
END TYPE

/'* \brief UDT for TIMER data, fetched in IO & RB mode.

This UDT is used to fetch the current register data from the TIMER
subsystems in IO and RB mode.

\since 0.4
'/
TYPE TimerArr
  AS UInt32 _
    DeAd    '*< Base address of TIMER subsystem
  AS UInt32 _
    CMax _  '*< Maximum counter value.
  , TCAR1 _ '*< Current value of TCAR1 register (IO, RB).
  , TCAR2   '*< Current value of TCAR2 register (IO, RB).
END TYPE


/'* \brief Structure for TIMER subsystem features, containing all
functions and variables to handle the subsystems.

This UDT contains the member function to control the features in each
of the four TIMER subsystems included in the AM33xx CPU and the related
variables.

\since 0.4
'/
TYPE TimerUdt
  AS Pruio_ PTR Top       '*< Pointer to the calling PruIo instance.
  AS TimerSet PTR _
    Init(PRUIO_AZ_TIMER) _'*< Initial subsystem configuration, used in the destructor PruIo::~PruIo().
  , Conf(PRUIO_AZ_TIMER)  '*< Current subsystem configuration, used in PruIo::config().
  AS TimerArr PTR _
    Raw(PRUIO_AZ_TIMER)   '*< Pointer to current raw subsystem data (IO), all 32 bits.
  AS UInt32 _
    InitParA _            '*< Offset to read data block.
  , PwmMode = &b001100001000011 _ '*< Control register for PWM output mode.
  , TimMode = &b001100001000010 _ '*< Control register for Timer mode.
  , TimHigh = &b000000010000000 _ '*< Control register for stopped Timer high.
  , Tim_Low = &b000000000000000 _ '*< Control register for stopped Timer low.
  , CapMode = &b010000110000000   '*< Control register for CAP input mode.
  AS ZSTRING PTR _
    E0 = @"TIMER subsystem not enabled" _ '*< Common error message.
  , E1 = @"pin has no TIMER capability" _ '*< Common error message.
  , E2 = @"pin not in TIMER mode" _       '*< Common error message.
  , E3 = @"duration too short" _          '*< Common error message.
  , E4 = @"duration too long" _           '*< Common error message.
  , E5 = @"pin not in CAP mode"           '*< Common error message.

  DECLARE CONSTRUCTOR (BYVAL AS Pruio_ PTR)
  DECLARE FUNCTION initialize CDECL() AS ZSTRING PTR
  DECLARE FUNCTION setValue CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t _
  , BYVAL AS Float_t = 0. _
  , BYVAL AS SHORT = 0) AS ZSTRING PTR
  DECLARE FUNCTION Value CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t PTR _
  , BYVAL AS Float_t PTR) AS ZSTRING PTR

  DECLARE FUNCTION pwm_set CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t _
  , BYVAL AS Float_t = 0.) AS ZSTRING PTR
  DECLARE FUNCTION pwm_get CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t PTR = 0 _
  , BYVAL AS Float_t PTR = 0) AS ZSTRING PTR
  'DECLARE FUNCTION cap_get CDECL( _
    'BYVAL AS UInt8 _
  ', BYVAL AS Float_t PTR = 0 _
  ', BYVAL AS Float_t PTR = 0 ) AS ZSTRING PTR
END TYPE
