/'* \file pruio_pwmss.bas
\brief The PWMSS component source code.

Source code file containing the function bodies to control the PWM
subsystems. This code controlls the modules of the PWMSS (eQEP, eCAP
and ePWM), containing member functions of classes PwmMod, CapMod and
QepMod and also TimerUdt.

\since 0.2
'/


' PruIo global declarations.
#INCLUDE ONCE "pruio_globals.bi"
' Header for PWMSS part, containing modules QEP, CAP and PWM.
#INCLUDE ONCE "pruio_pwmss.bi"
' driver header file
#INCLUDE ONCE "pruio.bi"
' Header file with convenience macros.
#INCLUDE ONCE "pruio_pins.bi"

'* The clock frequency
#DEFINE PWMSS_CLK  100e6
'* The half clock frequency
#DEFINE PWMSS_CLK_2 50e6


/'* \brief Constructor for the PWMSS subsystem configuration.
\param T A pointer of the calling PruIo structure.

The constructor prepares the DRam parameters to run the pasm_init.p
instructions. The adresses of the subsystems and the adresses of the
clock registers get prepared, and the index of the last parameter gets
stored to compute the offset in the Init and Conf data blocks.

\since 0.2
'/
CONSTRUCTOR PwmssUdt(BYVAL T AS Pruio_ PTR)
  Top = T
  WITH *Top
    VAR i = .ParOffs
    InitParA = i
    i += 1 : .DRam[i] = &h48300000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_PWM0, &h44E000D4uL, 0)

    i += 1 : .DRam[i] = &h48302000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_PWM1, &h44E000CCuL, 0)

    i += 1 : .DRam[i] = &h48304000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_PWM2, &h44E000D8uL, 0)

    .ParOffs = i
  END WITH
END CONSTRUCTOR


/'* \brief Initialize the register context after running the pasm_init.p instructions (private).
\returns Zero on success (may return an error string in future versions).

This is a private function, designed to be called from the main
constructor PruIo::PruIo(). It sets the pointers to the Init and Conf
structures in the data blocks. And it initializes some register
context, if the subsystem woke up and is enabled.

\since 0.2
'/
FUNCTION PwmssUdt.initialize CDECL() AS ZSTRING PTR
  WITH *Top
    VAR p_mem = .MOffs + .DRam[InitParA] _
      , p_raw = CAST(ANY PTR, .DRam) + PRUIO_DAT_PWM
    FOR i AS LONG = 0 TO PRUIO_AZ_PWMSS
      Raw(i) = p_raw
      Raw(i)->CMax = 0
      p_raw += SIZEOF(PwmssArr)

      Init(i) = p_mem
      Conf(i) = p_mem + .DSize

      WITH *Conf(i)
        IF .ClAd =  0 ORELSE _
           .IDVER = 0 THEN _ '                        subsystem disabled
                .DeAd = 0 : .ClVa = &h30000 : p_mem += 16 : _
                    Init(i)->DeAd = 0 : Init(i)->ClAd = 0 : CONTINUE FOR
        .ClVa = 2
        .SYSCONFIG = 2 SHL 2
        .CLKCONFIG = &b0100010001 ' enable all modules
        ' ePWM registers
        .TBPHS = 0
        .TBSTS = &b110
        .CMPCTL = 0
        ' eCAP registers
        .TSCTR = 0            ' reset counter
        .CTRPHS = 0
        .ECCTL1 = &b111001100
        .ECEINT = 0           ' disable all interupts
        .ECCLR = &b11111110   ' clear all interupt flags
      END WITH
      p_mem += SIZEOF(PwmssSet)
    NEXT
  END WITH : RETURN 0
END FUNCTION


/'* \brief Compute PWM output configuration from an eCAP module (private).
\param Nr The PWMSS subsystem index.
\param Freq A pointer to output the frequency value (or 0 for no output).
\param Duty A pointer to output the duty value (or 0 for no output).
\returns Zero on success, an error string otherwise.

This private functions computes the real PWM configuration of an eCAP
module. It's designed to get called from function PwmMod::Value().

\note This is a private function designed for internal use. It doesn't
      check the validity of the `Nr` parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.2
'/
FUNCTION PwmssUdt.cap_pwm_get CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL Freq AS Float_t PTR = 0 _
  , BYVAL Duty AS Float_t PTR = 0) AS ZSTRING PTR

  WITH *Conf(Nr)
    IF 2 <> .ClVa THEN                        Top->Errr = E0 : RETURN E0 ' PWM not enabled
    IF 0 = BIT(.ECCTL2, 9) THEN               Top->Errr = E9 : RETURN E9 ' eCAP module not in output mode
    IF Freq THEN *Freq = PWMSS_CLK / .CAP1
    IF Duty THEN *Duty = .CAP2 / .CAP1
  END WITH :                                                    RETURN 0
END FUNCTION


/'* \brief Configure PWM output at an eCAP module (private).
\param Nr The PWMSS subsystem index.
\param F The frequency to set (or -1 for no change).
\param D The duty cycle for output A (0.0 to 1.0, or -1 for no change).
\returns Zero on success, an error string otherwise.

This functions configures an eCAP module for PWM output. It sets the
frequency and the duty cycle. Only positive values in these parameters
force a change. Pass a negative value to stay with the current setting.
A duty parameters greater than 1.0 gets limited to 1.0 (= 100%).

\note This is a private function designed for internal use. It doesn't
      check the validity of the `Nr` parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.2
'/
FUNCTION PwmssUdt.cap_pwm_set CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL F AS Float_t _
  , BYVAL D AS Float_t = 0.) AS ZSTRING PTR

  STATIC AS CONST Float_t _
    f_min = PWMSS_CLK / &hFFFFFFFFuL '' minimal frequency
  STATIC AS UInt32 _
    cnt(...) = {0, 0, 0} _  '' initial module periods
  , cmp(...) = {0, 0, 0}    '' initial module compares

  WITH *Top
    VAR r = 0
    IF 2 <> Conf(Nr)->ClVa THEN                   .Errr = E0 : RETURN E0 ' PWMSS not enabled
    IF 0 = cnt(Nr) ANDALSO _
       0 >= F THEN                                .Errr = E1 : RETURN E1 ' set frequency first
    IF F > 0. THEN
      IF F < f_min ORELSE _
         F > PWMSS_CLK_2 THEN                     .Errr = E2 : RETURN E2 ' frequency not supported
     cnt(Nr) = CUINT(PWMSS_CLK / F)
    END IF
    IF D >= 0 THEN cmp(Nr) = IIF(D > 1., cnt(Nr), CUINT(cnt(Nr) * D))

    Conf(Nr)->CAP1 = cnt(Nr)
    Conf(Nr)->CAP2 = cmp(Nr)
    IF Conf(Nr)->ECCTL2 <> PwmMode THEN
      Conf(Nr)->ECCTL2 = PwmMode
      Raw(Nr)->CMax = 0
      r = PwmMode
    END IF

    IF .DRam[0] > PRUIO_MSG_IO_OK THEN                          RETURN 0

    PruReady(1) ' wait, if PRU is busy (should never happen)
    .DRam[5] = 0 ' counter start value
    .DRam[4] = cmp(Nr)
    .DRam[3] = cnt(Nr)
    .DRam[2] = Conf(Nr)->DeAd + &h100
    .DRam[1] = r OR (PRUIO_COM_CAP_PWM SHL 24)
  END WITH :                                                    RETURN 0
