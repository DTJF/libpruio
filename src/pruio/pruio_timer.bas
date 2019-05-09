/'* \file pruio_timer.bas
\brief The TIMER component source code.

Source code file containing the function bodies to control the TIMER
subsystem. See classes TimerUdt and PwmUdt for details.

\since 0.4
'/


' PruIo global declarations.
#INCLUDE ONCE "pruio_globals.bi"
' Header for PWMSS part, containing modules QEP, CAP and PWM.
#INCLUDE ONCE "pruio_pwmss.bi"
' Header for TIMER part.
#INCLUDE ONCE "pruio_timer.bi"
' driver header file
#INCLUDE ONCE "pruio.bi"
' Header file with convenience macros.
#INCLUDE ONCE "pruio_pins.bi"

'* The TIMER clock frequency.
#DEFINE TMRSS_CLK  24e6

/'* \brief The constructor for the TIMER features.
\param T A pointer of the calling PruIo structure.

The constructor prepares the DRam parameters to run the pasm_init.p
instructions. The adresses of the subsystems and the adresses of the
clock registers get prepared, and the index of the last parameter gets
stored to compute the offset in the Init and Conf data blocks.

\since 0.4
'/
CONSTRUCTOR TimerUdt(BYVAL T AS Pruio_ PTR)
  Top = T
  WITH *Top
    VAR i = .ParOffs
    InitParA = i
    i += 1 : .DRam[i] = &h48044000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_TIM4, &h44E00088uL, 0)

    i += 1 : .DRam[i] = &h48046000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_TIM5, &h44E000ECuL, 0)

    i += 1 : .DRam[i] = &h48048000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_TIM6, &h44E000F0uL, 0)

    i += 1 : .DRam[i] = &h4804A000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_TIM7, &h44E0007CuL, 0)
    .ParOffs = i
  END WITH
END CONSTRUCTOR


/'* \brief Initialize the register context after running the pasm_init.p instructions (private).
\returns 0 (zero) on success (may return an error string in future versions).

This is a private function, designed to be called from the main
constructor PruIo::PruIo(). It sets the pointers to the Init and Conf
structures in the data blocks. And it initializes some register
context, if the subsystem woke up and is enabled.

\since 0.4
'/
FUNCTION TimerUdt.initialize CDECL() AS ZSTRING PTR
  WITH *Top
    VAR p_mem = .MOffs + .DRam[InitParA] _
      , p_raw = CAST(ANY PTR, .DRam) + PRUIO_DAT_TIMER

    FOR i AS LONG = 0 TO PRUIO_AZ_TIMER
      Raw(i) = p_raw
      p_raw += SIZEOF(TimerArr)

      Init(i) = p_mem
      Conf(i) = p_mem + .DSize

      WITH *Conf(i)
        IF .ClAd = 0 ORELSE _
           .TIDR = 0 THEN _ '                         subsystem disabled
                .DeAd = 0 : .ClVa = &h30000 : p_mem += 16 : _
                    Init(i)->DeAd = 0 : Init(i)->ClAd = 0 : CONTINUE FOR
        .ClVa = 2
        '.TCAR1 = 0
        '.TCAR2 = 0
      END WITH

      'WITH *Init(i)
        '.TCAR1 = 0
        '.TCAR2 = 0
      'END WITH

      p_mem += SIZEOF(TimerSet)
    NEXT
  END WITH : RETURN 0
END FUNCTION


/'* \brief Configure timer output.
\param Ball The header pin to get timer output from.
\param Dur1 The low period duration in [ms] (or 0 to stop timer).
\param Dur2 The high period duration in [ms] (or 0 for minimal duration).
\param Mode The output mode (defaults to &h00).
\returns Zero on success, an error string otherwise.

This function sets timer output on a header pin. The default output is

- a low state for the `Dur1` period of time, then high state for `Dur2`, repeating endless.

Parameter `Mode` allows manipulation of this pulse train:

- Bit[0] inverts the signal (high first, then low).
- Bits[1-8] enables one shot mode (pulse train stops after a number of periods).

Parameter `Ball` specifies the header pin to use. Check section \ref
sSecTimer for available header pins. \Proj will check the pin
configuration (pinmuxing) and adapt it, if necessary and possible. If
unpossible an error message gets returned.

