/'* \file pruio_gpio.bas
\brief The GPIO component source code.

Source code file containing the function bodies to control the GPIO
subsystems. See class GpioUdt for details.

\since 0.2
'/


' PruIo global declarations.
#INCLUDE ONCE "pruio_globals.bi"
' Header for GPIO part.
#INCLUDE ONCE "pruio_gpio.bi"
' driver header file
#INCLUDE ONCE "pruio.bi"

/'* \brief The constructor for the GPIO features.
\param T A pointer of the calling PruIo structure.

The constructor prepares the DRam parameters to run the pasm_init.p
instructions. The adresses of the subsystems and the adresses of the
clock registers get prepared, and the index of the last parameter gets
stored to compute the offset in the Init and Conf data blocks.

\since 0.2
'/
CONSTRUCTOR GpioUdt(BYVAL T AS Pruio_ PTR)
  Top = T
  WITH *Top
    VAR i = .ParOffs
    InitParA = i
    i += 1 : .DRam[i] = &h44E07000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_GPIO0, &h44E00408uL, 0)

    i += 1 : .DRam[i] = &h4804C000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_GPIO1, &h44E000ACuL, 0)

    i += 1 : .DRam[i] = &h481AC000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_GPIO2, &h44E000B0uL, 0)

    i += 1 : .DRam[i] = &h481AE000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_GPIO3, &h44E000B4uL, 0)
    .ParOffs = i
  END WITH
END CONSTRUCTOR


/'* \brief Initialize the register context after running the pasm_init.p instructions (private).
\returns 0 (zero) on success (may return an error string in future versions).

This is a private function, designed to be called from the main
constructor PruIo::PruIo(). It sets the pointers to the Init and Conf
structures in the data blocks. And it initializes some register
context, if the subsystem woke up and is enabled.

\since 0.2
'/
FUNCTION GpioUdt.initialize CDECL() AS ZSTRING PTR
  WITH *Top
    VAR p_mem = .MOffs + .DRam[InitParA] _
      , p_raw = CAST(ANY PTR, .DRam) + PRUIO_DAT_GPIO

    FOR i AS LONG = 0 TO PRUIO_AZ_GPIO
      Raw(i) = p_raw
      p_raw += SIZEOF(GpioArr)

      Init(i) = p_mem
      Conf(i) = p_mem + .DSize

      WITH *Conf(i)
        IF .ClAd = 0 ORELSE .REVISION = 0 THEN _ '    subsystem disabled
                .DeAd = 0 : .ClVa = &h30000 : p_mem += 16 : _
                    Init(i)->DeAd = 0 : Init(i)->ClAd = 0 : CONTINUE FOR
        .ClVa = 2
        .CLEARDATAOUT = 0
        .SETDATAOUT = 0
        '.DATAIN = Init(i)->DATAIN
        '.DATAOUT = Init(i)->DATAOUT
      END WITH

      WITH *Init(i)
        .CLEARDATAOUT = 0
        .SETDATAOUT = 0
        var a = i * 32, e = a + 31
        FOR b AS INTEGER = 0 TO PRUIO_AZ_BALL
          var p = b - a
          SELECT CASE Top->BallGpio(b)
          CASE a TO e : if bit(.OE, p) then continue for ' input pin
            if BIT(.DATAOUT, p) then Top->BallInit[b] OR= &b10000000
          END SELECT
        NEXT
      END WITH

      p_mem += SIZEOF(GpioSet)
    NEXT
  END WITH : RETURN 0
END FUNCTION


/'* \brief Configure a GPIO.
\param Ball The CPU ball number to test.
\param Mo The modus to set (as Control Module pad register value).
\returns Zero on success (otherwise a string with an error message).

This function is used to configure a digital pin for GPIO. Use the
macros defined in pruio.bi to specify the pin number in parameter
`Ball` for a pin on the Beaglebone headers (ie P8_03 selects pin 3 on
header P8).

Parameter `Modus` specifies the pinmux mode for the ARM control module
(see \ArmRef{9} for details). By default the pin gets configured as
input pin with pulldown resistor. Other configurations are prepared as
enumerators \ref PinMuxing :

| macro name       | Description                              |
| ---------------: | :--------------------------------------- |
| PRUIO_GPIO_IN    | open input pin (no resistor)             |
| PRUIO_GPIO_IN_0  | low input pin (with pulldown resistor)   |
| PRUIO_GPIO_IN_1  | high input pin (with pullup resistor)    |
| PRUIO_GPIO_OUT0  | output pin set to low (no resistor)      |
| PRUIO_GPIO_OUT1  | output pin set to high (no resistor)     |

\note In case of device tree pinmuxing it's not possible to set the
state of a CPU ball (not connected to a header), because only header
pins are prepared for pinmuxing in the libpruio device tree overlay.

Wrapper function (C or Python): pruio_gpio_config().

\since 0.2
'/
FUNCTION GpioUdt.config CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Mo AS UInt8 = CAST(UInt8, PRUIO_GPIO_IN_0)) AS ZSTRING PTR
  WITH *Top
    BallCheck(" GPIO", .Errr)
    IF 7 <> (Mo AND &b111)                      THEN .Errr = E1 : RETURN .Errr ' no GPIO mode
    VAR r = .BallGpio(Ball) ' resulting GPIO (index and bit number)
    Mode = Mo XOR .BallConf[Ball]
    IF Mo <> PRUIO_PIN_RESET ANDALSO Mode = 0                THEN RETURN 0 ' nothing to config
    Indx = r SHR 5 : IF 2 <> Conf(Indx)->ClVa   THEN .Errr = E0 : RETURN .Errr ' GPIO subsystem not enabled
    IF Mode AND &b10100000 THEN ' change direction or value?
      Mode = Mo
      Mask = 1 SHL (r AND 31)
      setGpioSs()
    END IF                                                      : RETURN .setPin(Top, Ball, Mo)
  END WITH
