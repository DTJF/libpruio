Messages  {#ChaMessages}
========
\tableofcontents

\Proj contains two types of software

- software running on the host (ARM), reporting human readable messages, and
- software running on the PRUSS, reporting its state in form of a number code.

The number codes for the states of the PRUSS software get written to
PruIo::DRam `[0]` and the codes are defined in file pruio.hp. Ie.
code PRUIO_MSG_INIT_OK signals that the init instruction executed
successfuly. In normal operations the user need not care about this
feature, except when using RB mode.

Instead the user communicates with the functions of the API from the
host software. Most of this functions are designed to return 0 (zero)
on success or an error text (`ZSTRING PTR` in FB, `char*` in C) in
case of an error. Additionaly the member variable PruIo::Errr gets
set to the same message text. You can use either of them to handle the
error message. The texts are always internal strings owned by \Proj
and must not be freed.

Just a few functions do not follow this principle

- All constructors, since they don't return anything (they're SUBs).

- The function GpioUdt::Value(), since it returns the GPIO state
  and -1 in case of an error.

- The trigger specification functions AdcUdt::mm_trg_pin(),
  AdcUdt::mm_trg_ain() and AdcUdt::mm_trg_pre(), since they
  return the specification and 0 (zero) in case of an error.

For those functions the error message (if any) is only available in
variable PruIo::Errr.

In all cases, \Proj just sets the pointer PruIo::Errr. The
calling code may or may not handle the error message. When the code
tries to continue, it should reset the pointer to 0 (zero) to avoid
blocking further function calls due to former errors.

There's a last exception: The main destructor PruIo::~PruIo() cannot
use the variable PruIo::Errr, since it isn't available after the
destructor has finished. Instead, the destructor writes error messages
(if any) directly to stderr.

Here's an overview of all possible error messages from the public UDT
member functions and some hints on how to fix the related code:


# PruIo # {#SecErrPruIo}

## Constructor ## {#sSecPruIoCTor}

The constructor doesn't return a value. In order to check for errors,
you have to check the error variable PruIo::Errr. It contains 0 (zero)
on success. Otherwise it points to one of the following error messages:

\Item{"cannot open /dev/uio5"} The constructor failed to open the
interrupt file /dev/uio5 for read and write access. -> Make sure that
the kernel driver `uio_pruss` is loaded (ie. by an appropriate device
tree overlay) and the user has write privileges. Find details in
section \ref sSecPruDriver.

\Item{"failed loading Pru_Init instructions"} The constructor failed to
load the init instructions to the PRU. -> Internal problem, no hint for
fixing.

\Item{"failed executing Pru_Init instructions"} The constructor failed
to execute the init instructions on the PRU. -> There's some internal
error in the PRU instructions due to customization. Re-install or
re-compile the \Proj library.

\Item{"out of memory"} The constructor failed to allocate memory for
the configurations (Init and Conf). -> Make sure that you have at least
5 kB free.

\Item{"parsing kernel claims"} The constructor failed to scan for
kernel pinmux claims. This is not an error, but a warning. It occurs
when you loaded the kernel module for pinmuxing on kernel 3.8, and
\Proj cannot read in directory `/sys/kernel/debug`. Anyway, your
program will run unless it tries to change a pin configuration. (Like
on a no-pinmux configuration. In contrast, when an universal overlay is
loaded, you won't see this message. The constructor auto-switches the
overlay pinmuxing method.) -> Either execute the program with `sudo`,
or enable the free pinmux feature (= calling constructor
PruIo::PruIo(PRUIO_ACT_FREMUX OR ...) ).

\Item{"segfault"} There are lots of reasons for this kind of message.
When you're sure that it happens in the constructor, then it's most
likely that it happens because the driver tried to wtite to PRUSS
memory while the PRUSS isn't enabled. -> Make sure that the PRUSS are
enabled, by loading a device tree overlay that includes `&pruss {
status = "okay" }` and check if the `uio_pruss` kernel module is
loaded. See chapter \ref sSecPruDriver for further info.