END FUNCTION


/'* \brief Compute current values of eCAP Timer output (private).
\param Nr The PWMSS subsystem index.
\param Dur1 The variable to store the duration of initial state.
\param Dur2 The variable to store the duration of the pulse.
\returns Zero on success, an error string otherwise.

This private functions computes the real PWM configuration of an eCAP
module. It's designed to get called from function PwmMod::Value().

\note This is a private function designed for internal use. It doesn't
      check the validity of the `Nr` parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.4
'/
FUNCTION PwmssUdt.cap_tim_get CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL Dur1 AS Float_t PTR _
  , BYVAL Dur2 AS Float_t PTR) AS ZSTRING PTR

  IF Dur1 = 0 ORELSE Dur2 = 0 THEN Top->Errr = @"pass pointers" : RETURN Top->Errr
  WITH *Conf(Nr)
    VAR dur = *Dur1 + *Dur2 _ ' [mSec]
      , dmx = 1000. * &hFFFFFFFF / PWMSS_CLK _
      , dmn = 1000. * 2 / PWMSS_CLK
    SELECT CASE dur
    CASE IS <= 0. ' get current
      IF 2 <> .ClVa THEN                         Top->Errr = E0 : RETURN E0 ' PWMSS not enabled
      IF 0 = BIT(.ECCTL2, 9) THEN                Top->Errr = E9 : RETURN E9 ' eCAP module not in output mode
      IF BIT(.ECCTL2, 4) THEN ' running
        *Dur2 = 1000. * .CAP2 / PWMSS_CLK
        *Dur1 = 1000. * .CAP1 / PWMSS_CLK - *Dur2
      ELSE ' stopped
        *Dur2 = 0.
        *Dur1 = 0.
      END IF
    CASE IS < dmn ' get minimal
      *Dur1 = dmn
      *Dur2 = dmn / 2
    CASE IS > dmx ' get maximal
      *Dur1 = *Dur1 / dur * dmx
      *Dur2 = *Dur2 / dur * dmx
    CASE ELSE
      *Dur1 = 1000. * CULNG(*Dur1 / dur * PWMSS_CLK)
      *Dur2 = 1000. * CULNG(*Dur2 / dur * PWMSS_CLK)
    END SELECT
  END WITH :                                                     RETURN 0
END FUNCTION


/'* \brief Configure Timer output from an eCAP module (private).
\param Nr The PWMSS subsystem index.
\param Dur1 The duration of initial state.
\param Dur2 The duration of the pulse (0 (zero) for minimal.
\param Mode The mode of the timer output.
\returns Zero on success, an error string otherwise.

This functions configures an eCAP module for TIMER output. It sets the
durations for the initial state period and the pulse.

\note This is a private function designed for internal use. It doesn't
      check the validity of the `Nr` parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.4
'/
FUNCTION PwmssUdt.cap_tim_set CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL Dur1 AS Float_t _
  , BYVAL Dur2 AS Float_t _
  , BYVAL Mode AS SHORT) AS ZSTRING PTR

  STATIC AS CONST Float_t _
    d_min = 1000. *           &h2 / PWMSS_CLK _ '' minimal durarion [mSec]
  , d_max = 1000. * &hFFFFFFFFuLL / PWMSS_CLK   '' maximal duration [mSec]

  VAR dur = Dur1 + Dur2 ' [msec]
  WITH *Conf(Nr)
    IF 2 <> .ClVa                           THEN Top->Errr = E0 : RETURN E0 ' PWMSS not enabled

    Raw(Nr)->CMax = 0
    SELECT CASE dur
    CASE IS <= 0. ' -> switch off
      .CAP1 = &hFFFFFFFFuL
      .CAP2 = &h0
      .ECCTL2 = IIF(Mode AND &b01, PwmMode OR &b10000000000, PwmMode) ' default/invers
    CASE IS < d_min :                Top->Errr = Top->TimSS->E3 : RETURN Top->Errr ' duration too short
    CASE IS > d_max :                Top->Errr = Top->TimSS->E4 : RETURN Top->Errr ' duration too long
    CASE ELSE
      IF Mode >= &b10 THEN ' one-shot
        IF 0.01 >= Dur1 THEN         Top->Errr = Top->TimSS->E3 : RETURN Top->Errr ' one-shot duration too short
        Raw(Nr)->CMax = (Mode AND &b111111110) SHR 1
        .ECCTL2 = PwmMode OR IIF(Mode AND &b01, &b10010000000, &b00010000000) ' default/invers
      ELSE
        .ECCTL2 = IIF(Mode AND &b01, PwmMode OR &b10000000000, PwmMode) ' default/invers
      END IF
      .CAP1 = CULNG(.001 * dur * PWMSS_CLK) ' period
      VAR x = CULNG(Dur2 / dur * .CAP1) '     match
      .CAP2 = IIF(x > 0, x, 1)
    END SELECT
    .TSCTR = .CAP2
  END WITH

  WITH *Top
    IF .DRam[0] > PRUIO_MSG_IO_OK                            THEN RETURN 0

    PruReady(1) ' wait, if PRU is busy (should never happen)
    .DRam[5] = Conf(Nr)->TSCTR
    .DRam[4] = Conf(Nr)->CAP2
    .DRam[3] = Conf(Nr)->CAP1
    .DRam[2] = Conf(Nr)->DeAd + &h100
    .DRam[1] = Conf(Nr)->ECCTL2 OR (PRUIO_COM_CAP_TIM SHL 24)
  END WITH :                                                      RETURN 0
