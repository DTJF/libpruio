/'* \file pruio_pwmss.bas
\brief The PWMSS component source code.

Source code file containing the function bodies of the PWMSS component.
The code for the subsystem PWMSS and its modules (eQEP, eCAP and ePWM)
is in here.

'/

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
      , p_val = cast(any ptr, .DRam) + PRUIO_DAT_PWM
    FOR i AS LONG = 0 TO PRUIO_AZ_PWMSS
      Raw(i) = p_val
      Raw(i)->CMax = 0
      p_val += SIZEOF(PwmssArr)

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


/'* \brief The constructor for PWM features of the PWMSS.
\param T A pointer of the calling PruIo structure.

Each of the three Pulse Width Modulation SubSystem (PWMSS) in the CPU
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
    BallCheck(" PWM", .Errr)

    VAR m = .BallInit[Ball] AND &b111
    DIM AS ZSTRING PTR e
    SELECT CASE AS CONST Ball
    CASE P8_13 : e = IIF(m = 4, pwm_get(2, Hz, Du, 1), E1)
    CASE P8_19 : e = IIF(m = 4, pwm_get(2, Hz, Du, 0), E1)
    CASE P8_34 : e = IIF(m = 2, pwm_get(1, Hz, Du, 1), E1)
    CASE P8_36 : e = IIF(m = 2, pwm_get(1, Hz, Du, 0), E1)
    CASE P8_45 : e = IIF(m = 3, pwm_get(2, Hz, Du, 1), E1)
    CASE P8_46 : e = IIF(m = 3, pwm_get(2, Hz, Du, 0), E1)
    CASE P9_14 : e = IIF(m = 6, pwm_get(1, Hz, Du, 0), E1)
    CASE P9_16 : e = IIF(m = 6, pwm_get(1, Hz, Du, 1), E1)
    CASE P9_21 : e = IIF(m = 3, pwm_get(0, Hz, Du, 1), E1)
    CASE P9_22 : e = IIF(m = 3, pwm_get(0, Hz, Du, 0), E1)
    CASE P9_29 : e = IIF(m = 1, pwm_get(0, Hz, Du, 1), E1)
    CASE P9_31 : e = IIF(m = 1, pwm_get(0, Hz, Du, 0), E1)
    CASE P9_28 : e = IIF(m = 4, cap_get(2, Hz, Du), E1)
    CASE P9_42 : e = IIF(m = 0, cap_get(0, Hz, Du), E1)
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

'/
FUNCTION PwmMod.setValue CDECL( _
  BYVAL Ball AS UInt8, _
  BYVAL Hz AS Float_t, _
  BYVAL Du AS Float_t) AS ZSTRING PTR

  WITH *Top
    BallCheck(" PWM", .Errr)

    VAR m = .BallInit[Ball] AND &b111
    DIM AS ZSTRING PTR e
    SELECT CASE AS CONST Ball
    CASE P8_13 : IF m <> 4 THEN IF .setPin(Ball, &h0C) THEN RETURN .Errr
      RETURN pwm_set(2, Hz, -1., Du)
    CASE P8_19 : IF m <> 4 THEN IF .setPin(Ball, &h0C) THEN RETURN .Errr
      RETURN pwm_set(2, Hz, Du, -1.)
    CASE P8_34 : IF m <> 2 THEN IF .setPin(Ball, &h0A) THEN RETURN .Errr
      RETURN pwm_set(1, Hz, -1., Du)
    CASE P8_36 : IF m <> 2 THEN IF .setPin(Ball, &h0A) THEN RETURN .Errr
      RETURN pwm_set(1, Hz, Du, -1.)
    CASE P8_45 : IF m <> 3 THEN IF .setPin(Ball, &h0B) THEN RETURN .Errr
      RETURN pwm_set(2, Hz, -1., Du)
    CASE P8_46 : IF m <> 3 THEN IF .setPin(Ball, &h0B) THEN RETURN .Errr
      RETURN pwm_set(2, Hz, Du, -1.)
    CASE P9_14 : IF m <> 6 THEN IF .setPin(Ball, &h0E) THEN RETURN .Errr
      RETURN pwm_set(1, Hz, Du, -1.)
    CASE P9_16 : IF m <> 6 THEN IF .setPin(Ball, &h0E) THEN RETURN .Errr
      RETURN pwm_set(1, Hz, -1., Du)
    CASE P9_21 : IF m <> 3 THEN IF .setPin(Ball, &h0B) THEN RETURN .Errr
      RETURN pwm_set(0, Hz, -1., Du)
    CASE P9_22 : IF m <> 3 THEN IF .setPin(Ball, &h0B) THEN RETURN .Errr
      RETURN pwm_set(0, Hz, Du, -1.)
    CASE P9_29 : IF m <> 1 THEN IF .setPin(Ball, &h09) THEN RETURN .Errr
      RETURN pwm_set(0, Hz, -1., Du)
    CASE P9_31 : IF m <> 1 THEN IF .setPin(Ball, &h09) THEN RETURN .Errr
      RETURN pwm_set(0, Hz, Du, -1.)
    CASE P9_28 : IF m <> 4 THEN IF .setPin(Ball, &h0C) THEN RETURN .Errr
      RETURN cap_set(2, Hz, Du)
    CASE P9_42 : IF m <> 0 THEN IF .setPin(Ball, &h08) THEN RETURN .Errr
      RETURN cap_set(0, Hz, Du)
    END SELECT :                               .Errr = E0 : RETURN .Errr
  END WITH
