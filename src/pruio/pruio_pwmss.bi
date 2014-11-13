/'* \file pruio_pwmss.bi
\brief FreeBASIC header file for the PWMSS component declarations.

Header file for including the PWMSS component of libpruio. It contains
a UDT for the PWMSS subsystem, one for its registers and one UDT for
each module in the subsystem (eQEP, eCAP and ePWM) with the functions
to control the hardware.

The control functions are out-sourced in separate UDTs in order to make
the API easier to understand for the user. He wants a PWM output at pin
X or a CAP input at pin Y. And he should not care about the PWMSS
subsystems and its modules when doing simple tasks.

'/


/'* \brief Structure for PWMSS subsystem registers.

This UDT contains a set of all PWMSS subsystem registers. Is used to
store the initial configuration of the three subsystems in the AM33xx
CPU, and to hold their current configurations for the next call to
function PruIo::config().

Each Pulse Width Modulation SubSystem (PWMSS) cpntains three modules:
PWM, CAP and QEP. This structure holds the values for all registers of
all modules, but the functions to control the modules are separated in
the module UDTs PwmMod, CapMod and QepMod in order to
make the API more clear.

\since 0.2
'/
TYPE PwmssSet
  AS UInt32 _
    DeAd _ '*< Device address.
  , ClAd _ '*< Clock address.
  , ClVa   '*< Clock value (defaults to 2 = enabled, set to 0 = disabled).

  AS UInt32 _ '' PWMSS REGISTERS
    IDVER _     '*< IP Revision Register (see \ArmRef{15.1.3.1} ).
  , SYSCONFIG _ '*< System Configuration Register (see \ArmRef{15.1.3.2} ).
  , CLKCONFIG _ '*< Clock Configuration Register (see \ArmRef{15.1.3.3} ).
  , CLKSTATUS   '*< Clock Status Register (see \ArmRef{15.1.3.4} ).

  AS UInt32 _ '' eCAP registers (&h100)
    TSCTR _     '*< Time-Stamp Counter Register (see \ArmRef{15.3.4.1.1} ).
  , CTRPHS _    '*< Counter Phase Offset Value Register (see \ArmRef{15.3.4.1.2} ).
  , CAP1 _      '*< Capture 1 Register (see \ArmRef{15.3.4.1.3} ).
  , CAP2 _      '*< Capture 2 Register (see \ArmRef{15.3.4.1.4} ).
  , CAP3 _      '*< Capture 3 Register (see \ArmRef{15.3.4.1.5} ).
  , CAP4        '*< Capture 4 Register (see \ArmRef{15.3.4.1.6} ).
  AS UInt16 _
    ECCTL1 _    '*< Capture Control Register 1 (see \ArmRef{15.3.4.1.7} ).
  , ECCTL2 _    '*< Capture Control Register 2 (see \ArmRef{15.3.4.1.8} ).
  , ECEINT _    '*< Capture Interrupt Enable Register (see \ArmRef{15.3.4.1.9} ).
  , ECFLG _     '*< Capture Interrupt Flag Register (see \ArmRef{15.3.4.1.10} ).
  , ECCLR _     '*< Capture Interrupt Clear Register (see \ArmRef{15.3.4.1.11} ).
  , ECFRC       '*< Capture Interrupt Force Register (see \ArmRef{15.3.4.1.12} ).
  AS UInt32 _
    CAP_REV     '*< Revision ID Register (see \ArmRef{15.3.4.1.13} ).

  AS UInt32 _ '' QEP registers (&h180)
    QPOSCNT _   '*< Position Counter Register (see \ArmRef{15.4.3.1} ).
  , QPOSINIT _  '*< Position Counter Initialization Register (see \ArmRef{15.4.3.2} ).
  , QPOSMAX _   '*< Maximum Position Count Register (see \ArmRef{15.4.3.3} ).
  , QPOSCMP _   '*< Position-Compare Register 2/1 (see \ArmRef{15.4.3.4} ).
  , QPOSILAT _  '*< Index Position Latch Register (see \ArmRef{15.4.3.5} ).
  , QPOSSLAT _  '*< Strobe Position Latch Register (see \ArmRef{15.4.3.6} ).
  , QPOSLAT _   '*< Position Counter Latch Register (see \ArmRef{15.4.3.7} ).
  , QUTMR _     '*< Unit Timer Register (see \ArmRef{15.4.3.8} ).
  , QUPRD       '*< Unit Period Register (see \ArmRef{15.4.3.9} ).
  AS UInt16 _
    QWDTMR _    '*< Watchdog Timer Register (see \ArmRef{15.4.3.10} ).
  , QWDPRD _    '*< Watchdog Period Register (see \ArmRef{15.4.3.11} ).
  , QDECCTL _   '*< Decoder Control Register (see \ArmRef{15.4.3.12} ).
  , QEPCTL _    '*< Control Register (see \ArmRef{15.4.3.14} ).
  , QCASCTL _   '*< Capture Control Register (see \ArmRef{15.4.3.15} ).
  , QPOSCTL _   '*< Position-Compare Control Register (see \ArmRef{15.4.3.15} ).
  , QEINT _     '*< Interrupt Enable Register (see \ArmRef{15.4.3.16} ).
  , QFLG _      '*< Interrupt Flag Register (see \ArmRef{15.4.3.17} ).
  , QCLR _      '*< Interrupt Clear Register (see \ArmRef{15.4.3.18} ).
  , QFRC _      '*< Interrupt Force Register (see \ArmRef{15.4.3.19} ).
  , QEPSTS _    '*< Status Register (see \ArmRef{15.4.3.20} ).
  , QCTMR _     '*< Capture Timer Register (see \ArmRef{15.4.3.21} ).
  , QCPRD _     '*< Capture Period Register (see \ArmRef{15.4.3.22} ).
  , QCTMRLAT _  '*< Capture Timer Latch Register (see \ArmRef{15.4.3.23} ).
  , QCPRDLAT _  '*< Capture Period Latch Register (see \ArmRef{15.4.3.24} ).
  , empty       '*< adjust at UInt32 border
  AS UInt32 _
    QEP_REV     '*< Revision ID (see \ArmRef{15.4.3.25} ).

  AS UInt16 _  '' ePWM registers (&h200)
