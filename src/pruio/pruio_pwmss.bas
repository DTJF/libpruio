/'* \file pruio_pwmss.bas
\brief The PWMSS component source code.

Source code file containing the function bodies of the PWMSS component.
The code for the subsystem PWMSS and its modules (eQEP, eCAP and ePWM)
is in here.

\since 0.2
'/


' PruIo global declarations.
#include ONCE "pruio_globals.bi"
' Header for PWMSS part, containing modules QEP, CAP and PWM.
#include ONCE "pruio_pwmss.bi"
'' Header for TIMER part.
'#include ONCE "pruio_timer.bi"
' driver header file
#include ONCE "pruio.bi"
' Header file with convenience macros.
#include ONCE "pruio_pins.bi"

'* The clock frequency
#define PWMSS_CLK  100e6
'* The half clock frequency
#define PWMSS_CLK_2 50e6


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
           .IDVER = 0 THEN _ '                     subsystem not enabled
              .DeAd = 0 : .ClVa = 0 : p_mem += 16 : CONTINUE FOR
        .ClVa = 2
        .SYSCONFIG = 2 SHL 2
        .CLKCONFIG = &b0100010001 ' enable all modules
        ' ePWM registers
        .TBPHS = 0
        .TBSTS = &b110
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

'* Macro to check a CPU ball mode (ball must be in valid range, 0 to 109).
#DEFINE ModeCheck(_B_,_M_) (.BallConf[_B_] and &b111) <> _M_

'* Macro to check a CPU ball mode.
#DEFINE ModeSet(_B_,_M_) IF .setPin(_B_, _M_) THEN RETURN .Errr


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


/'* \brief Compute header pin PWM output configuration.
\param Ball The pin index.
\param Hz A pointer to output the frequency value (or 0 for no output).
\param Du A pointer to output the duty value (or 0 for no output).
\returns Zero on success, an error string otherwise.

This functions computes the real PWM output of a header pin. The real
setting may differ from the parameters passed to function
PwmMod::setValue(). Use this function to compute the active settings.

C-wrapper function: pruio_pwm_Value().

\since 0.2
'/
FUNCTION PwmMod.Value CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0) AS ZSTRING PTR

  WITH *Top
    DIM AS ZSTRING PTR e
    SELECT CASE AS CONST Ball
    CASE P8_07 : e = IIF(ModeCheck(Ball,2), E1, .TimSS->pwm_get(0, Hz, Du))
    CASE P8_09 : e = IIF(ModeCheck(Ball,2), E1, .TimSS->pwm_get(1, Hz, Du))
    CASE P8_10 : e = IIF(ModeCheck(Ball,2), E1, .TimSS->pwm_get(2, Hz, Du))
    CASE P8_08 : e = IIF(ModeCheck(Ball,2), E1, .TimSS->pwm_get(3, Hz, Du))
    CASE P8_13 : e = IIF(ModeCheck(Ball,4), E1, pwm_get(2, Hz, Du, 1))
    CASE P8_19 : e = IIF(ModeCheck(Ball,4), E1, pwm_get(2, Hz, Du, 0))
    CASE P8_34 : e = IIF(ModeCheck(Ball,2), E1, pwm_get(1, Hz, Du, 1))
    CASE P8_36 : e = IIF(ModeCheck(Ball,2), E1, pwm_get(1, Hz, Du, 0))
    CASE P8_45 : e = IIF(ModeCheck(Ball,3), E1, pwm_get(2, Hz, Du, 1))
    CASE P8_46 : e = IIF(ModeCheck(Ball,3), E1, pwm_get(2, Hz, Du, 0))
    CASE P9_14 : e = IIF(ModeCheck(Ball,6), E1, pwm_get(1, Hz, Du, 0))
    CASE P9_16 : e = IIF(ModeCheck(Ball,6), E1, pwm_get(1, Hz, Du, 1))
    CASE P9_21 : e = IIF(ModeCheck(Ball,3), E1, pwm_get(0, Hz, Du, 1))
    CASE P9_22 : e = IIF(ModeCheck(Ball,3), E1, pwm_get(0, Hz, Du, 0))
    CASE P9_29 : e = IIF(ModeCheck(Ball,1), E1, pwm_get(0, Hz, Du, 1))
    CASE P9_31 : e = IIF(ModeCheck(Ball,1), E1, pwm_get(0, Hz, Du, 0))
    CASE P9_28 : e = IIF(ModeCheck(Ball,4), E1, cap_get(2, Hz, Du))
    CASE JT_05 : e = IIF(ModeCheck(Ball,4), E1, cap_get(1, Hz, Du))
    CASE P9_42 : e = IIF(ModeCheck(Ball,0), E1, cap_get(0, Hz, Du))
    'CASE P8_15 : e = IIF(ModeCheck(Ball,5), E1, pru_cap_get(Hz, Du))
    CASE ELSE  : e = E0
    END SELECT : IF e THEN .Errr = e :                      RETURN .Errr
  END WITH : RETURN 0
