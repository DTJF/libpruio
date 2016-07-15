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
\param Freq The frequency to set (or -1 for no change).
\param Mode The modus to set (defaults to 1 = one cycle positive pulse).
\returns Zero on success, an error string otherwise.

This function sets timer output on a header pin (P8_07, P8_08, P8_09 or
P8_10). The output pulse train can be either

- a positive impulse of a given number of cycles (output starts low)
- a toggling of the output, or
- a negative impulse of a given number of cycles (output starts high)

Parameter `Ball` specifies the header pin to use. \Proj will check it's
configuration and adapt it, if necessary and possible. If unpossible an
error message gets returned.

\note This function always starts a new timer period (and breaks the
      current).

Parameter `Freq` specifies the frequency of the timer output in [Hz].
Due to hardware limitations, the allowed range is 1.0914e-5 <= Freq <=
12e6 (1 Day > period >= 83 ns).

\note Currently, \Proj uses CLK_M_OSC (24 MHz) input clock only.
      CLK_32KHZ (32.768 kHz) input clock isn't supported, yet.

Parameter `Mode` specifies the form of the generated output. A positive
value specifies a pulse train starting in low state and after the given
period of time the output gets high for the number of cycles specified
by `Mode` parameter, before the next period starts. A negative value
starts output in high state and the pulse is low for the absolute value
of the parameter `Mode` (ie. a value of -3 sets 3 cycles low state). A
value of 0 (zero) stops the timer. Depending on the previous state, the
output is either low when `Mode` was > 0 and high when `Mode` was < 0
before.

\note The pulse length is always a multiple of the hardware timer
      counter period. In order to get low frequencies, the counter gets
      pre-scaled (= slowed down). That means, the smaller the
      frequency, the longer the pulse. The time period of a one cycle
      pulse is between 83 ns and 21248 ns. Find further details in
      \ArmRef{20}.

