Messages  {#ChaMessages}
======
\tableofcontents

libpruio contains two types of software

- software running on the host (ARM), reporting human readable messages, and
- software running on the PRUSS, reporting its state in form of a number code.

The number codes for the states of the PRUSS software get written to
PruIo::DRam `[0]` and the codes are defined in file pruio.hp. Ie.
code PRUIO_MSG_INIT_OK signals that the init instruction executed
successfuly. In normal operations the user need not care about this
feature, except when using RB mode.

Instead the user communicates with the functions of the API from the
host software. Most of this functions are designed to return 0 (zero)
on success or an error text (`ZSTRING PTR` in FB, `*gchar` in C) in
case of an error. Additionaly the member variable PruIo::Errr gets
set to the same message text. You can use either of them to handle the
error message. The texts are always internal strings owned by libpruio
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

In all cases, libpruio just sets the pointer PruIo::Errr. The
calling code may or may not handle the error message. When the code
tires to continue, it should reset the pointer to 0 (zero) to avoid
blocking further function calls due to former errors.

There's a last exception: The main destructor PruIo::~PruIo cannot use
the variable PruIo::Errr, since it isn't available after the
destructor has finished. Instead, the destructor writes error messages
(if any) directly to stderr.

Here's an overview of all possible error messages from the public UDT
member functions and some hints on how to fix the related code:


PruIo {#SecErrPruIo}
=====

Constructor {#SubSecPruIoCTor}
-----------

\Item{"cannot open /dev/uio5"} The constructor failed to open the
interrupt file /dev/uio5 for read and write access. -> Make sure that
the kernel driver uio_pruss is loaded (ie. by an appropriate device
tree overlay) and the user has write privileges. Find details in
section \ref SecPreconditions.

\Item{"failed opening prussdrv library"} The constructor failed to
initialize the library libprussdrv. -> Make sure that the library is
working properly. (Follow the documentation and test some examples.)

\Item{"failed loading Pru_Init instructions"} The constructor failed to
load the init instructions to the PRU. -> Make sure that the library
libprussdrv is working properly. (Follow the documentation and test
some examples.)

\Item{"failed executing Pru_Init instructions"} The constructor failed
to execute the init instructions on the PRU. -> There's some internal
error in the PRU instructions due to customization. Re-install or
re-compile the libpruio library.

\Item{"out of memory"} The constructor failed to allocate memory for
the configurations (Init and Conf). -> Make sure that you have at least
5 kB free.


Destructor {#SubSecPruIoDTor}
----------

\note The variable PruIo::Errr isn't valid when the destructor
      finished. That's why the following messages get streamed directly
      to stderr.

\Item{"failed loading Pru_Exit instructions"} The destructor failed to
load the instructions to restore the subsystems initial state to the
PRU. -> Make sure that the library libprussdrv is working properly.
(Follow the documentation and test some examples.)

\Item{"failed executing Pru_Exit instructions"} The destructor failed
to execute instructions to restore the subsystems initial state on the
PRU. -> There's some internal error in the PRU instructions due to
customization. Re-install or re-compile the libpruio library.

\Item{"destructor warning: subsystems are NOT restored"} This is not an
error but just a warning. The destructor didn't restore the subsystems
initial state, since there were no data. Either the constructor
couldn't prepare this data due to an error, or the user deleted the
data to prevent restoring.

\Item{"destructor warning: constructor failed"} This is not an error
but just a warning. The destructor didn't do anything (and didn't
restore the subsystems initial state), since the constructor failed in
an early state.


config {#SubSecPruIoConfig}
------

\Item{"ADC not enabled"} Sampling analog lines is required, but the ADC
subsystem isn't enabled. -> Either check parameters *Samp* and *Mask*
in the previous call to function PruIo::config(). Or check the value of
`PruIo->Adc->Conf->ClVa` (and enable ADC subsystem).

\Item{"no step active"} The RB or MM mode is active (parameter *Samp* >
1), but the parameter *Mask* didn't specify any active channel. ->
Check those parameters in the previous call to function
PruIo::config().

\Item{"out of memory"} The external memory isn't big enough for the
required number of samples. -> Either reduce the number of samples
(parameter *Samp*) or the number of active steps (parameter *Mask*) in
the previous call to function PruIo::config(). Or increase the
size of the external memory (see ChaMemory for details).

\Item{"sample rate too big"} The specified sampling rate isn't
reachable with the current step configuration. -> Either reduce the
number of active steps (parameter *Mask*), or decrease the sampling
rate (increase parameter *Tmr*) in the previous call to function
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
the libpruio library.


rb_start {#SubSecErrRbStart}
--------

\Item{"ring buffer mode not ready"} Starting ring buffer (RB) mode is
required, but the PRU software isn't ready. -> Check if the ADC
subsystem is enabled. Check if there's at least one active step
(AdcUdt::ChAz `> 0`). Check the previous call to function
PruIo::config().


mm_start {#SubSecErrMmStart}
--------

\Item{"measurement mode not ready"} Starting measurement (MM) mode is
required, but the PRU software isn't ready. -> First, call function
PruIo::config().

\Item{"Trg...: too much pre-trigger samples"} (... replaced by trigger
number) The number of pre-trigger samples is too big. libpruio uses
the DRam area as ring buffer for pre-trigger values. Its maximun size
is `16 kB - PRUIO_DAT_ADC` -> Either reduce parameter *Samp* in the
previous call to AdcUdt::mm_trg_pre(). Or reduce the number of active
steps in parameter *Mask* in the previous call to PruIo::config().

\Item{"Trg...: pre-trigger step must be active"} (... replaced by trigger number)

\Item{"Trg...: unknown trigger pin number"} (... replaced by trigger
number) The ball number in the trigger specification is too big. This
means your trigger specification is brocken. (Did you customize it?) ->
Re-create a correct trigger specification.

\Item{"Trg...: trigger pin must be in mode 7 (GPIO)"} (... replaced by
trigger number) The trigger specification `...` should wait for an
GPIO event, but the related header pin (CPU ball number) isn't in GPIO
mode. -> Re-create the trigger specification with appropriate parameter
*Ball*. Or change pin configuration by a call to function
GpioUdt::config(), first.


Pin {#SubSecPruIoPin}
---

\Item{"unknown pin number"} The specified ball number is too big. ->
Make sure that parameter *Ball* is less or equal \ref PRUIO_AZ_BALL.


setPin {#SubSecPruIoSetPin}
------

\Item{"unknown setPin ball number"} The specified ball number is too
big. -> Make sure that parameter *Ball* is less or equal \ref
PRUIO_AZ_BALL.

\Item{"no ocp.* access"} The CPU ball isn't in the required modus and
needs a new pinmux setting, but libpruio has no access to the sysfs
folders. -> Either execute the code with administrator privileges. Or
make sure that digital lines are set to the required modi before you
execute the code.

\Item{"no pin control"} The required CPU ball (parameter *Ball*) is not
specified in the libpruio device tree overlay or the overlay isn't
loaded. -> Check the parameter *Ball*. Check if the CPU ball is
specified in the libpruio device tree overlay. Extend the device tree
overlay if you need access to further CPU balls.

\Item{"pinmux failed: P._.. -> x.." (points replaced by numbers)}
Pinmuxing isn't supported for that state. -> Check the parameters
*Ball* and *Mo*. Make sure that the required modus is defined in the
libpruio device tree overlay.


ADC {#SecErrAdc}
===

setStep {#SubSecErrSetStep}
-------

\Item{"ADC not enabled"}

\Item{"step number too big"} The specified step number is too big. ->
Make sure that parameter *Stp* is in the range of 0 to 16.

\Item{"channel number too big"} The specified channel number is too
big. -> Make sure that parameter *ChN* is in the range of 0 to 7.


mm_trg_pin {#SubSecErrMmTrgPin}
----------

\Item{"ADC not enabled"}

\Item{"too much values to skip"} The post trigger delay is too big. ->
Make sure that parameter *Skip* is in the range of 0 to 1023.

\Item{"unknown trigger pin number"} The specified ball number is too
big. -> Make sure that parameter *Ball* is less or equal \ref
PRUIO_AZ_BALL.

\Item{"GPIO subsystem not enabled"} The specified CPU ball is on a GPIO
subsystem that isn't enabled. -> Either check parameter *Ball*. Or make
sure that the GPIO subsystem is active (see constructor
PruIo::PruIo() ) and enabled (`PruIo->Gpio->Conf(n)->ClVa = 2` before
the call to PruIo::config() ).

\Item{"pin must be in GPIO mode (mode 7)"} The specified CPU ball isn't
in GPIO mode. -> Either check parameter *Ball*. Or call function
GpioUdt::config() to set appropriate mode, receiver and resistor
configuration, first.


mm_trg_ain {#SubSecErrMmTrgAin}
----------

\Item{"ADC not enabled"}

\Item{"invalid step number"} The specification should get created for a
non-valid step. -> Make sure to pass a number in the range of 1 to 16
as parameter *Stp* (the charge step - index 0 - cannot be used as
trigger).

\Item{"trigger step not configured"} The specification should get
created for a step that isn't configured jet. -> Configure the desired
step, first, by calling function AdcUdt::setStep().

\Item{"too much values to skip"} The post trigger delay is too big. ->
Make sure that parameter *Skip* is in the range of 0 to 1023.


mm_trg_pre {#SubSecErrMmTrgPre}
----------

\Item{"ADC not enabled"}

\Item{"invalid step number"} The specification should get created for a
non-valid step. -> Make sure to pass a number in the range of 1 to 16
as parameter *Stp* (the charge step - index 0 - cannot be used as
trigger).

\Item{"trigger step not configured"} The specification should get
created for a step that isn't configured jet. -> Configure the desired
step, first, by calling function AdcUdt::setStep().

\Item{"trigger step not activated"} The specification should get
created for a step that isn't activated. -> Check parameter *Stp*. Make
sure that the desired step bit is set in parameter *Mask* in the
previous call to function PruIo::config().

\Item{"too much pre-samples"} The number of pre-trigger samples is too
big. -> Make sure that parameter *Samp* is in the range of 0 to 1023.

\Item{"more pre-samples than samples"} The number of pre-trigger
samples is too big. -> Make sure that parameter *Samp* isn't greater
then parameter *Samp* in the previous call to function
PruIo::config().



GPIO {#SecErrGpio}
====

config {#SubSecErrGpioConfig}
------

\Item{"unknown GPIO pin number"} The specified ball number is too big. ->
Make sure that parameter *Ball* is less or equal \ref PRUIO_AZ_BALL.

\Item{"GPIO subsystem not enabled"} Setting a header pin in GPIO mode
is required, but the related GPIO subsystem isn't enabled. -> Set
`PruIo->Gpio->Conf(n)->ClVa = 2` (n is the number of the GPIO subsystem
connected to that ball number) and call function PruIo::config(),
first.

\Item{"no GPIO pin"} Setting a header pin in GPIO mode is required, but
the specified header pin (CPU ball number) isn't in the specified mode
and the pinmuxing failed. -> Check the parameter *Ball*. Make sure that
the CPU ball is in the appropriate mode before you execute the program.
Or make sure that pinmuxing is availible in libpruio.

\Item{"no ocp.* access"}

\Item{"no header pin"} The required CPU ball (parameter *Ball*) is not
connected to a header pin. libpruio pinmuxing is limited to a set of
CPU balls, specified in the libpruio device tree overlay. This set only
contains CPU balls connected to one of the headers P8 or P9. -> Check
the parameter *Ball*. Extend the device tree overlay if you need access
to further CPU balls.

\Item{"no pin control"} The required CPU ball is not in the specified
mode. libpruio tried to change the mode, but failed. -> Check the
parameter *Ball*. Check if the user has access to pinmuxing and the CPU
ball is specified in the libpruio device tree overlay. And check if the
overlay isn't loaded. Extend the device tree overlay if you need access
to further CPU balls.

\Item{"pinmux failed: P._.. -> x.." (points replaced by numbers)}
Pinmuxing cannot be done for that pin or that state.


Value {#SubSecErrGpioValue}
-----

\Item{"unknown GPIO input pin number"} The specified ball number is too
big. -> Make sure that parameter *Ball* is less or equal \ref
PRUIO_AZ_BALL.

\Item{"GPIO subsystem not enabled"} Getting a GPIO input is required,
but the related GPIO subsystem isn't enabled. -> Set
`PruIo->Gpio->Conf(n)->ClVa = 2` (n is the number of the GPIO subsystem
connected to that ball number) and call function PruIo::config(),
first.

\Item{"no GPIO pin"} Getting a GPIO input is required, but the
specified header pin (CPU ball number) isn't in GPIO mode. -> Check the
parameter *Ball*. Call function GpioUdt::config() to change the
pin configuration to GPIO in mode.


setValue {#SubSecErrGpioSetValue}
--------

\Item{"unknown GPIO output pin number"} The specified ball number is
too big. -> Make sure that parameter *Ball* is less or equal \ref
PRUIO_AZ_BALL.

\Item{"GPIO subsystem not enabled"} Setting a GPIO output is required,
but the related GPIO subsystem isn't enabled. -> Set
`PruIo->Gpio->Conf(n)->ClVa = 2` (n is the number of the PWMSS
connected to that ball number) and call function PruIo::config(),
first.

\Item{"no GPIO pin"} Setting a GPIO ouput is required, but the
specified header pin (CPU ball number) isn't in GPIO mode. -> Check the
parameter *Ball*. Call function GpioUdt::config() to change the
pin configuration to GPIO out mode.


PWM {#SecErrPwm}
===

setValue {#SubSecErrPwmSetValue}
--------

\Item{"unknown PWM pin number"} The specified ball number is too big. ->
Make sure that parameter *Ball* is less or equal \ref PRUIO_AZ_BALL.

\Item{"pin not in PWM mode"} Setting the values of a PWM output is
required, but the related header pin (CPU ball) isn't in PWM mode.
libruio tried to configure the CPU ball, but the call to function
PruIo::setPin() failed. -> Check the parameter *Ball*. Check if the CPU
ball is specified in the libpruio device tree overlay. Extend the
device tree overlay if you need access to further CPU balls.

\Item{"PWMSS not enabled"} Setting a PWM output is required, but the
related PWMSS subsystem isn't enabled. -> Set
`PruIo->PwmSS->Conf(n)->ClVa = 2` (n is the number of the PWMSS
connected to that ball number) and call function PruIo::config(),
first.

\Item{"set frequency in first call"}

\Item{"frequency not supported"} The module (PWM or CAP) isn't capable
to generate output at the required frequency. -> Check the parameter
*Hz* and set an appropriate value (CAP and PWM modules have different
frequency ranges).


Value {#SubSecErrPwmValue}
-----

\Item{"unknown PWM pin number"} The specified ball number is too big. ->
Make sure that parameter *Ball* is less or equal \ref PRUIO_AZ_BALL.

\Item{"pin not in PWM mode"} Getting the values of a PWM output is
required, but the related header pin (CPU ball) isn't in PWM mode. ->
Call function PwmMod::Value() to configure then header pin, first.

\Item{"PWMSS not enabled"} Getting the values of a PWM input is
required, but the related PWMSS subsystem isn't enabled. -> Set
`PruIo->PwmSS->Conf(n)->ClVa = 2` (n is the number of the PWMSS
connected to that ball number) and call function PruIo::config(),
first.

\Item{"eCAP module not in output mode"} Getting the values of a PWM
output of a CAP module in a PWMSS is required, but the module is in
input mode. -> Check the previous configuration of that pin.


CAP {#SecErrCap}
===

config {#SubSecErrCapConfig}
------

\Item{"unknown CAP pin number"} The specified ball number is too big. ->
Make sure that parameter *Ball* is less or equal \ref PRUIO_AZ_BALL.

\Item{"pin has no CAP capability"} Setting a CPU ball in CAP mode is
required, but it has no CAP capability. -> Check the parameter *Ball*.
(Only P9_28 and P9_42 have CAP capability on the BBB.)

\Item{"CAP not enabled"} Setting a CPU ball for CAP is required, but the
related PWMSS subsystem isn't enabled. -> Set
`PruIo->PwmSS(n)->Conf->ClVa = 2` (n is the number of the PWMSS
connected to that ball number) and call function PruIo::config(),
first.



Value {#SubSecErrCapValue}
-----

\Item{"unknown CAP pin number"} The specified ball number is too big. ->
Make sure that parameter *Ball* is less or equal \ref PRUIO_AZ_BALL.

\Item{"pin not in CAP mode"} Fetching a value is required, but the
header pin (CPU ball) isn't in CAP mode. -> Call function
CapMod::config(), first.


\Item{"IO/RB mode not running"} Fetching a value is required, but the
PRU software isn't running. -> Call function PruIo::config(),
first.

\Item{"CAP not enabled"} Fetching a value is required, but the related
PWMSS subsystem isn't enabled. -> Set `PruIo->PwmSS->Conf(n)->ClVa = 2`
(n is the number of the PWMSS connected to that ball number) and call
function PruIo::config(), first.


QEP {#SecErrQep}
===

config {#SubSecErrQepConfig}
------

\Item{To be continued ...}


Value {#SubSecErrQepValue}
-----

\Item{To be continued ...}