END FUNCTION


/'* \brief Set PWM output on a header pin.
\param Ball The CPU ball number.
\param Hz The frequency to set (or -1 for no change).
\param Du The duty cycle to set (0.0 to 1.0, or -1 for no change).
\returns Zero on success (otherwise a string with an error message).

This function sets PWM output on a header pin. PWM output may either be
generated by a eHRPWM or a eCAP module. Depending on the specified pin
number (parameter *Ball*), the corresponding PWMSS module gets
configured to the specified frequency and duty cycle.

It's recommended to make the first call to this function before the
call to function PruIo::config(), because eCAP pins (P9_28 or
P9_42) can be used in PWM output and in CAP input mode. A mode change
happens when the configurations gets transfered from the host to the
PRU. Also, when an eCAP pin is currently used as input, the new PWM
output mode gets active after the next call to function
PruIo::config().

Only positive values in the parameters *Hz* and *Du* force a
change. Pass a negative value to stay with the current setting. A duty
parameter greater than 1.0 gets limited to 1.0 (= 100%).

In the first call to this function, the parameter *Hz* must be
greater than 0 (zero), to set a valid period time. But both outputs A
and B of an eHRPWM module must run at the same frequency, so you need
not set the *Hz* parameter when you set the *Du* for the secand
output.

The hardware settings (integer values) are computed to match the passed
parameters *Hz* and *Du* as close as possible. Some parameter
combinations are impossible to match exactly, due to hardware
limitations (ie. 17 bit resolution in case of eHRPWM modules). Use
function PwmMod::Value() to compute the active settings and
calculate differences.

C-wrapper function: pruio_pwm_setValue().

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
      RETURN pwm_set(2, Hz, -1., Du)
    CASE P8_19 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h0C)
      RETURN pwm_set(2, Hz, Du, -1.)
    CASE P8_34 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)
      RETURN pwm_set(1, Hz, -1., Du)
    CASE P8_36 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)
      RETURN pwm_set(1, Hz, Du, -1.)
    CASE P8_45 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h0B)
      RETURN pwm_set(2, Hz, -1., Du)
    CASE P8_46 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h0B)
      RETURN pwm_set(2, Hz, Du, -1.)
    CASE P9_14 : IF ModeCheck(Ball,6) THEN ModeSet(Ball, &h0E)
      RETURN pwm_set(1, Hz, Du, -1.)
    CASE P9_16 : IF ModeCheck(Ball,6) THEN ModeSet(Ball, &h0E)
      RETURN pwm_set(1, Hz, -1., Du)
    CASE P9_21 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h0B)
      RETURN pwm_set(0, Hz, -1., Du)
    CASE P9_22 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h0B)
      RETURN pwm_set(0, Hz, Du, -1.)
    CASE P9_29 : IF ModeCheck(Ball,1) THEN ModeSet(Ball, &h09)
      RETURN pwm_set(0, Hz, -1., Du)
    CASE P9_31 : IF ModeCheck(Ball,1) THEN ModeSet(Ball, &h09)
      RETURN pwm_set(0, Hz, Du, -1.)
    CASE P9_28 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h0C)
      RETURN cap_set(2, Hz, Du)
    CASE JT_05 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h0C)
      RETURN cap_set(1, Hz, Du)
    CASE P9_42 : IF ModeCheck(Ball,0) THEN ModeSet(Ball, &h08)
      RETURN cap_set(0, Hz, Du)
    'CASE P8_15 : IF ModeCheck(Ball,5) THEN ModeSet(Ball, &h0D)
      'RETURN pru_cap_set(Hz, Du)
    END SELECT :                               .Errr = E0 : RETURN .Errr
  END WITH
