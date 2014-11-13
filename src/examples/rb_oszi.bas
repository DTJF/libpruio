/'* \file rb_oszi.bas
\brief Example: fetch ADC samples in a ring buffer and draw graf.

This file contains an example on how to use the ring buffer mode of
libpruio. A fixed step mask of AIN-4 and AIN-7 get sampled and drawn as
a line graf to a grafic window. Unlike IO mode, the step
mask cannot get changed in RB mode at run-time.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `fbc -w all rb_oszi.bas`

\since 0.2
'/

' include libpruio
#INCLUDE ONCE "../pruio/pruio.bi"
' include FreeBASIC grafics
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

'* Macro to draw a graph from the valid half of the ring buffer.
#MACRO DRAW_GRAF()
  LINE (0, 0) - (S_W, S_H), RGB(250, 250, 250), BF
  FOR c AS INTEGER = 0 TO .Adc->ChAz - 1
    VAR i = c + .Adc->ChAz
    LINE (0, S_H - CUINT(p[c] * scale)) - _
         (1, S_H - CUINT(p[i] * scale)), col(c)
    FOR x AS INTEGER = 2 TO S_W
      i += .Adc->ChAz
      LINE - (x, S_H - CUINT(p[i] * scale)), col(c)
    NEXT
  NEXT
#ENDMACRO

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  DO
    IF .Errr THEN ?"NEW failed: " & *.Errr : EXIT DO

    VAR samp = S_W SHL 1 '*< The number of samples to fetch (ring buffer size).
    S_W -= 1
    S_H -= 1
    VAR scale = S_H / 65520 '*< The scaling factor.

    IF .config(samp, &b100100000, 4e5) THEN _ '      configure steps 5+8
                                   ?"config failed: " & *.Errr : EXIT DO

    VAR half = .Adc->Samples SHR 1 _ '*< The half size of the ring buffer.
         , p = .Adc->Value           '*< A (local) pointer to the samples.
    IF .rb_start() THEN _ '                       start ring buffer mode
                                 ?"rb_start failed: " & *.Errr : EXIT DO

    DO '                                  read ring buffer and draw graf
      WHILE .DRam[0] < half : WEND
      DRAW_GRAF()
      p += half
      SCREENSET 0, 1

      WHILE .DRam[0] > half : WEND
      DRAW_GRAF()
      p -= half
      SCREENSET 1, 0
    LOOP UNTIL LEN(INKEY()) : ?
  LOOP UNTIL 1
  IF .Errr THEN SLEEP
END WITH

DELETE(io)

'' help Doxygen to dokument the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); PruIo::config(); PruIo::~PruIo();}
