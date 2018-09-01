Features  {#ChaFeatures}
========
\tableofcontents

libpruio is designed to enable fast (faster than sysfs), flexible
(customizable) and easy (single source) access to the AM33xx CPU
subsystems. Its features in short

- run on PRU-0 or PRU-1 (default)
- control subsystems at runtime (disable or enable and configure)
- run in different run modi (IO, RB and MM)
- configure header pins
- get digital input (GPIO)
- set digital output (GPIO)
- analyse digital input train (CAP frequency and duty cycle)
- set digital output train (PWM frequency and duty cycle)
- get analog input (ADC)
- apply samples bit encoding (12 to 16 bit)
- configure ADC settings (input channel, timing, averaging)
- perform high-speed measurements (up to 200 kSamples/s)
- start measurement by trigger events (up to 4)
- trigger on analog (single or all) or digital (GPIO) lines
- perform a pre-trigger that starts measurement before the trigger event happens


# PRUSS {#SecPruss}

libpruio contains software running on the host system (ARM) and
software running on a Programable Realtime Unit SubSystem (PRUSS). The
AM33xx CPU on Beaglebone hardware contains two PRU subsystems. libpruio
can either use PRU-0 or PRU-1 (the later is the default). To use PRU-0,
just clear bit 0 in parameter *Act* when calling the constructor
PruIo::PruIo().


# Operation {#SecOperation}

libpruio controls the AM33xx CPU subsystems

- TSC_ADCSS (Touch Screen Controler and Analog to Digital Converter
  SubSystem)

- GPIO (4x General Purpose Input Output subsystem)

- PWMSS (3x Pulse Width Modulation SubSystem, containing modules PWM,
  CAP and QEP)

- TIMERSS (4x Timer and PWM features)

by a sequence of these three steps

-# Create a PruIo structure, read initial configuration (constructor
   PruIo::PruIo() ).

-# Upload customize configuration to the subsystem registers (function
   PruIo::config() ) and start operation (possibly by functions
   PruIo::rb_start() or PruIo::mm_start() ).

-# When done, restore original register configuration and destroy the
   PruIo structure (destructor PruIo::~PruIo).

\note Create and use just one PruIo structure at a time.

libpruio offers a set of API functions to do simple IO task at a
reasonable speed. They may be inefficient in case of advanced
requirements. Therefor libpruio allows direct access to all register
configurations of the subsystems. This is for experts only. Further
customization of the subsystems configuration for analog and digital
lines can get done by adapting the subsystem registers before step 2.

\note It's save to control the Beaglebone hardware by the libpruio API
      functions. In contrast accessing the register sets directly is
      for experts only and may cause non-revisible hardware damages.


# Modi {#SecModi}

libpruio supports three run modi. They differ in the priority of the
timing of the ADC subsystem restarts:

-# IO mode (inaccurate ADC timing): the PRU is running in an endless
   loop and handles input and output lines of all subsystems at the
   same priority. Depending on the number of enabled subsystems and the
   step configuration, there may be some delay of up to 50 ns before
   the ADC subsystems starts again to fetches the next set of samples.

-# RB mode (accurate ADC timing): the PRU is running in an endless
   loop and handles restarts of the ADC subsystem at prefered priority.
   Digital input and output gets only handled when the PRU is waiting
   for the next ADC restart. This may cause some delay of up to 50 ns
   before a digital output gets set or a digital value gets in.

-# MM mode (accurate ADC timing): the PRU waits for a start command and
   performs a single measurement. It handles analog samples only (no
   digital IO available).

Choose the run modus by setting parameter *Samp* in the call to
function PruIo::config()

- `Samp = 1` for IO mode, starting immediately, running endless.

- `Samp > 1` for RB mode, starting by a call to function
  PruIo::rb_start(), running endless.

- `Samp > 1` for MM mode, starting by a call to function
  PruIo::mm_start(), stoping after measurement is done.

To stop an endless mode (IO or RB) call function PruIo::config() again.
Or destroy the libpruio structure when done by calling the destructor
PruIo::~PruIo.


# Pinmuxing {#SecPinmuxingIntro}

A digital line of the AM33xx CPU needs to be configured before use (see
section \ref SecPinmuxing for details). libpruio checks the pin
configuration at run-time, and tries to adapt it if necessary.

- An input line gets configured by a call to the config member function
  (ie. GpioUdt::config() or CapMod::config() ).

- An output line gets configured either by the above functions or by
  the first call to the setValue member function (ie.
  GpioUdt::setValue() or PwmMod::setValue() ).