END FUNCTION


/'* \brief Compute PWM output configuration from an eCAP module (private).
\param Nr The PWMSS subsystem index.
\param Freq A pointer to output the frequency value (or 0 for no output).
\param Duty A pointer to output the duty value (or 0 for no output).
\returns Zero on success, an error string otherwise.

This private functions computes the real PWM configuration of an eCAP
module. It's designed to get called from function PwmMod::Value().

\note This is a private function designed for internal use. It doesn't
      check the validity of the *Nr* parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.2
'/
FUNCTION PwmMod.cap_get CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL Freq AS Float_t PTR = 0 _
  , BYVAL Duty AS Float_t PTR = 0) AS ZSTRING PTR

  WITH *Top->PwmSS->Conf(Nr)
    IF 2 <> .ClVa THEN Top->Errr = E2  /' PWM not enabled '/ : RETURN E2
    IF 0 = BIT(.ECCTL2, 9) THEN RETURN @"eCAP module not in output mode"
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
      check the validity of the *Nr* parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.2
'/
FUNCTION PwmMod.cap_set CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL F AS Float_t _
  , BYVAL D AS Float_t = 0.) AS ZSTRING PTR

  STATIC AS CONST Float_t _
    f_min = PWMSS_CLK / &hFFFFFFFFuL '' minimal frequency
  'STATIC AS Float_t _
   'freq(...) = {0., 0., 0.} '' initial module frequencies
  STATIC AS UInt32 _
    cnt(...) = {0, 0, 0} _  '' initial module periods
  , cmp(...) = {0, 0, 0}    '' initial module compares

  WITH *Top
    VAR r = 0
    IF 2 <> .PwmSS->Conf(Nr)->ClVa THEN           .Errr = E2 : RETURN E2 ' PWM not enabled
    IF 0 = cnt(Nr) ANDALSO _
      F <= 0. THEN                                .Errr = E3 : RETURN E3' set frequency first
    WITH *.PwmSS
      IF F > 0. THEN
        IF F < f_min ORELSE _
           F > PWMSS_CLK_2 THEN               Top->Errr = E4 : RETURN E4 ' frequency not supported
       cnt(Nr) = CUINT(PWMSS_CLK / F)
      END IF
      IF D >= 0 THEN cmp(Nr) = IIF(D > 1., cnt(Nr), CUINT(cnt(Nr) * D))

      .Conf(Nr)->CAP1 = cnt(Nr)
      .Conf(Nr)->CAP2 = cmp(Nr)
      IF .Conf(Nr)->ECCTL2 <> .PwmMode THEN
        .Conf(Nr)->ECCTL2 = .PwmMode
        .Raw(Nr)->CMax = 0
        r = .PwmMode
      END IF
    END WITH

    IF .DRam[0] > PRUIO_MSG_IO_OK THEN                          RETURN 0

    WHILE .DRam[1] : WEND '   wait, if PRU is busy (should never happen)
    .DRam[4] = cmp(Nr)
    .DRam[3] = cnt(Nr)
    .DRam[2] = .PwmSS->Conf(Nr)->DeAd + &h100
    .DRam[1] = r OR (PRUIO_COM_CAP_PWM SHL 24)
  END WITH :                                                    RETURN 0
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
      check the validity of the *Nr* parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.2
