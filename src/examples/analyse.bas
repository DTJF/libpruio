/'* \file analyse.bas
\brief Example: analyse the subsystems configurations.

This file contains an example on how to use libpruio to read the
configurations of the subsystems (initial and corrent). It creates a
PruIo structure containing the data and then prints out in a
human-readable form. You may 'borrow' some code for debugging purposes
in your code. Find a functional description in section \ref
sSecExaAnalyse.

Licence: GPLv3, Copyright 2014-\Year by \Mail

Compile by: `fbc -w all analyse.bas`

\since 0.0
'/

' include libpruio
#INCLUDE ONCE "BBB/pruio.bi"
' include board pin header
#INCLUDE ONCE "BBB/pruio_boardpins.bi"

'' Output all CPU balls or just subset of header pins?
'#DEFINE __ALL_BALLS__

'* The type of the output (either Init or Conf).
#DEFINE  OUT_TYPE Init ' alternative: Conf

'* Output the context of a single register.
#DEFINE REG(_R_) RIGHT("                 " & #_R_, 17) & ": " & HEX(.##_R_, SIZEOF(.##_R_) * 2)
'* Output the start of a set.
#DEFINE DEV(_N_) !"\n" & _N_ & _
                       " (DeAd: " & HEX(.DeAd, 8) & _
                       ", ClAd: " & HEX(.ClAd, 8) & _
                       ", ClVa: " & HEX(.ClVa, 8) & ")"

'* Output the CPU ball configuration.
#MACRO BALL_OUT(OUT_TYPE)
  ?!"\nControl Module (DeAd: " & HEX(.OUT_TYPE->DeAd, 8) & ")"
  FOR i AS INTEGER = 0 TO UBOUND(.OUT_TYPE->Value)
    ?"  " & *.get_config(i)
  NEXT
#ENDMACRO

'* Output the configuration of all GPIO subsystems.
#MACRO GPIO_OUT(OUT_TYPE)
  FOR n AS INTEGER = 0 TO UBOUND(.Gpio->OUT_TYPE)
    WITH *.Gpio->OUT_TYPE(n)
      ?DEV("GPIO-" & n)
      ?REG(REVISION)
      IF 0 = .ClAd THEN ?" --> subsystem not handled " & *IIF(.REVISION, @"(is up)", @"(is down)") : CONTINUE FOR
      IF 0 = .REVISION THEN        ?" --> wake up failed" : CONTINUE FOR

      ?REG(SYSCONFIG)
      ?REG(EOI)
      ?REG(IRQSTATUS_RAW_0)
      ?REG(IRQSTATUS_RAW_1)
      ?REG(IRQSTATUS_0)
      ?REG(IRQSTATUS_1)
      ?REG(IRQSTATUS_SET_0)
      ?REG(IRQSTATUS_SET_1)
      ?REG(IRQSTATUS_CLR_0)
      ?REG(IRQSTATUS_CLR_1)
      ?REG(IRQWAKEN_0)
      ?REG(IRQWAKEN_1)
      ?REG(SYSSTATUS)
      ?REG(CTRL)
      ?REG(OE)
      ?REG(DATAIN)
      ?REG(DATAOUT)
      ?REG(LEVELDETECT0)
      ?REG(LEVELDETECT1)
      ?REG(RISINGDETECT)
      ?REG(FALLINGDETECT)
      ?REG(DEBOUNCENABLE)
      ?REG(DEBOUNCINGTIME)
      ?REG(CLEARDATAOUT)
      ?REG(SETDATAOUT)
    END WITH
  NEXT
#ENDMACRO

'* Output the configuration of all TIMER subsystems.
#MACRO TIMER_OUT(OUT_TYPE)
  FOR n AS INTEGER = 0 TO UBOUND(.TimSS->OUT_TYPE)
    WITH *.TimSS->OUT_TYPE(n)
      ?DEV("TIMER-" & 4 + n)
      ?REG(TIDR)
      IF 0 = .ClAd THEN ?" --> subsystem not handled " & *IIF(.TIDR, @"(is up)", @"(is down)") : CONTINUE FOR
      IF 0 = .TIDR THEN        ?" --> wake up failed" : CONTINUE FOR

      ?REG(TIOCP_CFG)
      ?REG(IRQ_EOI)
      ?REG(IRQSTATUS_RAW)
      ?REG(IRQSTATUS)
      ?REG(IRQENABLE_SET)
      ?REG(IRQENABLE_CLR)
      ?REG(IRQWAKEEN)
      ?REG(TCLR)
      ?REG(TCRR)
      ?REG(TLDR)
      ?REG(TTGR)
      ?REG(TWPS)
      ?REG(TMAR)
      ?REG(TCAR1)
      ?REG(TSICR)
      ?REG(TCAR2)
    END WITH
  NEXT
#ENDMACRO