END FUNCTION


/'* \brief Set registers in GPIO subsystem

This procedure writes new values to the related registers of the GPIO
subsystem to specify the required direction (in or out), and in case of
output the required state (low or high). It's low-level and private,
not intended for public usage.

\since 0.6.4
'/
SUB GpioUdt.setGpioSs()
  WITH *Conf(Indx)
    IF BIT(Mode, 5) THEN '          input Ball
      .OE OR= Mask
      .CLEARDATAOUT AND= NOT Mask
      .SETDATAOUT   AND= NOT Mask
    ELSE '                         output Ball
      .OE AND= NOT Mask
      IF BIT(Mode, 7) THEN '          set high
        .CLEARDATAOUT AND= NOT Mask
        .SETDATAOUT    OR= Mask
      ELSE '                           set low
        .CLEARDATAOUT  OR= Mask
        .SETDATAOUT   AND= NOT Mask
      END IF
    END IF
  END WITH
  WITH *Top
    IF .DRam[0] > PRUIO_MSG_IO_OK                          THEN EXIT SUB

    PruReady(1) ' wait, if PRU is busy (should never happen)
    .DRam[5] = Conf(Indx)->OE
    .DRam[4] = Conf(Indx)->SETDATAOUT
    .DRam[3] = Conf(Indx)->CLEARDATAOUT
    .DRam[2] = Conf(Indx)->DeAd + &h100
    .DRam[1] = PRUIO_COM_GPIO_CONF SHL 24
  END WITH
END SUB


/'* \brief Set the state of a GPIO.
\param Ball The CPU ball number to test.
\param Mo The state to set (0 = low, high otherwise).
\returns Zero on success (otherwise a pointer to an error message).

This function is used to set the state of an output GPIO. Set parameter
`Ball` to the required header pin (=CPU ball) by using the convenience
macros defined in(ie. P8_03 selects pin 3 on header P8). Use
pruio_pins_pocket.bi or pruio_pins_blue.bi for Pocket Beaglebone or
Beaglebone Blue boards.

Parameter `Mo` specifies either the state to set (0 or 1). Or it
specifies the pinmux mode to test and the state in the MSB.

Wrapper function (C or Python): pruio_gpio_setValue().

\since 0.2
'/
FUNCTION GpioUdt.setValue CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Mo AS UInt8 = 0) AS ZSTRING PTR

  WITH *Top
    BallCheck(" GPIO output", .Errr)
    VAR r = .BallGpio(Ball)  ' resulting GPIO (index and bit number)
    Indx = r SHR 5 : IF 2 <> Conf(Indx)->ClVa   THEN .Errr = E0 : RETURN .Errr ' GPIO subsystem not enabled
    Mask = 1 SHL (r AND 31)
    SELECT CASE AS CONST Mo
    CASE 0    : Mode = PRUIO_GPIO_OUT0 : r = .BallConf[Ball] XOR Mode
    CASE 1    : Mode = PRUIO_GPIO_OUT1 : r = .BallConf[Ball] XOR Mode
    CASE 255  : Mode = .BallInit[Ball] : r = Mo ' reset
    CASE ELSE : IF &b111 <> (Mo AND &b111)      THEN .Errr = E1 : RETURN .Errr ' no Gpio mode
                Mode = Mo              : r = .BallConf[Ball] XOR Mo
    END SELECT
    IF r AND &b10100000 THEN setGpioSs() ' i/o or state changed -> configure GPIO subsystem
    IF r AND &b01011000 THEN _ '         receiver or resistor changed -> pinmux
      IF .setPin(Top, Ball, Mode) THEN _ ' error -> re-conf and report error
                           Mode = .BallConf[Ball] : setGpioSs() : RETURN .Errr
    /' all OK, set new mode '/           .BallConf[Ball] = Mode : RETURN 0
  END WITH
END FUNCTION


/'* \brief Get the state of a GPIO.
\param Ball The CPU ball number to test.
\returns The GPIO state (otherwise -1, check PruIo::Errr for an error message).

This function is used to get the state of a digital pin (GPIO). Use the
macros defined in pruio.bi to specify the pin number in parameter
`Ball` for a pin on the Beaglebone headers (ie P8_03 selects pin 3 on
header P8).

It's possible to get the state of a CPU ball (not connected to a
header), also. In this case you need to find the matching CPU ball
number and pass it in as the parameter `Ball`.

The function returns the state of input and output pins. Return values
are

| Value | Description                   |
| ----: | :---------------------------- |
| 1     | GPIO is in high state         |
| 0     | GPIO is in low state          |
| -1    | error (undefined ball number) |

Wrapper function (C or Python): pruio_gpio_Value().

\since 0.2
'/
FUNCTION GpioUdt.Value CDECL(BYVAL Ball AS UInt8) AS Int32
  WITH *Top
    BallCheck(" GPIO input", -1)
    VAR r = .BallGpio(Ball) _ ' resulting GPIO (index and bit number)
      , i = r SHR 5 _         ' index of GPIO
      , n = r AND 31          ' number of bit
    IF 2 <> Conf(i)->ClVa THEN                       .Errr = E0 : RETURN -1 ' GPIO subsystem not enabled
    IF &b111 <> (.BallConf[Ball] AND &b111) THEN     .Errr = E2 : RETURN -1 ' no GPIO pin
                                   RETURN IIF(BIT(Raw(i)->Mix, n), 1, 0)
  END WITH
END FUNCTION