'/
FUNCTION PwmMod.pwm_get CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL F AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0  _
  , BYVAL Mo AS UInt8) AS ZSTRING PTR

  WITH *Top->PwmSS->Conf(Nr)
    IF 2 <> .ClVa THEN Top->Errr = E2  /' PWM not enabled '/ : RETURN E2
    VAR p = CAST(UInt32, .TBPRD)
    IF F THEN
      VAR d1 = (.TBCTL SHR 7) AND &b111, d2 = (.TBCTL SHR 10) AND &b111
      VAR cg = p * IIF(d1, d1 SHL 1, 1) * (1 SHL d2)
      *F = PWMSS_CLK / IIF(BIT(.TBCTL, 1), cg SHL 1, cg + 1)
    END IF
    IF Du THEN
      VAR c = CAST(UInt32, IIF(Mo, .CMPB, .CMPA))
      IF BIT(.TBCTL, 1) THEN '                             count up-down
        p SHL= 1
        IF IIF(Mo, .AQCTLB, .AQCTLA) AND &b010001000000 THEN c = p - c
      ELSE '                                                    count up
        p += 1
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
current setting. Duty parameters (*Da* and *Db*) greater than 1.0 get
limited to 1.0 (= 100%).

\note This is a private function designed for internal use. It doesn't
      check the validity of the *Nr* parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.2