Parameter `Dur1` specifies the time period of the starting state in
[mSec]. Parameter `Dur2` specifies the time period of the toggled state
(= pulse) in [mSec]. If `Dur2` is 0 (zero), the minimal pulse time is
used (one clock impluse).

If the summ of both, `Dur1` and `Dur2`, is smaller or equal 0 (zero),
the timer gets stopped (when running in continuous mode) in the state
specified by bit 0 (invers bit) of parameter `Mode`.

When parameter `Mode` is greater than 1 the timer fires a number of
pulses and stops afterwards. The maximal number of pulses is 255, and
twice the pulses have to get specified. Ie `Mode = 2` sends one pulse,
`Mode = 510` sends 255 pulses (=maximum), and `Mode = 511` sends 255
pulses (=maximum) in invers mode. In one shot mode parameter `Dur1`
must not be less than 0.01 [mSec].

\note Each call to this function starts a new timer period (and breaks
      the current).

\note Due to hardware limitations, the allowed range for the summ of
      both `Dur1` and `Dur2` is limited. See the table in section \ref
      sSecTimer for details.

\note The pulse length is always a multiple of the hardware timer
      counter period. In order to get low frequencies, the counter gets
      pre-scaled (= slowed down). This means, the longer the `Dur1` +
      `Dur2` summ, the longer the minimal pulse duration. The duration
      of a minimal pulse from an eCAP module is 50 ns and from a TIMER
      subsystem is between 83 ns and 21248 ns. Find further details in
      \ArmRef{20}.

\note Currently, for pulse trains generated by TIMER subsystems \Proj
      uses CLK_M_OSC (24 MHz) input clock only. CLK_32KHZ (32.768 kHz)
      input clock isn't supported, yet.

Wrapper function (C or Python): pruio_tim_setValue().