_ '*< Time-Base Submodule Registers (see \ArmRef{15.2.4.1} ).
    TBCTL _     '*< Time-Base Control Register
  , TBSTS _     '*< Time-Base Status Register
  , TBPHSHR _   '*< Extension for HRPWM Phase Register
  , TBPHS _     '*< Time-Base Phase Register
  , TBCNT _     '*< Time-Base Counter Register
  , TBPRD _     '*< Time-Base Period Register
_ '' Counter-Compare Submodule Registers (see \ArmRef{15.2.4.2} ).
  , CMPCTL _    '*< Counter-Compare Control Register
  , CMPAHR _    '*< Extension for HRPWM Counter-Compare A Register
  , CMPA _      '*< Counter-Compare A Register
  , CMPB _      '*< Counter-Compare B Register
_ '' Action-Qualifier Submodule Registers (see \ArmRef{15.2.4.3} ).
  , AQCTLA _    '*< Action-Qualifier Control Register for Output A (EPWMxA)
  , AQCTLB _    '*< Action-Qualifier Control Register for Output B (EPWMxB)
  , AQSFRC _    '*< Action-Qualifier Software Force Register
  , AQCSFRC _   '*< Action-Qualifier Continuous S/W Force Register Set
_ '' Dead-Band Generator Submodule Registers (see \ArmRef{15.2.4.4} ).
  , DBCTL _     '*< Dead-Band Generator Control Register
  , DBRED _     '*< Dead-Band Generator Rising Edge Delay Count Register
  , DBFED _     '*< Dead-Band Generator Falling Edge Delay Count Register
_ '' Trip-Zone Submodule Registers (see \ArmRef{15.2.4.5} ).
  , TZSEL _     '*< Trip-Zone Select Register
  , TZCTL _     '*< Trip-Zone Control Register
  , TZEINT _    '*< Trip-Zone Enable Interrupt Register
  , TZFLG _     '*< Trip-Zone Flag Register
  , TZCLR _     '*< Trip-Zone Clear Register
  , TZFRC _     '*< Trip-Zone Force Register
_ '' Event-Trigger Submodule Registers (see \ArmRef{15.2.4.6} ).
  , ETSEL _     '*< Event-Trigger Selection Register
  , ETPS _      '*< Event-Trigger Pre-Scale Register
  , ETFLG _     '*< Event-Trigger Flag Register
  , ETCLR _     '*< Event-Trigger Clear Register
  , ETFRC _     '*< Event-Trigger Force Register
_ '' PWM-Chopper Submodule Registers (see \ArmRef{15.2.4.7} ).
  , PCCTL _     '*< PWM-Chopper Control Register
_  '' High-Resolution PWM (HRPWM) Submodule Registers (see \ArmRef{15.2.4.8} ).
  , HRCTL       '*< HRPWM Control Register
END TYPE


/'* \brief UDT for PWMSS data, fetched in IO & RB mode.

This UDT is used to fetch the current register data from eCAP and eQEP
modules in IO and RB mode.

\since 0.2
'/
TYPE PwmssArr
  AS UInt32 _
    DeAd   '*< Subsystem address.
  AS UInt32 _
    CMax _ '*< Maximum counter value.
  , C1 _   '*< On time counter value.
  , C2 _   '*< Period time counter value.
  , fe1 _  '*< future expansion
  , fe2 _  '*< future expansion
  , fe3 _  '*< future expansion
  , fe4    '*< future expansion
END TYPE


/'* \brief Structure for PWMSS subsystem features, containing all
variables to handle the subsystems.

This UDT contains (only) the configuration of the three PWMSS
subsystems in the CPU. The functions to drive the hardware are in
separate UDTs, to make the API more easy to understand. See UDTs
PwmMod, CapMod and ŗef QepMod for details.

