/'* \file button.bas
\brief Example: get state of a button.

This file contains an example on how to use libpruio to get the state
of a button connetect to a GPIO pin on the beaglebone board. Here pin 7
on header P8 is used as input with pullup resistor. Connect the button
between P8_07 (GPIO input) and P8_01 (GND).

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `fbc -w all button.bas`

'/

' include libpruio
#INCLUDE ONCE "../pruio/pruio.bi"
' include the convenience macros for header pins
#INCLUDE ONCE "../pruio/pruio_pins.bi"

'* The header pin to use.
#DEFINE PIN P8_07

' *****  main  *****

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup devices.

WITH *io
  DO
    IF .Errr THEN    ?"initialisation failed (" & *.Errr & ")" : EXIT DO

    IF .Gpio->config(PIN, PRUIO_GPIO_IN_1) THEN _ '        configure pin
                  ?"pin configuration failed (" & *.Errr & ")" : EXIT DO

    IF .config() THEN _
                             ?"config failed (" & *.Errr & ")" : EXIT DO

    DO '                           print current state (until keystroke)
      ?!"\r" & .Gpio->Value(PIN);
      SLEEP 100
    LOOP UNTIL LEN(INKEY()) : ?
  LOOP UNTIL 1
  IF .Gpio->config(PIN, PRUIO_PIN_RESET) THEN _ '       re-configure pin
                         ?"pin re-configuration failed (" & *.Errr & ")"

  IF .Errr THEN ?"press any key to quit" : SLEEP
END WITH

DELETE io '                    reset ADC, PinMux and GPIOs, clear memory

'' help Doxygen to dokument the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); GpioUdt::config(); PruIo::config(); GpioUdt::Value(); PruIo::~PruIo();}
