/'* \file pruio_adc.bas
\brief The ADC component source code.

Source code file containing the function bodies of the ADC component.

'/


/'* \brief The constructor for the ADC features.
\param T A pointer of the calling PruIo structure.

The constructor prepares the DRam parameters to run the pasm_init.p
instructions. The adress of the subsystem and the adress of the clock
registers get prepared, and the index of the last parameter gets stored
to compute the offset in the Init and Conf data blocks.

\since 0.2
'/
CONSTRUCTOR AdcUdt(BYVAL T AS Pruio_ PTR)
  Top = T
  WITH *Top
    VAR i = .ParOffs
    InitParA = i
    i += 1 : .DRam[i] = &h44E0D000uL
    i += 1 : .DRam[i] = IIF(.DevAct AND PRUIO_ACT_ADC, &h44E004BCuL, 0)
    .ParOffs = i
  END WITH
END CONSTRUCTOR


/'* \brief Initialize the register context after running the pasm_init.p instructions (private).
\param Av The avaraging for default step configuration.
\param OpD The open delay for default step configuration.
\param SaD The sample delay for default step configuration.
\returns Zero on success (otherwise a string with an error message).

This is a private function, designed to be called from the main
constructor PruIo::PruIo(). It sets the pointers to the Init and
Conf structures in the data blocks. And it initializes some register
context, if the subsystem woke up and is enabled.

'/
FUNCTION AdcUdt.initialize CDECL( _
    BYVAL  Av AS UInt8  = PRUIO_DEF_AVRAGE _
  , BYVAL OpD AS UInt32 = PRUIO_DEF_ODELAY _
  , BYVAL SaD AS UInt8  = PRUIO_DEF_SDELAY) AS ZSTRING PTR

  WITH *Top
    var p = .MOffs + .DRam[InitParA]
    Init = p
    Conf = p + .DSize
  END WITH

  WITH *Conf
    IF .ClAd =  0 ORELSE _
       .REVISION = 0 THEN _ '                      subsystem not enabled
                                        .DeAd = 0 : .ClVa = 0 : RETURN 0
    .ClVa = 2
    .SYSCONFIG = 0
    .CTRL = &b11

    VAR a = ABS((Av > 1) + (Av > 2) + (Av > 4) + (Av > 8)) SHL 2 _
      , d = OpD AND &h3FFFF
    FOR i AS LONG = 1 TO 8 '                       set default ADC steps
      WITH .St_p(i)
        .Confg = a + ((i - 1) SHL 19)
        .Delay = d + SaD SHL 24
      END WITH
    NEXT
  END WITH : RETURN 0
END FUNCTION


/'* \brief Configuration of ADC parameters for PRU (private).
\param Samp The number of samples to fetch (or 1 for IO mode).
\param Mask The step mask to use.
\param Tmr The timer value in ns (ignored in IO mode).
\param Mds The bit encoding modus (0 = 12 bit, ... 4 = 16 bit).
\returns Zero on success (otherwise a string with an error message).

This is a private function, designed to be called from PruIo::config().
It checks if the ADC subsystem is enabled and prepares parameters in
PruIo::DRam. Don't call it directly.

'/
FUNCTION AdcUdt.configure CDECL( _
    BYVAL Samp AS UInt32 = PRUIO_DEF_SAMPLS _
  , BYVAL Mask AS UInt32 = PRUIO_DEF_STPMSK _
  , BYVAL  Tmr AS UInt32 = PRUIO_DEF_TIMERV _
  , BYVAL  Mds AS UInt16 = PRUIO_DEF_LSLMOD) AS ZSTRING PTR

  WITH *Top
    Value = CAST(ANY PTR, .DRam) + PRUIO_DAT_ADC + 4

    IF 2 <> Conf->ClVa THEN '                      subsystem not enabled
      IF Samp < 2 ANDALSO _
         Mask = 0 THEN .DRam[2] = Samp _
                  ELSE .DRam[2] = 0 : .Errr = E5 '       ADC not enabled
      .DRam[3] = 0
      .DRam[4] = 0
      .DRam[5] = 0 :                                        RETURN .Errr
    END IF

    ChAz = 0
    VAR c = UBOUND(Conf->St_p) _
      , r = 0 _ ' first active step
      , d = 0   ' duration of all steps
    FOR i AS LONG = c - 1 TO 0 STEP -1
      IF 0 = BIT(Mask, i) THEN CONTINUE FOR
      r = i '                                        find right-most bit
      ChAz += 1 '                                            count steps
      WITH Conf->St_p(r) '                calculate clock cycles (delay)
        VAR opd = .Delay AND &h3FFFF _
          , smd = .Delay SHR 24 _
          , avr = (.Confg SHR 2) AND &b111
        d += opd + 1 + (14 + smd) * IIF(avr, 1 SHL avr, 1)
      END WITH
    NEXT

    IF Samp < 2 THEN ' IO mode
      Samples = 1
      TimerVal = 0
    ELSE
      IF r < 1 THEN             .Errr = @"no step active" : RETURN .Errr
      Samples = Samp * ChAz
      IF (Samples SHL 1) > .ESize THEN _
                                 .Errr = @"out of memory" : RETURN .Errr
      d *= (Conf->ADC_CLKDIV + 1) * 417 '417 ≈ 1000000 / 2400 (= 1 GHz / 2.4 MHz)
      d += 30 '                             PRU cycles for restart [GHz]
      IF Tmr <= d THEN     .Errr = @"sample rate too big" : RETURN .Errr
      TimerVal = Tmr
      Value = .ERam
    END IF
    WITH *Conf
      IF BIT(Mask, 31) THEN _ '                   adapt idle step config
        .IDLECONFIG = .St_p(r).Confg AND &b1111111111111111111100000

      Mask AND= (1 SHL c) - 1
      .STEPENABLE = Mask
    END WITH
    LslMode = IIF(Mds < 4, Mds, CAST(UInt16, 4))

    .DRam[2] = Samples
    .DRam[3] = Mask
    .DRam[4] = LslMode
    .DRam[5] = TimerVal
  END WITH : RETURN 0
