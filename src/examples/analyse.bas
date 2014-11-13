/'* \file analyse.bas
\brief Example: analyse the subsystems configurations.

This file contains an example on how to use libpruio to read the
configurations of the subsystems (initial and corrent). It creates a
PruIo structure containing the data and then prints out in a
human-readable form. You may 'borrow' some code for debugging purposes
in your code.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `fbc -w all analyse.bas`

'/

' include libpruio
#INCLUDE ONCE "../pruio/pruio.bi"
'~ #INCLUDE ONCE "../pruio/pruio.bas"
' include the convenience macros for header pins
#INCLUDE ONCE "../pruio/pruio_pins.bi"
' include macros to print out register context
#INCLUDE ONCE "../pruio/pruio_out.bi"

  '* The type of the output (either Inint or Conf).
#define OUT_TYPE Init ' alternative: Conf

' *****  main  *****

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  IF .Errr THEN
    ?"initialisation failed (" & *.Errr & ")"
  ELSE
#IF __ALL_PINS__
    BALL_OUT(OUT_TYPE)
#ELSE
    ?"Header Pins:"
    FOR i AS LONG = 0 TO UBOUND(P8_Pins)
      ?"  " & *.Pin(P8_Pins(i))
    NEXT
    FOR i AS LONG = 0 TO UBOUND(P9_Pins)
      ?"  " & *.Pin(P9_Pins(i))
    NEXT
#ENDIF

    GPIO_OUT(OUT_TYPE)
    ADC_OUT(OUT_TYPE)
    PWMSS_OUT(OUT_TYPE)
  END IF
END WITH

DELETE io '                    reset ADC, PinMux and GPIOs, clear memory

'' help Doxygen to dokument the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); PruIo::~PruIo();}
