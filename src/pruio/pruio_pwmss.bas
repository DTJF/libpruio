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
' Header for TIMER part.
#include ONCE "pruio_timer.bi"
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
FUNCTION PwmssUdt.initialize cdecl() AS zstring ptr
  WITH *Top
    var p_mem = .MOffs + .DRam[InitParA] _
      , p_raw = cast(any ptr, .DRam) + PRUIO_DAT_PWM
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
    CASE P9_42 : e = IIF(ModeCheck(Ball,0), E1, cap_get(0, Hz, Du))
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
    CASE P9_42 : IF ModeCheck(Ball,0) THEN ModeSet(Ball, &h08)
      RETURN cap_set(0, Hz, Du)
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
  STATIC AS Float_t _
   freq(...) = {0., 0., 0.} '' initial module frequencies
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
  STATIC AS UInt16 pars(..., 1) = { _ '' dividers to scale the clock
      {   1, 0} _
    , {   2, 1} _
    , {   4, 2} _
    , {   6, 3} _
    , {   8, 4} _
    , {  10, 5} _
    , {  12, 6} _
    , {  14, 7} _
    , {  16, 2 + 2 SHL 3} _
    , {  20, 5 + 1 SHL 3} _
    , {  24, 6 + 1 SHL 3} _
    , {  28, 7 + 1 SHL 3} _
    , {  32, 2 + 3 SHL 3} _
    , {  40, 5 + 2 SHL 3} _
    , {  48, 3 + 3 SHL 3} _
    , {  56, 7 + 2 SHL 3} _
    , {  64, 4 + 3 SHL 3} _
    , {  80, 5 + 3 SHL 3} _
    , {  96, 6 + 3 SHL 3} _
    , { 112, 7 + 3 SHL 3} _
    , { 128, 0 + 7 SHL 3} _
    , { 160, 5 + 4 SHL 3} _
    , { 192, 6 + 4 SHL 3} _
    , { 224, 7 + 4 SHL 3} _
    , { 256, 1 + 7 SHL 3} _
    , { 320, 5 + 5 SHL 3} _
    , { 384, 3 + 6 SHL 3} _
    , { 448, 7 + 5 SHL 3} _
    , { 512, 2 + 7 SHL 3} _
    , { 640, 5 + 6 SHL 3} _
    , { 768, 3 + 7 SHL 3} _
    , { 896, 7 + 6 SHL 3} _
    , {1024, 4 + 7 SHL 3} _
    , {1280, 5 + 7 SHL 3} _
    , {1536, 6 + 7 SHL 3} _
    , {1792, 7 + 7 SHL 3} _
    }

  STATIC AS Float_t _
   freq(...) = {0., 0., 0.} _ ' module frequencies
  , d_a(...) = {0., 0., 0.} _ ' module duty A
  , d_b(...) = {0., 0., 0.}   ' module duty B
  STATIC AS UInt16 _
    cnt(...) = {0, 0, 0} _ ' module periods
  , c_a(...) = {0, 0, 0} _ ' module counters A
  , c_b(...) = {0, 0, 0}   ' module counters B

  VAR ctl = 0, aqc = 0
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
      IF cycle <= &h10000 THEN '                           count up mode
        cnt(Nr) = cycle - 1
      ELSEIF cycle < &h20000 THEN '        no divisor count up-down mode
        cnt(Nr) = cycle SHR 1
        ctl = 2
      ELSE '                                  divisor count up-down mode
        VAR x = UBOUND(pars) SHR 2 _
        , fac = cycle SHR 17 _
        ,   i = x SHL 1

        WHILE x '                          search matching clock divisor
          i += IIF(fac >= pars(i, 0), x, -x)
          x SHR= 1
        WEND
        WHILE fac >= pars(i, 0)
          i += 1
        WEND

        cnt(Nr) = CUINT(.5 + PWMSS_CLK_2 / pars(i, 0) / F)
        ctl = 2 _
            + (pars(i, 1) SHL 7) ' clock divisor
      END IF
      ctl += (1 SHL 15) _ ' free run
           + (1 SHL 13) _ ' count up after SYNCI
           + (3 SHL 4)    ' dissable SYNCO
      .TBCTL = ctl
      .TBPRD = cnt(Nr)
      .TBCNT = 0
      c_a(Nr) = 0
      c_b(Nr) = 0
    END IF

    IF Da >= 0. THEN d_a(Nr) = IIF(Da > 1., 1., Da) : c_a(Nr) = 0
    IF 0 = c_a(Nr) THEN '                     calc new duty for A output
      IF BIT(.TBCTL, 1) THEN '                              up-down mode
        IF d_a(Nr) >= .5 _
          THEN .AQCTLA = &b000001000010 : c_a(Nr) = CUINT((cnt(Nr) SHL 1) * (1 - d_a(Nr))) _
          ELSE .AQCTLA = &b000000010010 : c_a(Nr) = CUINT((cnt(Nr) SHL 1) * d_a(Nr))
      ELSE '                                                     up mode
               .AQCTLA = &b000000010010 : c_a(Nr) = CUINT(.5 + (cnt(Nr) + 1) * d_a(Nr))
      END IF
      .CMPA = c_a(Nr)
    END IF

    IF Db >= 0. THEN d_b(Nr) = IIF(Db > 1., 1., Db) : c_b(Nr) = 0
    IF 0 = c_b(Nr) THEN '                     calc new duty for B output
      IF BIT(.TBCTL, 1) THEN '                              up-down mode
        IF d_b(Nr) >= .5 _
          THEN .AQCTLB = &b010000000010 : c_b(Nr) = CUINT((cnt(Nr) SHL 1) * (1 - d_b(Nr))) _
          ELSE .AQCTLB = &b000100000010 : c_b(Nr) = CUINT((cnt(Nr) SHL 1) * d_b(Nr))
      ELSE '                                                     up mode
               .AQCTLB = &b000100000010 : c_b(Nr) = CUINT(.5 + (cnt(Nr) + 1) * d_b(Nr))
      END IF
      .CMPB = c_b(Nr)
    END IF
    aqc = .AQCTLA + .AQCTLB SHL 16
  END WITH

  WITH *Top
    IF .DRam[0] > PRUIO_MSG_IO_OK THEN                          RETURN 0

    WHILE .DRam[1] : WEND '   wait, if PRU is busy (should never happen)
    .DRam[5] = cnt(Nr) SHL 16
    .DRam[4] = aqc
    .DRam[3] = c_a(Nr) + c_b(Nr) SHL 16
    .DRam[2] = .PwmSS->Conf(Nr)->DeAd + &h200
    .DRam[1] = IIF(ctl, ctl, 0) + PRUIO_COM_PWM SHL 24
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
    CASE P9_42 : IF ModeCheck(Ball,0) THEN ModeSet(Ball, &h20)
    'CASE    88 : IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h22)
      'm = 1
    'CASE    92 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h24)
      'm = 2
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

