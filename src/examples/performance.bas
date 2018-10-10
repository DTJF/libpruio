/'* \file performance.bas
\brief Example: test execution speed of several methods to toggle a GPIO pin.

This file contains an example on measuring the execution speed of
different controllers that toggles a GPIO output. It measures the
frequency of the toggled output from open and closed loop controllers
and computes their mimimum, avarage and maximum execution speed. Find a
functional description in section \ref sSecExaPerformance.

The code performs 50 tests of each controller version and outputs the
toggling frequencies in Hz at the end. The controllers are classified
by

-# Open loop
  - Direct GPIO
  - Function Gpio->Value
-# Closed loop
  - Input direct GPIO, output direct GPIO
  - Input function Gpio->Value, output direct GPIO
  - Input function Gpio->Value, output function Gpio->setValue
  - Input Adc->Value, output direct GPIO
  - Input Adc->Value, output function Gpio->Value

Licence: GPLv3, Copyright 2014-\Year by \Mail

Compile by: `fbc -w all performance.bas`

\since 0.4.0
'/

' include libpruio
#INCLUDE ONCE "BBB/pruio.bi"
' include the convenience macros for header pins
#INCLUDE ONCE "BBB/pruio_pins.bi"

'* The pin to use for CAP input.
#DEFINE C_IN P9_42
'* The pin to use for GPIO output.
#DEFINE GOUT P8_16
'* The pin to use for GPIO input.
#DEFINE G_IN P8_14

'* Macro to measure the frequency and compute statistics.
#MACRO FREQ(_N_)
  IF .Cap->Value(C_IN, @f0, NULL) THEN _ '                 get CAP input
                         ?"Cap->Value failed (" & *.Errr & ")" : EXIT DO
  sf(_N_) += f0
  IF f0 < nf(_N_) THEN nf(_N_) = f0
  IF f0 > xf(_N_) THEN xf(_N_) = f0
  ?f0,
  SLEEP 1
#ENDMACRO

'* Macro to set output pin by fast direct PRU command (no error checking).
#MACRO DIRECT(_O_)
  IF _O_ THEN
    cd AND= NOT m0
    sd  OR= m0
  ELSE
    cd  OR= m0
    sd AND= NOT m0
  END IF

  WHILE .DRam[1] : WEND '   wait, if PRU is busy (should never happen)
  .DRam[5] = oe
  .DRam[4] = sd
  .DRam[3] = cd
  .DRam[2] = ad
  .DRam[1] = PRUIO_COM_GPIO_CONF SHL 24
#ENDMACRO

'* Macro to set output by normal GPIO function (for better readability).
#DEFINE FUNC(_O_) IF .Gpio->setValue(GOUT, _O_) THEN _ ' set GPIO output
                      ?"GPIO setValue failed (" & *.Errr & ")" : EXIT DO


' *****  main  *****

VAR io = NEW PruIo(PRUIO_DEF_ACTIVE, 0, 0, 0) '*< Create a PruIo structure, wakeup devices.

WITH *io
  DO
    IF .Errr THEN    ?"initialisation failed (" & *.Errr & ")" : EXIT DO

    IF .Gpio->setValue(GOUT, 0) THEN _ '      configure GPIO output GOUT
                 ?"GOUT configuration failed (" & *.Errr & ")" : EXIT DO

    IF .Gpio->config(G_IN, PRUIO_GPIO_IN) THEN _ ' conf. GPIO input G_IN
                 ?"G_IN configuration failed (" & *.Errr & ")" : EXIT DO

    IF .Cap->config(C_IN, 1000) THEN _ '        configure CAP input C_IN
                 ?"C_IN configuration failed (" & *.Errr & ")" : EXIT DO

    IF .Adc->setStep(1, 0, 0, 0, 0) THEN _ '     configure fast Adc step
                        ?"ADC setStep failed (" & *.Errr & ")" : EXIT DO

    IF .config(1, 1 SHL 1) THEN _ '                        start IO mode
                             ?"config failed (" & *.Errr & ")" : EXIT DO

    DIM AS CONST ZSTRING PTR desc(...) = _ '*< A text description for the tests.
    { @"Open loop, direct GPIO" _
    , @"Open loop, function Gpio->Value" _
    , @"Closed loop, direct GPIO to direct GPIO" _
    , @"Closed loop, function Gpio->Value to direct GPIO" _
    , @"Closed loop, function Gpio->Value to function Gpio->setValue" _
    , @"Closed loop, Adc->Value to direct GPIO" _
    , @"Closed loop, Adc->Value to function Gpio->Value"}
    DIM AS Float_t _
        f0 _               '*< Variable for measured frequency.
      , nf(UBOUND(desc)) _ '*< The minimum frequencies.
      , xf(UBOUND(desc)) _ '*< The maximum frequencies.
      , sf(UBOUND(desc))   '*< The summe of measured frequencies (to compute avarage).
    DIM AS UInt32 _
        n = 0 _ '*< The counter for test cycles.
      , c = 3 _ '*< The number of cycles for each test.
     , r1 = .BallGpio(G_IN) _  '*< Resulting input GPIO (index and bit number).
     , g1 = r1 SHR 5 _         '*< Index of input GPIO.
     , m1 = 1 SHL (r1 AND 31) _'*< The bit number of input bit.
     , r0 = .BallGpio(GOUT) _  '*< Resulting output GPIO (index and bit number).
     , g0 = r0 SHR 5 _         '*< Index of output GPIO.
     , m0 = 1 SHL (r0 AND 31) _'*< Mask for output bit.
     , cd = 0 _                '*< Register value for CLEARDATAOUT.
     , sd = 0 _                '*< Register value for SETDATAOUT.
     , ad = .Gpio->Conf(g0)->DeAd + &h100 _ '*< Subsystem adress.
     , oe = .Gpio->Conf(g0)->OE '*< Output enable register.

    FOR i AS INTEGER = 0 TO UBOUND(desc) ' initialize minimum values
      nf(i) = 100e6
    NEXT

    FOR n = 0 TO 49 '                                  perform the tests