## Destructor ## {#sSecPruIoDTor}

Th destructor doesn't return a value. It also doesn't use the error
variable PruIo::Errr.

\note The variable PruIo::Errr is no longer valid when the destructor
      is called. That's why destructor messages don't use that
      variable. Instead all messages get streamed directly to `STDERR`.

You may see one of the following output:

\Item{"failed loading Pru_Exit instructions"} The destructor failed to
load the instructions to restore the subsystems initial state to the
PRU. -> Make sure that the library libprussdrv is working properly.
(Follow the documentation and test some examples.)

\Item{"failed executing Pru_Exit instructions"} The destructor failed
to execute instructions to restore the subsystems initial state on the
PRU. -> There's some internal error in the PRU instructions due to
customization. Re-install or re-compile the \Proj library.

\Item{"destructor warning: subsystems are NOT restored"} This is not an
error but just a warning. The destructor didn't restore the subsystems
initial state, since there were no data. Either the constructor
couldn't prepare this data due to an error, or the user deleted the
data to prevent restoring.

\Item{"destructor warning: constructor failed"} This is not an error
but just a warning. The destructor didn't do anything (and didn't
restore the subsystems initial state), since the constructor failed in
an early state.


## config ## {#sSecPruIoConfig}

\Item{"ADC not enabled"} Sampling analog lines is required (parameter
Mask not equal zero), but the ADC subsystem isn't enabled. -> Either
check constructor parameter `Act` (bit 1 - ADC must be set). Or, if you
don't need ADC sampling, pass zero as parameter `Mask` in the function
call PruIo::config().

\Item{"no step active"} The RB or MM mode is active (parameter `Samp` >
1), but the parameter `Mask` didn't specify any active channel. ->
Check those parameters in the previous call to function
PruIo::config().

\Item{"out of memory"} The external memory isn't big enough for the
required number of samples. -> Either reduce the number of samples
(parameter `Samp`) or the number of active steps (parameter `Mask`) in
the previous call to function PruIo::config(). Or increase the
size of the external memory (see \ref ChaMemory for details).

\Item{"sample rate too big"} The specified sampling rate isn't
reachable with the current step configuration. -> Either reduce the
number of active steps (parameter `Mask`), or decrease the sampling
rate (increase parameter `Tmr`) in the previous call to function
PruIo::config(). Or decrease the step delays (Open and / or Sample
Delay in AdcSet::St_p) before that call.

\Item{"failed loading Pru_Run instructions"} For safety reasons the PRU
instruction get (re-)loaded each time in function PruIo::config().
The function failed to load the instructions to the PRU. -> Make sure
that the library libprussdrv is working properly. (Follow the
documentation and test some examples.)

\Item{"failed executing Pru_Run instructions"} The function failed to
execute the PRU instructions on the PRU. -> There's some internal error
in the PRU instructions due to customization. Re-install or re-compile
the \Proj library.


## rb_start ## {#sSecErrRbStart}

\Item{"ring buffer mode not ready"} Starting ring buffer (RB) mode is
required, but the PRU software isn't ready. -> Check if the ADC
subsystem is enabled. Check if there's at least one active step
(AdcUdt::ChAz `> 0`). Check the previous call to function
PruIo::config().


## mm_start ## {#sSecErrMmStart}

\Item{"measurement mode not ready"} Starting measurement (MM) mode is
required, but the PRU software isn't ready. -> First, call function
PruIo::config().

\Item{"Trg...: too much pre-trigger samples"} (... replaced by trigger
number) The number of pre-trigger samples is too big. \Proj uses
the DRam area as ring buffer for pre-trigger values. Its maximun size
is `16 kB - PRUIO_DAT_ADC` -> Either reduce parameter `Samp` in the
previous call to AdcUdt::mm_trg_pre(). Or reduce the number of active
steps in parameter `Mask` in the previous call to PruIo::config().

