Features  {#ChaFeatures}
========
\tableofcontents

Here's some feedback about the \Proj project. [lejan
wrote:](http://www.freebasic.net/forum/viewtopic.php?f=14&t=22501&p=217404#p217404)

    Dear TJF,

    I just wanted to thank you for sharing such a great library! I have
    been using this in C for a robotics project and this library really
    took the hassle out of a lot of the programming work. The Beaglebone is
    not as well supported as Arduino or Rasp Pi so your library is very
    much appreciated.

    Peter

Thanks, for the feedback! It seems that the major goal is reached.

\Proj is designed to provide faster, more flexible (customizable) and
more easy (single source) access to the AM33xx CPU subsystems, compared
to the methods provided by the kernel. Its features in short

- run on PRU-0 or PRU-1 (default)
- control subsystems at runtime (disable or enable and configure)
- run in different run modes (IO, RB and MM)
- configure header pins
- get digital input (GPIO)
- set digital output (GPIO)
- analyse digital input train (CAP frequency and duty cycle)
- set digital output train (PWM frequency and duty cycle)
- get digital input from Quadrature Encoder (QEP position and speed)
- get analog input (ADC)
- apply samples bit encoding (12 to 16 bit)
- configure ADC settings (input channel, timing, averaging)
- perform high-speed measurements (up to 200 kSamples/s)
- start measurement by trigger events (up to 4)
- trigger on analog (single or all) or digital (GPIO) lines
- perform a pre-trigger that starts measurement before the trigger event happens

It's designed for BeagleBone boards

- with 2x46 headers (White, Gree, Black)
- with 3x36 headers (Pocket)
- with individual connectors (Blue)

and runs on all kernel versions above 3.8 (including 4.x).


# PRUSS # {#SecPruss}

The AM33xx CPU on Beaglebone hardware contains two PRU subsystems.
\Proj runs software on the host system (ARM) and on a Programable
Realtime Unit SubSystem (PRUSS), either on PRU-0 or PRU-1 (the later is
the default). Due to the PRU support the load on the ARM is very low,
even complex controllers can operate at reasonable speed. The second
PRU is free for a custom controller working in real-time, and using
\Proj measurement configuration and data.


# Operation # {#SecOperation}

\Proj controls the AM33xx CPU subsystems

- TSC_ADCSS (Touch Screen Controler and Analog to Digital Converter
  SubSystem)

- GPIO (4x General Purpose Input Output subsystem)

- PWMSS (3x Pulse Width Modulation SubSystem, containing modules PWM,
  CAP and QEP)

- TIMERSS (4x Timer and PWM features)

Therefor the application executes a sequence of these three steps

-# Create a PruIo structure, read initial configuration (constructor
   PruIo::PruIo() ).

-# Upload customize configuration to the subsystem registers (function
   PruIo::config() ) and start operation (possibly by functions
   PruIo::rb_start() or PruIo::mm_start() ).

-# When done, restore original register configuration and destroy the
   PruIo structure (destructor PruIo::~PruIo() ).

\note Create and use just one PruIo structure at a time.

\Proj offers a set of API functions to do simple IO task at a
reasonable speed. They may be inefficient in case of advanced
requirements. Therefor \Proj allows direct access to all register
configurations of the subsystems. This is for experts only. Further
customization of the subsystems configuration for analog and digital
lines can get done by adapting the subsystem registers before step 2.

\note It's save to control the Beaglebone hardware by the \Proj API
      functions. In contrast accessing the register sets directly is
      for experts only and may cause non-revisible hardware damages.


# Run Modes # {#SecModi}

\Proj supports three run modes. They differ in the priority of the
timing of the ADC subsystem restarts:

-# IO mode (inaccurate ADC timing): the PRU is running in an endless
   loop and handles input and output lines of all subsystems at the
   same priority. Depending on the number of enabled subsystems, their
   usage and the ADC step configuration, there may be some latency (< 1
   &micro;s) before the next ADC sampling sequence.

-# RB mode (accurate ADC timing): the PRU is running in an endless
   loop and handles restarts of the ADC subsystem at prefered priority.
   Digital input and output gets only handled when the PRU is waiting
   for the next ADC restart. This may cause some delay (< 1 &micro;s)
   before a digital output line gets set or a digital value gets in.

