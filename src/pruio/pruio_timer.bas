/'* \file pruio_timer.bas
\brief The TIMER component source code.

Source code file containing the function bodies of the TIMER component.

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
                      .DeAd = 0 : .ClVa = 0 : p_mem += 16 : CONTINUE FOR
        .ClVa = 2
        .TCAR1 = 0
        .TCAR2 = 0
      END WITH

      WITH *Init(i)
        .TCAR1 = 0
        .TCAR2 = 0
      END WITH

      p_mem += SIZEOF(TimerSet)
    NEXT
  END WITH : RETURN 0
END FUNCTION


/'* \brief Configure timer output.
\param Ball The header pin to configure.
\param Dur1 The duration in [ms] before state change (or 0 to stop timer).
\param Dur2 The duration in [ms] for the state change (or 0 for minimal duration).
\param Mode The modus to set (defaults to 0 = one cycle positive pulse).
\returns Zero on success, an error string otherwise.

This function sets timer output on a header pin. The output can be either

- a low state for the `Dur1` period of time, then high state fur `Dur2`, then this sequence again endless.
- a high state for the `Dur1` period of time, then low state fur `Dur2`, then this sequence again endless.

Parameter `Ball` specifies the header pin to use. Check section \ref
SubSecTimer for available header pins. \Proj will check the pins
configuration and adapt it, if necessary and possible. If unpossible an
error message gets returned.

Parameter `Dur1` specifies the time period of the start state in
seconds. Parameter `Dur2` specifies the time period of the state change
(= pulse) in seconds. When `Dur2`is 0 (zero) then the pulse has minimal
duration. When `Dur2`is 0 (zero) then the timer stops in its initial
state.

Parameter `Mode` is a bitmaks that specifies the form of the generated
output. It can either be low state with high pulse (default), or hight
state with low pulse (bit PRUIO_TIMER_INVERS set)- Then timer pins send
a single pulse and then returns to the initial state, endless. In
contrast the sequence can get repeated again and again when bit
PRUIO_TIMER_CONTINUE is set.

\note This function always starts a new timer period (and breaks the
      current).

\note Due to hardware limitations, the allowed range for the summ of
      both `Dur1` and `Dur2` is limited. See the table in section \ref
      SubSecTimer for details.

\note The pulse length is always a multiple of the hardware timer
      counter period. In order to get low frequencies, the counter gets
      pre-scaled (= slowed down). That means, the longer the `Dur1`
      summ, the longer the minimal pulse. The time period of a minimal
      CAP pulse is 50 ns and a minimal TIMER pulse is between 83 ns and
      21248 ns. Find further details in \ArmRef{20}.

\note Currently, \Proj uses CLK_M_OSC (24 MHz) input clock only.
      CLK_32KHZ (32.768 kHz) input clock isn't supported, yet.

