/'* \file 1.bas
\brief Example: minimal code for ADC input.

This file contains an short and simple example for text output of the
analog input lines. It's designed for the description pages and shows
the basic usage of libpruio with a minimum of source code, translatable
between FreeBASIC and C.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `fbc -w all 1.bas`

'/


'#INCLUDE ONCE "../pruio/pruio.bas" '   include source
#INCLUDE ONCE "../pruio/pruio.bi" '   include header
VAR io = NEW PruIo()              '*< create new driver UDT

IF io->config() THEN '          upload (default) settings, start IO mode
                                PRINT"config failed (" & *io->Errr & ")"
ELSE
'' now current ADC samples are available for AIN0 to AIN7 in array Adc->Value[]

  FOR n AS LONG = 1 TO 13 ''                            print some lines
    FOR i AS LONG = 1 TO 8 ''                                  all steps
      PRINT " " & HEX(io->Adc->Value[i], 4); ''output one channel in hex
    NEXT
    PRINT ''                                                   next line
  NEXT
END IF

'' we're done

DELETE io                         '   destroy driver UDT

'' help Doxygen to dokument the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); PruIo::config(); PruIo::~PruIo();}