END FUNCTION


/'* \brief Customize a single configuration step.
\param Stp Step index (0 = step 0 => charge step, 1 = step 1 (=> AIN-0 by default),  ..., 17 = idle step)-
\param ChN Channel number to scan (0 = AIN-0, 1 = AIN-1, ...)-
\param Av New value for avaraging (defaults to 4)-
\param SaD New value for sample delay (defaults to 0)-
\param OpD New value for open delay (defaults to 0x98)-
\returns Zero on success (otherwise a string with an error message).

This function is used to adapt a step configuration. In the
constructor, steps 1 to 8 get configured for AIN-0 to AIN-7 (other
steps stay un-configured). By this function you can customize the
default settings and / or configure further steps (input channel
number, avaraging and delay values).

|      Stp | Description |
| -------: | :---------- |
| 0        | charge step |
| 1        | step 1      |
| 2        | step 2      |
| ...      | ...         |
| 16       | step 16     |

\note This sets the local data on the host system (ARM). The setup gets
      uploaded to the PRU and activated when calling function
      PruIo::config().

It's also possible to directly write to the step configuration in
member variables AdcSet::St_p `(i).Confg` and
AdcSet::St_p `(i).Delay`. See \ArmRef{12} for details on ADC
configurations.

'/
FUNCTION AdcUdt.setStep CDECL( _
    BYVAL Stp AS UInt8 _
  , BYVAL ChN AS UInt8 _
  , BYVAL  Av AS UInt8  = PRUIO_DEF_AVRAGE _
  , BYVAL SaD AS UInt8  = PRUIO_DEF_SDELAY _
  , BYVAL OpD AS UInt32 = PRUIO_DEF_ODELAY) AS ZSTRING PTR

  WITH *Top
    IF 2 <> Conf->ClVa THEN                    .Errr = E5 : RETURN .Errr ' ADC not enabled
    IF Stp > UBOUND(Conf->St_p) THEN           .Errr = E0 : RETURN .Errr ' step number too big
    IF ChN > 7 THEN                            .Errr = E1 : RETURN .Errr ' channel number too big
  END WITH

  WITH *Conf.St_p(Stp)
    VAR a = ABS((Av > 1) + (Av > 2) + (Av > 4) + (Av > 8))
    .Confg = (a SHL 2) + (ChN SHL 19)
    .Delay = (OpD AND &h3FFFF) + (SaD SHL 24)
  END WITH : RETURN 0
END FUNCTION


/'* \brief Create a trigger configuration for a digital trigger (GPIO).
\param Ball The CPU ball number to test.
\param GpioV The state to check (defaults to high = 1).
\param Skip The number of samples to skip (defaults to 0 = zero, max. 1023).
\returns The trigger configuration (or zero in case of an error, check PruIo::Errr).

This function is used to create a configuration for a digital (= GPIO)
trigger. Pass the returned value as parameter to function
PruIo::mm_start(). The measurement (or the next trigger) will start
when the specified GPIO gets in to the declared state.

The parameter Skip can be used to hold up the start for a certain
time (previously defined by the Tmr parameter in the last call to
function PruIo::config() ).

This trigger is a fast trigger. The ADC subsystem is waiting in idle
mode while the GPIO gets checked.

\note When the CPU ball number (parameter *Ball*) is on a GPIO
       subsystem that is not enabled, an error gets reported (return
       value = zero). When you switch off the subsystem after creating
       the trigger specification, the trigger has no effect (it gets
       skipped).