'' Open loop controllers
      FOR i AS INTEGER = 0 TO c
        DIRECT(1)
        DIRECT(0)
      NEXT
      FREQ(0) ' Open loop, direct GPIO

      FOR i AS INTEGER = 0 TO c
        FUNC(1) '                                   set GPIO output high
        FUNC(0) '                                    set GPIO output low
      NEXT
      FREQ(1) ' Open loop, function Gpio->Value

'' Closed loop controllers
      FOR i AS INTEGER = 0 TO c
        DIRECT(1) '                                 set GPIO output high
        WHILE  0 = (.Gpio->Raw(g1)->Mix AND m1) : WEND

        DIRECT(0) '                                  set GPIO output low
        WHILE m1 = (.Gpio->Raw(g1)->Mix AND m1) : WEND
      NEXT
      FREQ(2) ' Closed loop, direct GPIO to direct GPIO

      FOR i AS INTEGER = 0 TO c
        DIRECT(1) '                                 set GPIO output high
        WHILE .Gpio->Value(G_IN) < 1 : WEND

        DIRECT(0) '                                  set GPIO output low
        WHILE .Gpio->Value(G_IN) > 0 : WEND
      NEXT
      FREQ(3) ' Closed loop, function Gpio->Value to direct GPIO

      FOR i AS INTEGER = 0 TO c
        FUNC(1) '                                   set GPIO output high
        WHILE .Gpio->Value(G_IN) < 1 : WEND

        FUNC(0) '                                    set GPIO output low
        WHILE .Gpio->Value(G_IN) > 0 : WEND
      NEXT
      FREQ(4) ' Closed loop, function Gpio->Value to function Gpio->setValue

      FOR i AS INTEGER = 0 TO c
        DIRECT(1)
        WHILE .Adc->Value[1] <= &h7FFF : WEND

        DIRECT(0)
        WHILE .Adc->Value[1] >  &h7FFF : WEND
      NEXT
      FREQ(5) ' Closed loop, Adc->Value to direct GPIO

      FOR i AS INTEGER = 0 TO c
        FUNC(1) '                                   set GPIO output high
        WHILE .Adc->Value[1] <= &h7FFF : WEND

        FUNC(0) '                                    set GPIO output low
        WHILE .Adc->Value[1] >  &h7FFF : WEND
      NEXT
      FREQ(6) ' Closed loop, Adc->Value to function Gpio->Value
      ?
    NEXT
    ?"  Results:"
    FOR i AS INTEGER = 0 TO UBOUND(desc)
      ?*desc(i) & ":"
      ?"  Minimum: "; nf(i)
      ?"  Avarage: "; sf(i) / n
      ?"  Maximum: "; xf(i)
    NEXT : ?
  LOOP UNTIL 1
  IF .Errr THEN ?"press any key to quit" : SLEEP
END WITH

DELETE io '                    reset ADC, PinMux and GPIOs, clear memory

'' help Doxygen to document the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); GpioUdt::config(); PruIo::config(); CapMod::Value(); GpioUdt::Value(); GpioUdt::setValue(); PruIo::~PruIo();}

