/'* \file analyse.bas
\brief Example: analyse the subsystems configurations.

This file contains an example on how to use libpruio to read the
configurations of the subsystems (initial and corrent). It creates a
PruIo structure containing the data and then prints out in a
human-readable form. You may 'borrow' some code for debugging purposes
in your code.

Licence: GPLv3, Copyright 2014-\Year by \Mail

Compile by: `fbc -w all analyse.bas`

\since 0.0
'/

' include libpruio
#INCLUDE ONCE "BBB/pruio.bi"
' include the convenience macros for header pins
#INCLUDE ONCE "BBB/pruio_pins.bi"
' include macros to print out register context
#INCLUDE ONCE "BBB/pruio_out.bi"

'' Output all CPU balls or just header pins?
'#DEFINE __ALL_BALLS__

'* The type of the output (either Init or Conf).
#DEFINE  OUT_TYPE Init ' alternative: Conf

' *****  main  *****

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  IF .Errr THEN
    ?"initialisation failed (" & *.Errr & ")"
  ELSE
#IFDEF __ALL_BALLS__
    BALL_OUT(OUT_TYPE)
#ELSE
    ?"Header Pins:"
    FOR i AS LONG = 0 TO UBOUND(P8_Pins)
      ?"  " & *.Pin(P8_Pins(i))
    NEXT
    FOR i AS LONG = 0 TO UBOUND(P9_Pins)
      ?"  " & *.Pin(P9_Pins(i))
    NEXT
    ?"  " & *.Pin(JT_04)
    ?"  " & *.Pin(JT_05)
#ENDIF

    GPIO_OUT(OUT_TYPE)
    ADC_OUT(OUT_TYPE)
    PWMSS_OUT(OUT_TYPE)
    TIMER_OUT(OUT_TYPE)
  END IF
END WITH

DELETE io '                    reset ADC, PinMux and GPIOs, clear memory

'' help Doxygen to document the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); PruIo::~PruIo();}