\since 0.4
'/
FUNCTION TimerUdt.setValue CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL Freq AS Float_t _
  , BYVAL Mode AS short = 1) AS ZSTRING PTR

  STATIC AS CONST Float_t _
    f_min = TMRSS_CLK / &hFFFFFFFF00uLL _'' minimal frequency
  , f_max = TMRSS_CLK / &h10 ''             maximal frequency
  STATIC AS UInt32 _
         pre = 0 _
        , nr = 0 _
         , r = 0 _
         , m = 0 _
  , cnt(...) = {0, 0, 0, 0}  '' initial timer periods

  WITH *Top
    SELECT CASE AS CONST Ball
    CASE P8_07 : nr = 0
    CASE P8_09 : nr = 1
    CASE P8_10 : nr = 2
    CASE P8_08 : nr = 3
    CASE ELSE :                                    .Errr = E1 : RETURN .Errr ' no Timer pin
    END SELECT

    IF 2 <> Conf(nr)->ClVa THEN                    .Errr = E0 : RETURN .Errr ' TIMER not enabled
    IF ModeCheck(Ball,2) THEN ModeSet(Ball, &h0A)

    IF Freq < 0. THEN
      IF 0 = cnt(nr) THEN                    .Errr = .Pwm->E3 : RETURN .Errr ' set frequency first
      pre = Conf(Nr)->TCLR AND &b111100
    ELSE
      IF Freq < f_min ORELSE _
         Freq > f_max THEN                   .Errr = .Pwm->E4 : RETURN .Errr ' frequency not supported
      VAR x = CULNGINT(TMRSS_CLK / Freq)
      SELECT CASE AS CONST x SHR 32 '' faster than LOG
      CASE   0        : pre = 0        : cnt(Nr) = x
      CASE   1        : pre = &b100000 : cnt(nr) = x SHR 1
      CASE   2 to   3 : pre = &b100100 : cnt(nr) = x SHR 2
      CASE   4 to   7 : pre = &b101000 : cnt(nr) = x SHR 3
      CASE   8 to  15 : pre = &b101100 : cnt(nr) = x SHR 4
      CASE  16 to  31 : pre = &b110000 : cnt(nr) = x SHR 5
      CASE  32 to  63 : pre = &b110100 : cnt(nr) = x SHR 6
      CASE  64 to 127 : pre = &b111000 : cnt(nr) = x SHR 7
      CASE 128 to 255 : pre = &b111100 : cnt(nr) = x SHR 8
      CASE ELSE :                            .Errr = .Pwm->E4 : RETURN .Errr ' frequency not supported
      END SELECT
      Conf(nr)->TLDR = &hFFFFFFFFuL - cnt(nr)
    END IF

    r = PwmMode OR pre
    SELECT CASE Mode
    CASE 0
      r = iif(bit(m, nr), TimHigh, Tim_Low)
    CASE IS > 0
      m = bitreset(m, nr)
      Conf(nr)->TMAR = Conf(nr)->TLDR + iif(1 + Mode < cnt(nr), Mode, cnt(Nr) - 1)
      Conf(nr)->TCRR = Conf(nr)->TMAR
    CASE ELSE
      m = bitset(m, nr)
      Conf(nr)->TMAR =   &hFFFFFFFFuL - iif(1 - Mode < cnt(nr), Mode, cnt(Nr) - 1)
      Conf(nr)->TCRR =   &hFFFFFFFFuL
    END SELECT
    Conf(nr)->TCLR = r

    IF .DRam[0] > PRUIO_MSG_IO_OK THEN                          RETURN 0

    WHILE .DRam[1] : WEND '   wait, if PRU is busy (should never happen)
    .DRam[5] = Conf(nr)->TCRR
    .DRam[4] = Conf(nr)->TMAR
    .DRam[3] = Conf(nr)->TLDR
    .DRam[2] = Conf(nr)->DeAd
    .DRam[1] = r OR (PRUIO_COM_TIM_PWM SHL 24)
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
  , f_max = TMRSS_CLK / &h10 ''             maximal frequency
  STATIC AS UInt32 _
         pre = 0 _
         , r = 0 _
  , cnt(...) = {0, 0, 0, 0} _  '' initial timer periods
  , cmp(...) = {0, 0, 0, 0}    '' initial timer match values

  WITH *Top
    IF 2 <> Conf(Nr)->ClVa THEN                    .Errr = E0 : RETURN .Errr ' TIMER not enabled

    IF Freq < 0. THEN
      IF 0 = cnt(Nr) THEN                    .Errr = .Pwm->E3 : RETURN .Errr ' set frequency first
      pre = Conf(Nr)->TCLR AND &b111100
    ELSE
      IF Freq < f_min ORELSE _
         Freq > f_max THEN                   .Errr = .Pwm->E4 : RETURN .Errr ' frequency not supported
      VAR x = CULNGINT(TMRSS_CLK / Freq)
      SELECT CASE AS CONST x SHR 32 '' faster than LOG
      CASE   0        : pre = 0        : cnt(Nr) = x
      CASE   1        : pre = &b100000 : cnt(Nr) = x SHR 1
      CASE   2 to   3 : pre = &b100100 : cnt(Nr) = x SHR 2
      CASE   4 to   7 : pre = &b101000 : cnt(Nr) = x SHR 3
      CASE   8 to  15 : pre = &b101100 : cnt(Nr) = x SHR 4
      CASE  16 to  31 : pre = &b110000 : cnt(Nr) = x SHR 5
      CASE  32 to  63 : pre = &b110100 : cnt(Nr) = x SHR 6
      CASE  64 to 127 : pre = &b111000 : cnt(Nr) = x SHR 7
      CASE 128 to 255 : pre = &b111100 : cnt(Nr) = x SHR 8
      CASE ELSE :                            .Errr = .Pwm->E4 : RETURN .Errr ' frequency not supported
      END SELECT
      Conf(Nr)->TLDR = &hFFFFFFFFuL - cnt(Nr)
    END IF

    r = PwmMode OR pre
    IF Duty >= 0. THEN
      cmp(Nr) = IIF(Duty >= 1., cnt(Nr), CUINT(cnt(Nr) * Duty))
      SELECT CASE cmp(Nr)
      CASE is >= cnt(Nr) - 1 : r = PwmHigh
      CASE is <=           1 : r = Pwm_Low
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

    VAR cnt = &hFFFFFFFFuLL - .TLDR _
      , pre = (.TCLR AND &b111100) SHR 2
    SELECT CASE .TCLR
    CASE &b000000010000011 : IF Duty THEN *Duty = 1.
    CASE &b000000000000011 : IF Duty THEN *Duty = 0.
    CASE ELSE
      IF (PwmMode AND .TCLR) <> PwmMode THEN Top->Errr = E2 :  RETURN E2 ' TIMER not in PWM output mode
      IF Duty THEN *Duty = cnt / (&hFFFFFFFFuL - .TMAR)
    END SELECT
    IF Freq THEN *Freq = TMRSS_CLK / (cnt SHL IIF(pre, (pre AND &b111) + 1, 0))
  END WITH :                                                    RETURN 0
END FUNCTION