'/
FUNCTION AdcUdt.mm_trg_pin CDECL( _
    BYVAL Ball AS UInt8 _
  , BYVAL GpioV AS UInt8 = 0 _
  , BYVAL Skip AS UInt16 = 0) AS UInt32

  WITH *Top
    IF 2 <> Conf->ClVa THEN                        .Errr = E5 : RETURN 0 ' ADC not enabled
    IF Skip > 1023 THEN                            .Errr = E2 : RETURN 0 'too much values 2 skip
    BallCheck(" trigger", 0)
    VAR g = .BallGpio(Ball) _ ' resulting GPIO (index and bit number)
      , i = g SHR 5           ' index of GPIO

    IF 2 <> .Gpio->Conf(i)->ClVa THEN _
                        .Errr = @"GPIO subsystem not enabled" : RETURN 0
    IF 7 <> (.BallConf[Ball] AND &b111) THEN _
                 .Errr = @"pin must be in GPIO mode (mode 7)" : RETURN 0
  END WITH

  DIM AS UInt32 r =  (Skip SHL 22) _  ' number of samples to skip
        +               (1 SHL 21) _  ' GPIO bit
        +            (Ball SHL  8) _  ' Ball number
        + IIF(GpioV = 0, 1 SHL  7, 0) ' negative bit
  RETURN r
END FUNCTION


/'* \brief Create a trigger configuration for an analog input trigger.
\param Stp The step number to use for trigger input (or 0 for all active steps).
\param AdcV The sample value to match (positive checks greater than, negative checks less than).
\param Rela Not zero means AdcV is relative to the sample at start (ignored when Stp = 0).
\param Skip The number of samples to skip (defaults to 0 = zero, max. 1023).
\returns The trigger configuration (or zero in case of an error, check PruIo::Errr).

This function is used to create a configuration for an analog (= AIN)
trigger. Pass the returned value as parameter to function
PruIo::mm_start(). The measurement (or the next trigger) will start
when the specified analog input (AIN) gets in to the declared state.

The parameter *Stp* specifies the step number to use for the trigger.
This may be an active step (enabled in the PruIo::config() call).
Or it can be a further step with customized settings only for trigger
purposes (see trigger.bas for an example).

The parameter *AdcV* specifies the value to compare with. A positive
value starts when the input is greater than AdcV. A negative value
starts when the input is less than AdcV.

AdcV is scalled like the samples, so when the previuos call to function
PruIo::config() requires 16 bit samples (Mds = 4), AdcV has to be
specified as 16 bit value as well.

AdcV can either be an absolute value or a relative value. For the later
case set parameter *Rela* to any value <> zero. The driver will
fetch the current analog input value when the trigger gets active and
adds AdcV to calculate the absolute trigger value.

This trigger value gets auto-limited to a certain range (ie &hF0 to
&hFF00, in case of default 16 bit setting), to avoid trigger values
that never can be reached.

The parameter *Skip* can be used to hold up the start for a certain
time (previously defined by the Tmr parameter in the last call to
function PruIo::config() ). Example:

~~~{.bas}
 Tmr = 1e8              ' 10 Hz
Skip = 500              ' skip 500 samples
time = Skip / Tmr * 1e9 ' delay time = 5 seconds (1e9 = Hz / GHz)
~~~

This trigger is a fast trigger. Only the specified step is active while
waiting for the event. The trigger step can be inactive in the Mask of
the previous call to function PruIo::config() and only be used for
trigger purposes. (Ie. a short open delay can get specified for the
trigger step since there is no channel muxing.)

\note All error checks in this function are related to the parameters
      of the previuos call to function PruIo::config(). The
      created specification may get invalid by changing the ADC
      settings by a further call to function PruIo::config() with
      different parameters (ie. when the trigger step gets cleared). To
      be on the save side, re-create your trigger specifications after
      each call to function PruIo::config().

'/
FUNCTION AdcUdt.mm_trg_ain CDECL( _
    BYVAL Stp AS UInt8 _
  , BYVAL AdcV AS Int32 _
  , BYVAL Rela AS UInt8 = 0 _
  , BYVAL Skip AS UInt16 = 0) AS UInt32

  WITH *Top
    IF 2 <> Conf->ClVa THEN                        .Errr = E5 : RETURN 0 ' ADC not enabled
    IF Stp > 16 THEN                               .Errr = E4 : RETURN 0 ' invalid step number
    IF Stp ANDALSO 0 = Conf->St_p(Stp).Confg THEN  .Errr = E3 : RETURN 0 ' trigger step not configured
    IF Skip > 1023 THEN                            .Errr = E2 : RETURN 0 ' too much values to skip
  END WITH

  VAR v = ABS(AdcV) SHR LslMode
  IF v < &hF THEN v = &hF ELSE IF v > &hFF0 THEN v = &hFF0

  DIM AS UInt32 r =  (Skip SHL 22) _  ' number of samples to skip
        +               (v SHL 8) _   ' sample AdcV to check
        + IIF(AdcV < 0,  1 SHL 7, 0)  ' negative bit
  IF 0 = Stp THEN  r += (1 SHL 5) _   ' all step bit,
              ELSE r +=  Stp - 1 _    ' or step number
        +      IIF(Rela, 1 SHL 6, 0)  ' and relative bit
  RETURN r