\Item{"Trg...: pre-trigger step must be active"} (... replaced by
trigger number) The function call specifies a pre-trigger for an
non-active ADC step. -> Either adapt the parameter `Mask` in function
call PruIo::config() and make the required pre-trigger step active. Or
adapt the pre-trigger configuration in function call
AdcUdt::mm_trg_pre() to a step that ist active in the current `Mask`
parameter.

\Item{"Trg...: unknown trigger pin number"} (... replaced by trigger
number) The ball number in the trigger specification is too big. This
means your trigger specification is brocken. (Did you customize it?) ->
Re-create a correct trigger specification.

\Item{"Trg...: trigger pin must be in mode 7 (GPIO)"} (... replaced by
trigger number) The trigger specification `...` should wait for an
GPIO event, but the related header pin (CPU ball number) isn't in GPIO
mode. -> Re-create the trigger specification with appropriate parameter
`Ball`. Or change pin configuration by a call to function
GpioUdt::config(), first.


## Pin ## {#sSecPruIoPin}

\Item{"unknown pin number"} The specified ball number is too big. ->
Make sure that parameter `Ball` is less or equal \ref PRUIO_AZ_BALL.


## setPin ## {#sSecPruIoSetPin}

\Item{"unknown setPin ball number"} The specified ball number is too
big. -> Make sure that parameter `Ball` is less or equal \ref
PRUIO_AZ_BALL.

\Item{"no ocp access"} The CPU ball isn't in the required modus and
needs a new pinmux setting, but \Proj has no access to the sysfs
folders. -> Either load the universal device tree overlay and execute
the code with administrator privileges. Or make sure that digital lines
are set to the required modes before you execute the code. Or consider
to use the loadable kernel module and execute with  administrator
privileges.

\Item{"pinmux failed: P._.. -> x.."} (points replaced by numbers) The
CPU ball isn't in the required modus and needs a new pinmux setting,
but either the pin or the mode isn't specified in the \Proj device tree
overlay, or the overlay isn't loaded. -> Check the parameters `Ball`
and `Mo`. Make sure that the required modus is defined in the \Proj
device tree overlay and that overlay is loaded. Or consider to use the
loadable kernel module and execute with administrator privileges.

\Item{"pin P._.. claimed by ..."} (or "ball... claimed by ...") The LKM
(loadable kernel module) is active and the program requires pinmuxing,
but the related pin (CPU ball) is claimed by another system. -> Either
enable the free pinmux feature (by calling constructor
PruIo::PruIo(PRUIO_ACT_FREMUX OR ...) ). Or disable the pin claim by
loading an other device tree overlay. Or (on kernel >= 4.14) remove the
trigger file by executing

    sudo rm /boot/dtbs/`uname -r`/am335x-boneblack-uboot-univ.dtb

\Item{"pinmux missing"} The program requires pinmuxing, but there is no
pinmux configuration on your system. -> Load the kernel module and
execute with administrator privileges.

\note The above errors may occur in any XXX.setValue() or xxx.config()
      function, since \Proj tries to adapt a pin when its muxmode
      doesn't match.


# ADC # {#SecErrAdc}

## setStep ## {#sSecErrSetStep}

\Item{"ADC not enabled"} You try to configure an ADC step, but in the
constructor call PruIo::PruIo() the first parameter `Act` doesn't
enable the ADC subsystem, so no sampling is possible. -> Enable the ADC
subsystem by adding PRUIO_ACT_ADC to the first parameter `Act` in the
constructor PruIo::PruIo() call.

\Item{"step number too big"} The specified step number is too big. ->
Make sure that parameter `Stp` is in the range of 0 to 16.

\Item{"channel number too big"} The specified channel number is too
big. -> Make sure that parameter `ChN` is in the range of 0 to 7.


## mm_trg_pin ## {#sSecErrMmTrgPin}

\Item{"ADC not enabled"} You try to configure an ADC trigger, but in
the constructor call PruIo::PruIo() the first parameter `Act` doesn't
enable the ADC subsystem, so no sampling is possible. -> Enable the ADC
subsystem by adding PRUIO_ACT_ADC to the first parameter `Act` in the
constructor PruIo::PruIo() call.