END FUNCTION


/'* \brief Compute PWM output configuration from an eCAP module (private).
\param Nr The PWMSS subsystem index.
\param Freq A pointer to output the frequency value (or 0 for no output).
\param Duty A pointer to output the duty value (or 0 for no output).
\returns Zero on success, an error string otherwise.

This functions computes the real PWM configuration of an eCAP module.

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
   freq(...) = {0., 0., 0.} '' module frequencies
  STATIC AS UInt32 _
    cnt(...) = {0, 0, 0} _  '' module periods
  , cmp(...) = {0, 0, 0}    '' module compares

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
    .DRam[1] = r OR (PRUIO_COM_PWM_CAP SHL 24)
  END WITH :                                                    RETURN 0
END FUNCTION


/'* \brief Compute PWM output configuration from an eHRPWM module (private).
\param Nr The PWMSS subsystem index.
\param F A pointer to output the frequency value (or 0 for no output).
\param Du A pointer to output the duty value (or 0 for no output).
\param Mo The output channel (0 = A, otherwise B).
\returns Zero on success, an error string otherwise.

This functions computes the real configuration of an eHRPWM module.

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

Each of the three Pulse Width Modulation SubSystem (PWMSS) in the CPU
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

  static as UInt8 m
  WITH *Top
    BallCheck(" CAP", .Errr)

    m = .BallInit[Ball] AND &b111
    dim AS ZSTRING PTR e
    SELECT CASE AS CONST Ball
    CASE P9_28 : IF m <> 4 THEN IF .setPin(Ball, &h24) THEN RETURN .Errr
      m = 2
    CASE P9_42 : IF m <> 0 THEN IF .setPin(Ball, &h20) THEN RETURN .Errr
    'CASE    88 : IF m <> 2 THEN IF .setPin(Ball, &h22) THEN RETURN .Errr
      'm = 1
    'CASE    92 : IF m <> 4 THEN IF .setPin(Ball, &h24) THEN RETURN .Errr
      'm = 2
    'CASE    93 : IF m <> 4 THEN IF .setPin(Ball, &h24) THEN RETURN .Errr
      'm = 1
    'CASE    98 : IF m <> 3 THEN IF .setPin(Ball, &h23) THEN RETURN .Errr
      'm = 2
    'CASE    99 : IF m <> 3 THEN IF .setPin(Ball, &h23) THEN RETURN .Errr
      'm = 1
    CASE ELSE                                : .Errr = E0 : RETURN .Errr
    END SELECT
  END WITH
  WITH *Top->PwmSS
    IF 2 <> .Conf(m)->ClVa THEN        Top->Errr = E2 : RETURN E2 ' CAP not enabled
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

  static as UInt8 m
  WITH *Top
    BallCheck(" CAP", .Errr)

    m = .BallInit[Ball] AND &b111
    dim AS ZSTRING PTR e
    SELECT CASE AS CONST Ball
    CASE P9_28 : IF m <> 4 THEN e = E1 ELSE m = 2
    CASE P9_42 : IF m <> 0 THEN e = E1
    'CASE 88 : IF m <> 2 THEN e = E1 ELSE m = 1
    'CASE 92 : IF m <> 4 THEN e = E1 ELSE m = 2
    'CASE 93 : IF m <> 4 THEN e = E1 ELSE m = 1
    'CASE 98 : IF m <> 3 THEN e = E1 ELSE m = 2
    'CASE 99 : IF m <> 3 THEN e = E1 ELSE m = 1
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



'/'* \brief The constructor for QEP features of the PWMSS.
'\param T A pointer of the calling PruIo structure.

'FIXME

'\since 0.2
''/
'CONSTRUCTOR QepMod(BYVAL T AS Pruio_ PTR)
  'Top = T
'END CONSTRUCTOR

