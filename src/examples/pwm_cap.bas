/'* \file pwm_cap.bas
\brief Example: PWM output and CAP input.

This file contains an example on how to measure the frequency and duty
cycle of a pulse train with a eCAP module input. The program sets
another pin as eHRPWM output to generate a pulse width modulated signal
as source for the measurement. The output can be changed by some keys,
the frequency and duty cycle of the input is shown continously in the
terminal output.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `fbc -w all pwm_cap.bas`

'/

' include libpruio
#INCLUDE ONCE "../pruio/pruio.bi"
' include the convenience macros for header pins
#INCLUDE ONCE "../pruio/pruio_pins.bi"

'* The pin for PWM output.
#DEFINE P_OUT P9_21
'* The pin for CAP input.
#DEFINE P_IN P9_42

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  DO
    IF .Errr THEN ?"NEW failed: " & *.Errr : EXIT DO

    IF .Cap->config(P_IN, 2.) THEN _ '               configure input pin
                ?"failed setting input @P_IN (" & *.Errr & ")" : EXIT DO

    DIM AS Float_t _
        f1 _ '*< Variable for calculated frequency.
      , d1 _ '*< Variable for calculated duty cycle.
      , f0 = 31250 _ '*< The required frequency.
      , d0 = .5      '*< The required duty cycle.
    IF .Pwm->setValue(P_OUT, f0, d0) THEN _
              ?"failed setting output @P_OUT (" & *.Errr & ")" : EXIT DO

    IF .config(1, 2) THEN _ '                upload configuration to PRU
                                   ?"config failed: " & *.Errr : EXIT DO

    WHILE 1
      VAR k = ASC(INKEY()) '*< The key code.
      IF k THEN
        SELECT CASE AS CONST k '                react on user keystrokes
        CASE ASC("0") : d0 = 0.0
        CASE ASC("1") : d0 = 0.1
        CASE ASC("2") : d0 = 0.2
        CASE ASC("3") : d0 = 0.3
        CASE ASC("4") : d0 = 0.4
        CASE ASC("5") : d0 = 0.5
        CASE ASC("6") : d0 = 0.6
        CASE ASC("7") : d0 = 0.7
        CASE ASC("8") : d0 = 0.8
        CASE ASC("9") : d0 = 0.9
        CASE ASC(",") : d0 = 1.0
        CASE ASC("*") : f0 = IIF(f0 < 1000000, f0 * 2, 1000000.)
        CASE ASC("/") : f0 = IIF(f0 > .5, f0 / 2, .5)
        CASE ASC("m") : f0 = IIF(f0 > 5.5, f0 - 5., .5)
        CASE ASC("p") : f0 = IIF(f0 < 999995., f0 + 5., 1000000.)
        CASE ASC("+") : f0 = 1000000
        CASE ASC("-") : f0 = .5
        CASE ELSE : EXIT WHILE '                                  finish
        END SELECT

        IF .Pwm->setValue(P_OUT, f0, d0) THEN _ '         set new output
              ?"failed setting PWM output (" & *.Errr & ")" : EXIT WHILE

        ?!"\n--> " & LEFT("Frequency: " & f0 & SPACE(10), 20) _
                   & LEFT(", Duty: " & d0 & SPACE(10), 20) '   user info
      END IF

      IF .Cap->Value(P_IN, @f1, @d1) THEN _ '          get current input
             ?"failed reading input @P_IN (" & *.Errr & ")" : EXIT WHILE

      ?!"\r    " & LEFT("Frequency: " & f1 & SPACE(10), 20) _
                 & LEFT(", Duty: " & d1 & SPACE(10), 20); '    user info
      SLEEP 1
    WEND : ?
  LOOP UNTIL 1
END WITH

DELETE(io)

'' help Doxygen to dokument the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); CapMod::config(); PruIo::config(); CapMod::Value(); PwmMod::setValue(); PruIo::~PruIo();}