\since 0.4
'/
FUNCTION TimerUdt.setValue CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Dur1 AS Float_t _
  , BYVAL Dur2 AS Float_t = 0. _
  , BYVAL Mode AS SHORT = 0) AS ZSTRING PTR

  STATIC AS CONST Float_t _
    d_min = 1000. * &h4 / TMRSS_CLK '' minimal duration [mSec]
  DIM AS UInt32 nr = 0

  WITH *Top
    SELECT CASE AS CONST Ball
    CASE P8_07 : nr = 0
    CASE P8_09 : nr = 1
    CASE P8_10 : nr = 2
    CASE P8_08 : nr = 3
    CASE P9_28 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h0C)
      RETURN .PwmSS->cap_tim_set(2, Dur1, Dur2, Mode)
    CASE JT_05 : IF ModeCheck(Ball,4) THEN ModeSet(Ball, &h0C)
      RETURN .PwmSS->cap_tim_set(1, Dur1, Dur2, Mode)
    CASE P9_42 : IF ModeCheck(Ball,0) THEN ModeSet(Ball, &h08)
      RETURN .PwmSS->cap_tim_set(0, Dur1, Dur2, Mode)
    CASE ELSE :                                      .Errr = E1 : RETURN E1 ' no Timer pin
    END SELECT

    IF 2 <> Conf(nr)->ClVa THEN                      .Errr = E0 : RETURN E0 ' TIMER not enabled
    IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)

    VAR dur = Dur1 + Dur2 ' [mSec]
    WITH *Conf(nr)
      Raw(nr)->CMax = 0
      SELECT CASE dur
      CASE IS <= 0. : .TCLR = IIF(Mode AND &b01, TimHigh, Tim_Low) ' stop
      CASE IS < d_min :                          Top->Errr = E3 : RETURN E3 ' duration too short
      CASE ELSE
        VAR cnt = CULNGINT(.001 * dur * TMRSS_CLK)
        SELECT CASE AS CONST (cnt SHR 32) '' faster than LOG -> prescaler
        CASE   0        : .TCLR = TimMode
        CASE   1        : .TCLR = TimMode OR &b100000 : cnt SHR= 1
        CASE   2 TO   3 : .TCLR = TimMode OR &b100100 : cnt SHR= 2
        CASE   4 TO   7 : .TCLR = TimMode OR &b101000 : cnt SHR= 3
        CASE   8 TO  15 : .TCLR = TimMode OR &b101100 : cnt SHR= 4
        CASE  16 TO  31 : .TCLR = TimMode OR &b110000 : cnt SHR= 5
        CASE  32 TO  63 : .TCLR = TimMode OR &b110100 : cnt SHR= 6
        CASE  64 TO 127 : .TCLR = TimMode OR &b111000 : cnt SHR= 7
        CASE 128 TO 255 : .TCLR = TimMode OR &b111100 : cnt SHR= 8
        CASE ELSE :                              Top->Errr = E4 : RETURN E4 ' duration too long
        END SELECT
        .TLDR = &hFFFFFFFFuL - cnt

        VAR match = CULNG(Dur1 / dur * cnt)
        SELECT CASE match
        CASE IS <= 2      : .TMAR = &hFFFFFFFEuL : .TCRR = .TMAR : .TLDR += 1
          .TCLR XOR= &b0110000000000  ' toggle on overflow
        CASE IS > cnt - 2 : .TMAR = .TLDR + 2    : .TCRR = .TMAR + 2 : .TLDR += 1
          .TCLR XOR= &b1110000000000  ' pulse instead of toggle
        CASE ELSE         : .TMAR = &hFFFFFFFFuL - match : .TCRR = .TMAR + 2
        END SELECT

        IF Mode AND &b01 THEN .TCLR XOR= &b0000010000000 ' invers
        IF Mode >= &b10 THEN ' one-shot
          IF 0.01 >= Dur1 THEN                   Top->Errr = E3 : RETURN Top->Errr ' duration too short
          Raw(nr)->CMax = (Mode AND &b111111110) SHR 1
          .TCLR OR= &b100000000 ' one shot, bit 8!!
        END IF
      END SELECT
    END WITH

    IF .DRam[0] > PRUIO_MSG_IO_OK                            THEN RETURN 0

    PruReady(1) ' wait, if PRU is busy (should never happen)
    .DRam[5] = Conf(nr)->TMAR
    .DRam[4] = Conf(nr)->TLDR
    .DRam[3] = Conf(nr)->TCRR
    .DRam[2] = Conf(nr)->DeAd
    .DRam[1] = Conf(nr)->TCLR OR (PRUIO_COM_TIM_TIM SHL 24)
  END WITH :                                                      RETURN 0
END FUNCTION


/'* \brief Compute timer output.
\param Ball The header pin to configure.
\param Dur1 The duration in [ms] low state.
\param Dur2 The duration in [ms] high state.
\returns Zero on success, an error string otherwise.

This function computes the real values for timer output durations.
Since function TimerUdt::setValue() rounds the input parameters to the
best matching values, this function can get used to pre-compute the
final values, or get the current setting.

In order to read the current setting, pass negative values (or zero)
for parameters `Dur1` and `Dur2`.

Wrapper function (C or Python): pruio_tim_Value().

