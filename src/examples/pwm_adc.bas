/'* \file pwm_adc.bas
\brief Example: generate PWM outputs and fetch them as ADC samples, draw graf.

This file contains an example on how to use libpruio to generate pulse
width modulated (PWM) output. Here the two channels (A + B) of an
eHRPWM module and a eCAP module (in PWM) mode generate the PWM signal.
The output can get measured by the ADC subsystem at channels AIN-0 to
AIN-2 and shown as a line graf in a graphics windows.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `fbc -w all pwm_adc.bas`

'/

' include libpruio
#INCLUDE ONCE "../pruio/pruio.bi"
' include the convenience macros for header pins
#INCLUDE ONCE "../pruio/pruio_pins.bi"
' include FB grafics
#INCLUDE ONCE "fbgfx.bi"

VAR S_W = 0 _ '*< The screen width.
  , S_H = 0 _ '*< The srceen hight
  , BPP = 0 _ '*< The bits per plain number.
  , full = fb.GFX_FULLSCREEN '*< Fullscreen or windowed mode.
SCREENINFO S_W, S_H, BPP '                         get screen resolution

IF LEN(COMMAND) THEN '                   customized resolution required?
  VAR p = INSTR(COMMAND, "x") _       '*< The position of the 'x' character (if any).
    , w = VALINT(COMMAND) _           '*< The required window width.
    , h = VALINT(MID(COMMAND, p + 1)) '*< The required window hight.
  IF p ANDALSO w ANDALSO h THEN
    IF w < S_W - 4 ANDALSO h < S_H - 24 THEN full = fb.GFX_WINDOWED
    S_W = IIF(w < S_W, w, S_W) '           set maximum custom resolution
    S_H = IIF(h < S_H, h, S_H)
  ELSE
    PRINT "set resolution like 640x400"
    END
  END IF
END IF

SCREENRES S_W, S_H, BPP, 2, full '                 set screen resolution
IF 0 = SCREENPTR THEN                  PRINT "no grafic available" : END

'* The colors for the lines (= channels).
DIM AS UInt32 _
  col(...) = { _
    RGBA(255,   0,   0, 255) _
  , RGBA(  0, 255,   0, 255) _
  , RGBA(  0,   0, 255, 255) _
    }

'* The previous data of the channels.
DIM AS UInt32 _
  last(...) = { _
    0 _
  , 0 _
  , 0 _
  , 0 _
  , 0 _
  , 0 _
  , 0 _
  , 0 _
    }

'* UDT to hold data for an output channel
TYPE PWM_PIN
  AS UInt8 _
    Pin        '*< The ball number.
  AS Float_t _
    Freq _     '*< The frequency to set.
  , Duty       '*< The duty cycle.
  AS ZSTRING PTR _
    Nam        '*< The name of the header pin.
END TYPE

