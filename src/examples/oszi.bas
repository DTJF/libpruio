/'* \file oszi.bas
\brief Example: draw a graph of analog inputs.

This file contains an example on how to use libpruio to continuously
draw a graph of the sampled data from the analog input lines.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `fbc -w all oszi.bas`

'/

' include libpruio
#INCLUDE ONCE "../pruio/pruio.bi"
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
    RGBA(  0,   0,   0, 255) _
  , RGBA(255,   0,   0, 255) _
  , RGBA(  0, 255,   0, 255) _
  , RGBA(  0,   0, 255, 255) _
  , RGBA(255, 255,   0, 255) _
  , RGBA(255,   0, 255, 255) _
  , RGBA(  0, 255, 255, 255) _
  , RGBA(127, 127, 127, 255) _
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

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  DO '                                  pseudo loop, just to avoid GOTOs
    IF .Errr THEN               ?"New failed (" & *.Errr & ")" : EXIT DO

    IF .config() THEN        ?"config failed (" & *.Errr & ")" : EXIT DO

    WITH *.Adc
      S_H -= 1
      VAR scale = S_H / 65520 _ '*< The factor to scale values.
          , gap = 2 _           '*< The gap between x values.
           , fg = RGB(0, 0, 0) _      '*< The foreground color.
           , bg = RGB(250, 250, 250)  '*< The background color.
      FOR i AS INTEGER = 0 TO 7
        last(i) = S_H - CUINT(.Value[i + 1] * scale)
      NEXT

      COLOR fg, bg
      CLS
      DO
      VAR k = ASC(INKEY()) '*< The key code.
        IF k THEN '                                    handle user input
          VAR m = .Conf->STEPENABLE '*< The step mask.
          SELECT CASE AS CONST k
          CASE ASC("0") : m XOR= 1 SHL 1
          CASE ASC("1") : m XOR= 1 SHL 2
          CASE ASC("2") : m XOR= 1 SHL 3
          CASE ASC("3") : m XOR= 1 SHL 4
          CASE ASC("4") : m XOR= 1 SHL 5
          CASE ASC("5") : m XOR= 1 SHL 6
          CASE ASC("6") : m XOR= 1 SHL 7
          CASE ASC("7") : m XOR= 1 SHL 8
          CASE ASC("+") : m = &b111111110
          CASE ELSE : EXIT DO
          END SELECT
          IF m THEN
            .Conf->STEPENABLE = m
            WHILE .Top->DRam[1] : WEND ' PRU is busy (should not happen)
            .Top->DRam[2] = m
            .Top->DRam[1] = PRUIO_COM_ADC
          END IF
        END IF

        FOR x AS INTEGER = 0 TO S_W - gap STEP gap '          draw graph
          LINE (x + 1, 0) - STEP (gap, S_H), bg, BF
          FOR i AS INTEGER = 1 TO 8
            IF 0 = BIT(.Conf->STEPENABLE, i) THEN CONTINUE FOR
            VAR neu = S_H - CUINT(.Value[i] * scale) _ '*< The new sample.
                , j = i - 1                            '*< The channel index.
            LINE (x, last(j)) - (x + gap, neu), col(j)
            last(j) = neu
          NEXT
          LINE (0, 0) - STEP (gap, S_H), bg, BF
        NEXT
      LOOP
    END WITH
  LOOP UNTIL 1
  IF .Errr THEN ?"press any key to quit" : SLEEP
END WITH

DELETE io

'' help Doxygen to dokument the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); PruIo::config(); PruIo::~PruIo();}