\since 0.4
'/
FUNCTION TimerUdt.Value CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Dur1 AS Float_t PTR _
  , BYVAL Dur2 AS Float_t PTR) AS ZSTRING PTR

  IF Dur1 = 0 ORELSE Dur2 = 0 THEN Top->Errr = @"pass pointers" : RETURN Top->Errr
  DIM AS Uint32 nr
  WITH *Top
    SELECT CASE AS CONST Ball
    CASE P8_07 : nr = 0
    CASE P8_09 : nr = 1
    CASE P8_10 : nr = 2
    CASE P8_08 : nr = 3
    CASE P9_28 : RETURN IIF(ModeCheck(Ball,4), E2, .PwmSS->cap_tim_get(2, Dur1, Dur2))
    CASE JT_05 : RETURN IIF(ModeCheck(Ball,4), E2, .PwmSS->cap_tim_get(1, Dur1, Dur2))
    CASE P9_42 : RETURN IIF(ModeCheck(Ball,0), E2, .PwmSS->cap_tim_get(0, Dur1, Dur2))
    CASE ELSE :                                   .Errr = E1 : RETURN E1 ' no Timer pin
    END SELECT
  END WITH
  WITH *Conf(nr)
    VAR dur = *Dur1 + *Dur2 _ ' [mSec]
     , dmax = 1000. * &hFFFFFFFF00uLL / TMRSS_CLK _
     , dmin = 1000. * 4 / TMRSS_CLK
    SELECT CASE dur
    CASE IS <= 0. ' get current
      IF 2 <> .ClVa THEN                         Top->Errr = E0 : RETURN E0 ' TIMER subsystem not enabled
      IF BIT(.TCLR, 13) THEN                     Top->Errr = E2 : RETURN E2 ' pin not in TIMER mode
      IF BIT(.TCLR, 6) THEN ' running
        VAR f = IIF(BIT(.TCLR, 5), (1 SHL ((.TCLR SHR 2) AND &b111)) * 2000., 1000.)
        *Dur1 = f * (       .TMAR - .TLDR) / TMRSS_CLK
        *Dur2 = f * (&hFFFFFFFFuL - .TMAR) / TMRSS_CLK
      ELSE ' stopped
        *Dur2 = 0.
        *Dur1 = 0.
      END IF
    CASE IS <= dmin ' get minimal
      *Dur1 = dmin
      *Dur2 = dmin / 2
    CASE IS >= dmax ' get maximal, splited by ratio Dur1/Dur2
      *Dur1 = *Dur1 / dur * dmax
      *Dur2 = *Dur2 / dur * dmax
    CASE ELSE '!!! log !!!
      VAR cnt = CULNGINT(.001 * dur * TMRSS_CLK), n = cnt SHR 32
      IF n THEN n = LOG(n)/LOG(2) : cnt = (cnt SHR n) SHL n
      *Dur1 = 1000. * CULNGINT(*Dur1 / dur * cnt) / TMRSS_CLK
      *Dur2 = 1000. * CULNGINT(*Dur2 / dur * cnt) / TMRSS_CLK
    END SELECT
  END WITH :                                                     RETURN 0
END FUNCTION


/'* \brief Configure PWM output at a TIMER pin (private).
\param Nr The TIMER subsystem index.
\param Freq The frequency to set (or -1 for no change).
\param Duty The duty cycle to set (0.0 to 1.0, or -1 for no change).
\returns Zero on success, an error string otherwise.

This private function configures a TIMER subsystem for PWM output. It
sets the frequency `Freq` and the duty cycle `Duty`. Only positive
values in these parameters force a change. Pass a negative value to
stay with the current setting. A `Duty` parameter greater than 1.0 gets
limited to 1.0 (= 100%).

\note This is a private function designed for internal use. It doesn't
      check the validity of the `Nr` parameter. Values greater than
      PRUIO_AZ_TIMER may result in wired behaviour.