'* The structures for the output pins.
DIM AS PWM_PIN ch(...) = { _
    TYPE<PWM_PIN>(P9_14, 2.5, .5, @"P9_14 (A)") _
  , TYPE<PWM_PIN>(P9_16, 2.5, .2, @"P9_16 (B)") _
  , TYPE<PWM_PIN>(P9_42, 2.5, .8, @"P9_42 (C)") _
  }

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  DO
    IF .Errr THEN ?"NEW failed: " & *.Errr : EXIT DO

    FOR i AS INTEGER = 0 TO UBOUND(ch) '              configure PWM pins
      IF .Pwm->setValue(ch(i).Pin, ch(i).Freq, ch(i).Duty) THEN _
         ?"failed setting " & *ch(i).nam & " (" & *.Errr & ")" : EXIT DO
    NEXT

    IF .config(1, &b1110) THEN _ ' configure steps 1, 2, 3 (AIN-[0,1,2])
      ?"config failed: " & *.Errr & " --> " & .DRam[0] : SLEEP : EXIT DO

    VAR scale = S_H / 65520 _   '*< The factor to scale values.
          , x = 0 _             '*< The start x position.
        , gap = 1 _             '*< The gap between x values.
       , xmax = S_W - gap - 1 _ '*< The maximal x position.
          , m = 0 _             '*< The mask for in-active channels.
          , n = 2 _             '*< The active channel number.
         , fg = RGB(0, 0, 0) _      '*< The foreground color.
         , bg = RGB(250, 250, 250)  '*< The background color.
    FOR i AS INTEGER = 0 TO UBOUND(ch) '                get start values
      last(i) = S_H - CUINT(.Adc->Value[i + 1] * scale)
    NEXT

    WINDOWTITLE(*ch(n).nam _
            & ": Frequency = " & ch(n).Freq & " Hz" _
            & ", Duty = " & (ch(n).Duty) * 100) & "%"
    COLOR fg, bg
    CLS
    DO
      VAR k = ASC(INKEY()) '*< The key code.
      IF k THEN
        SELECT CASE AS CONST k '                react on user keystrokes
        CASE ASC("A"), ASC("a") : m = BITRESET(&hFF, 0): n = 256 'PWMSS 1, output PWM-A (P9_14)
        CASE ASC("B"), ASC("b") : m = BITRESET(&hFF, 1): n = 257 'PWMSS 1, output PWM-B (P9_16)
        CASE ASC("C"), ASC("c") : m = BITRESET(&hFF, 2): n = 258 'PWMSS 0, output eCAP  (P9_42)
        CASE ASC("0") : m = BITRESET(&hFF, n) : ch(n).Duty = 0.0
        CASE ASC("1") : m = BITRESET(&hFF, n) : ch(n).Duty = 0.1
        CASE ASC("2") : m = BITRESET(&hFF, n) : ch(n).Duty = 0.2
        CASE ASC("3") : m = BITRESET(&hFF, n) : ch(n).Duty = 0.3
        CASE ASC("4") : m = BITRESET(&hFF, n) : ch(n).Duty = 0.4
        CASE ASC("5") : m = BITRESET(&hFF, n) : ch(n).Duty = 0.5
        CASE ASC("6") : m = BITRESET(&hFF, n) : ch(n).Duty = 0.6
        CASE ASC("7") : m = BITRESET(&hFF, n) : ch(n).Duty = 0.7
        CASE ASC("8") : m = BITRESET(&hFF, n) : ch(n).Duty = 0.8
        CASE ASC("9") : m = BITRESET(&hFF, n) : ch(n).Duty = 0.9
        CASE ASC(",") : m = BITRESET(&hFF, n) : ch(n).Duty = 1.0
        CASE ASC("+") : IF ch(n).Freq < 5.0 THEN ch(n).Freq += .5
        CASE ASC("-") : IF ch(n).Freq > 0.9 THEN ch(n).Freq -= .5
        CASE ASC("*") : ch(n).Freq = 5.0
        CASE ASC("/") : ch(n).Freq = .5
        CASE 13 : m = 0 : n += 256
        CASE ELSE : EXIT DO '                                     finish
        END SELECT

        IF n > UBOUND(ch) THEN
          n -= 256
        ELSE
          IF .Pwm->setValue(ch(n).Pin, ch(n).Freq, ch(n).Duty) THEN _
                  ?"failed setting PWM value (" & *.Errr & ")" : EXIT DO
        END IF

        WINDOWTITLE(*ch(n).nam _
            & ": Frequency = " & ch(n).Freq & " Hz" _
            & ", Duty = " & (ch(n).Duty) * 100) & "%"
      END IF

      LINE (x + 1, 0) - STEP (gap, S_H), bg, BF
      FOR i AS INTEGER = 0 TO UBOUND(ch) '                    draw lines
        IF BIT(m, i) THEN CONTINUE FOR
        VAR neu = S_H - CUINT(.Adc->Value[i + 1] * scale) '*< The new value.
        LINE (x, last(i)) - (x + gap, neu), col(i)
        last(i) = neu
        LINE (0, 0) - STEP (gap, S_H), 0, BF
      NEXT
      x += gap : IF x > xmax THEN x = 0
      SLEEP 1
    LOOP : ?
  LOOP UNTIL 1
  IF .Errr THEN SLEEP
END WITH

DELETE(io)

'' help Doxygen to dokument the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); PwmMod::setValue(); PruIo::config(); PruIo::~PruIo();}
