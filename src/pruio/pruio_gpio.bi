/'* \file pruio_gpio.bi
\brief FreeBASIC header file for GPIO component of libpruio.

Header file for including in to libpruio. It contains the declarations
for the GPIO component of the library.

'/


/'* \brief Structure for GPIO subsystem registers.

This UDT contains a set of all GPIO subsystem registers. Is used to
store the initial configuration of the four subsystems in the AM33xx
CPU, and to hold their current configurations for the next call to
function PruIo::config().

\since 0.2
'/
TYPE GpioSet
  AS UInt32 _
    DeAd _ '*< Device address.
  , ClAd _ '*< Clock address.
  , ClVa   '*< Clock value (defaults to 2 = enabled, set to 0 = disabled).

  AS UInt32 _
    REVISION _        '*< Register at offset  00h (see \ArmRef{25.4.1.1} ).
  , SYSCONFIG _       '*< Register at offset  10h (see \ArmRef{25.4.1.2} ).
  , EOI _             '*< Register at offset  20h (see \ArmRef{25.4.1.3} ).
  , IRQSTATUS_RAW_0 _ '*< Register at offset  24h (see \ArmRef{25.4.1.4} ).
  , IRQSTATUS_RAW_1 _ '*< Register at offset  28h (see \ArmRef{25.4.1.5} ).
  , IRQSTATUS_0 _     '*< Register at offset  2Ch (see \ArmRef{25.4.1.6} ).
  , IRQSTATUS_1 _     '*< Register at offset  30h (see \ArmRef{25.4.1.7} ).
  , IRQSTATUS_SET_0 _ '*< Register at offset  34h (see \ArmRef{25.4.1.8} ).
  , IRQSTATUS_SET_1 _ '*< Register at offset  38h (see \ArmRef{25.4.1.9} ).
  , IRQSTATUS_CLR_0 _ '*< Register at offset  3Ch (see \ArmRef{25.4.1.10} ).
  , IRQSTATUS_CLR_1 _ '*< Register at offset  40h (see \ArmRef{25.4.1.11} ).
  , IRQWAKEN_0 _      '*< Register at offset  44h (see \ArmRef{25.4.1.12} ).
  , IRQWAKEN_1 _      '*< Register at offset  48h (see \ArmRef{25.4.1.13} ).
  , SYSSTATUS _       '*< Register at offset 114h (see \ArmRef{25.4.1.14} ).
  , CTRL _            '*< Register at offset 130h (see \ArmRef{25.4.1.15} ).
  , OE _              '*< Register at offset 134h (see \ArmRef{25.4.1.16} ).
  , DATAIN _          '*< Register at offset 138h (see \ArmRef{25.4.1.17} ).
  , DATAOUT _         '*< Register at offset 13Ch (see \ArmRef{25.4.1.18} ).
  , LEVELDETECT0 _    '*< Register at offset 140h (see \ArmRef{25.4.1.19} ).
  , LEVELDETECT1 _    '*< Register at offset 144h (see \ArmRef{25.4.1.20} ).
  , RISINGDETECT _    '*< Register at offset 148h (see \ArmRef{25.4.1.21} ).
  , FALLINGDETECT _   '*< Register at offset 14Ch (see \ArmRef{25.4.1.22} ).
  , DEBOUNCENABLE _   '*< Register at offset 150h (see \ArmRef{25.4.1.23} ).
  , DEBOUNCINGTIME _  '*< Register at offset 154h (see \ArmRef{25.4.1.24} ).
  , CLEARDATAOUT _    '*< Register at offset 190h (see \ArmRef{25.4.1.25} ).
  , SETDATAOUT        '*< Register at offset 194h (see \ArmRef{25.4.1.26} ).
END TYPE

/'* \brief UDT for GPIO data, fetched in IO & RB mode.

This UDT is used to fetch the current register data from the GPIO
modules in IO and RB mode.

'/
TYPE GpioArr
  AS UInt32 _
    DeAd       '*< Base address of GPIO subsystem + 0x100.
  AS UInt32 _
    DATAIN _   '*< Current Value of DATAIN register (IO).
  , DATAOUT _  '*< Current Value of DATAOUT register (IO).
  , Mix        '*< Current state of pins (IN&OUT mixed).
END TYPE


/'* \brief Structure for GPIO subsystem features, containing all
functions and variables to handle the subsystems.

This UDT contains the member function to control the features in each
of the four GPIO subsystems included in the AM33xx CPU and the related
variables.

\since 0.2
'/
TYPE GpioUdt
  AS  Pruio_ PTR Top      '*< Pointer to the calling PruIo instance.
  AS GpioSet PTR _
    Init(PRUIO_AZ_GPIO) _ '*< Initial subsystem configuration, used in the destructor PruIo::~PruIo.
  , Conf(PRUIO_AZ_GPIO)   '*< Current subsystem configuration, used in PruIo::config().
  AS GpioArr PTR _
    Raw(PRUIO_AZ_GPIO)    '*< Pointer to current raw subsystem data (IO), all 32 bits.
  AS UInt32 InitParA      '*< Offset to read data block offset.
  AS ZSTRING PTR _
    E0 = @"GPIO subsystem not enabled" _ '*< Common error message.
  , E1 = @"no GPIO pin"                  '*< Common error message.

  DECLARE CONSTRUCTOR (BYVAL AS Pruio_ PTR)
  DECLARE FUNCTION initialize CDECL() AS ZSTRING PTR
  DECLARE FUNCTION config CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS UInt8 = CAST(UInt8, PRUIO_GPIO_IN_0)) AS ZSTRING PTR
  DECLARE FUNCTION Value CDECL( _
    BYVAL AS UInt8) AS Int32
  DECLARE FUNCTION setValue CDECL( _
    BYVAL AS UInt8 _
  , BYVAL AS UInt8 = 0) AS ZSTRING PTR
END TYPE
