/'* \file stepper.bas
\brief Example: control a stepper motor.

This file contains an example on how to use libpruio to control a
4-wire stepper motor:

- configure 4 pins as output
- receive user action in loop
- inform user about the current state
- change motor direction
- change motor speed
- stop holded or in power off mode
- move a single step (in holded mode)
- quit

Find a functional description in section \ref sSecExaStepper. In
contrast to example stepper, this code handles the pins simultaneously.

Licence: GPLv3, Copyright 2014-\Year by \Mail

Compile by: `fbc -w all stepper2.bas`

\since 0.0
'/

' include libpruio
#INCLUDE ONCE "BBB/pruio.bi"
' include the convenience macros for header pins
#INCLUDE ONCE "BBB/pruio_pins.bi"

'* The first pin of the stepper.
#DEFINE P1 P8_03
'* The second pin of the stepper.
#DEFINE P2 P8_04
'* The third pin of the stepper.
#DEFINE P3 P8_05
'* The fourth pin of the stepper.
#DEFINE P4 P8_06

' declare pin masks (all pins at one GPIO-SS#SUSYS)
DIM SHARED AS UInt32 _
  SUSYS _     '*< GPIO-SS number
, MASKS(8, 1) '*< Masks for each stepper state (SET, CLEAR)


/'* \brief Declare masks for the stepper states
\param Io pointer to PruIo structure

We store the GPIO-SS number is SUSYS and create bit-masks for each
stepper pin. Then we create combined masks for each possible stepper
state, one to set the GPIOs high and a second to clear the previously
set GPIOs.

\since 0.6.8
'/
SUB MaskInit(BYVAL Io AS PruIo PTR)
  WITH *Io
    SUSYS = .BallGpio(P4) SHR 5
    VAR m0 = 1 SHL (.BallGpio(P1) AND &b11111)
    VAR m1 = 1 SHL (.BallGpio(P2) AND &b11111)
    VAR m2 = 1 SHL (.BallGpio(P3) AND &b11111)
    VAR m3 = 1 SHL (.BallGpio(P4) AND &b11111)
    MASKS(0, 0) = m0      : MASKS(0, 1) = m1 + m2 + m3
    MASKS(1, 0) = m0 + m1 : MASKS(1, 1) = m2 + m3
    MASKS(2, 0) = m1      : MASKS(2, 1) = m0 + m2 + m3
    MASKS(3, 0) = m1 + m2 : MASKS(3, 1) = m0 + m3
    MASKS(4, 0) = m2      : MASKS(4, 1) = m0 + m1 + m3
    MASKS(5, 0) = m2 + m3 : MASKS(5, 1) = m0 + m1
    MASKS(6, 0) = m3      : MASKS(6, 1) = m0 + m1 + m2
    MASKS(7, 0) = m3 + m0 : MASKS(7, 1) = m1 + m2
    MASKS(8, 0) = 0       : MASKS(8, 1) = m0 + m1 + m2 + m3
  END WITH
END SUB

/'* \brief make the motor move the next step.
\param Io pointer to PruIo structure
\param Rot direction of rotation (1 or -1)

This function sets 4 output pins for a stepper motor driver. It
remembers the last step as static variable (starting at 0 = zero) and
adds the new position to it. So the Rot parameter should either be 1 or
-1 to make the motor move one step in any direction.

Instead of setting each pin one after the other by function
.Gpio->setValue(), here all high pins get masked in register SETDATAOUT
and all low pins in CLEARDATAOUT, and finally the data gets written to
the hardware in order to set all pins at the same time.

'/
SUB move(BYVAL Io AS PruIo PTR, BYVAL Rot AS BYTE = 1)
  STATIC AS long p = 0
  WITH *Io
    p += Rot
    p AND= IIF(Rot AND &b1, &b111, &b110)

    WITH *.Gpio->Conf(SUSYS)
      .SETDATAOUT = MASKS(p, 0)
      .CLEARDATAOUT = MASKS(p, 1)
    END WITH
    .Gpio->flush(SUSYS) ' write data to hardware registers
  END WITH
END SUB



' *****  main  *****

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  DO '                                  pseudo loop, just to avoid GOTOs
    IF .Errr THEN    ?"initialisation failed (" & *.Errr & ")" : EXIT DO