\since 0.4
'/
FUNCTION TimerUdt.setValue CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Dur1 AS Float_t _
  , BYVAL Dur2 AS Float_t = 0. _
  , BYVAL Mode AS SHORT = 0) AS ZSTRING PTR

  STATIC AS CONST Float_t _
    d_min =              &h4 / TMRSS_CLK _ '' minimal durarion
  , d_max = &h10000000000uLL / TMRSS_CLK   '' maximal duration
  STATIC AS UInt32 _
     pru_cmd = 0 _
       , pre = 0 _
        , nr = 0

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
    CASE ELSE :                                   .Errr = E1 : RETURN E1 ' no Timer pin
    END SELECT

    IF 2 <> Conf(nr)->ClVa THEN                   .Errr = E0 : RETURN E0 ' TIMER not enabled
    IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)

    IF Dur1 <= 0. THEN ' switch off
      Conf(nr)->TCLR = IIF(BIT(Mode, 1), TimHigh, Tim_Low)
      pru_cmd = PRUIO_COM_TIM_PWM
    ELSE
      VAR dur = Dur1 + Dur2
      IF dur < d_min ORELSE _
         dur > d_max THEN              .Errr = .PwmSS->E2 : RETURN .Errr ' frequency not supported

      VAR x = CULNGINT(dur * TMRSS_CLK)
      SELECT CASE AS CONST x SHR 32 '' faster than LOG
      CASE   0        : pre = 0
      CASE   1        : pre = &b100000 : x SHR= 1
      CASE   2 TO   3 : pre = &b100100 : x SHR= 2
      CASE   4 TO   7 : pre = &b101000 : x SHR= 3
      CASE   8 TO  15 : pre = &b101100 : x SHR= 4
      CASE  16 TO  31 : pre = &b110000 : x SHR= 5
      CASE  32 TO  63 : pre = &b110100 : x SHR= 6
      CASE  64 TO 127 : pre = &b111000 : x SHR= 7
      CASE 128 TO 255 : pre = &b111100 : x SHR= 8
      CASE ELSE :                      .Errr = .PwmSS->E2 : RETURN .Errr ' frequency not supported
      END SELECT

      IF Dur2 <= 0. THEN
        Conf(nr)->TCLR = TimMode
        pru_cmd = PRUIO_COM_TIM_PWM
        Conf(nr)->TCRR = &hFFFFFFFFuL - x
      ELSE
        Conf(nr)->TCLR = PwmMode
        pru_cmd = PRUIO_COM_TIM_PWM
        Conf(nr)->TLDR = &hFFFFFFFFuL - x

        VAR y = CULNG(x * Dur2 / dur)
        SELECT CASE y
        CASE IS < 2     : Conf(nr)->TMAR =   &hFFFFFFFFuL - 2
        CASE IS > x - 1 : Conf(nr)->TMAR = Conf(nr)->TLDR + 2
        CASE ELSE       : Conf(nr)->TMAR = Conf(nr)->TLDR + y
        END SELECT
        Conf(nr)->TCRR = Conf(nr)->TMAR
      END IF
      Conf(nr)->TCLR OR= pre _
                      OR IIF(BIT(Mode, 0), &b10, 0) _
                      OR IIF(BIT(Mode, 1), &b10000000, 0)
    END IF

    IF .DRam[0] > PRUIO_MSG_IO_OK THEN                          RETURN 0

    WHILE .DRam[1] : WEND '   wait, if PRU is busy (should never happen)
    .DRam[5] = Conf(nr)->TCRR
    .DRam[4] = Conf(nr)->TMAR
    .DRam[3] = Conf(nr)->TLDR
    .DRam[2] = Conf(nr)->DeAd
    .DRam[1] = Conf(nr)->TCLR OR (pru_cmd SHL 24)
  END WITH :                                                    RETURN 0
END FUNCTION


/'* \brief Compute timer output.
\param Ball The header pin to configure.
\param Dur1 The duration in [ms] before state change (or 0 to stop timer).
\param Dur2 The duration in [ms] for the state change (or 0 for minimal duration).
\param Mode The modus to set (defaults to 0 = one cycle positive pulse).
\returns Zero on success, an error string otherwise.

This function computes the real values of the timer output. Since
function TimerUdt::setValue() rounds the input parameters to the best
matching values, this function can get used to compute the current
setting.