END FUNCTION


/'* \brief Compute PWM output configuration from an eHRPWM module (private).
\param Nr The PWMSS subsystem index.
\param F A pointer to output the frequency value (or 0 for no output).
\param Du A pointer to output the duty value (or 0 for no output).
\param Mo The output channel (0 = A, otherwise B).
\returns Zero on success, an error string otherwise.

This private functions computes the real configuration of an eHRPWM
module. It's designed to get called from function PwmMod::Value().

\note This is a private function designed for internal use. It doesn't
      check the validity of the `Nr` parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.2
'/
FUNCTION PwmssUdt.pwm_pwm_get CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL F AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0  _
  , BYVAL Mo AS UInt8) AS ZSTRING PTR

  WITH *Conf(Nr)
    IF 2 <> .ClVa THEN                        Top->Errr = E0 : RETURN E0 ' PWMSS not enabled
    VAR p = CAST(UInt32, .TBPRD)
    IF F THEN
      VAR d1 = (.TBCTL SHR 7) AND &b111, d2 = (.TBCTL SHR 10) AND &b111
      VAR cg = p * IIF(d1, d1 SHL 1, 1) * (1 SHL d2)
      *F = PWMSS_CLK / IIF(BIT(.TBCTL, 1), cg SHL 1, cg)
    END IF
    IF Du THEN
      VAR c = CAST(UInt32, IIF(Mo, .CMPB, .CMPA))
      IF BIT(.TBCTL, 1) THEN '                             count up-down
        p SHL= 1
        IF IIF(Mo, .AQCTLB, .AQCTLA) AND &b010001000000 THEN c = p - c
      END IF
      *Du = c / p
    END IF
  END WITH :                                                    RETURN 0
END FUNCTION



/'* \brief Configure PWM output at a eHRPWM module (private).
\param Nr The PWMSS subsystem index.
\param F The frequency to set (or -1 for no change).
\param Da The duty cycle for output A (0.0 to 1.0, or -1 for no change).
\param Db The duty cycle for output B (0.0 to 1.0, or -1 for no change).
\returns Zero on success, an error string otherwise.

This private function configures an eHRPWM module. It sets the common
frequency and both output duties A and B. Only positive values in these
parameters force a change. Pass a negative value to stay with the
current setting. Duty parameters (`Da` and `Db`) greater than 1.0 get
limited to 1.0 (= 100%).

\note This is a private function designed for internal use. It doesn't
      check the validity of the `Nr` parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.2
'/
FUNCTION PwmssUdt.pwm_pwm_set CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL F AS Float_t _
  , BYVAL Da AS Float_t = 0. _
  , BYVAL Db AS Float_t = 0.) AS ZSTRING PTR

  STATIC AS CONST Float_t _
    f_min = PWMSS_CLK_2 / &h6FFF900   '' minimal frequency (128 * 14 * 65535)
  STATIC AS Float_t _
   freq(...) = {0., 0., 0.} _ ' module frequencies
  , d_a(...) = {0., 0., 0.} _ ' module duty A
  , d_b(...) = {0., 0., 0.}   ' module duty B
  STATIC AS UInt16 _
    cnt(...) = {0, 0, 0} _ ' module periods
  , c_a(...) = {0, 0, 0} _ ' module counters A
  , c_b(...) = {0, 0, 0}   ' module counters B

  VAR ctl = 0
  WITH *Conf(Nr)
    IF 2 <> .ClVa THEN                        Top->Errr = E0 : RETURN E0 ' PWMSS not enabled
    IF 0 = cnt(Nr) THEN
      IF F <= 0. THEN                         Top->Errr = E1 : RETURN E1 ' set frequency first
    ELSE
      IF F > 0. ANDALSO freq(Nr) <> F THEN cnt(Nr) = 0
    END IF

    IF 0 = cnt(Nr) THEN '                    calc new period (frequency)
      VAR cycle = IIF(F > f_min ANDALSO F <= PWMSS_CLK_2, CUINT(.5 + PWMSS_CLK / F), 0uL)
      IF 2 > cycle THEN                       Top->Errr = E2 : RETURN E2 ' frequency not supported

      freq(Nr) = ABS(F)
      IF cycle <= &h10000 ANDALSO 0 = BIT(Top->Pwm->ForceUpDown, Nr) THEN ' count up mode
        cnt(Nr) = cycle
      ELSEIF cycle < &h20000 THEN '        no divisor count up-down mode
        cnt(Nr) = cycle SHR 1
        ctl = 2
      ELSE '                                  divisor count up-down mode
        VAR fac = cycle SHR 17 _
           , x1 = 1 + CINT(INT(LOG(fac / 14) / LOG(2)))
        IF x1 < 0 THEN x1 = 0
        VAR x2 = (fac SHR x1) \ 2 + 1
        cnt(Nr) = CUINT(.5 + PWMSS_CLK_2 / F / (IIF(x2, x2 SHL 1, 1) SHL x1))
        ctl = 2 + x2 SHL 7 + x1 SHL 10 ' clock divisor
      END IF
      ctl OR= (3 SHL 14) + (Top->Pwm->Cntrl(Nr) AND &b0010000001111100)
      .TBCTL = ctl
      .TBPRD = cnt(Nr)
      .TBCNT = 0
      c_a(Nr) = 0
      c_b(Nr) = 0
    END IF

    IF Da >= 0. THEN d_a(Nr) = IIF(Da > 1., 1., Da) : c_a(Nr) = 0
    IF 0 = c_a(Nr) THEN '                     calc new duty for A output
      IF BIT(.TBCTL, 1) ORELSE BIT(Top->Pwm->ForceUpDown, Nr) THEN 'up-down mode
        IF d_a(Nr) >= .5 _
          THEN .AQCTLA = Top->Pwm->AqCtl(0, Nr, 2) : c_a(Nr) = CUINT((cnt(Nr) SHL 1) * (1 - d_a(Nr))) _
          ELSE .AQCTLA = Top->Pwm->AqCtl(0, Nr, 1) : c_a(Nr) = CUINT((cnt(Nr) SHL 1) * d_a(Nr))
      ELSE '                                                        up mode
               .AQCTLA = Top->Pwm->AqCtl(0, Nr, 0) : c_a(Nr) = CUINT(.5 + (cnt(Nr) + 1) * d_a(Nr))
      END IF
      .CMPA = c_a(Nr)
    END IF

    IF Db >= 0. THEN d_b(Nr) = IIF(Db > 1., 1., Db) : c_b(Nr) = 0
    IF 0 = c_b(Nr) THEN '                     calc new duty for B output
      IF BIT(.TBCTL, 1) ORELSE BIT(Top->Pwm->ForceUpDown, Nr) THEN ' up-down mode
        IF d_b(Nr) >= .5 _
          THEN .AQCTLB = Top->Pwm->AqCtl(1, Nr, 2) : c_b(Nr) = CUINT((cnt(Nr) SHL 1) * (1 - d_b(Nr))) _
          ELSE .AQCTLB = Top->Pwm->AqCtl(1, Nr, 1) : c_b(Nr) = CUINT((cnt(Nr) SHL 1) * d_b(Nr))
      ELSE '                                                         up mode
               .AQCTLB = Top->Pwm->AqCtl(1, Nr, 0) : c_b(Nr) = CUINT(.5 + (cnt(Nr) + 1) * d_b(Nr))
      END IF
      .CMPB = c_b(Nr)
    END IF

    IF Top->DRam[0] > PRUIO_MSG_IO_OK THEN                      RETURN 0

    WHILE Top->DRam[1] : WEND ' wait, if PRU is busy (should never happen)
    Top->DRam[5] = .TBCNT + .TBPRD SHL 16
    Top->DRam[4] = .AQCTLA + .AQCTLB SHL 16
    Top->DRam[3] = .CMPA + .CMPB SHL 16
    Top->DRam[2] = .DeAd + &h200
    Top->DRam[1] = IIF(ctl, ctl, 0) + PRUIO_COM_PWM SHL 24
  END WITH :                                                    RETURN 0