'* Output the configuration of all PWMSS subsystems.
#MACRO PWMSS_OUT(OUT_TYPE)
  FOR n AS INTEGER = 0 TO UBOUND(.PwmSS->OUT_TYPE)
    WITH *.PwmSS->OUT_TYPE(n)
      ?DEV("PWMSS-" & n)
      ?REG(IDVER)
      IF 0 = .ClAd THEN ?" --> subsystem not handled " & *IIF(.IDVER, @"(is up)", @"(is down)") : CONTINUE FOR
      IF 0 = .IDVER THEN           ?" --> wake up failed" : CONTINUE FOR

      ?REG(SYSCONFIG)
      ?REG(CLKCONFIG)
      ?REG(CLKSTATUS)
      ?"  eCAP"
      ?REG(TSCTR)
      ?REG(CTRPHS)
      ?REG(CAP1)
      ?REG(CAP2)
      ?REG(CAP3)
      ?REG(CAP4)
      ?REG(ECCTL1)
      ?REG(ECCTL2)
      ?REG(ECEINT)
      ?REG(ECFLG)
      ?REG(ECCLR)
      ?REG(ECFRC)
      ?REG(CAP_REV)
      ?"  QEP"
      ?REG(QPOSCNT)
      ?REG(QPOSINIT)
      ?REG(QPOSMAX)
      ?REG(QPOSCMP)
      ?REG(QPOSILAT)
      ?REG(QPOSSLAT)
      ?REG(QPOSLAT)
      ?REG(QUTMR)
      ?REG(QUPRD)
      ?REG(QWDTMR)
      ?REG(QWDPRD)
      ?REG(QDECCTL)
      ?REG(QEPCTL)
      ?REG(QCAPCTL)
      ?REG(QPOSCTL)
      ?REG(QEINT)
      ?REG(QFLG)
      ?REG(QCLR)
      ?REG(QFRC)
      ?REG(QEPSTS)
      ?REG(QCTMR)
      ?REG(QCPRD)
      ?REG(QCTMRLAT)
      ?REG(QCPRDLAT)
      ?REG(QEP_REV)
      ?"  ePWM"
      ?REG(TBCTL)
      ?REG(TBSTS)
      ?REG(TBPHSHR)
      ?REG(TBPHS)
      ?REG(TBCNT)
      ?REG(TBPRD)
      ?REG(CMPCTL)
      ?REG(CMPAHR)
      ?REG(CMPA)
      ?REG(CMPB)
      ?REG(AQCTLA)
      ?REG(AQCTLB)
      ?REG(AQSFRC)
      ?REG(AQCSFRC)
      ?REG(DBCTL)
      ?REG(DBRED)
      ?REG(DBFED)
      ?REG(TZSEL)
      ?REG(TZCTL)
      ?REG(TZEINT)
      ?REG(TZFLG)
      ?REG(TZCLR)
      ?REG(TZFRC)
      ?REG(ETSEL)
      ?REG(ETPS)
      ?REG(ETFLG)
      ?REG(ETCLR)
      ?REG(ETFRC)
      ?REG(PCCTL)
    END WITH
  NEXT
#ENDMACRO

'* Output the configuration of the ADC subsystem.
#MACRO ADC_OUT(OUT_TYPE)
  DO
    WITH *.Adc->OUT_TYPE
      ?DEV("ADC")
      ?REG(REVISION)
      IF 0 = .ClAd THEN ?" --> subsystem not handled " & *IIF(.REVISION, @"(is up)", @"(is down)") : EXIT DO
      IF 0 = .REVISION THEN             ?" --> wake up failed" : EXIT DO

      ?REG(SYSCONFIG)
      ?REG(IRQSTATUS_RAW)
      ?REG(IRQSTATUS)
      ?REG(IRQENABLE_SET)
      ?REG(IRQENABLE_CLR)
      ?REG(IRQWAKEUP)
      ?REG(DMAENABLE_SET)
      ?REG(DMAENABLE_CLR)
      ?REG(CTRL)
      ?REG(ADCSTAT)
      ?REG(ADCRANGE)
      ?REG(ADC_CLKDIV)
      ?REG(ADC_MISC)
      ?REG(STEPENABLE)
      ?REG(IDLECONFIG)
      ?"      CHARGE_STEP: " & HEX(.St_p( 0).Confg, 8), HEX(.St_p( 0).Delay, 8)
      FOR i AS INTEGER = 1 TO UBOUND(.St_p)
        WITH .St_p(i)
          ?"          STEP-" & RIGHT("0" & i, 2) & ": " & HEX(.Confg, 8), HEX(.Delay, 8)
        END WITH
      NEXT
      ?REG(FIFO0COUNT)
      ?REG(FIFO0THRESHOLD)
      ?REG(DMA0REQ)
      ?REG(FIFO1COUNT)
      ?REG(FIFO1THRESHOLD)
      ?REG(DMA1REQ)
    END WITH
  LOOP UNTIL 1
#ENDMACRO


' *****  main  *****

VAR io = NEW PruIo '*< Create a PruIo structure, wakeup subsystems.

WITH *io
  IF .Errr THEN
    ?"initialisation failed (" & *.Errr & ")"
  ELSE
#IFDEF __ALL_BALLS__
    BALL_OUT(OUT_TYPE)
#ELSE
    VAR typ = "" _ '*< Board type
     , pins = ""   '*< Array of board specific ball numbers
    SELECT CASE AS CONST .BbType
    CASE PBB2x36 : typ = "Pocketbeagle 2x36" : pins = HEADERPINS_POCKET
    CASE BB_Blue : typ = "Beaglebone Blue"   : pins = HEADERPINS_BLUE
    CASE ELSE    : typ = "Beaglebone 2x46"   : pins = HEADERPINS_BB
    END SELECT
    ?"Header Pins (" & typ & "):"
    FOR i AS LONG = 0 TO LEN(pins) - 1
      ?"  " & *.Pin(pins[i])
    NEXT
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
