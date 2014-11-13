/'* \file pruio_out.bi
\brief Pre-defined macros to print out the subsystems configurations.

This file contains macros to print out the configuration of the
subsystems handled by libpruio. The destructors runs the pruio__init.p
code, which collects the register context of each subsystem. These
convenience macros can print out all that register context.

'/

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
    WITH *.Gpio->OUT_TYPE (n)
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

'* Output the configuration of all PWMSS subsystems.
#MACRO PWMSS_OUT(OUT_TYPE)
  FOR n AS INTEGER = 0 TO UBOUND(.PwmSS->OUT_TYPE)
    WITH *.PwmSS->OUT_TYPE (n)
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
      ?REG(QCASCTL)
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