-# MM mode (accurate ADC timing): the PRU waits for a start command and
   performs a single measurement. It handles analog samples only (no
   digital IO available).

The run mode gets specified by parameter `Samp` in the call to function
PruIo::config()

- `Samp = 1` for IO mode, starting immediately, running endless.

- `Samp > 1` for RB mode, starting by a call to function
  PruIo::rb_start(), running endless.

- `Samp > 1` for MM mode, starting by a call to function
  PruIo::mm_start(), stoping after measurement is done.

To stop an endless mode (IO or RB) call function PruIo::config() again.
Or destroy the \Proj structure when done by calling the destructor
PruIo::~PruIo().


# Pinmuxing # {#SecPinmuxingIntro}

Most digital lines of the AM33xx CPU support several features and need
to be configured before use (see section \ref SecPinmuxing for
details). \Proj checks the pin configuration at run-time, and tries to
adapt it if necessary.

- An input line gets configured by a call to the config member function
  (ie. GpioUdt::config() or CapMod::config() ).

- An output line gets configured either by the above functions or by
  the first call to the setValue member function (ie.
  GpioUdt::setValue() or PwmMod::setValue() ).

\Proj supports multiple pinmuxing methods. Depending on the kernel
version and the system configuration pinmuxing at run-time may require
administrator privileges. The most advanced method is the loadable
kernel module, described in section \ref sSecLKM. Or you can run your
application with user privileges by making sure that digital lines are
in the required state (configuration) before executing the code.


# GPIO # {#SecGpio}

General Purpose Input Output is available by the GpioUdt member
functions (in IO and RB mode, for all header pins). See section \ref
sSecGpio for further info.

- Function GpioUdt::config() sets the CPU ball in the required state
  (internal resistor pullup/pulldown/nopull, receiver active). This may
  need pinmuxing capability, see \ref SecPinmuxing.

- Function GpioUdt::Value() gets the current state (input or output).

- Function GpioUdt::setValue() sets an output state (includes
  GpioUdt::config() call).

Furthermore, multi lines can get accessed simultameously by direct
access to the PRU interface (experts only).


# CAP # {#SecCap}

Capture And Analyse a digital Pulse train is available by the member
functions of class ::CapMod (in IO and RB mode). The frequency and duty
cycle of a pulse train can get measured. See section \ref sSecCap for
further info.

- Call Function CapMod::config() to configure the pin as CAP input.

- Call function CapMod::Value() to get the current frequency and/or duty cycle.

A minimal frequency can get specified to limit the reaction time in
case of no input.


# PWM # {#SecPwm}

Generating a Pulse Width Modulated output is available by the ::PwmMod
member functions (in IO and RB mode). Therefor \Proj uses different
subsystems: the PWM modules and the CAP modules in the PWMSS
subsystems, as well as the `TIMER [4-7]` subsystems. All modules are
supported in a transparent API. See section \ref sSecPwm for further
info.

- Function PwmMod::setValue() sets the frequncy and duty cycle
  (and configure the pin, if necessary).

- Function CapMod::Value() gets the current frequency and/or
  duty cycle (they may differ from the required values).

Furthermore advanced features of the PWMSS subsystems can be used by
direct access to the register configuration and PRU interface, ie.
syncronizing multiple PWM outputs (experts only).


# TIMER # {#SecTim}

Generating a pulse train on output line[s]. The time period until the
pulse starts and its duration gets specified. See section \ref
sSecTimer for details.

- Function TimerUdt::setValue() sets the duration or stops a
  running TIMER (and configure the pin, if necessary).

- Function TimerUdt::Value() gets the current durations (those
  may differ from the required values).


# QEP # {#SecQep}

