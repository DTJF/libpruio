/'* \file io_input.bas
\brief Example: print digital and analog inputs.

This file contains an example on how to use libpruio to print out the
state of the digital GPIOs and the analog input lines.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `fbc -w all io_input.bas`

'/

' include libpruio
#INCLUDE ONCE "../pruio/pruio.bi"


' *****  main  *****

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  DO '                                  pseudo loop, just to avoid GOTOs
    IF .Errr THEN    ?"initialisation failed (" & *.Errr & ")" : EXIT DO

'                  transfer default settings to PRU and start in IO mode
    IF .config() THEN        ?"config failed (" & *.Errr & ")" : EXIT DO

    ?"   .   |   .   |   .   |   .   |"
    ?:?:?:?:?
    VAR x = POS() _      '*< The cursor column for output.
      , y = CSRLIN() - 5 '*< The cursor line for output.
    DO '                           print current state (until keystroke)
      LOCATE y, x, 0
      ?BIN(.Gpio->Raw(0)->Mix, 32) '                              GPIOs 0 - 3
      ?BIN(.Gpio->Raw(1)->Mix, 32)
      ?BIN(.Gpio->Raw(2)->Mix, 32)
      ?BIN(.Gpio->Raw(3)->Mix, 32)
      ?HEX(.Adc->Value[1], 4) & " " & _ '                           AIN 0 - 7
       HEX(.Adc->Value[2], 4) & " " & _
       HEX(.Adc->Value[3], 4) & " " & _
       HEX(.Adc->Value[4], 4) & "  " & _
       HEX(.Adc->Value[5], 4) & " " & _
       HEX(.Adc->Value[6], 4) & " " & _
       HEX(.Adc->Value[7], 4) & " " & _
       HEX(.Adc->Value[8], 4);
    LOOP UNTIL LEN(INKEY())
    ?
  LOOP UNTIL 1
END WITH

DELETE io '                    reset ADC, PinMux and GPIOs, clear memory

'' help Doxygen to dokument the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); PruIo::config(); PruIo::~PruIo();}
