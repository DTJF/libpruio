/'* \file sos.bas
\brief Example: blink user LED 3.

This file contains an example on how to use libpruio to control the
user LED 3 (near ethernet connector) on the beaglebone board. It shows
how to unlock a CPU ball that is used by the system. And it shows how
to control the unlocked ball. Find a functional description in
section \ref sSecExaSos.

Licence: GPLv3, Copyright 2014-\Year by \Mail

Compile by: `fbc -w all sos.bas`

\since 0.0
'/


' include libpruio
#INCLUDE ONCE "BBB/pruio.bi"

'* The CPU ball to control (user LED 3).
#DEFINE PIN 24
'* Output a short blink.
#DEFINE OUT_K .Gpio->setValue(PIN, pinmode + 128) : SLEEP 150 _
            : .Gpio->setValue(PIN, pinmode) : SLEEP 100
'* Output a long blink.
#DEFINE OUT_L .Gpio->setValue(PIN, pinmode + 128) : SLEEP 350 _
            : .Gpio->setValue(PIN, pinmode) : SLEEP 100
'* Output a 'S' (short - short - short).
#DEFINE OUT_S OUT_K : OUT_K : OUT_K : SLEEP 150
'* Output an 'O' (long - long - long).
#DEFINE OUT_O OUT_L : OUT_L : OUT_L : SLEEP 150

' *****  main  *****

'* Create a PruIo instance, wakeup only GPIO-1 subsystem, ignore kernel claims.
'VAR io = NEW PruIo(PRUIO_ACT_FREMUX OR PRUIO_ACT_GPIO1)
VAR io = NEW PruIo()

WITH *io
  DO
    IF .Errr THEN    ?"initialisation failed (" & *.Errr & ")" : EXIT DO

    VAR pinmode = .BallConf[PIN] '*< The current pinmode.

    IF .config(1, 0) THEN    ?"config failed (" & *.Errr & ")" : EXIT DO

    ?"watch SOS code on user LED 3 (near ethernet connector)"
    ?
    ?"execute the following command to get rid of mmc1 triggers"
    ?"  sudo su && echo none > /sys/class/leds/beaglebone:green:usr3/trigger && echo 0 > /sys/class/leds/beaglebone:green:usr3/brightness && exit"
    ?
    ?"press any key to quit"
    DO '                           print current state (until keystroke)
      ?!"S"; : OUT_S : IF .Errr THEN ?"blink failed (" & *.Errr & ")": EXIT DO
      ?!"O"; : OUT_O
      ?!"S"; : OUT_S
      ?!"\r   \r"; : SLEEP 1500
    LOOP UNTIL LEN(INKEY()) : ?
    if .Gpio->setValue(PIN, pinmode) then _ '       reset LED (cosmetic)
          ?"reset failed (" & *.Errr & ") press any key to quit" : SLEEP
  LOOP UNTIL 1
END WITH

DELETE io '                    reset ADC, PinMux and GPIOs, clear memory

'' help Doxygen to document the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); PruIo::config(); GpioUdt::setValue(); PruIo::~PruIo();}