'                                            initial output pin settings
    IF .Gpio->config(P1, PRUIO_GPIO_OUT1) THEN ?"failed setting P1 (" & *.Errr & ")"
    IF .Gpio->config(P2, PRUIO_GPIO_OUT0) THEN ?"failed setting P2 (" & *.Errr & ")"
    IF .Gpio->config(P3, PRUIO_GPIO_OUT0) THEN ?"failed setting P3 (" & *.Errr & ")"
    IF .Gpio->config(P4, PRUIO_GPIO_OUT1) THEN ?"failed setting P4 (" & *.Errr & ")"
    IF .Errr THEN                                                EXIT DO
    MaskInit(io)

'     pin config OK, transfer local settings to PRU and start PRU driver
    IF .config() THEN        ?"config failed (" & *.Errr & ")" : EXIT DO

    ? '                                          print user informations
    ?"Controls: (other keys quit, 1 and 3 only when Direction = 0)"
    ?"                       8 = faster"
    ?"  4 = rotate CW        5 = stop, hold position   6 = rotate CCW"
    ?"  1 = single step CW   2 = slower                3 = single step CCW"
    ?"  0 = stop, power off"
    ?
    ?"Pins","Direction","Sleep" : ?

    VAR w = 128 _        '*< The wait (delay) value.
      , d = 0 _          '*< The direction value.
      , x = 16 _         '*< The cursor column for output.
      , y = CSRLIN() - 1 '*< The cursor line for output
    LOCATE y, x, 0 : ?RIGHT(" " & d, 2), RIGHT("  " & w, 3); ' user info
    DO '                                                    endless loop
      VAR k = ASC(INKEY()) '*< The key code.
      IF k THEN
        SELECT CASE AS CONST k '                react on user keystrokes
        CASE ASC("2") : IF w < 512 THEN w SHL= 1 '                faster
        CASE ASC("8") : IF w >   1 THEN w SHR= 1 '                slower
        CASE ASC("4") : d = -1 '                            half step CW
        CASE ASC("7") : d = -2 '                           half step CCW
        CASE ASC("9") : d =  2 '                            full step CW
        CASE ASC("6") : d =  1 '                           full step CCW
        CASE ASC("5") : d =  0 : move(io, d) '              powered stop
        CASE ASC("1") : IF 0 = d THEN move(io, -1) '      single step CW
        CASE ASC("3") : IF 0 = d THEN move(io,  1) '     single step CCW
        CASE ASC("0") : d =  0 '                          unpowered stop
          WITH *.Gpio->Conf(SUSYS) ' set OFF state
            .SETDATAOUT = MASKS(8, 0)
            .CLEARDATAOUT = MASKS(8, 1)
          END WITH
          .Gpio->flush(SUSYS) ' write data to hardware registers
        CASE ELSE : EXIT DO '                                     finish
        END SELECT

        LOCATE y, x, 0
        ?RIGHT(" " & d, 2), RIGHT("  " & w, 3); '              user info
      END IF
      IF d THEN move(io, d) '                             move the motor
      LOCATE y, 1, 0
      ? .Gpio->Value(P1) & "-" _
      & .Gpio->Value(P2) & "-" _
      & .Gpio->Value(P3) & "-" _
      & .Gpio->Value(P4);
      SLEEP w '                            control the frequency = speed
    LOOP UNTIL .Errr : ?
    IF .Errr THEN ?"abborted: " & *.Errr

    WITH *.Gpio->Conf(SUSYS) ' set OFF state
      .SETDATAOUT = MASKS(8, 0)
      .CLEARDATAOUT = MASKS(8, 1)
    END WITH
    .Gpio->flush(SUSYS) ' write data to hardware registers
    IF .Errr THEN ?"zeroing pins failed: : " & *.Errr

    IF .Errr THEN ?"re-setting pins failed: : " & *.Errr
  LOOP UNTIL 1
END WITH

DELETE io '                    reset ADC, PinMux and GPIOs, clear memory

'' help Doxygen to document the main code
'&/** The main function. */
'&int main() {PruIo::PruIo(); GpioUdt::config(); PruIo::config(); GpioUdt::setValue(); GpioUdt::Value(); PruIo::~PruIo();}