'/
FUNCTION PwmMod.pwm_set CDECL( _
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
  WITH *Top->PwmSS->Conf(Nr)
    IF 2 <> .ClVa THEN                        Top->Errr = E2 : RETURN E2 ' PWM not enabled
    IF 0 = cnt(Nr) THEN
      IF F <= 0. THEN                         Top->Errr = E3 : RETURN E3 ' set frequency
    ELSE
      IF F > 0. ANDALSO freq(Nr) <> F THEN cnt(Nr) = 0
    END IF

    IF 0 = cnt(Nr) THEN '                    calc new period (frequency)
      VAR cycle = IIF(F > f_min ANDALSO F <= PWMSS_CLK_2, CUINT(.5 + PWMSS_CLK / F), 0uL)
      IF 2 > cycle THEN                       Top->Errr = E4 : RETURN E4 ' frequency not supported

      freq(Nr) = ABS(F)
      IF cycle <= &h10000 ANDALSO 0 = BIT(ForceUpDown, Nr) THEN ' count up mode
        cnt(Nr) = cycle - 1
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
      ctl OR= (3 SHL 14) + (Cntrl(Nr) AND &b0010000001111100)
      .TBCTL = ctl
      .TBPRD = cnt(Nr)
      .TBCNT = 0
      c_a(Nr) = 0
      c_b(Nr) = 0
    END IF

    IF Da >= 0. THEN d_a(Nr) = IIF(Da > 1., 1., Da) : c_a(Nr) = 0
    IF 0 = c_a(Nr) THEN '                     calc new duty for A output
      IF BIT(.TBCTL, 1) ORELSE BIT(ForceUpDown, Nr) THEN '  up-down mode
        IF d_a(Nr) >= .5 _
          THEN .AQCTLA = AqCtl(0, Nr, 2) : c_a(Nr) = CUINT((cnt(Nr) SHL 1) * (1 - d_a(Nr))) _
          ELSE .AQCTLA = AqCtl(0, Nr, 1) : c_a(Nr) = CUINT((cnt(Nr) SHL 1) * d_a(Nr))
      ELSE '                                                    up mode
               .AQCTLA = AqCtl(0, Nr, 0) : c_a(Nr) = CUINT(.5 + (cnt(Nr) + 1) * d_a(Nr))
      END IF
      .CMPA = c_a(Nr)
    END IF

    IF Db >= 0. THEN d_b(Nr) = IIF(Db > 1., 1., Db) : c_b(Nr) = 0
    IF 0 = c_b(Nr) THEN '                     calc new duty for B output
      IF BIT(.TBCTL, 1) ORELSE BIT(ForceUpDown, Nr) THEN '  up-down mode
        IF d_b(Nr) >= .5 _
          THEN .AQCTLB = AqCtl(1, Nr, 2) : c_b(Nr) = CUINT((cnt(Nr) SHL 1) * (1 - d_b(Nr))) _
          ELSE .AQCTLB = AqCtl(1, Nr, 1) : c_b(Nr) = CUINT((cnt(Nr) SHL 1) * d_b(Nr))
      ELSE '                                                    up mode
               .AQCTLB = AqCtl(1, Nr, 0) : c_b(Nr) = CUINT(.5 + (cnt(Nr) + 1) * d_b(Nr))
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

The parameter *FLow* specifies the minimal frequency to measure in Hz.
When not set (values < .0232831) and the input doesn't change, the
counter runs until an overflow before it returns the new values (in
this case frequency = 0 and duty cycle = 0). This lasts about 43
seconds before the new values are available. To shorten this time, you
can specify the lowest frequency. When a period without change is over,
the counter gets restarted.

C-wrapper function: pruio_cap_config().

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
    'CASE JT_04 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h24) ' input???
      'm = 1
    CASE P9_42 : IF ModeCheck(Ball,0) THEN ModeSet(Ball, &h20)
    'CASE P8_15 : IF ModeCheck(Ball,5) THEN ModeSet(Ball, &h25) ' pr1_ecap0_ecap_capin_apwm_o (also on P9_42)
    'CASE    88 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h22)
      'm = 1
    'CASE    93 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h24)
      'm = 1
    'CASE    98 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h23)
      'm = 2
    'CASE    99 : IF ModeCheck(Ball,3) THEN ModeSet(Ball, &h23)
      'm = 1
    CASE ELSE                                : .Errr = E0 : RETURN .Errr
    END SELECT
  END WITH
  WITH *Top->PwmSS
    IF 2 <> .Conf(m)->ClVa THEN            Top->Errr = E2 : RETURN E2 ' CAP not enabled
    VAR cnt = &hFFFFFFFFul
    IF FLow > PWMSS_CLK/ &hFFFFFFFFul THEN
      cnt = CUINT(PWMSS_CLK / FLow)
      IF cnt < 200 THEN cnt = 200
    END IF
    .Raw(m)->CMax = cnt

    IF .Conf(m)->ECCTL2 <> .CapMode THEN ' eCAP module not in input mode
      .Conf(m)->ECCTL2 = .CapMode
      IF Top->DRam[0] > PRUIO_MSG_IO_OK THEN                    RETURN 0

      WHILE Top->DRam[1] : WEND '                   wait, if PRU is busy
      Top->DRam[2] = .Conf(m)->DeAd + &h100
      Top->DRam[1] = .CapMode + (PRUIO_COM_CAP SHL 24)
    END IF
  END WITH :                                                    RETURN 0
END FUNCTION


/'* \brief Analyse a digital pulse train, get frequency and duty cycle.
\param Ball The CPU ball number to test.
\param Hz A pointer to store the frequency value (or null).
\param Du A pointer to store the duty cycle value (or null).
\returns Zero on success (otherwise a string with an error message).

This function returns the frequency and duty cycle of a digital pulse
train on a header pin. The header pin needs to get configured first by
a call to function CapMod::config().

The parameters *Hz* and *Du* contain the results of the last measured
period. You can pass a zero pointer to either of them if you don't need
this value.

A period is limited by the counter resolution. The minimal frequency is
0.0232831 Hz, so a period lasts maximal 43 seconds. When the state of
the input pin doesn't change twice during a period, the counter
restarts and zero gets returned for both results (*Hz* and *Du*). The
minimal frequency can get adapted by parameter *FLow* in the previous
call to function CapMod::config().

C-wrapper function: pruio_cap_Value().

\since 0.2
'/
FUNCTION CapMod.Value CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0) AS ZSTRING PTR

  VAR m = 0
  WITH *Top
    DIM AS ZSTRING PTR e
    SELECT CASE AS CONST Ball
    CASE P9_28 : IF ModeCheck(Ball,4) THEN e = E1 ELSE m = 2
    'CASE JT_05 IF ModeCheck(Ball,4) THEN e = E1 ELSE m = 1  '-> eCAP1_in_PWM1_out, JTag header input???
    CASE P9_42 : IF ModeCheck(Ball,0) THEN e = E1
    'CASE P8_15: IF ModeCheck(Ball,5) THEN e = E1 ELSE m = -1 ' pr1_ecap0_ecap_capin_apwm_o (also on P9_42)
    'CASE 88 : IF ModeCheck(Ball,2) THEN e = E1 ELSE m = 1
    'CASE 93 : IF ModeCheck(Ball,4) THEN e = E1 ELSE m = 1
    'CASE 98 : IF ModeCheck(Ball,3) THEN e = E1 ELSE m = 2
    'CASE 99 : IF ModeCheck(Ball,3) THEN e = E1 ELSE m = 1
    CASE ELSE  : e = E0
    END SELECT : IF e THEN .Errr = e                      : RETURN .Errr

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
    Top->Errr = E2                     /' CAP not enabled '/ : RETURN E2
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
SubSecQep for further information and see \ArmRef{15.4.2.5} for
details.

