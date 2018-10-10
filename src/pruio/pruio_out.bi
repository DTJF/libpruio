/'* \file pruio_out.bi
\brief Pre-defined macros to print out the subsystems configurations.

This file contains macros to print out the configuration of the
subsystems handled by libpruio. The constructor runs the pruio__init.p
code, which collects the register context of each subsystem. These
convenience macros can print out all that register context.

\since 0.2
'/

'* Array of CPU ball numbers for all digital pins on header P8.
DIM SHARED AS UInt8 P8_Pins(...) = { _
  P8_03 _
, P8_04 _
, P8_05 _
, P8_06 _
, P8_07 _
, P8_08 _
, P8_09 _
, P8_10 _
, P8_11 _
, P8_12 _
, P8_13 _
, P8_14 _
, P8_15 _
, P8_16 _
, P8_17 _
, P8_18 _
, P8_19 _
, P8_20 _
, P8_21 _
, P8_22 _
, P8_23 _
, P8_24 _
, P8_25 _
, P8_26 _
, P8_27 _
, P8_28 _
, P8_29 _
, P8_30 _
, P8_31 _
, P8_32 _
, P8_33 _
, P8_34 _
, P8_35 _
, P8_36 _
, P8_37 _
, P8_38 _
, P8_39 _
, P8_40 _
, P8_41 _
, P8_42 _
, P8_43 _
, P8_44 _
, P8_45 _
, P8_46 _
  }

'* Array of CPU ball numbers for all digital pins on header P9.
DIM SHARED AS UInt8 P9_Pins(...) = { _
  P9_11 _
, P9_12 _
, P9_13 _
, P9_14 _
, P9_15 _
, P9_16 _
, P9_17 _
, P9_18 _
, P9_19 _
, P9_20 _
, P9_21 _
, P9_22 _
, P9_23 _
, P9_24 _
, P9_25 _
, P9_26 _
, P9_27 _
, P9_28 _
, P9_29 _
, P9_30 _
, P9_31 _
, P9_41 _
, P9_42 _
  }

'* Array of CPU ball numbers for all digital pins on header P9.
DIM SHARED AS UInt8 JT_Pins(...) = { _
  JT_04 _
, JT_05 _
  }

'* Array of CPU ball numbers for all digital pins on header P9.
DIM SHARED AS UInt8 SD_Pins(...) = { _
  SD_01 _
, SD_02 _
, SD_03 _
, SD_05 _
, SD_07 _
, SD_08 _
, SD_10 _
  }


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