\since 0.2
'/
FUNCTION CapMod.Value CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0) AS ZSTRING PTR

  var m = 0
  WITH *Top
    dim AS ZSTRING PTR e
    SELECT CASE AS CONST Ball
    CASE P9_28 : IF ModeCheck(Ball,4) THEN e = E1 ELSE m = 2
    CASE P9_42 : IF ModeCheck(Ball,0) THEN e = E1
    'CASE 88 : IF ModeCheck(Ball,2) THEN e = E1 ELSE m = 1
    'CASE 92 : IF ModeCheck(Ball,4) THEN e = E1 ELSE m = 2
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
    end if
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

\since 0.2
'/
CONSTRUCTOR QepMod(BYVAL T AS Pruio_ PTR)
  Top = T
END CONSTRUCTOR


/'* \brief Configure header pins as eQEP input (and output).
\param Ball The CPU ball number for input A.
\param PMax The maximum position counter value (defaults to &h7FFFFFFF).
\param VHz The frequency to compute velocity values (defaults to 25 Hz).
\param Scale The Scale factor for velocity values (defaults to 1.0).
\param Mo The modus to use for pinmuxing (defaults to 0).
\returns Zero on success (otherwise a string with an error message).

This function configures headers pins to be used for quadrature encoder
sensors (analysed by the QEP subsystem). By default the module gets
configured to work in Quadrature Count Mode, meaning that the
Quadrature detector is used to analyse raw input. See \ref SubSecQep
for further information and see \ArmRef{15.4.2.5} for details.

Up to three header pins may get configured, but only one of the pins get
specified by parameter *Ball* directly. The other pins are configured
internally, depending on the type of the specified pin. libpruio
selects the matching pins for the subsystem connected to the specified
pin.

- When an A input pin is specified, the QEP system runs in frequency
  count mode. No position is available (always returns zero) and the
  velocity is always positive (no direction gets detected).

- When an B input pin is specified, the QEP system runs in position /
  velocity mode, but no reference position (index) is detected.

- When an Index input pin is specified, the QEP system runs in position
  / velocity mode, and the reference index position is used to reset
  the position counter.

(In case of subsystem 2 either P8 pins (P8_11, P8_12, P8_??) or P9 pins
(P9_27, P9_42, P9_??) can be used. libpruio selects the matching pins
on the same header in that case.)

Parameter *PMax* is the maximum value for the position counter. On
overflow (`Pos > PMax`) the counter starts at 0 (zero) again. In case
of an underflow (`Pos < 0`) the counter continues at PMax. Note that
each impulse is counted four times (positive and negative transition,
sensor A and B). Ie. for a rotary encoder with 1024 impulses specify
the PMax parameter as `4095 = 1024 * 4 - 1`. The maximum value is
&h7FFFFFFF (which is the default). The highest bit is reserved for
velocity computation. Higher values can get specified, but will result
in inaccurate velocity computation in case of an position counter over-
or underflow.