END FUNCTION


/'* \brief The constructor for PWM features of the PWMSS.
\param T A pointer of the calling PruIo structure.

Each of the three Pulse Width Modulation SubSystems (PWMSS) in the CPU
contains modules (PWM, CAP and QEP). In order to create a clear API
from the user point of view, the functions to control the modules are
separated to extra classes. This UDT contains functions to control the
PWM module.

The constructor just copies a pointer to the calling main UDT PruIo.

\since 0.2
'/
CONSTRUCTOR PwmMod(BYVAL T AS Pruio_ PTR)
  Top = T
END CONSTRUCTOR


/'* \brief Compute PWM output configuration.
\param Ball The pin index.
\param Hz A pointer to output the frequency value (or 0 for no output).
\param Du A pointer to output the duty value (or 0 for no output).
\returns Zero on success, an error string otherwise.

This functions computes the real PWM output of a header pin. The real
setting may differ from the parameters passed to function
PwmMod::setValue(). Use this function to compute the active settings.

Wrapper function (C or Python): pruio_pwm_Value().

\since 0.2
'/
FUNCTION PwmMod.Value CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0) AS ZSTRING PTR

  WITH *Top
    DIM AS ZSTRING PTR e
    SELECT CASE AS CONST Ball
    CASE P8_07 : e = IIF(ModeCheck(Ball,2), .PwmSS->E3, .TimSS->pwm_get(0, Hz, Du))
    CASE P8_09 : e = IIF(ModeCheck(Ball,2), .PwmSS->E3, .TimSS->pwm_get(1, Hz, Du))
    CASE P8_10 : e = IIF(ModeCheck(Ball,2), .PwmSS->E3, .TimSS->pwm_get(2, Hz, Du))
    CASE P8_08 : e = IIF(ModeCheck(Ball,2), .PwmSS->E3, .TimSS->pwm_get(3, Hz, Du))
    CASE P8_13 : e = IIF(ModeCheck(Ball,4), .PwmSS->E3, .PwmSS->pwm_pwm_get(2, Hz, Du, 1))
    CASE P8_19 : e = IIF(ModeCheck(Ball,4), .PwmSS->E3, .PwmSS->pwm_pwm_get(2, Hz, Du, 0))
    CASE P8_34 : e = IIF(ModeCheck(Ball,2), .PwmSS->E3, .PwmSS->pwm_pwm_get(1, Hz, Du, 1))
    CASE P8_36 : e = IIF(ModeCheck(Ball,2), .PwmSS->E3, .PwmSS->pwm_pwm_get(1, Hz, Du, 0))
    CASE P8_45 : e = IIF(ModeCheck(Ball,3), .PwmSS->E3, .PwmSS->pwm_pwm_get(2, Hz, Du, 1))
    CASE P8_46 : e = IIF(ModeCheck(Ball,3), .PwmSS->E3, .PwmSS->pwm_pwm_get(2, Hz, Du, 0))
    CASE P9_14 : e = IIF(ModeCheck(Ball,6), .PwmSS->E3, .PwmSS->pwm_pwm_get(1, Hz, Du, 0))
    CASE P9_16 : e = IIF(ModeCheck(Ball,6), .PwmSS->E3, .PwmSS->pwm_pwm_get(1, Hz, Du, 1))
    CASE P9_21 : e = IIF(ModeCheck(Ball,3), .PwmSS->E3, .PwmSS->pwm_pwm_get(0, Hz, Du, 1))
    CASE P9_22 : e = IIF(ModeCheck(Ball,3), .PwmSS->E3, .PwmSS->pwm_pwm_get(0, Hz, Du, 0))
    CASE P9_29 : e = IIF(ModeCheck(Ball,1), .PwmSS->E3, .PwmSS->pwm_pwm_get(0, Hz, Du, 1))
    CASE P9_31 : e = IIF(ModeCheck(Ball,1), .PwmSS->E3, .PwmSS->pwm_pwm_get(0, Hz, Du, 0))
    CASE P9_28 : e = IIF(ModeCheck(Ball,4), .PwmSS->E3, .PwmSS->cap_pwm_get(2, Hz, Du))
    CASE JT_05 : e = IIF(ModeCheck(Ball,4), .PwmSS->E3, .PwmSS->cap_pwm_get(1, Hz, Du))
    CASE P9_42 : e = IIF(ModeCheck(Ball,0), .PwmSS->E3, .PwmSS->cap_pwm_get(0, Hz, Du))
    'CASE P8_15 : e = IIF(ModeCheck(Ball,5), .PwmSS->E3, pru_cap_get(Hz, Du))
    CASE ELSE  : e = .PwmSS->E4
    END SELECT : IF e THEN .Errr = e :                      RETURN .Errr
  END WITH : RETURN 0
END FUNCTION