\Item{"too much values to skip"} The post trigger delay is too big. ->
Make sure that parameter `Skip` is in the range of 0 to 1023.

\Item{"unknown trigger pin number"} The specified ball number is too
big. -> Make sure that parameter `Ball` is less or equal \ref
PRUIO_AZ_BALL.

\Item{"GPIO subsystem not enabled"} The specified CPU ball is on a GPIO
subsystem that isn't enabled. -> Either check parameter `Ball`. Or make
sure that the GPIO subsystem is active (see constructor
PruIo::PruIo() ) and enabled (`PruIo->Gpio->Conf(n)->ClVa = 2` before
the call to PruIo::config() ).

\Item{"pin must be in GPIO mode (mode 7)"} The specified CPU ball isn't
in GPIO mode. -> Either check parameter `Ball`. Or call function
GpioUdt::config() to set appropriate mode, receiver and resistor
configuration, first.


## mm_trg_ain ## {#sSecErrMmTrgAin}

\Item{"ADC not enabled"} You try to configure an ADC trigger, but in
the constructor call PruIo::PruIo() the first parameter `Act` doesn't
enable the ADC subsystem, so no sampling is possible. -> Enable the ADC
subsystem by adding PRUIO_ACT_ADC to the first parameter `Act` in the
constructor PruIo::PruIo() call.

\Item{"invalid step number"} The specification should get created for a
non-valid step. -> Make sure to pass a number in the range of 1 to 16
as parameter `Stp` (the charge step - index 0 - cannot be used as
trigger).

\Item{"trigger step not configured"} The specification should get
created for a step that isn't configured jet. -> Configure the desired
step, first, by calling function AdcUdt::setStep().

\Item{"too much values to skip"} The post trigger delay is too big. ->
Make sure that parameter `Skip` is in the range of 0 to 1023.


## mm_trg_pre ## {#sSecErrMmTrgPre}

\Item{"ADC not enabled"} You try to configure an ADC trigger, but in
the constructor call PruIo::PruIo() the first parameter `Act` doesn't
enable the ADC subsystem, so no sampling is possible. -> Enable the ADC
subsystem by adding PRUIO_ACT_ADC to the first parameter `Act` in the
constructor PruIo::PruIo() call.

\Item{"invalid step number"} The specification should get created for a
non-valid step. -> Make sure to pass a number in the range of 1 to 16
as parameter `Stp` (the charge step - index 0 - cannot be used as
trigger).

\Item{"trigger step not configured"} The specification should get
created for a step that isn't configured jet. -> Configure the desired
step, first, by calling function AdcUdt::setStep().

\Item{"trigger step not activated"} The specification should get
created for a step that isn't activated. -> Check parameter `Stp`. Make
sure that the desired step bit is set in parameter `Mask` in the
previous call to function PruIo::config().

\Item{"too much pre-samples"} The number of pre-trigger samples is too
big. -> Make sure that parameter `Samp` is in the range of 0 to 1023.

\Item{"more pre-samples than samples"} The number of pre-trigger
samples is too big. -> Make sure that parameter `Samp` isn't greater
then parameter `Samp` in the previous call to function
PruIo::config().



# GPIO # {#SecErrGpio}

\note When the pin (CPU ball) is not in the matching mode, \Proj
      tries to configure it. In that case you also may get error
      messages as described in \ref sSecPruIoSetPin.


## config ## {#sSecErrGpioConfig}

\Item{"unknown GPIO output pin number"} The specified ball number is
too big. -> Make sure that parameter `Ball` is less or equal \ref
PRUIO_AZ_BALL.

\Item{"no GPIO mode"} Setting a header pin in GPIO mode is required,
but the specified mode in parameter `Mo` is not a GPIO mode. -> Make
sure to specify a valid GPIO mode (ie. from enumerators ::PinMuxing).