\since 0.2
'/
TYPE PwmssUdt
  AS Pruio_ PTR Top        '*< Pointer to the calling PruIo instance.
  AS PwmssSet PTR _
    Init(PRUIO_AZ_PWMSS) _ '*< Initial subsystem configuration, used in the destructor PruIo::~PruIo.
  , Conf(PRUIO_AZ_PWMSS)   '*< Current subsystem configuration, used in PruIo::config().
  AS PwmssArr PTR _
    Raw(PRUIO_AZ_PWMSS)    '*< Pointer to current raw subsystem data (IO).
  AS UInt32 InitParA       '*< Initial parameters offset.
  AS CONST UInt16 _
    PwmMode = &b1011010000 _'*< Value for ECCTL2 in PWM mode.
  , CapMode = &b0011010110  '*< Value for ECCTL2 in CAP mode.

  DECLARE CONSTRUCTOR (BYVAL AS Pruio_ PTR)
  DECLARE FUNCTION initialize CDECL() AS ZSTRING PTR
END TYPE


/'* \brief UDT for PWM modules, containing the functions to drive the hardware.

Pulse width modulated (PWM) output can get generated in two ways. The
PWM subsystems (PWMSS) contain a ePWM module, which can generate two
PWM outputs at the same frequency (up to 17 bit resolution). And the
PWMSS contains a eCAP module, which can generate a single PWM output
(up to 32 bit resolution). All PWM generators (ePWM-1/2 and eCAP) are
controlled by the member functions of this structure (UDT). See
\ArmRef{15} for hardware details.

To use a header pins as PWM output, the pin must be in *pwm* mode
before starting your code. Then just set the desired period (frequency)
and duty cycle (load) by a call to function PwmMod::setValue().

'/
TYPE PwmMod
  AS  Pruio_ PTR Top  '*< pointer to the calling PruIo instance
  AS ZSTRING PTR _
    E0 = @"pin has no PWM capability" _   '*< common error message
  , E1 = @"pin not in PWM mode" _         '*< common error message
  , E2 = @"PWMSS not enabled" _           '*< common error message
  , E3 = @"set frequency in first call" _ '*< common error message
  , E4 = @"frequency not supported"       '*< common error message

  DECLARE CONSTRUCTOR (BYVAL AS Pruio_ PTR)
  DECLARE FUNCTION Value CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t PTR = 0 _
  , BYVAL AS Float_t PTR = 0) AS ZSTRING PTR
  DECLARE FUNCTION setValue CDECL( _
    BYVAL AS UInt8, _
    BYVAL AS Float_t, _
    BYVAL AS Float_t) AS ZSTRING PTR
  DECLARE FUNCTION pwm_set CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t _
  , BYVAL AS Float_t = 0. _
  , BYVAL AS Float_t = 0.) AS ZSTRING PTR
  DECLARE FUNCTION cap_set CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t _
  , BYVAL AS Float_t = 0.) AS ZSTRING PTR
  DECLARE FUNCTION pwm_get CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t PTR = 0 _
  , BYVAL AS Float_t PTR = 0  _
  , BYVAL AS UInt8) AS ZSTRING PTR
  DECLARE FUNCTION cap_get CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t PTR = 0 _
  , BYVAL AS Float_t PTR = 0 ) AS ZSTRING PTR
END TYPE


/'* \brief UDT for PWMSS-CAP modules, containing the functions to drive the hardware.

This structure contains the functions to drive the hardware of the eCAP
modul in the PWMSS subsystems in input mode.

See \ArmRef{15.3} for hardware details.

'/
TYPE CapMod
  AS  Pruio_ PTR Top  '*< pointer to the calling PruIo instance
  AS ZSTRING PTR _
    E0 = @"pin has no CAP capability" _ '*< common error message
  , E1 = @"pin not in CAP mode" _       '*< common error message
  , E2 = @"CAP not enabled"             '*< common error message

  DECLARE CONSTRUCTOR (BYVAL AS Pruio_ PTR)
  DECLARE FUNCTION config CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t = 0.) AS ZSTRING PTR
  DECLARE FUNCTION Value CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS Float_t PTR = 0 _
  , BYVAL AS Float_t PTR = 0) AS ZSTRING PTR
END TYPE


'/'* \brief UDT for PWMSS-QEP modules, containing the functions to drive the hardware.

'This structure contains the functions to drive the hardware of the eQEP
'modul in the PWMSS subsystems.

'See \ArmRef{15.4} for hardware details.

''/
'TYPE QepMod
  'AS  Pruio_ PTR Top  '*< pointer to the calling PruIo instance
  'AS ZSTRING PTR _
    'E0 = @"pin has no QEP capability" _ '*< common error message
  ', E1 = @"pin not in QEP mode" _       '*< common error message
  ', E2 = @"QEP not enabled"             '*< common error message

  'DECLARE CONSTRUCTOR (BYVAL AS Pruio_ PTR)
  'DECLARE FUNCTION config CDECL( _
    'BYVAL AS UInt8 _
  ', BYVAL AS UInt8 = 0 _
  ', BYVAL AS UInt8 = 0 _
  ', BYVAL AS UInt8 = 0) AS ZSTRING PTR
  'DECLARE FUNCTION Value CDECL( _
    'BYVAL AS UInt8 _
  ', BYVAL AS Float_t PTR = 0) AS ZSTRING PTR
'END TYPE