Pinmuxing at run-time requires administrator privileges. To run your
libpruio application with user privileges, make sure that digital lines
are in the required state (configuration) before executing the code.


# GPIO {#SecGpio}

General Purpose Input Output is available by the GpioUdt member
functions (in IO and RB mode, for all header pins). See section \ref
sSecGpio for further info.

- Call GpioUdt::config() to set the CPU ball in the required state
  (internal resistor pullup/pulldown/nopull, receiver active) when
  running under administrator privileges. Otherwise use a device tree
  overlays or an external tool like pinconfig-pin (Charles
  Steinkuehler).

- Call function GpioUdt::Value() to get the current state (input or output).

- Call function GpioUdt::setValue() to set an output state.

- Call function GpioUdt::config() to specify the mode of an input pin.

Furthermore, simultameous input and output can get realized by direct
access to the PRU software (experts only).


# CAP {#SecCap}

Capture And Analyse a digital Pulse train is available by the CapMod
member functions (in IO and RB mode). The frequency and duty cycle of
an header pin pulse train can get measured. See section \ref sSecCap
for further info.

- Call function CapMod::config() to configure the pin as CAP input.

- Call function CapMod::Value() to get the current frequency and/or duty cycle.

A minimal frequency can get specified to limit the reaction time in
case of no input.


# PWM {#SecPwm}

Generating a Pulse Width Modulated output is available by the PwmMod
member functions (in IO and RB mode). Therefor libpruio uses different
subsystems: the PWM modules and the CAP modules in the PWMSS
subsystems, as well as the `TIMER [4-7]` subsystems. All modules are
supported in a transparent API. See section \ref sSecPwm for further
info.

- Call function PwmMod::setValue() to set the frequncy and duty cycle
  (and configure the pin, if necessary).

- Call function CapMod::Value() to get the current frequency and/or
  duty cycle (those may differ from the required values).

Furthermore advanced features of the PWMSS subsystems can be used by
direct access to the register configuration and PRU software (experts
only).


# TIMER {#SecTim}

Generating a pulse at an output line. The time period until the pulse
starts and its duration gets specified. See section \ref sSecTimer for
details.

- Call function TimerUdt::setValue() to set the durations or stop a
  running TIMER (and configure the pin, if necessary).

- Call function TimerUdt::Value() to get the current durations (those
  may differ from the required values).


# QEP {#SecQep}