/'* \brief Set PWM output on a header pin.
\param Ball The CPU ball number.
\param Hz The frequency to set (or -1 for no change).
\param Du The duty cycle to set (0.0 to 1.0, or -1 for no change).
\returns Zero on success (otherwise a string with an error message).

This function sets PWM output on a header pin. PWM output may either be
generated by a eHRPWM or a eCAP module in the PWMSS subsystem, or by
one of the TIMER-[4-7] subsystems. Depending on the specified pin
number (parameter `Ball`), the corresponding PWMSS module or TIMERSS
gets configured to the specified frequency and duty cycle.

It's recommended to make the first call to this function before the
call to function PruIo::config(), because eCAP pins (P9_28 or
P9_42) can be used in PWM output and in CAP input mode. A mode change
happens when the configurations gets transfered from the host to the
PRU. Also, when an eCAP pin is currently used as input, the new PWM
output mode gets active after the next call to function
PruIo::config().

Only positive values in the parameters `Hz` and `Du` force a
change. Pass a negative value to stay with the current setting. A duty
parameter greater than 1.0 gets limited to 1.0 (= 100%).

In the first call to this function, the parameter `Hz` must be greater
than 0 (zero), to set a valid period time. In case of eHRPWM modules
both outputs A and B of must run at the same frequency, so you need not
set the `Hz` parameter when you set the `Du` parameter for the second
output.

The hardware settings (integer values) are computed to match the passed
parameters `Hz` and `Du` as close as possible. Some parameter
combinations are impossible to match exactly, due to hardware
limitations (ie. 17 bit resolution in case of eHRPWM modules). Use
function PwmMod::Value() to compute the active settings, in order to
calculate differences.

Wrapper function (C or Python): pruio_pwm_setValue().

\since 0.2
'/
FUNCTION PwmMod.setValue CDECL( _
  BYVAL Ball AS UInt8, _
  BYVAL Hz AS Float_t, _
  BYVAL Du AS Float_t) AS ZSTRING PTR

  WITH *Top
    SELECT CASE AS CONST Ball
    CASE P8_07 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)
      RETURN .TimSS->pwm_set(0, Hz, Du)
    CASE P8_09 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)
      RETURN .TimSS->pwm_set(1, Hz, Du)
    CASE P8_10 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)
      RETURN .TimSS->pwm_set(2, Hz, Du)
    CASE P8_08 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)
      RETURN .TimSS->pwm_set(3, Hz, Du)
    CASE P8_13 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h0C)
      RETURN .PwmSS->pwm_pwm_set(2, Hz, -1., Du)
    CASE P8_19 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h0C)
      RETURN .PwmSS->pwm_pwm_set(2, Hz, Du, -1.)
    CASE P8_34 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)
      RETURN .PwmSS->pwm_pwm_set(1, Hz, -1., Du)
    CASE P8_36 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)
      RETURN .PwmSS->pwm_pwm_set(1, Hz, Du, -1.)
    CASE P8_45 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h0B)
      RETURN .PwmSS->pwm_pwm_set(2, Hz, -1., Du)
    CASE P8_46 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h0B)
      RETURN .PwmSS->pwm_pwm_set(2, Hz, Du, -1.)
    CASE P9_14 : IF ModeCheck(Ball,6) THEN ModeSet(Ball, &h0E)
      RETURN .PwmSS->pwm_pwm_set(1, Hz, Du, -1.)
    CASE P9_16 : IF ModeCheck(Ball,6) THEN ModeSet(Ball, &h0E)
      RETURN .PwmSS->pwm_pwm_set(1, Hz, -1., Du)
    CASE P9_21 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h0B)
      RETURN .PwmSS->pwm_pwm_set(0, Hz, -1., Du)
    CASE P9_22 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h0B)
      RETURN .PwmSS->pwm_pwm_set(0, Hz, Du, -1.)
    CASE P9_29 : IF ModeCheck(Ball,1) THEN ModeSet(Ball, &h09)
      RETURN .PwmSS->pwm_pwm_set(0, Hz, -1., Du)
    CASE P9_31 : IF ModeCheck(Ball,1) THEN ModeSet(Ball, &h09)
      RETURN .PwmSS->pwm_pwm_set(0, Hz, Du, -1.)
    CASE P9_28 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h0C)
      RETURN .PwmSS->cap_pwm_set(2, Hz, Du)
    CASE P9_42 : IF ModeCheck(Ball,0) THEN ModeSet(Ball, &h08)
      RETURN .PwmSS->cap_pwm_set(0, Hz, Du)
    CASE JT_05 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h0C)
      RETURN .PwmSS->cap_pwm_set(1, Hz, Du)
    CASE SD_10 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)
      RETURN .PwmSS->cap_pwm_set(1, Hz, Du)
    'CASE P8_15 : IF ModeCheck(Ball,5) THEN ModeSet(Ball, &h0D)
      'RETURN pru_cap_set(Hz, Du)
    END SELECT :                       .Errr = .PwmSS->E4 : RETURN .Errr ' pin has no PWM capability
  END WITH
END FUNCTION



/'* \brief Synchronize PWMSS-PWM modules
\param Mask The bit-mask to set
\returns Zero on success (otherwise a string with an error message).

All clocks of the PWM modules in the PWM sub systems can get enabled or
disabled by a single write access to TBCLK register in the controll
modules (CM). This feature allows to syncronise PWM signals generated
by several modules on different subsystem. The process is

-# stopp the related PWMSS-PWM modules
-# configure the registers
-# start the clocks simultaneou0sly

In order to stop a clock, set its bit in the Mask parameter to 0
(zero). Bit 2 is for PWMSS2-PWM, Bit 1 for PWMSS1-PWM and Bit 0 for
PWMSS0-PWM module.

Once you configured the modules and uploaded the configuration to the
PRUSS (by calling PruIo::config() ) you can start all PWM modules by a
further call with their Mask bits set to 1. See \ArmRef{15.2.2.3.4} for
details,

Examples:

    .sync(&b000) ' -> stopps all PWM module clocks
    .sync(&b101) ' -> starts clocks of modules 2 and 0, counters synchonized

\since 0.6
'/
FUNCTION PwmMod.Sync CDECL( _
  BYVAL Mask AS UInt8) AS ZSTRING PTR
  WITH *Top
    IF .MuxFnr < 1 ORELSE .MuxFnr > 255                      THEN RETURN @"libpruio LKM missing"
    PRINT #.MuxFnr, "FF" & HEX(Mask, 2) : SEEK #.MuxFnr, 1      : RETURN 0
  END WITH
END FUNCTION