\Item{"GPIO subsystem not enabled"} Setting a header pin in GPIO mode
is required, but the related GPIO subsystem isn't enabled. -> Set
`PruIo->Gpio->Conf(n)->ClVa = 2` (n is the number of the GPIO subsystem
connected to that ball number) and call function PruIo::config(),
first.


## Value ## {#sSecErrGpioValue}

\Item{"unknown GPIO output pin number"} The specified ball number is
too big. -> Make sure that parameter `Ball` is less or equal \ref
PRUIO_AZ_BALL.

\Item{"no GPIO pin"} Getting a GPIO input is required, but the
specified header pin (CPU ball number) isn't in GPIO mode. -> Check the
parameter `Ball`. Call function GpioUdt::config() to change the pin
configuration to GPIO input mode.

\Item{"GPIO subsystem not enabled"} Getting a GPIO input is required,
but the related GPIO subsystem isn't enabled. -> Set
`PruIo->Gpio->Conf(n)->ClVa = 2` (n is the number of the GPIO subsystem
connected to that ball number) and call function PruIo::config(),
first.


## setValue ## {#sSecErrGpioSetValue}

\Item{"unknown GPIO output pin number"} The specified ball number is
too big. -> Make sure that parameter `Ball` is less or equal \ref
PRUIO_AZ_BALL.

\Item{"GPIO subsystem not enabled"} Setting a GPIO output is required,
but the related GPIO subsystem isn't enabled. -> Set
`PruIo->Gpio->Conf(n)->ClVa = 2` (n is the number of the PWMSS
connected to that ball number) and call function PruIo::config(),
first.

\Item{"no GPIO mode"} Setting a new mode for the GPIO output is
required, but the specified mode isn't a GPIO mode. -> Check the
parameter `Mo`, use enumerators ::PinMuxing.


# PWM # {#SecErrPwm}

\note When the pin (CPU ball) is not in the matching mode, \Proj
      tries to configure it. In that case you also may get error
      messages as described in \ref sSecPruIoSetPin.

## setValue ## {#sSecErrPwmSetValue}

\Item{"pin has no PWM capability"} The specified ball number has no
TIMER capability. -> Make sure that parameter `Ball` is one of the PWM
pins listed in section \ref sSecPwm.

\Item{"pin not in PWM mode"} Setting the values of a PWM output is
required, but the related header pin (CPU ball) isn't in PWM mode.
libruio tried to configure the CPU ball, but the call to function
PruIo::setPin() failed. -> Check the parameter `Ball`. Check if the CPU
ball is specified in the \Proj device tree overlay. Extend the
device tree overlay if you need access to further CPU balls.

\Item{"PWMSS not enabled"} Setting a PWM output is required, but the
related PWMSS subsystem isn't enabled. -> Set
`PruIo->PwmSS->Conf(n)->ClVa = 2` (n is the number of the PWMSS
connected to that ball number) and call function PruIo::config(),
first.

\Item{"set frequency in first call"} This is the first call to set PWM
output at the given pin, but the specified frequency in parameter
`Hz` is invalid. -> Make sure to pass a valid frequency in the first
call.

\Item{"frequency not supported"} The module (PWM or CAP) isn't capable
to generate output at the required frequency. -> Check the parameter
`Hz` and set an appropriate value (CAP and PWM modules have different
frequency ranges).

## Value ## {#sSecErrPwmValue}

\Item{"pin has no PWM capability"} The specified ball number has no
TIMER capability. -> Make sure that parameter `Ball` is one of the PWM
pins listed in section \ref sSecPwm.

\Item{"pin not in PWM mode"} Getting the values of a PWM output is
required, but the related header pin (CPU ball) isn't in PWM mode. ->
Call function PwmMod::setValue() to configure then header pin, first.

\Item{"PWMSS not enabled"} Getting the values of a PWM output is
required, but the related PWMSS subsystem isn't enabled. -> Set
`PruIo->PwmSS->Conf(n)->ClVa = 2` (n is the number of the PWMSS
connected to that ball number) and call function PruIo::config(),
first.

