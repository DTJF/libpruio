/'* \file pruio_gpio.bas
\brief The GPIO component source code.

Source code file containing the function bodies of the GPIO component.

'/


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
      , p_val = CAST(ANY PTR, .DRam) + PRUIO_DAT_GPIO' + offsetof(GpioArr, Mix)

    FOR i AS LONG = 0 TO PRUIO_AZ_GPIO
      Raw(i) = p_val
      p_val += SIZEOF(GpioArr)

      Init(i) = p_mem
      Conf(i) = p_mem + .DSize

      WITH *Conf(i)
        IF .ClAd = 0 ORELSE _
           .REVISION = 0 THEN _ '                  subsystem not enabled
             .DeAd = 0 : .ClVa = 0 : p_mem += 16 : CONTINUE FOR
        .ClVa = 2
        .CLEARDATAOUT = 0
        .SETDATAOUT = 0
      END WITH

      WITH *Init(i)
        .CLEARDATAOUT = 0
        .SETDATAOUT = 0
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
*Ball* for a pin on the Beaglebone headers (ie P8_03 selects pin 3 on
header P8).

Its not possible to set the state of a CPU ball (not connected to a
header), because only header pins are prepared for pinmuxing in the
libpruio device tree overlay.

Parameter *Modus* specifies the pinmux mode for the ARM control module
(see \ArmRef{9} for details). By default the pin gets configured as input pin
with pulldown resistor. Other configurations are prepared
as enumerators PruIo::PinMuxing :

| macro name       | Description                              |
| ---------------: | :--------------------------------------- |
| PRUIO_GPIO_IN    | open input pin (no resistor)             |
| PRUIO_GPIO_IN_0  | low input pin (with pulldown resistor)   |
| PRUIO_GPIO_IN_1  | high input pin (with pullup resistor)    |
| PRUIO_GPIO_OUT0  | output pin set to low (no resistor)      |
| PRUIO_GPIO_OUT1  | output pin set to high (no resistor)     |

'/
FUNCTION GpioUdt.config CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Mo AS UInt8 = CAST(UInt8, PRUIO_GPIO_IN_0)) AS ZSTRING PTR
  WITH *Top
    BallCheck(" GPIO", .Errr)
    IF 7 <> (Mo AND &b111) THEN         .Errr = @"no GPIO mode" : RETURN .Errr
    VAR r = .BallGpio(Ball) _ ' resulting GPIO (index and bit number)
      , i = r SHR 5 _         ' index of GPIO
      , n = r AND 31 _        ' number of bit
      , m = 1 SHL n           ' mask for bit
    IF 2 <> Conf(i)->ClVa THEN                       .Errr = E0 : RETURN .Errr ' GPIO subsystem not enabled

    VAR x = Mo AND &b1111111
    IF x <> .BallConf[Ball] THEN IF .setPin(Ball, x) THEN         RETURN .Errr
    IF (x AND PRUIO_RX_ACTIV) = PRUIO_RX_ACTIV       THEN         RETURN 0 ' input, we're done

    WITH *Conf(i)
      IF BIT(Mo, 5) THEN '                                    input Ball
        .OE OR= m
        .CLEARDATAOUT AND= NOT m
        .SETDATAOUT   AND= NOT m
        m = 0
      ELSE '                                                 output Ball
        .OE AND= NOT m
        IF BIT(Mo, 7) THEN '                                    set high
          .CLEARDATAOUT AND= NOT m
          .SETDATAOUT    OR= m
        ELSE '                                                   set low
          .CLEARDATAOUT  OR= m
          .SETDATAOUT   AND= NOT m
        END IF
      END IF
    END WITH
    IF .DRam[0] > PRUIO_MSG_IO_OK THEN                            RETURN 0

    WHILE .DRam[1] : WEND '   wait, if PRU is busy (should never happen)
    .DRam[5] = Conf(i)->OE
    .DRam[4] = Conf(i)->SETDATAOUT
    .DRam[3] = Conf(i)->CLEARDATAOUT
    .DRam[2] = Conf(i)->DeAd + &h100
    .DRam[1] = PRUIO_COM_GPIO_CONF SHL 24
  END WITH :                                                      RETURN 0