'FUNCTION PwmMod.SyncToggle CDECL( _
  'BYVAL Mask AS UInt8 = 0,
  'BYVAL Curr AS UInt8 PTR = 0) AS ZSTRING PTR
  'WITH *Top
    'if Curr then
      'PruReady(1) ' wait if PRU busy
      '.DRam[2] = &h44E10664uL
      '.DRam[1] = 4 OR PRUIO_COM_PEEK
      'PruReady(1) ' wait if PRU busy
      '*Curr = DRam[2]
    'end if
    'if Mask then
      'IF .MuxFnr < 1 ORELSE .MuxFnr > 255                    THEN RETURN @"libpruio LKM missing"

      'PRINT #.MuxFnr, "FF" & HEX(Mask, 2) : SEEK #.MuxFnr, 1    : RETURN 0
    'END if
  'END WITH
'END FUNCTION


/'* \brief The constructor for the CAP feature of the PWMSS.
\param T A pointer of the calling PruIo structure.

Each of the three Pulse Width Modulation SubSystems (PWMSS) in the CPU
contains modules (PWM, CAP and QEP). In order to create a clear API
from the user point of view, the functions to control the modules are
separated to extra classes. This UDT contains functions to control the
CAP module, which is used to analyse the frequency and duty cycle of a
digital pulse train.

The constructor just copies a pointer to the calling main UDT PruIo.

\since 0.2
'/
CONSTRUCTOR CapMod(BYVAL T AS Pruio_ PTR)
  Top = T
END CONSTRUCTOR


/'* \brief Configure a header pin as eCAP input.
\param Ball The CPU ball number to configure.
\param FLow Minimal frequency to measure in Hz (> .0232831).
\returns Zero on success (otherwise a string with an error message).

This function configures a header pin for Capture and Analyse Pulse
(CAP) trains. The pins configuration gets checked. If it's not
configured as input for the CAP module in the PWMSS subsystem, libpruio
tries to adapt the pinmuxing. This fails if the program isn't executed
with admin privileges.

Currently CAP is available on pins P9_42 and P9_28. The later is used
for MCASP-0 on the BBB.

The parameter `FLow` specifies the minimal frequency to measure in Hz.
When not set (values < .0232831) and the input doesn't change, the
counter runs until an overflow before it returns the new values (in
this case frequency = 0 and duty cycle = 0). This lasts about 43
seconds before the new values are available. To shorten this time, you
can specify the lowest frequency. When a period without change is over,
the counter gets restarted.

Wrapper function (C or Python): pruio_cap_config().

\since 0.2
'/
FUNCTION CapMod.config CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL FLow AS Float_t = 0.) AS ZSTRING PTR

  VAR m = 0
  WITH *Top
    SELECT CASE AS CONST Ball
    CASE P9_28 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h24)
      m = 2
    CASE JT_04 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h24)
      m = 2
    CASE P9_42 : IF ModeCheck(Ball,0) THEN ModeSet(Ball, &h20)
    CASE SD_10 : IF ModeCheck(Ball,1) THEN ModeSet(Ball, &h22)
      m = 1
    'CASE P8_15 : IF ModeCheck(Ball,5) THEN ModeSet(Ball, &h25) ' pr1_ecap0_ecap_capin_apwm_o (also on P9_42)
    'CASE    88 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h22)
      'm = 1
    'CASE    93 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h24)
      'm = 1
    'CASE    98 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h23)
      'm = 2
    'CASE    99 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h23)
      'm = 1
    CASE ELSE                              : .Errr = .PwmSS->E6 : RETURN .Errr ' pin has no CAP capability
    END SELECT
    IF 2 <> .PwmSS->Conf(m)->ClVa       THEN .Errr = .PwmSS->E0 : RETURN .Errr ' PWMSS not enabled
    WITH *.PwmSS
      VAR cnt = &hFFFFFFFFul
      IF FLow > PWMSS_CLK/ &hFFFFFFFFul THEN
        cnt = CUINT(PWMSS_CLK / FLow)
        IF cnt < 256 THEN cnt = 256
      END IF
      .Raw(m)->CMax = cnt
      .Conf(m)->ECCTL2 = .CapMode
    END WITH

    IF .DRam[0] > PRUIO_MSG_IO_OK                            THEN RETURN 0

    PruReady(1) ' wait, if PRU is busy
    .DRam[2] = .PwmSS->Conf(m)->DeAd + &h100
    .DRam[1] = .PwmSS->CapMode + (PRUIO_COM_CAP SHL 24)
  END WITH :                                                      RETURN 0
END FUNCTION


/'* \brief Analyse a digital pulse train, get frequency and duty cycle.
\param Ball The CPU ball number to test.
\param Hz A pointer to store the frequency value (or null).
\param Du A pointer to store the duty cycle value (or null).
\returns Zero on success (otherwise a string with an error message).

This function returns the frequency and duty cycle of a digital pulse
train on a header pin. The header pin needs to get configured first by
a call to function CapMod::config().

The parameters `Hz` and `Du` contain the results of the last measured
period. You can pass a zero pointer to either of them if you don't need
this value.

A period is limited by the counter resolution. The minimal frequency is
0.0232831 Hz, so a period lasts maximal 43 seconds. When the state of
the input pin doesn't change twice during a period, the counter
restarts and zero gets returned for both results (`Hz` and `Du`). The
minimal frequency can get adapted by parameter `FLow` in the previous
call to function CapMod::config().

Wrapper function (C or Python): pruio_cap_Value().