Up to three header pins may get configured, but only one of the pins get
specified by parameter *Ball* directly. The other pins are configured
internally, depending on the type of the specified pin. libpruio
selects the matching pins for the subsystem connected to the specified
pin (parameter *Ball*).

- When an A input pin is specified, the QEP system runs in frequency
  count mode. No position is available (always counts upwards) and the
  velocity is always positive (no direction gets detected).

- When an B input pin is specified, the QEP system runs in position /
  velocity mode, but no reference position (index) is detected.

- When an Index input pin is specified, the QEP system runs in position
  / velocity mode, and the reference index position is used to reset
  the position counter.

Parameter *PMax* is the maximum value for the position counter. On
overflow (`Pos > PMax`) the counter starts at 0 (zero) again. In case
of an underflow (`Pos < 0`) the counter continues at PMax. Note that
each impulse is counted four times (positive and negative transition,
input A and B). Ie. for a rotary encoder with 1024 impulses specify
the PMax parameter as `4095 = 1024 * 4 - 1`. The maximum value is
&h7FFFFFFF (which is the default). The highest bit is reserved for
velocity computation. Higher values can get specified, but will result
in inaccurate velocity computation in case of an position counter over-
or underflow.

Parameter *VHz* is the frequency to update velocity computation. The
capture unit of the QEP module is used to generate velocity input and
to latch the input values at the given frequency. The minimal frequency
is less than 12 Hz and the maximum frquency is 50 GHz. The higher the
frequency, the less is the resolution of the speed measurement. So it's
recommended to use the lowest possible frequency. The default value is
25 Hz.

Parameter *Scale* is a factor to be applied to the computed velocity
value. By default this factor is 1.0 and the velocity gets computed as
transitions per second. Ie. to compute the rotational speed in rpm of a
sensor with 1024 lines per revolution, set this factor as

~~~{.bas}
Scale = 60 [s/min] / (1024 [imp/rev] * 4 [cnt/imp])
~~~

C-wrapper function: pruio_qep_config().

