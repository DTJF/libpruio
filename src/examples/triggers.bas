/'* \file triggers.bas
\brief Example: start measurements in MM mode by triggers.

This file contains an example on how to use libpruio to measure analog
input and draw a graph of the sampled data. Triggering of measurement
can be done by different events.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `fbc -w all triggers.bas`

'/

' include libpruio
#INCLUDE ONCE "../pruio/pruio.bi"
' include the convenience macros for header pins
#INCLUDE ONCE "../pruio/pruio_pins.bi"
' include FreeBASIC grafics
#INCLUDE ONCE "fbgfx.bi"

'* define the pin to use for digital trigger
#DEFINE PIN P8_07
'* define the step number to use for analog trigger
#DEFINE STP 11

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

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  DO '                                  pseudo loop, just to avoid GOTOs
    IF .Errr THEN    ?"initialisation failed (" & *.Errr & ")" : EXIT DO


    IF .Gpio->config(PIN, PRUIO_GPIO_IN_1) THEN _ '   configure GPIO pin
                ?"failed setting trigger pin (" & *.Errr & ")" : EXIT DO

    IF .Adc->setStep(STP, 4, 0, 0, 0) THEN _ '   configure fast ADC step
               ?"failed setting trigger step (" & *.Errr & ")" : EXIT DO

'    config OK here, transfer local settings to PRU and start PRU driver
    VAR gap = 2 _                      '*< The gap between x values.
      , samp = S_W \ gap _             '*< The number of samples to fetch.
      , mask = (1 SHL 5) + (1 SHL 8) _ '*< Steps 5 & 8 active (AIN4, AIN7).
      ,  tmr = 1e6                     '*< The sampling rate (1 kHz).
    IF .config(samp, mask, tmr) THEN _
                             ?"config failed (" & *.Errr & ")" : EXIT DO

    VAR trg = 0 '*< The current trigger value.
    VAR trg1 = .Adc->mm_trg_pin(PIN)                     '*< A GPIO trigger specification.
    IF 0 = trg1 THEN      ?"trg1 spec failed (" & *.Errr & ")" : EXIT DO

    VAR trg2 = .Adc->mm_trg_ain(STP, &h8000)             '*< An analog trigger specification.
    IF 0 = trg2 THEN      ?"trg2 spec failed (" & *.Errr & ")" : EXIT DO

    VAR trg3 = .Adc->mm_trg_pre(0, -&h8000, samp SHR 1)  '*< A pre-trigger specification.
    IF 0 = trg3 THEN      ?"trg3 spec failed (" & *.Errr & ")" : EXIT DO

    S_W -= 1 : S_H -= 1
    VAR lnr = IIF(S_H > 72, S_H SHR 3 - 8, 1) _ '*< The menue line number.
      , max = .Adc->Samples - .Adc->ChAz _      '*< The max. index for samples.
    , scale = S_H / 65520 _                     '*< The factor to scale sample to screen pixels.
        , k = 0 _                 '*< The keycode of user input.
       , fg = RGB(0, 0, 0) _      '*< The foreground color.
       , bg = RGB(250, 250, 250)  '*< The background color.
    COLOR fg, bg
    CLS
    DO '                                     loop to handle user actions
      LOCATE lnr, 1, 0
      ? '                                                print user menu
      ?"Choose trigger type"
      ?"  0 = no trigger (start immediately)"
      ?"  1 = GPIO trigger (pin P8_07 low)"
      ?"  2 = analog trigger, AIN-4 > 0.9 V"
      ?"  3 = analog pre-trigger, any AIN < 0.9 V"
      DO : SLEEP 1000, 0 : k = ASC(INKEY()) : LOOP UNTIL k '     get key

      CLS
      SELECT CASE AS CONST k '                 re-act on user keystrokes
      CASE ASC("0") : trg = 0    : ?"starting immediately ...";
      CASE ASC("1") : trg = trg1 : ?"waiting for GPIO trigger (pin P8_07 low) ...";
      CASE ASC("2") : trg = trg2 : ?"waiting for analog trigger (AIN-4 > 0.9 V) ...";
        CIRCLE (0, S_H SHR 1), 5, RGB(200, 200, 200), , , 1, F
      CASE ASC("3") : trg = trg3 : ?"waiting for analog pre-trigger (any AIN < 0.9 V) ..." ;
        CIRCLE (S_W SHR 1, S_H SHR 1), 5, RGB(200, 200, 200), , , 1, F
      CASE ELSE : EXIT DO
      END SELECT

      IF .mm_start(trg) THEN ?"mm_start failed (" & *.Errr & ")" : CONTINUE DO

      line (0, 0)-STEP (S_W, 7), bg, BF
      FOR c AS INTEGER = 0 TO .Adc->ChAz - 1 '                draw graph
        VAR i = c + .Adc->ChAz _ '*< The samples index.
          , x = gap              '*< The x position at the screen.
        LINE (0, S_H - CUINT(.Adc->Value[c] * scale)) _
           - (x, S_H - CUINT(.Adc->Value[i] * scale)), col(c)
        DO
          i += .Adc->ChAz : IF i >= max THEN EXIT DO
          x += gap
          LINE - (x, S_H - CUINT(.Adc->Value[i] * scale)), col(c)
        LOOP
      NEXT
    LOOP
  LOOP UNTIL 1
  IF .Errr THEN ?"press any key to quit" : SLEEP
END WITH

DELETE io

'' help Doxygen to dokument the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); GpioUdt::config(); AdcUdt::setStep(); PruIo::config(); AdcUdt::mm_trg_pin(); AdcUdt::mm_trg_ain(); AdcUdt::mm_trg_pre(); PruIo::~PruIo();}
