/'* \file rb_file.bas
\brief Example: fetch ADC samples in a ring buffer and save to file.

This file contains an example on how to use the ring buffer mode of
libpruio. A fixed step mask of AIN-0, AIN-1 and AIN-2 get configured
for maximum speed, sampled in to the ring buffer and from there saved
as raw data to some files. Find a description on the output in section
[Examples -> rb_file](ChaExamples.html#SSecExaRbFile).

Licence: GPLv3

Copyright 2014-\Year by \Mail

Compile by: `fbc -w all rb_file.bas`

\since 0.4.0
'/


' include libpruio
#INCLUDE ONCE "../pruio/pruio.bi"

CONST tSamp = 123401 _  '*< The number of samples in the files (per step).
      , tmr = 5000 _    '*< The sampling rate in ns (5000 -> 200 kHz).
   , NoStep = 3 _       '*< The number of active steps (must match setStep calls and mask).
   , NoFile = 2 _       '*< The number of files to write.
   , NamFil = "output." '*< The output file names.

VAR io = NEW PruIo()    '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  DO
    IF .Errr THEN                     ?"NEW failed: " & *.Errr : EXIT DO

    IF .Adc->setStep( 9, 0, 0, 0, 0) THEN _
                     ?"step 9 configuration failed: " & *.Errr : EXIT DO
    IF .Adc->setStep(10, 1, 0, 0, 0) THEN _
                    ?"step 10 configuration failed: " & *.Errr : EXIT DO
    IF .Adc->setStep(11, 2, 0, 0, 0) THEN _
                    ?"step 11 configuration failed: " & *.Errr : EXIT DO

    VAR mask = &b111 SHL 9 _         '*< The active steps (9 to 11).
      , tInd = tSamp * NoStep _      '*< The maximum total index.
      , half = ((.ESize SHR 2) \ NoStep) * NoStep '*< The maximum index of the half ring buffer.

    IF half > tInd THEN half = tInd  '        adapt size for small files
    VAR samp = (half SHL 1) \ NoStep '*< The number of samples (per step).

    IF .config(samp, mask, tmr, 0) THEN _ '             configure driver
                                   ?"config failed: " & *.Errr : EXIT DO

    IF .rb_start() THEN _ '                       start ring buffer mode
                                 ?"rb_start failed: " & *.Errr : EXIT DO

    VAR p0 = .Adc->Value _           '*< A pointer to the start of the ring buffer.
      , p1 = p0 + half               '*< A pointer to the middle of the ring buffer.
    FOR n AS INTEGER = 0 TO NoFile - 1
      VAR fnam = NamFil & n _        '*< The file name.
         , fnr = FREEFILE            '*< The file number.
      IF OPEN(fnam FOR OUTPUT AS fnr) THEN
        ?"Cannot open " & fnam
      ELSE
        ?"Creating file " & fnam
        VAR i = 0                    '*< Start index.
        WHILE i < tInd
          i += half
          IF i > tInd THEN '          fetch the rest (no complete chunk)
            VAR rest = tInd + half - i _ '*< The rest of the buffer (in bytes).
              , iEnd = IIF(p1 >= p0, rest, rest + half) '*< The last byte of the rest.
            WHILE .DRam[0] < iEnd : SLEEP 1 : WEND
            ?"  writing samples " & (tInd - rest) & "-" & (tInd - 1)
            PUT #fnr, , *p0, rest
            SWAP p0, p1 :                                     EXIT WHILE
          END IF

          IF p1 > p0 THEN WHILE .DRam[0] < half : SLEEP 1 : WEND _
                     ELSE WHILE .DRam[0] > half : SLEEP 1 : WEND
          ?"  writing samples " & (i - half) & "-" & (i - 1)
          PUT #fnr, , *p0, half
          SWAP p0, p1
        WEND
        ?"Finished file " & fnam
        CLOSE #fnr
      END IF
    NEXT
  LOOP UNTIL 1
  IF .Errr THEN SLEEP
END WITH

DELETE(io)

'' help Doxygen to document the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); AdcUddt::setStep(); PruIo::config(); PruIo::~PruIo();}