\since 0.4.0
'/
FUNCTION QepMod.config CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL PMax AS UInt32 = 0 _
  , BYVAL VHz AS Float_t = 25. _
  , BYVAL Scale AS Float_t = 1. _
  , BYVAL Mo AS UInt8 = 0) AS ZSTRING PTR

  VAR m = 0, x = 0
  STATIC AS Float_t fmin = PWMSS_CLK / (&hFFFF SHL 7) ' minimal frequency
  WITH *Top
    IF VHz < fmin ORELSE VHz > PWMSS_CLK_2 THEN _
                          .Errr = @"frequency not supported" : RETURN .Errr
    SELECT CASE AS CONST Ball
    CASE P8_11, P8_12, P8_16 : m = 2
      VAR v = IIF(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h2C)
      IF ModeCheck(P8_12,4) THEN ModeSet(P8_12,v)
      IF Ball = P8_12 THEN x = 2 : EXIT SELECT
      IF ModeCheck(P8_11,4) THEN ModeSet(P8_11,v)
      IF Ball = P8_11 THEN x = 1 : EXIT SELECT
      IF ModeCheck(P8_16,4) THEN ModeSet(P8_16,v)
    CASE P8_33, P8_35, P8_31 : m = 1
      VAR v = IIF(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h2A)
      IF ModeCheck(P8_35,2) THEN ModeSet(P8_35,v)
      IF Ball = P8_35 THEN x = 2 : EXIT SELECT
      IF ModeCheck(P8_33,2) THEN ModeSet(P8_33,v)
      IF Ball = P8_33 THEN x = 1 : EXIT SELECT
      IF ModeCheck(P8_31,2) THEN ModeSet(P8_31,v)
    CASE P8_41, P8_42, P8_39 : m = 2
      VAR v = IIF(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h2B)
      IF ModeCheck(P8_41,3) THEN ModeSet(P8_41,v)
      IF Ball = P8_42 THEN x = 2 : EXIT SELECT
      IF ModeCheck(P8_42,3) THEN ModeSet(P8_42,v)
      IF Ball = P8_42 THEN x = 1 : EXIT SELECT
      IF ModeCheck(P8_39,3) THEN ModeSet(P8_39,v)
    CASE P9_27, P9_42, 104, P9_41, 106 : m = 0
      VAR v = IIF(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h29)
      IF ModeCheck( 104 ,1) THEN ModeSet( 104 ,v)
      IF Ball = P9_42 ORELSE Ball = 104 THEN x = 2 : EXIT SELECT
      IF ModeCheck(P9_27,1) THEN ModeSet(P9_27,v)
      IF Ball = P9_27 THEN x = 1 : EXIT SELECT
      IF ModeCheck( 106 ,1) THEN ModeSet( 106 ,v)
    CASE ELSE :  /'  pin has no QEP capability '/ .Errr = E0 : RETURN .Errr
    END SELECT
  END WITH
  WITH *Top->PwmSS->Conf(m)
    IF 2 <> .ClVa THEN  /' QEP not enabled '/ Top->Errr = E2 : RETURN E2
    .QPOSCNT = 0
    .QPOSINIT = 0
    '.QPOSMAX = iif(PMax andalso x <> 2, PMax, &h7FFFFFFFuL)
    .QPOSLAT = 0
    .QUTMR = 0
    .QUPRD = cuint(PWMSS_CLK / VHz)

    VAR ccps = .QUPRD \ &h10000
    IF ccps > 1 THEN ccps = 1 + INT(LOG(ccps) / LOG(2))
    SELECT CASE AS CONST x
    CASE 2 '                                               up count mode
      .QPOSMAX = &h7FFFFFFFuL
      .QDECCTL = &b1000000000000000
      .QEPCTL  = &b0001000010001110
      .QCAPCTL = &b1000000000000000 or (ccps shl 4)
    CASE 1 '                                        direction count mode
      .QPOSMAX = iif(PMax, PMax, &h7FFFFFFFuL)
      .QDECCTL = &b0000000000000000
      .QEPCTL  = &b0001000010001110
      .QCAPCTL = &b1000000000000010 or (ccps shl 4)
    CASE ELSE '                          direction count mode with index
      .QPOSMAX = iif(PMax, PMax, &h7FFFFFFFuL)
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
single sensor signal gets evaluated (when an A input was specified as
parameter *Ball* for function QepMod::config() ) to compute speed
information. Or two sensor signals gets evaluated to compute speed and
position information.

The position value is scaled in transitions (since the start or the
last index impulse) and counts upwards in case of a single input (A pin
passed as parameter *Ball* to QepMod::config()). Otherwise the position
gets counted considering the direction. The *Velo* value is scaled as
transitions per second by default and get get customized by parameter
*Scale* in the previous call to function QepMod::config(). Either of
the parameters *Posi* or *Velo* may be NULL to skip this computation.

In order to speed up execution this function doesn't check the
configuration of all input pins, meaning it computes (erratic) output
even if some (or all) of the pins are not in the matching
configuration.

C-wrapper function: pruio_qep_Value().

\since 0.4.0
'/
FUNCTION QepMod.Value CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Posi AS UInt32 PTR = 0 _
  , BYVAL Velo AS Float_t PTR = 0) AS ZSTRING PTR

  VAR m = 0
  WITH *Top
    SELECT CASE AS CONST Ball
    CASE P8_11, P8_12, P8_16 : m = 2
    CASE P8_33, P8_35, P8_31 : m = 1
    CASE P8_41, P8_42, P8_39 : m = 2
    CASE P9_27, P9_42, 104, P9_41, 106 : m = 0
    CASE ELSE  :                               .Errr = E0 : RETURN .Errr
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