Parameter *FHz* is the frequency to update velocity computation. The
capture unit of the QEP module is used to generate velocity input and
to latch the input values at the given frequency. The minimal frequency
is less than 12 Hz and the maximum frquency is 50 GHz. The higher the
frequency, the less is the resolution of the speed measurement. So it's
recommended to use the lowest possible frequency. The default value is
25 Hz.

Parameter *Scale* is a factor to be applied to the computed velocity
value. By default this factor is 1.0 and the velocity gets computed as
transitions per second. Ie. to compute the rotational speed in rpm of a
sensor with 1024 impulses per revolution, set this factor as

~~~{.bas}
Scale = 60 [s / min] / (1024 [imp / rev] * 4 [cnt / imp])
~~~

\since 0.2.2
'/
FUNCTION QepMod.config CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL PMax AS UInt32 = 0 _
  , BYVAL VHz AS Float_t = 25. _
  , BYVAL Scale AS Float_t = 1. _
  , BYVAL Mo AS UInt32 = 0) AS ZSTRING PTR

  var m = 0
  static as Float_t fmin = PWMSS_CLK / (&hFFFF SHL 7) ' minimal frequency
  WITH *Top
    SELECT CASE AS CONST Ball
    CASE P8_11, P8_12, P8_16
      m = iif(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h2C)
      if ModeCheck(P8_12,4) THEN ModeSet(P8_12,m)
      if Ball = P8_12 then m = 256 + 2 : exit select
      if ModeCheck(P8_11,4) THEN ModeSet(P8_11,m)
      if Ball = P8_11 then m = 512 + 2 : exit select
      if ModeCheck(P8_16,4) THEN ModeSet(P8_16,m)
      m = 2
    CASE P8_31, P8_33, P8_35
      m = iif(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h2A)
      if ModeCheck(P8_35,2) THEN ModeSet(P8_35,m)
      if Ball = P8_35 then m = 256 + 1 : exit select
      if ModeCheck(P8_33,2) THEN ModeSet(P8_33,m)
      if Ball = P8_33 then m = 512 + 1 : exit select
      if ModeCheck(P8_31,2) THEN ModeSet(P8_31,m)
      m = 1
    CASE P8_39, P8_41, P8_42
      m = iif(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h2B)
      if ModeCheck(P8_41,3) THEN ModeSet(P8_41,m)
      if Ball = P8_42 then m = 256 + 2 : exit select
      if ModeCheck(P8_42,3) THEN ModeSet(P8_42,m)
      if Ball = P8_42 then m = 512 + 2 : exit select
      if ModeCheck(P8_39,3) THEN ModeSet(P8_39,m)
      m = 2
    CASE P9_27, P9_41, P9_42, 104, 106
      m = iif(Mo = PRUIO_PIN_RESET, PRUIO_PIN_RESET, &h29)
      if ModeCheck( 104 ,1) THEN ModeSet( 104 ,m)
      if Ball = P9_42 orelse Ball = 104 then m = 256 + 0 : exit select
      if ModeCheck(P9_27,1) THEN ModeSet(P9_27,m)
      if Ball = P9_27 then m = 512 + 0 : exit select
      if ModeCheck( 106 ,1) THEN ModeSet( 106 ,m)
      m = 0
    CASE ELSE :  /' pin has no QEPA capability '/ .Errr = E0 : RETURN .Errr
    END SELECT
    if VHz < fmin orelse VHz > PWMSS_CLK_2 then _
                          .Errr = @"frequency not supported" : Return .Errr
  END WITH
  m and= &b11
  WITH *Top->PwmSS->Conf(m)
    if 2 <> .ClVa then _
                        Top->Errr = E2 /' PWM not enabled '/ : RETURN E2

  'AS UInt32 _ '' QEP registers (&h180)
    .QPOSCNT = 0   '*< Position Counter Register (see \ArmRef{15.4.3.1} ).
    .QPOSINIT = 0  '*< Position Counter Initialization Register (see \ArmRef{15.4.3.2} ).
    .QPOSMAX = iif(PMax, PMax, &h7FFFFFFFuL) '*< Maximum Position Count Register (see \ArmRef{15.4.3.3} ).
    '.QPOSCMP = 0   '*< Position-Compare Register 2/1 (see \ArmRef{15.4.3.4} ).
    '.QPOSILAT = 0  '*< Index Position Latch Register (see \ArmRef{15.4.3.5} ).
    '.QPOSSLAT = 0  '*< Strobe Position Latch Register (see \ArmRef{15.4.3.6} ).
    .QPOSLAT = 0   '*< Position Counter Latch Register (see \ArmRef{15.4.3.7} ).
    .QUTMR = 0     '*< Unit Timer Register (see \ArmRef{15.4.3.8} ).
    .QUPRD = cuint(PWMSS_CLK / VHz)      '*< Unit Period Register (see \ArmRef{15.4.3.9} ).

    var ccps = (.QUPRD \ &h10000)
    if ccps > 1 then ccps = 1 + int(log(ccps) / log(2))
  'AS UInt16 = 0
    '.QWDTMR = 0    '*< Watchdog Timer Register (see \ArmRef{15.4.3.10} ).
    '.QWDPRD = 0    '*< Watchdog Period Register (see \ArmRef{15.4.3.11} ).
    .QDECCTL = &b0000000000000000   '*< Decoder Control Register (see \ArmRef{15.4.3.12} ).
    .QEPCTL  = &b0001000010001110   '*< Control Register (see \ArmRef{15.4.3.14} ).
    .QCAPCTL = &b1000000000000010 or (ccps shl 4)   '*< Capture Control Register (see \ArmRef{15.4.3.15} ).
    .QPOSCTL = &b0000000000000000   '*< Position-Compare Control Register (see \ArmRef{15.4.3.15} ).
    '.QEINT = 0     '*< Interrupt Enable Register (see \ArmRef{15.4.3.16} ).
    '.QFLG = 0      '*< Interrupt Flag Register (see \ArmRef{15.4.3.17} ).
    '.QCLR = 0      '*< Interrupt Clear Register (see \ArmRef{15.4.3.18} ).
    '.QFRC = 0      '*< Interrupt Force Register (see \ArmRef{15.4.3.19} ).
    '.QEPSTS = 0    '*< Status Register (see \ArmRef{15.4.3.20} ).
    .QCTMR = 0     '*< Capture Timer Register (see \ArmRef{15.4.3.21} ).
    .QCPRD = 0     '*< Capture Period Register (see \ArmRef{15.4.3.22} ).
    '.QCTMRLAT = 0  '*< Capture Timer Latch Register (see \ArmRef{15.4.3.23} ).
    '.QCPRDLAT = 0  '*< Capture Period Latch Register (see \ArmRef{15.4.3.24} ).

    var fx = 1 SHL ((.QCAPCTL SHr 4) and &b111) _
      , fp = 1 SHL (.QCAPCTL and &b1111)
    FVh(m) = Scale * PWMSS_CLK / .QUPRD
    FVl(m) = Scale * PWMSS_CLK / fx * fp
    var t = .QUPRD \ fx, p2 = fp / 2
    Prd(m) = cuint(fp * t / (-p2 + sqr(p2 * p2 + t / fp))) SHL 16
  END WITH :                                                    return 0