Reading and analysing signals from incremental [Quadrature Encoder
Pulse Trains](https://en.wikipedia.org/wiki/Rotary_encoder). Those
encoders generate pulses by two (mostly light barriers) sensors,
scanning a regular grid (bar code), while both sensors are out of phase
by 90 degrees. By analysing those signals, the position (angle) and the
speed of the movement can get detected.

- Function QepMod::config() configures up to three pins for
  QEP signals.

- Function QepMod::Value() reads the current values (position
  and speed).

\Proj supports multiple measurement configurations:

- single pin (speed only)

- double pin (speed and position)

- tripple pin (speed and position, accurate reset by index pin)

The mode gets specified by the call to function QepMod::config(). See
section \ref sSecQep for further info.


# ADC # {#SecAdc}

In all run modes (IO, RB and MM) Analog Digital Converted input can get
sampled by the ::AdcUdt member functions, controling the Touch Screen
Controler and Analog to Digital Converter SubSystem (TSC_ADC_SS). It
samples analog data on eight input lines (AIN-0 to AIN-7).

\note On Beaglebone hardware line AIN-7 is hard wired by a voltage
      divider on board to the 3V3 power supply.

The ADC subsystem can use up to `16` step configurations (and an
additional charge step) to perform a measurement. \Proj
pre-configures steps `1` to `8` by default to sample lines AIN-0 to
AIN-7.

- Function PruIo::config() sets the run mode, the step mask, the
  measurement timing and the bit encoding.

- Function AdcUdt::setStep() customizes a step configuration
  (optional).

- Array AdcUdt::Value holds the sampled values. The context
  depends on the run mode of \Proj, specified by the parameter
  *Samp* in the most recent call to function PruIo::config().


## Bit Encoding ## {#sSecBitEncoding}

The Beaglebone ADC subsystem samples 12 bit values in the range of `0`
to `4095`. Most other devices (ie. like sound cards) use `16` bit
encoding (in the range of `0` to `65535`) and the values cannot get
compared directly. Therefor \Proj can left shift the samples internaly.
By default the output is 16 bit encoded (range 0 to 65520).

- Parameter *Mds* in function PruIo::config() call adapts the bit encoding.


## Ring Buffer ## {#sSecRB}

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


## Measurement Mode and Triggers ## {#sSecTriggers}

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


# Subsystem Control # {#SecSubSysCont}

\Proj controls several subsystems, listed in section \ref
SecOperation. Each of these subsystems can either

- get configured and used (the default), or

- get switched of (ie. to reduce power consumption), or

- get ignored (no subsystem access, just evaluate the initial state).

To ignore a subsystem, clear its status bit in parameter *Act* when
calling the constructor PruIo::PruIo(). Each subsystem gets controlled
by its own status bit. When a system is set to be ignored, \Proj
cannot access it. There's no configuration data and there's no reset to
the initial state for the subsystem by the destructor PruIo::~PruIo().

By default all subsystems are active (not ignored). All active
subsystems are enabled after the constructor call (unless the hardware
fails). Check

- the subsystems initial clock value to find out if the subsystem was
  enabled before the constructor call (ie. AdcSet::ClVa or
  GpioSet::ClVa have values of `2` if enabled),

- the subsystems version information to find out if the subsystem is
  enabled after the constructor call (ie. AdcSet::REVISION or
  PwmssSet::IDVER have values of `0` (zero) if wakeup failed).

\Proj stores a complete set of configuration data for active
subsystems and restores their state by the destructor when finished.
Active subsystems can get enabled or disabled at run-time. Each call to
function PruIo::config() can change a subsystem state.

- A set status bit in parameter *Act* for the constructor
  PruIo::PruIo() call enable the subsystem.

- To disable a subsystem, set the clock value to `0` (zero), before
  calling function PruIo::config(). Ie. set
  `PruIo->PwmSS->Conf(2)->ClVa = 0` to switch off the third PWMSS
  subsystem (PWMSS-2).

- To re-enable a subsystem, set the clock value to `2`, before calling
  function PruIo::config() again. Ie. set `PruIo->Adc->Conf->ClVa = 2`
  to enable the ADC subsystem.


# Overlays # {#SecOverlays}

The \Proj package contains tools to create, compile and install
device tree overlays in folder src/config.

- Either an overlay with fixed pin configuration. This overlay type
  configures the pins to a certain state before the \Proj code gets
  executed. The code can run with user privileges.

- Or an universal overlay, that provide run-time pinmuxing capability.
  That means the pin mode and resistor / receiver configuration can get
  changed when the \Proj code is running. The later needs admin
  privileges.

For a customized overlay adapt the source code, compile and execute it:

- Use dts_custom.bas for overlays with fixed pinmuxing, or

- use dts_universal.bas for overlays providing run-time pinmuxing capability.