END FUNCTION


/'* \brief Create a trigger configuration for an analog input trigger.
\param Stp The step number to use for trigger input.
\param AdcV The sample value to match (positive check greater than, negative check less than).
\param Samp The number of samples for the pre-trigger.
\param Rela If AdcV is relative to the current input.
\returns The trigger configuration (or zero in case of an error, check PruIo::Errr).

This function is used to create a configuration for an analog (= AIN)
pre-trigger. Pass the returned value as parameter to function
PruIo::mm_start(). The measurement on all active steps will start
immediately and collect the input values in a ring buffer. Normal
measurement starts when the specified analog input (AIN) gets in to the
declared state.

Either a certain step (that must be activated in the previous call to
function PruIo::config() ) can be checked. Or all active inputs
get checked against the specified AdcV. In the later case AdcV is
allways an absolute value (parameter Rela gets ignored).

The parameter AdcV specifies the value to compare with. A positive
value starts when the input is greater than AdcV. A negative value
starts when the input is less than AdcV.

AdcV is scalled like the samples, so when the previuos call to function
PruIo::config() requires 16 bit samples (Mds = 4), AdcV has to be
specified as 16 bit value as well.

AdcV can either be an absolute value or a relative value. For the later
case set parameter Rela to any value <> zero. The driver will
fetch the current analog input value when the trigger gets active and
add AdcV to calculate the absolute trigger value.

The trigger value gets auto-limited to a certain range (ie &hF0 to
&hFF00, in case of default 16 bit setting), to avoid trigger values
that never can be reached.

Parameter Samp is used to specify the number of samples to fetch
before the trigger event occurs. It specifies the number of sampling
sets for all active channels. Its maximum value is limited to 1023 and
also by the amount of memory available (approx. 7000 samples in DRam0
and DRam1) to sort the ring buffer.

The pre-trigger is a slow trigger. The ADC subsystem goes through all
activated steps while waiting for the trigger event.

\note All error checks in this function are related to the parameters
      of the previuos call to function PruIo::config(). The
      created specification may get invalid by changing the ADC
      settings by a further call to function PruIo::config() with
      different parameters (ie. when the trigger step gets cleared). To
      be on the save side, re-create your trigger specifications after
      each call to function PruIo::config().

\note A pre-trigger is always the last trigger specification in the
      call to function PruIo::mm_start() (all further
      specifications get ignored).

'/
FUNCTION AdcUdt.mm_trg_pre CDECL( _
    BYVAL Stp AS UInt8 _
  , BYVAL AdcV AS Int32 _
  , BYVAL Samp AS UInt16 = 0 _
  , BYVAL Rela AS UInt8 = 0) AS UInt32

  WITH *Top
    IF 2 <> Conf->ClVa THEN                        .Errr = E5 : RETURN 0 ' ADC not enabled
    IF Stp > 16 THEN                               .Errr = E4 : RETURN 0 ' invalid step number
    IF Stp ANDALSO 0 = Conf->St_p(Stp).Confg THEN  .Errr = E3 : RETURN 0 ' trigger step not configured
    IF Stp ANDALSO 0 = (Conf->STEPENABLE AND (1 SHL Stp)) THEN _
                        .Errr = @"trigger step not activated" : RETURN 0
    VAR t = (Samp + 1) * ChAz
    IF t > ((16384 - PRUIO_DAT_ADC - 32) SHR 1) THEN _
                              .Errr = @"too much pre-samples" : RETURN 0
    IF t > Samples THEN _
                     .Errr = @"more pre-samples than samples" : RETURN 0
  END WITH

  VAR v = ABS(AdcV) SHR LslMode
  IF v < &hF THEN v = &hF ELSE IF v > &hFF0 THEN v = &hFF0

  DIM AS UInt32 r = (Samp SHL 22)  _   ' number of pre-samples
        +              (v SHL  8)  _   ' sample AdcV to check
        + IIF(AdcV < 0, 1 SHL  7, 0) _ ' negative bit
        +              (1 SHL  4)      ' pre-trigger bit
  IF 0 = Stp THEN r += (1 SHL  5)  _   ' all step bit,
             ELSE r +=  Stp -  1   _   ' or step number
        +     IIF(Rela, 1 SHL  6, 0)   ' and relative bit
  RETURN r
END FUNCTION