\Item{"eCAP module not in output mode"} Getting the values of a PWM
output of a CAP module in a PWMSS is required, but the module is in
input mode. -> Check the previous configuration of that pin.

## snyc ## {#sSecErrPwmSync}

\Item{"libpruio LKM missing"} This function needs the loadable kernel
module (LKM) named `libpruio`. Check the output of `lsmod | grep
libpruio` . If empty, you have to install and load that module.
Otherwise you cannot use that feature. See chapter \ref ChaPreparation
for details.


# TIMER # {#SecErrTim}

\note When the pin (CPU ball) is not in the matching mode, \Proj
      tries to configure it. In that case you also may get error
      messages as described in \ref sSecPruIoSetPin.

## setValue ## {#sSecErrTimSetValue}

\Item{"pin has no TIMER capability"} The specified ball number has no
TIMER capability. -> Make sure that parameter `Ball` is one of the
TIMER pins listed in section \ref sSecTimer.

\Item{"TIMER subsystem not enabled"} Setting a TIMER output is
required, but the related TIMERSS subsystem isn't enabled. -> Set
`PruIo->TimSS->Conf(n)->ClVa = 2` (n is the number of the TIMERSS
connected to that ball number) and call function PruIo::config(),
first.

\Item{"duration too short"} The module (TIMER or CAP) isn't capable to
generate output at the required time periods. -> Check the parameters
`Dur1` and `Dur2`, and set appropriate values. TIMER and CAP modules
have different ranges, see section \ref sSecTimer. Note: in one shot
mode the minimal duration is bigger.

\Item{"duration too long"} The module (TIMER or CAP) isn't
capable to generate output at the required time periods. -> Check the
parameters `Dur1` and `Dur2`, and set appropriate values. TIMER and
CAP modules have different ranges, see section \ref sSecTimer.

\Item{"pin not in TIMER mode"} Setting the values for a
TIMER output is required, but the pin is not in TIMER mode, and
therefor cannot generate TIMER pulses. -> Check the (previous)
configuration of that pin. Or enable LKM pinmuxing, see chapter \ref
ChaPreparation for details.

\note When the pin (CPU ball) is not in the matching mode, \Proj
      tries to configure it. In that case you also may get error
      messages as described in \ref sSecPruIoSetPin.


## Value ## {#sSecErrTimValue}

\Item{"pin has no TIMER capability"} The specified ball number has no
TIMER capability. -> Make sure that parameter `Ball` is on of the TIMER
pins listed in section \ref sSecTimer.

\Item{"TIMER subsystem not enabled"} Getting the values of a TIMER
output is required, but the related TIMER subsystem isn't enabled. ->
Set `PruIo->TimSS->Conf(n)->ClVa = 2` (n is the number of the TIMERSS
connected to that ball number) and call function PruIo::config(),
first.

\Item{"pin not in TIMER mode"} Getting the values of a TIMER output is
required, but the pin is not in TIMER mode, and therefor cannot
generate TIMER pulses. -> Check the (previous) configuration of that
pin. Or enable LKM pinmuxing, see chapter \ref ChaPreparation for
details.


# CAP # {#SecErrCap}

\note When the pin (CPU ball) is not in the matching mode, \Proj
      tries to configure it. In that case you also may get error
      messages as described in \ref sSecPruIoSetPin.

## config ## {#sSecErrCapConfig}

\Item{"unknown CAP pin number"} The specified ball number is too big. ->
Make sure that parameter `Ball` is less or equal \ref PRUIO_AZ_BALL.

\Item{"pin has no CAP capability"} Setting a CPU ball in CAP mode is
required, but it has no CAP capability. -> Check the parameter `Ball`.
(Only P9_28 and P9_42 have CAP capability on the BBB.)

\Item{"CAP not enabled"} Setting a CPU ball for CAP is required, but the
related PWMSS subsystem isn't enabled. -> Set
`PruIo->PwmSS(n)->Conf->ClVa = 2` (n is the number of the PWMSS
connected to that ball number) and call function PruIo::config(),
first.

