/'* \file button.bas
\brief Example: get state of a button.

This file contains an example on how to use libpruio to get the state
of a button connetect to a GPIO pin on the beaglebone board. Here pin 7
on header P8 is used as input with pullup resistor. Connect the button
between P8_07 (GPIO input) and P8_01 (GND). Find a functional
description in section \ref sSecExaButton.

Licence: GPLv3, Copyright 2014-\Year by \Mail

Compile by: `fbc -w all button.bas`

\since 0.0.2
'/

' include libpruio
#INCLUDE ONCE "BBB/pruio.bi"
' include the convenience macros for header pins
#INCLUDE ONCE "BBB/pruio_pins.bi"

'* The header pin to use.
#DEFINE PIN P8_07

' *****  main  *****

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup devices.

WITH *io
  DO
    IF .Errr THEN    ?"initialisation failed (" & *.Errr & ")" : EXIT DO
    IF .config() THEN        ?"config failed (" & *.Errr & ")" : EXIT DO
    DO '                           print current state (until keystroke)
      ?!"\r" & .Gpio->Value(PIN);
      SLEEP 100
    LOOP UNTIL LEN(INKEY()) : ?
  LOOP UNTIL 1

  IF .Errr THEN ?"press any key to quit" : SLEEP
END WITH

DELETE io '                    reset ADC, PinMux and GPIOs, clear memory

'' help Doxygen to document the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); GpioUdt::config(); PruIo::config(); GpioUdt::Value(); PruIo::~PruIo();}