\since 0.2
'/
FUNCTION CapMod.Value CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0) AS ZSTRING PTR

  VAR m = 0
  WITH *Top
    DIM AS ZSTRING PTR e
    IF 2 <> .PwmSS->Conf(m)->ClVa THEN
      e = .PwmSS->E0 ' PWMSS not enabled
    else
      SELECT CASE AS CONST Ball
      CASE P9_28 : IF ModeCheck(Ball,4) THEN e = .PwmSS->E5 ELSE m = 2
      CASE P9_42 : IF ModeCheck(Ball,0) THEN e = .PwmSS->E5 ' pin not in CAP mode
      'CASE P8_15 : IF ModeCheck(Ball,5) THEN e = .PwmSS->E5 ELSE m = -1 ' pr1_ecap0_ecap_capin_apwm_o (also on P9_42)
      CASE JT_04 : IF ModeCheck(Ball,4) THEN e = .PwmSS->E5 ELSE m = 2
      'CASE 88 : IF ModeCheck(Ball,2) THEN e = .PwmSS->E5 ELSE m = 1
      'CASE 98 : IF ModeCheck(Ball,3) THEN e = .PwmSS->E5 ELSE m = 2
      'CASE 99 : IF ModeCheck(Ball,3) THEN e = .PwmSS->E5 ELSE m = 1
      CASE ELSE  : e = .PwmSS->E6 ' pin has no CAP capability
      END SELECT
    END IF : IF e THEN .Errr = e                          : RETURN .Errr

    IF .DRam[0] > PRUIO_MSG_IO_OK THEN
      IF Hz THEN *Hz = 0
      IF Du THEN *Du = 0
                        .Errr = @"IO/RB mode not running" : RETURN .Errr
    END IF
  END WITH
  WITH *Top->PwmSS->Raw(m)
    IF .CMax THEN
      IF Hz THEN *Hz = IIF(.C2, PWMSS_CLK / .C2, 0.)
      IF Du THEN *Du = IIF(.C2, (.C2 - .C1) / .C2, 0.)
                                                                RETURN 0
    END IF
    IF Hz THEN *Hz = 0
    IF Du THEN *Du = 0
    Top->Errr = Top->PwmSS->E5                        : RETURN Top->Errr ' pin not in CAP mode
  END WITH
END FUNCTION



/'* \brief The constructor for QEP features of the PWMSS.
\param T A pointer of the calling PruIo structure.

Each of the three Pulse Width Modulation SubSystems (PWMSS) in the CPU
contains modules (PWM, CAP and QEP). In order to create a clear API
from the user point of view, the functions to control the modules are
separated to extra classes. This UDT contains functions to control the
QEP module, which is used to analyse the outputs of quadrature
encoder pulse trains.

The constructor just copies a pointer to the calling main UDT PruIo.

\since 0.4.0
'/
CONSTRUCTOR QepMod(BYVAL T AS Pruio_ PTR)
  Top = T
END CONSTRUCTOR


/'* \brief Configure header pins and a eQEP module.
\param Ball The CPU ball number (either input A, B or I).
\param PMax The maximum position counter value (defaults to &h7FFFFFFF).
\param VHz The frequency to compute velocity values (defaults to 25 Hz).
\param Scale The Scale factor for velocity values (defaults to 1.0).
\param Mo The modus to use for pinmuxing (0 or PRUIO_PIN_RESET).
\returns Zero on success (otherwise a string with an error message).

This function configures headers pins to be used for quadrature encoder
sensors (analysed by the QEP subsystem). By default the module gets
configured to work in Quadrature Count Mode, meaning that the
Quadrature detector is used to analyse raw input. See subsection \ref
sSecQep for further information and see \ArmRef{15.4.2.5} for
details.

Up to three header pins may get configured, but only one of the pins get
specified by parameter `Ball` directly. The other pins are configured
internally, depending on the type of the specified pin. libpruio
selects the matching pins for the subsystem connected to the specified
pin (parameter `Ball`).

- When an A input pin is specified, the QEP system runs in frequency
  count mode. No position is available (always counts upwards) and the
  velocity is always positive (no direction gets detected).

- When an B input pin is specified, the QEP system runs in position /
  velocity mode, but no reference position (index) is detected.

- When an Index input pin is specified, the QEP system runs in position
  / velocity mode, and the reference index position is used to reset
  the position counter.

Parameter `PMax` is the maximum value for the position counter. On
overflow (`Pos > PMax`) the counter starts at 0 (zero) again. In case
of an underflow (`Pos < 0`) the counter continues at PMax. Note that
each impulse is counted four times (positive and negative transition,
input A and B). Ie. for a rotary encoder with 1024 impulses specify
the PMax parameter as `4095 = 1024 * 4 - 1`. The maximum value is
&h7FFFFFFF (which is the default). The highest bit is reserved for
velocity computation. Higher values can get specified, but will result
in inaccurate velocity computation in case of an position counter over-
or underflow.

Parameter `VHz` is the frequency to update velocity computation. The
capture unit of the QEP module is used to generate velocity input and
to latch the input values at the given frequency. The minimal frequency
is less than 12 Hz and the maximum ferquency is 50 GHz. The higher the
frequency, the less is the resolution of the speed measurement. So it's
recommended to use the lowest possible frequency. The default value is
25 Hz.

Parameter `Scale` is a factor to be applied to the computed velocity
value. By default this factor is 1.0 and the velocity gets computed as
transitions per second. Ie. to compute the rotational speed in rpm of a
sensor with 1024 lines per revolution, set this factor as

~~~{.bas}
Scale = 60 [s/min] / (1024 [imp/rev] * 4 [cnt/imp])
~~~

Wrapper function (C or Python): pruio_qep_config().