END FUNCTION



/'* \brief Analyse a digital pulse train, get frequency and duty cycle.
\param Ball The CPU ball number to test.
\param Posi A pointer to store the position value (or NULL).
\param Velo A pointer to store the valocity value (or NULL).
\returns Zero on success (otherwise a string with an error message).

FIXME

\since 0.2
'/
FUNCTION QepMod.Value CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Posi AS UInt32 PTR = 0 _
  , BYVAL Velo AS Float_t PTR = 0) AS ZSTRING PTR

  var m = 0
  WITH *Top
    dim as zstring ptr e
    SELECT CASE AS CONST Ball
    CASE P8_11, P8_12
      if ModeCheck(P8_12,4) then e = E1 : exit select
      if ModeCheck(P8_11,4) then e = E1 else m = 2
    CASE P8_33, P8_35
      if ModeCheck(P8_35,2) then e = E1 : exit select
      if ModeCheck(P8_33,2) then e = E1 else m = 1
    CASE P8_41, P8_42
      if ModeCheck(P8_41,3) then e = E1 : exit select
      if ModeCheck(P8_42,3) then e = E1 else m = 2
    CASE P9_27, P9_42, 104
      if ModeCheck( 104 ,1) then e = E1 : exit select
      if ModeCheck(P9_27,1) then e = E1 else m = 0
    CASE ELSE  : e = E0
    END SELECT : if e then .Errr = e :                      RETURN .Errr

    IF .DRam[0] > PRUIO_MSG_IO_OK THEN
      if Posi then *Posi = 0
      if Velo then *Velo = 0.
                           .Errr = @"IO mode not running" : return .Errr
    end if
  END WITH
  WITH *Top->PwmSS->Raw(m)
   if Velo then
     var dx = CINT(.NPos - .OPos)
     if .PLat > Prd(m) then
        *Velo = dx * FVh(m)
      else
        *Velo = iif(.PLat, sgn(dx) * FVl(m) / hiword(.PLat), 0.)
      end if
    end if
   if Posi then *Posi = .QPos

  END WITH :                                                    return 0
END FUNCTION