\since 0.4
'/
FUNCTION TimerUdt.Value CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Dur1 AS Float_t PTR = 0 _
  , BYVAL Dur2 AS Float_t PTR = 0 _
  , BYVAL Mode AS SHORT PTR = 0) AS ZSTRING PTR

  DIM AS Uint32 nr
  DIM AS ZSTRING PTR e
  WITH *Top
    SELECT CASE AS CONST Ball
    CASE P8_07 : nr = 0
    CASE P8_09 : nr = 1
    CASE P8_10 : nr = 2
    CASE P8_08 : nr = 3
    CASE P9_28 : e = IIF(ModeCheck(Ball,4), E2, .PwmSS->cap_tim_get(2, Dur1, Dur2, Mode))
    CASE JT_05 : e = IIF(ModeCheck(Ball,4), E2, .PwmSS->cap_tim_get(1, Dur1, Dur2, Mode))
    CASE P9_42 : e = IIF(ModeCheck(Ball,0), E2, .PwmSS->cap_tim_get(0, Dur1, Dur2, Mode))
    CASE ELSE :                                   .Errr = E1 : RETURN E1 ' no Timer pin
    END SELECT

    IF 2 <> Conf(nr)->ClVa THEN                   .Errr = E0 : RETURN E0 ' TIMER not enabled
    IF Conf(nr)->TCLR <> PwmMode THEN             .Errr = E2 : RETURN E2 ' TIMER module not in output mode
  END WITH

  WITH *Conf(Nr)
    VAR dur = (&hFFFFFFFF - .TLDR) / TMRSS_CLK _
      , d_2 = (&hFFFFFFFF - .TMAR) / TMRSS_CLK
    IF Dur1 THEN *Dur1 = dur - d_2
    IF Dur2 THEN *Dur2 = d_2
    IF Mode THEN *Mode = IIF(BIT(.TCLR, 1), &b01, 0) _
                      OR IIF(BIT(.TCLR, 7), &b10, 0)
  END WITH :                                                    RETURN 0
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
      check the validity of the *Nr* parameter. Values greater than
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
  STATIC AS UInt32 _
         pre = 0 _
         , r = 0 _
  , cnt(...) = {0, 0, 0, 0} _  '' initial timer periods
  , cmp(...) = {0, 0, 0, 0}    '' initial timer match values

  WITH *Top
    IF 2 <> Conf(Nr)->ClVa THEN                   .Errr = E0 : RETURN E0 ' TIMER not enabled

    IF Freq < 0. THEN
      IF 0 = cnt(Nr) THEN              .Errr = .PwmSS->E1 : RETURN .Errr ' set frequency first
      pre = Conf(Nr)->TCLR AND &b111100
    ELSE
      IF Freq < f_min ORELSE _
         Freq > f_max THEN             .Errr = .PwmSS->E2 : RETURN .Errr ' frequency not supported
      VAR x = CULNGINT(TMRSS_CLK / Freq) - 1
      SELECT CASE AS CONST x SHR 32 '' faster than LOG
      CASE   0        : cnt(Nr) = x       : pre = 0
      CASE   1        : cnt(Nr) = x SHR 1 : pre = &b100000
      CASE   2 TO   3 : cnt(Nr) = x SHR 2 : pre = &b100100
      CASE   4 TO   7 : cnt(Nr) = x SHR 3 : pre = &b101000
      CASE   8 TO  15 : cnt(Nr) = x SHR 4 : pre = &b101100
      CASE  16 TO  31 : cnt(Nr) = x SHR 5 : pre = &b110000
      CASE  32 TO  63 : cnt(Nr) = x SHR 6 : pre = &b110100
      CASE  64 TO 127 : cnt(Nr) = x SHR 7 : pre = &b111000
      CASE 128 TO 255 : cnt(Nr) = x SHR 8 : pre = &b111100
      CASE ELSE :                      .Errr = .PwmSS->E2 : RETURN .Errr ' frequency not supported
      END SELECT
      Conf(Nr)->TLDR = &hFFFFFFFFuL - cnt(Nr)
    END IF

    r = PwmMode OR pre
    IF Duty >= 0. THEN
      cmp(Nr) = IIF(Duty >= 1., cnt(Nr), CUINT(cnt(Nr) * Duty)) - 1
      SELECT CASE cmp(Nr)
      CASE IS <=           1 : r = Pwm_Low
      CASE IS >= cnt(Nr) - 1 : r = PwmHigh
      CASE ELSE : Conf(Nr)->TMAR = Conf(Nr)->TLDR + cmp(Nr)
      END SELECT
    END IF

    IF Conf(Nr)->TCLR <> r THEN
      Conf(Nr)->TCLR = r
      Conf(Nr)->TCRR = &hFFFFFFFFuL
    ELSE
      r = 0
    END IF

    IF .DRam[0] > PRUIO_MSG_IO_OK THEN                          RETURN 0

    WHILE .DRam[1] : WEND '   wait, if PRU is busy (should never happen)
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
      check the validity of the *Nr* parameter. Values greater than
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
    CASE PwmHigh : IF Duty THEN *Duty = 1.
    CASE Pwm_Low : IF Duty THEN *Duty = 0.
    CASE ELSE
      IF (PwmMode AND .TCLR) <> PwmMode THEN Top->Errr = E2 :  RETURN E2 ' TIMER not in PWM output mode
      IF Duty THEN *Duty = (.TMAR -.TLDR + 1) / cnt
    END SELECT
    IF Freq THEN *Freq = TMRSS_CLK / (cnt SHL IIF(pre, (pre AND &b111) + 1, 0))
  END WITH :                                                    RETURN 0
END FUNCTION