\since 0.4.0
'/
FUNCTION QepMod.config CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL PMax AS UInt32 = &h7FFFFFFFul _
  , BYVAL VHz AS Float_t = 25. _
  , BYVAL Scale AS Float_t = 1. _
  , BYVAL Mo AS UInt8 = 0) AS ZSTRING PTR

  VAR m = 0, x = 0
  STATIC AS Float_t fmin = PWMSS_CLK / (&hFFFF SHL 7) ' minimal frequency
  WITH *Top
    IF VHz < fmin ORELSE VHz > PWMSS_CLK_2 THEN _
                                          .Errr = .PwmSS->E2 : RETURN .Errr ' frequency not supported
    SELECT CASE AS CONST Ball
    CASE P8_11, P8_12, P8_16 : m = 2
      VAR v = IIF(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h2C)
      IF ModeCheck(P8_12,4) THEN ModeSet(P8_12,v)
      IF Ball = P8_12 THEN                       x = 2 : EXIT SELECT
      IF ModeCheck(P8_11,4) THEN ModeSet(P8_11,v)
      IF Ball = P8_11 THEN                       x = 1 : EXIT SELECT
      IF ModeCheck(P8_16,4) THEN ModeSet(P8_16,v)
    CASE P8_33, P8_35, P8_31 : m = 1
      VAR v = IIF(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h2A)
      IF ModeCheck(P8_35,2) THEN ModeSet(P8_35,v)
      IF Ball = P8_35 THEN                       x = 2 : EXIT SELECT
      IF ModeCheck(P8_33,2) THEN ModeSet(P8_33,v)
      IF Ball = P8_33 THEN                       x = 1 : EXIT SELECT
      IF ModeCheck(P8_31,2) THEN ModeSet(P8_31,v)
    CASE P8_41, P8_42, P8_39 : m = 2
      VAR v = IIF(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h2B)
      IF ModeCheck(P8_41,3) THEN ModeSet(P8_41,v)
      IF Ball = P8_42 THEN                       x = 2 : EXIT SELECT
      IF ModeCheck(P8_42,3) THEN ModeSet(P8_42,v)
      IF Ball = P8_42 THEN                       x = 1 : EXIT SELECT
      IF ModeCheck(P8_39,3) THEN ModeSet(P8_39,v)
    CASE P9_27, P9_42, 104, P9_41, 106 : m = 0
      VAR v = IIF(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h29)
      IF ModeCheck( 104 ,1) THEN ModeSet( 104 ,v)
      IF Ball = P9_42 ORELSE Ball = 104 THEN     x = 2 : EXIT SELECT
      IF ModeCheck(P9_27,1) THEN ModeSet(P9_27,v)
      IF Ball = P9_27 THEN                       x = 1 : EXIT SELECT
      IF ModeCheck( 106 ,1) THEN ModeSet( 106 ,v)
    CASE ELSE :                           .Errr = .PwmSS->E8 : RETURN .Errr' pin has no QEP capability
    END SELECT
    IF 2 <> .PwmSS->Conf(m)->ClVa THEN    .Errr = .PwmSS->E0 : RETURN .Errr' PWMSS not enabled
  END WITH
  WITH *Top->PwmSS->Conf(m)
    .QPOSCNT = 0
    .QPOSINIT = 0
    .QPOSMAX = PMax
    .QPOSLAT = 0
    .QUTMR = 0
    .QUPRD = cuint(PWMSS_CLK / VHz)

    VAR ccps = .QUPRD \ &h10000
    IF ccps > 1 THEN ccps = 1 + INT(LOG(ccps) / LOG(2))
    SELECT CASE AS CONST x
    CASE 2 '                                               up count mode
      .QDECCTL = &b1000000000000000
      .QEPCTL  = &b0001000010001110
      .QCAPCTL = &b1000000000000000 or (ccps shl 4)
    CASE 1 '                                        direction count mode
      .QDECCTL = &b0000000000000000
      .QEPCTL  = &b0001000010001110
      .QCAPCTL = &b1000000000000010 or (ccps shl 4)
    CASE ELSE '                          direction count mode with index
      .QDECCTL = &b0000000000000000
      .QEPCTL  = &b0000001010001110
      .QCAPCTL = &b1000000000000010 or (ccps shl 4)
    END SELECT
    .QPOSCTL = &b0000000000000000
    .QCTMR = 0
    .QCPRD = 0

    VAR fx = 1 SHL ((.QCAPCTL SHR 4) AND &b111) _
      , fp = 1 SHL (.QCAPCTL AND &b1111) _
      , t = .QUPRD \ fx _
      , p2 = fp / 2
    FVh(m) = Scale * PWMSS_CLK / .QUPRD
    FVl(m) = Scale * PWMSS_CLK / fx * fp
    Prd(m) = CUINT(fp * t / (-p2 + SQR(p2 * p2 + t / fp))) SHL 16
    IF Top->DRam[0] > PRUIO_MSG_IO_OK THEN                     RETURN 0

    WHILE Top->DRam[1] : WEND '                     wait, if PRU is busy
    Top->DRam[6] = .QCAPCTL
    Top->DRam[5] = .QDECCTL OR .QEPCTL SHL 16
    Top->DRam[4] = .QUPRD
    Top->DRam[3] = .QPOSMAX
    Top->DRam[2] = .DeAd + &h180
    Top->DRam[1] = PRUIO_COM_QEP SHL 24
  END WITH :                                                   RETURN 0
END FUNCTION


/'* \brief Analyse the QEP input pulse trains, get position and velocity.
\param Ball The CPU ball number (as in QepMod::config() call).
\param Posi A pointer to store the position value (or NULL).
\param Velo A pointer to store the valocity value (or NULL).
\returns Zero on success (otherwise a string with an error message).

Compute position and speed from the sensor pulse trains. Either a
single sensor signal gets evaluated (when an A input is specified as
parameter `Ball`) to compute Velo information only. Or two sensor
signals get evaluated to compute the speed and the position (when a B
or C input is specified as parameter `Ball`).

The position value is scaled in transitions (since the start or the
last index impulse) and counts upwards in case of a single input (A pin
passed as parameter `Ball`). Otherwise the position gets counted
considering the direction. The `Velo` value is scaled as transitions
per second by default and get customized by parameter `Scale` in the
previous call to function QepMod::config(). Either of the parameters
`Posi` or `Velo` may be NULL to skip this computation.

In order to speed up execution this function doesn't check the
configuration of all input pins, meaning it computes (erratic) output
even if some (or all) of the pins are not in the matching
configuration.

Wrapper function (C or Python): pruio_qep_Value().

\since 0.4.0
'/
FUNCTION QepMod.Value CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Posi AS UInt32 PTR = 0 _
  , BYVAL Velo AS Float_t PTR = 0) AS ZSTRING PTR

  VAR m = 0
  WITH *Top
    SELECT CASE AS CONST Ball
    CASE P8_12 : Posi = 0 : m = 2
    CASE P8_11, P8_16 :     m = 2
    CASE P8_35 : Posi = 0 : m = 1
    CASE P8_33, P8_31 :     m = 1
    CASE P8_41 : Posi = 0 : m = 2
    CASE P8_42, P8_39 :     m = 2
    CASE P9_42, 104 : Posi = 0 : m = 0
    CASE P9_27, P9_41, 106 :     m = 0
    CASE ELSE  :                       .Errr = .PwmSS->E0 : RETURN .Errr 'PwmSS not enabled
    END SELECT

    IF .DRam[0] > PRUIO_MSG_IO_OK THEN
      IF Posi THEN *Posi = 0
      IF Velo THEN *Velo = 0.
                        .Errr = @"IO/RB mode not running" : RETURN .Errr
    END IF
  END WITH
  WITH *Top->PwmSS->Raw(m)
    IF Velo THEN
      VAR dx = CINT(.NPos - .OPos)
      IF .PLat > Prd(m) THEN
        *Velo = dx * FVh(m)
      ELSE
        *Velo = IIF(HIWORD(.PLat), SGN(dx) * FVl(m) / HIWORD(.PLat), 0.)
      END IF
    END IF
    IF Posi THEN *Posi = .QPos
  END WITH :                                                    RETURN 0
END FUNCTION