Reading and analysing signals from incremental [Quadrature Encoder
Pulse Trains](https://en.wikipedia.org/wiki/Rotary_encoder). Those
encoders generate pulses by two (mostly light barriers) sensors,
scanning a regular grid (bar code), while both sensors are out of phase
by 90 degrees. By analysing those signals, the position (angle) and the
speed of the movement can get detected.

- Call function QepMod::config() to configure up to three pins for
  QEP signals.

- Call function QepMod::Value() to read the current values (position
  and speed).

\Proj supports different measuremnt configurations:

- single pin (speed only)

- double pin (speed and position)

- tripple pin (speed and position, accurate reset by index pin)

The mode gets specified by the call to function QepMod::config(). See
section \ref sSecQep for further info.


# ADC {#SecAdc}

In all modes (IO, RB and MM) Analog Digital Converted input can get
sampled by the AdcUdt member functions, controling the Touch Screen
Controler and Analog to Digital Converter Subsystem (TSC_ADC_SS). It
samples analog data on eight input lines (AIN-0 to AIN-7). While line
AIN-7 is connected by a voltage divider on board to the 3V3 power
supply, the other lines (AIN-0 to AIN-6) are free available.

The ADC subsystem can use up to `16` step configurations (and an
additional charge step) to perform a measurement. libpruio
pre-configures steps `1` to `8` by default to sample lines AIN-0 to
AIN-7.

- Call function PruIo::config() to set the run mode, the step mask, the
  measurement timing and the bit encoding.

- Call function AdcUdt::setStep() to customize a step configuration
  (optional).

- Read array AdcUdt::Value to get the sampled values. The context
  depends on the run mode of libpruio, specified by the parameter
  *Samp* in the most recent call to function PruIo::config().


## Bit Encoding {#sSecBitEncoding}

The Beaglebone ADC subsystem samples 12 bit values in the range of `0` to
`4095`. Most other devices (ie. like sound cards) use `16` bit encoding
(in the range of `0` to `65535`) and the values cannot get compared
directly. Therefor libpruio can left shift the samples internaly. By
default the output is 16 bit encoded (range 0 to 65520).

- Adapt parameter *Mds* in the call to function PruIo::config() to
  customize the bit encoding.


## Ring Buffer {#sSecRB}

In Ring Buffer (RB) mode the samples from the ADC subsystem
continuously get stored in the external memory. The calling software
has to make sure that only valid values get read. Therefor the value of
PruIo::DRam `[0]` contains the most recent write position (UInt32
index).

In order to run RB mode, specify the size of the ring buffer by the
number of samples (> 1) in the call to PruIo::config() and then start
measurement by calling function PruIo::rb_start(). Read samples as
AdcUdt::Value[index] and make sure that index is always behind the
counter PruIo::DRam `[0]` (at the end of the ring buffer memory, the
index counter jumps to 0 (zero)). Find examples in rb_file.bas
(rb_file.c) or rb_oszi.bas.


## Measurement Mode and Triggers {#sSecTriggers}

In Measurement Mode (MM mode) the start of a measurement is either
immediately, or the start can get triggered by up to four events. When
the first event happens, the second trigger gets started, and so on.
The last specified trigger starts the measurement.

A trigger event may be a digital line reaching a certain state or an
analog line reaching a certain voltage. The voltage can get specified
as an absolute voltage or as a difference related to the measured
voltage at trigger start.

Post-triggers may delay the measurement start or the start of the next
trigger for a certain time.

A pre-trigger can be used to start the measurement before the event
happens. Only one pre-trigger is allowed, it's always the last trigger.

Call function

- AdcUdt::mm_trg_pin() to create a trigger specification for a
  digital line,

- AdcUdt::mm_trg_ain() to create a trigger specification for an
  analog line, and

- AdcUdt::mm_trg_pre() to create a pre-trigger specification for
  an analog line.

Pass the trigger specification[s] to function PruIo::mm_start() to
activate them. Read the samples as AdcUdt::Value[index] and make sure
that the index doesn't leave the range specified by the number of
samples in the call to RruIo::config(). Find am exmple in file
triggers.bas.


# Subsystem Control {#SecSubSysCont}

libpruio controls several subsystems, listed in section \ref
SecOperation. Each of these subsystems can either

- get configured and used (the default), or

- get switched of (ie. to reduce power consumption). or

- get ignored (no subsystem access, just evaluate the initial state).

To ignore a subsystem, clear its status bit in parameter *Act* when
calling the constructor PruIo::PruIo(). Each subsystem gets controlled
by its own status bit. When a system is set to be ignored, libpruio
cannot access it. There's no configuration data and there's no reset to
the initial state for the subsystem by the destructor PruIo::~PruIo.

By default all subsystems are active (not ignored). All active
subsystems are enabled after the constructor call (unless the hardware
fails). Check

- the subsystems initial clock value to find out if the subsystem was
  enabled before the constructor call (ie. AdcSet::ClVa or
  GpioSet::ClVa have values of `2` if enabled),

- the subsystems version information to find out if the subsystem is
  enabled after the constructor call (ie. AdcSet::REVISION or
  PwmssSet::IDVER have values of `0` (zero) if wakeup failed).

libpruio stores a complete set of configuration data for active
subsystems and restores their state by the destructor when finished.
Active subsystems can get enabled or disabled at run-time. Each call to
function PruIo::config() can change a subsystem state.

- Set a subsystem status bit in parameter *Act* when calling the
  constructor PruIo::PruIo() to enable it.

- To disable a subsystem, set the clock value to `0` (zero), before
  calling function PruIo::config(). Ie. set
  `PruIo->PwmSS->Conf(2)->ClVa = 0` to switch off the third PWMSS
  subsystem (PWMSS-2).

- To enable a subsystem, set the clock value to `2`, before calling
  function PruIo::config(). Ie. set `PruIo->Adc->Conf->ClVa = 2`
  to enable the ADC subsystem.


# Overlays {#SecOverlays}

The libpruio package contains tools to create, compile and install
device tree overlays in folder src/config.

- Either an overlay with fixed pin configuration. This overlay type
  configures the pins to a certain state before the libpruio code gets
  executed. The code can run with user privileges.

- Or an universal overlay, that provide run-time pinmuxing capability.
  That means the pin mode and resistor / receiver configuration can get
  changed when the libpruio code is running. The later needs admin
  privileges.

For a customized overlay adapt the source code, compile and execute it:

- Use dts_custom.bas for overlays with fixed pinmuxing, or

- use dts_universal.bas for overlays providing run-time pinmuxing capability.