END FUNCTION


/'* \brief Set the state of a GPIO.
\param Ball The CPU ball number to test.
\param Mo The state to set (0 = low, high otherwise).
\returns Zero on success (otherwise a pointer to an error message).

This function is used to set the state of an output GPIO. Set parameter
*Ball* to the required header pin (=CPU ball) by using the convenience
macros defined in pruio_pins.bi (ie. P8_03 selects pin 3 on header P8).

Parameter *Mo* specifies either the state to set (0 or 1). Or it specifies the pinmux mode and the state.

'/
FUNCTION GpioUdt.setValue CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Mo AS UInt8 = 0) AS ZSTRING PTR

  WITH *Top
    BallCheck(" GPIO output", .Errr)
    VAR r = .BallGpio(Ball) _  ' resulting GPIO (index and bit number)
      , i = r SHR 5 _          ' index of GPIO
      , m = 1 SHL (r AND 31) _ ' mask for bit
      , x = IIF(Mo > 1, Mo AND &b1111111, PRUIO_GPIO_OUT0) '*< the pinmux mode

    IF 2 <> Conf(i)->ClVa THEN                 .Errr = E0 : RETURN .Errr ' GPIO subsystem not enabled
    IF x AND &b111 <> 7 THEN                   .Errr = E1 : RETURN .Errr ' no GPIO mode
    IF .BallConf[Ball] <> x THEN _
      IF .setPin(Ball, x) THEN                              RETURN .Errr ' pinmux failed

    IF Mo = 1 ORELSE BIT(Mo, 7) THEN
      Conf(i)->CLEARDATAOUT AND= NOT m
      Conf(i)->SETDATAOUT    OR= m
    ELSE
      Conf(i)->CLEARDATAOUT  OR= m
      Conf(i)->SETDATAOUT   AND= NOT m
    END IF

    IF .DRam[0] > PRUIO_MSG_IO_OK THEN                          RETURN 0

    WHILE .DRam[1] : WEND '   wait, if PRU is busy (should never happen)
    .DRam[4] = Conf(i)->SETDATAOUT
    .DRam[3] = Conf(i)->CLEARDATAOUT
    .DRam[2] = Conf(i)->DeAd + &h100
    .DRam[1] = PRUIO_COM_GPIO_OUT SHL 24
  END WITH :                                                    RETURN 0
END FUNCTION


/'* \brief Get the state of a GPIO.
\param Ball The CPU ball number to test.
\returns The GPIO state (otherwise -1, check PruIo::Errr for an error message).

This function is used to get the state of a digital pin (GPIO). Use the
macros defined in pruio.bi to specify the pin number in parameter
*Ball* for a pin on the Beaglebone headers (ie P8_03 selects pin 3 on
header P8).

It's possible to get the state of a CPU ball (not connected to a
header), also. In this case you need to find the matching CPU ball
number and pass it in as the parameter *Ball*.

The function returns the state of input and output pins. Return values
are

| Value | Description                   |
| ----: | :---------------------------- |
| 1     | GPIO is in high state         |
| 0     | GPIO is in low state          |
| -1    | error (undefined ball number) |

'/
FUNCTION GpioUdt.Value CDECL(BYVAL Ball AS UInt8) AS Int32
  WITH *Top
    BallCheck(" GPIO input", -1)
    VAR r = .BallGpio(Ball) _ ' resulting GPIO (index and bit number)
      , i = r SHR 5 _         ' index of GPIO
      , n = r AND 31          ' number of bit
    IF 2 <> Conf(i)->ClVa THEN                    .Errr = E0 : RETURN -1 ' GPIO subsystem not enabled
    IF .BallConf[Ball] AND &b111 <> 7 THEN        .Errr = E1 : RETURN -1 ' no GPIO pin
                                   RETURN IIF(BIT(Raw(i)->Mix, n), 1, 0)
  END WITH
END FUNCTION