\since 0.4
'/
FUNCTION TimerUdt.pwm_set CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL Freq AS Float_t _
  , BYVAL Duty AS Float_t = 0.) AS ZSTRING PTR

  STATIC AS CONST Float_t _
    f_min = TMRSS_CLK / &hFFFFFFFF00uLL _'' minimal frequency
  , f_max = TMRSS_CLK / &h4 ''              maximal frequency
  STATIC AS UInt32 r = 0 _
  , cnt(...) = {0, 0, 0, 0} _  '' initial timer periods
  , cmp(...) = {0, 0, 0, 0}    '' initial timer match values

  WITH *Top
    IF 2 <> Conf(Nr)->ClVa THEN                   .Errr = E0 : RETURN E0 ' TIMER not enabled

    IF Freq < 0. THEN ' frequency unchanged
      IF 0 = cnt(Nr) THEN              .Errr = .PwmSS->E1 : RETURN .Errr ' set frequency first
      r = PwmMode OR (Conf(Nr)->TCLR AND &b111100)
    ELSE
      IF Freq < f_min ORELSE _
         Freq > f_max THEN             .Errr = .PwmSS->E2 : RETURN .Errr ' frequency not supported
      VAR x = CULNGINT(TMRSS_CLK / Freq)
      SELECT CASE AS CONST x SHR 32 '' faster than LOG -> set prescaler
      CASE   0        : cnt(Nr) = x       : r = PwmMode
      CASE   1        : cnt(Nr) = x SHR 1 : r = PwmMode OR &b100000
      CASE   2 TO   3 : cnt(Nr) = x SHR 2 : r = PwmMode OR &b100100
      CASE   4 TO   7 : cnt(Nr) = x SHR 3 : r = PwmMode OR &b101000
      CASE   8 TO  15 : cnt(Nr) = x SHR 4 : r = PwmMode OR &b101100
      CASE  16 TO  31 : cnt(Nr) = x SHR 5 : r = PwmMode OR &b110000
      CASE  32 TO  63 : cnt(Nr) = x SHR 6 : r = PwmMode OR &b110100
      CASE  64 TO 127 : cnt(Nr) = x SHR 7 : r = PwmMode OR &b111000
      CASE 128 TO 255 : cnt(Nr) = x SHR 8 : r = PwmMode OR &b111100
      CASE ELSE :                      .Errr = .PwmSS->E2 : RETURN .Errr ' frequency not supported
      END SELECT
    END IF
    Conf(Nr)->TLDR = &hFFFFFFFFuL - cnt(Nr)

    IF Duty >= 0. THEN ' change duty
      cmp(Nr) = IIF(Duty >= 1., cnt(Nr), CUINT(cnt(Nr) * Duty))
      SELECT CASE cmp(Nr)
      CASE IS <=           1 : r = Tim_Low
      CASE IS >= cnt(Nr) - 1 : r = TimHigh
      CASE ELSE : Conf(Nr)->TMAR = Conf(Nr)->TLDR + cmp(Nr) - 1
      END SELECT
    END IF

    IF Conf(Nr)->TCLR = r THEN ' control reg unchanged
      r = 0
    ELSE
      Conf(Nr)->TCLR = r
      Conf(Nr)->TCRR = &hFFFFFFFEuL
    END IF

    IF .DRam[0] > PRUIO_MSG_IO_OK THEN                          RETURN 0

    PruReady(1) ' wait, if PRU is busy (should never happen)
    .DRam[5] = Conf(Nr)->TCRR
    .DRam[4] = Conf(Nr)->TMAR
    .DRam[3] = Conf(Nr)->TLDR
    .DRam[2] = Conf(Nr)->DeAd
    .DRam[1] = r OR (PRUIO_COM_TIM_PWM SHL 24)
  END WITH :                                                    RETURN 0
END FUNCTION


/'* \brief Compute PWM output configuration from a TIMER subsystem (private).
\param Nr The TIMER subsystem index.
\param Freq A pointer to output the frequency value (or 0 for no output).
\param Duty A pointer to output the duty value (or 0 for no output).
\returns Zero on success, an error string otherwise.

This private functions computes the real PWM configuration of a TIMER
subsystem. It's designed to get called from function PwmMod::Value().

\note This is a private function designed for internal use. It doesn't
      check the validity of the `Nr` parameter. Values greater than
      PRUIO_AZ_GPIO may result in wired behaviour.

\since 0.4
'/
FUNCTION TimerUdt.pwm_get CDECL( _
    BYVAL Nr AS UInt8 _
  , BYVAL Freq AS Float_t PTR = 0 _
  , BYVAL Duty AS Float_t PTR = 0) AS ZSTRING PTR

  WITH *Conf(Nr)
    IF 2 <> .ClVa THEN Top->Errr = E0   /' TIMER disabled '/ : RETURN E0

    VAR cnt = &hFFFFFFFFuLL - .TLDR + 1 _
      , pre = (.TCLR AND &b111100) SHR 2
    SELECT CASE .TCLR
    CASE TimHigh : IF Duty THEN *Duty = 1.
    CASE Tim_Low : IF Duty THEN *Duty = 0.
    CASE ELSE
      IF (PwmMode AND .TCLR) <> PwmMode THEN Top->Errr = E2 :  RETURN E2 ' TIMER not in PWM output mode
      IF Duty THEN *Duty = (.TMAR -.TLDR + 1) / cnt
    END SELECT
    IF Freq THEN *Freq = TMRSS_CLK / (cnt SHL IIF(pre, (pre AND &b111) + 1, 0))
  END WITH :                                                    RETURN 0
END FUNCTION