'/'* \brief Configure a header pin as eCAP input.
'\param BallA The CPU ball number for input A.
'\param BallB The CPU ball number for input B.
'\param BallI The CPU ball number for index input/output.
'\param BallS The CPU ball number for strobe input/output.
'\returns Zero on success (otherwise a string with an error message).

'Each of the three The Pulse Width Modulation SubSystem (PWMSS) in the
'CPU contains modules (PWM, CAP and QEP). In order to create a clear
'API from the user point of view, the functions to control the modules
'are separated to extra classes. This UDT contains functions to control
'the QEP module.

'The constructor just copies a pointer to the calling main UDT
'PruIo.


''/
'FUNCTION QepMod.config CDECL( _
    'BYVAL BallA AS UInt8 _
  ', BYVAL BallB AS UInt8 = 0 _
  ', BYVAL BallI AS UInt8 = 0 _
  ', BYVAL BallS AS UInt8 = 0) AS ZSTRING PTR

  'WITH *Top
    'var _
    'Ball = BallA : BallCheck(" QEP", .Errr)
    'Ball = BallB : BallCheck(" QEP", .Errr)
    'Ball = BallI : BallCheck(" QEP", .Errr)
    'Ball = BallS : BallCheck(" QEP", .Errr)

    'var m = .BallInit[BallA] and &b111
    'static as zstring ptr e
    'SELECT CASE AS CONST Ball
    'CASE P8_12 : if m <> 3 then e = E1 else m = 2
      'e = iif(BallB, iif(.BallInit[BallB] and &b111 <> 3, E1, e), e)
      'e = iif(BallI, iif(.BallInit[BallI] and &b111 <> 3, E1, e), e)
      'e = iif(BallS, iif(.BallInit[BallS] and &b111 <> 3, E1, e), e)
    'CASE P8_41 : if m <> 4 then e = E1 else m = 2
      'e = iif(BallB, iif(.BallInit[BallB] and &b111 <> 4, E1, e), e)
      'e = iif(BallI, iif(.BallInit[BallI] and &b111 <> 4, E1, e), e)
      'e = iif(BallS, iif(.BallInit[BallS] and &b111 <> 4, E1, e), e)
    'CASE P8_35 : if m <> 6 then e = E1 else m = 1
      'e = iif(BallB, iif(.BallInit[BallB] and &b111 <> 6, E1, e), e)
      'e = iif(BallI, iif(.BallInit[BallI] and &b111 <> 6, E1, e), e)
      'e = iif(BallS, iif(.BallInit[BallS] and &b111 <> 6, E1, e), e)
    'CASE P9_42 : if m <> 1 then e = E1 else m = 0
      'e = iif(BallB, iif(.BallInit[BallB] and &b111 <> 1, E1, e), e)
      'e = iif(BallI, iif(.BallInit[BallI] and &b111 <> 1, E1, e), e)
      'e = iif(BallS, iif(.BallInit[BallS] and &b111 <> 1, E1, e), e)
    'CASE ELSE  : e = E0
    'END SELECT : if e then .Errr = e :                      RETURN .Errr

  'END WITH
  'WITH *Top->PwmSS
    'if 2 <> .Conf(m)->ClVa then _
                        'Top->Errr = E2 /' PWM not enabled '/ : RETURN E2

  'END WITH :                                                    return 0
'END FUNCTION



'/'* \brief Analyse a digital pulse train, get frequency and duty cycle.
'\param Ball The CPU ball number to test.
'\param Posi A pointer to store the position value (or NULL).
'\returns Zero on success (otherwise a string with an error message).

'FIXME

'\since 0.2
''/
'FUNCTION QepMod.Value CDECL( _
    'BYVAL Ball AS UInt8 _
  ', BYVAL Posi AS Float_t PTR = 0) AS ZSTRING PTR

  'WITH *Top
    'BallCheck(" QEP", .Errr)

    'var m = .BallInit[Ball] and &b111
    'static as zstring ptr e
    'SELECT CASE AS CONST Ball
    'CASE P8_12 : if m <> 3 then e = E1 else m = 2
    'CASE P8_41 : if m <> 4 then e = E1 else m = 2
    'CASE P8_35 : if m <> 6 then e = E1 else m = 1
    'CASE P9_42 : if m <> 1 then e = E1 else m = 0
    'CASE ELSE  : e = E0
    'END SELECT : if e then .Errr = e :                      RETURN .Errr

    'IF .DRam[0] > PRUIO_MSG_IO_OK THEN
      'if Posi then *Posi = 0
                           '.Errr = @"IO mode not running" : return .Errr
    'end if

  'END WITH
  'WITH *Top->PwmSS->Raw(m)
   ''if 0 = .CMax then Top->Errr = E2    /' QEP not enabled '/ : RETURN E2

  'END WITH :                                                    return 0
'END FUNCTION