\note When the pin (CPU ball) is not in the matching mode, \Proj
      tries to configure it. In that case you also may get error
      messages as described in \ref sSecPruIoSetPin.


## Value ## {#sSecErrCapValue}

\Item{"unknown CAP pin number"} The specified ball number is too big. ->
Make sure that parameter `Ball` is less or equal \ref PRUIO_AZ_BALL.

\Item{"pin not in CAP mode"} Fetching a value is required, but the
header pin (CPU ball) isn't in CAP mode. -> Call function
CapMod::config(), first.

\Item{"IO/RB mode not running"} Fetching a value is required, but the
PRU software isn't running. -> Call function PruIo::config(), first.

\Item{"CAP not enabled"} Fetching a value is required, but the related
PWMSS subsystem isn't enabled. -> Set `PruIo->PwmSS->Conf(n)->ClVa = 2`
(n is the number of the PWMSS connected to that ball number) and call
function PruIo::config(), first.


# QEP # {#SecErrQep}

\note When the pin (CPU ball) is not in the matching mode, \Proj
      tries to configure it. In that case you also may get error
      messages as described in \ref sSecPruIoSetPin.

## config ## {#sSecErrQepConfig}

\Item{pin has no QEP capability} The specified ball number can not get
muxed to a PWMSS-QEP module -> Make sure to specify a correct pin, see
\ref sSecQep for details.

\Item{QEP not enabled} Setting a CPU ball for QEP is required, but the
related PWMSS subsystem isn't enabled. -> Set
`PruIo->PwmSS(n)->Conf->ClVa = 2` (n is the number of the PWMSS
connected to that ball number) and call function PruIo::config(),
first.

\Item{frequency not supported} The specified frequency for speed
measurement is out of the supported range -> Specify a frequency in the
range of 12 to 50e6 Hz, see \ref sSecQep for details.

\note When the pin (CPU ball) is not in the matching mode, \Proj
      tries to configure it. In that case you also may get error
      messages as described in \ref sSecPruIoSetPin.


## Value ## {#sSecErrQepValue}

\Item{pin has no QEP capability} The specified ball number is not
connected to a PWMSS-QEP module -> Make sure to specify a correct pin,
see \ref sSecQep for details.

\Item{IO/RB mode not running} Fetching a value is required, but the PRU
software isn't running. -> Call function PruIo::config(), first.


# CMake # {#SecCMake}

CMake, or better CMakeFbc errors may occur when you prepare the build
tree. That is after downloading and installing the source tree, but
before building the binaries.

\Item{-- Configuring incomplete, errors occurred!} CMake couldn't
process all configurations. That's a fatal error, it's unlikely that
building this configuration will produce anything reasonable. Check the
lines before for errors or warnings and solve them. The system
preparation is described in Chapter \ref ChaPreparation. The build tree
is fine when the `cmakefbc ..` command output ends with:

~~~{.txt}
-- Configuring done
-- Generating done
-- Build files have been written to: /home/debian/YOUR/PATH/HERE
~~~

\Item{>> no target ...} Some components are missing on your system,
necessary to build that target. Only the listed target is affected,
other targets may work (reorted by text `>> target <...> OK!`). No
action is required, until you need to build that target. In that case
check the lines before for message for errors or warnings and solve
them. The system preparation is described in Chapter \ref
ChaPreparation.

\Item{cmakefbc_deps: skipping dir.bi ...} The dependency scanner misses
an include file and cannot generate a CMake dependency for it. That's
just a warning information, no action is required. Find details in the
(cmakefbc package documentation)[github.com/dtjf/cmakefbc].


# make # {#SecMake}

Make errors occur after you installed and prepared the source tree, and
when you start building targets.

\Item{file INSTALL cannot copy file} You executed a ` make install`
instruction for a restricted location. The script has no permission to
perform the required task. Prepend `sudo` to your command.
