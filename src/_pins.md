Pins  {#ChaPins}
====
\tableofcontents

The Beaglebone hardware contains two header connectors, each with 46
pins. That is 92 pins in total. Some of them have no input / output
capability (such as RESET, GND or power supply lines). But the majority
are either analog or digital lines, free or unfree, all to be controled
by libpruio.

Analog lines always operate as input. In contrast, digital lines can
either operate as input or output. Some digital lines have several
features and need to get configured in the maching mode (pinmuxing)
before usage. Some lines are used to control the boot sequence and
mustn't be connected at boot-time. Others are reserved to be used by
the operating system, but they can get freed by massive
re-configuration of the boot sequence, so that libpruio can control
them. Some header pins are connected to two CPU balls (and both CPU
balls must not be set in contrary output states).

Here's an overview of the Beaglebone Black default configuration (the
Beaglebone White setting is different). libpruio can operate on all
colored pins

![Header pins controllable by libpruio](pins.png)


Analog {#SecAnalog}
======

Analog lines work always as input line. Analog output isn't supported
by the Beaglebone hardware (but can get achieved by a combination of a
PWM output and a hardware filter).

Analog inputs operate in the range of 0 to 1V8. The header pins are
directly connected to the CPU connectors. There's no overvoltage
protection, so in order to avoid hardware damages you mustn't trespass
the maximum voltage range.

In addition to the seven analog lines available on the header pins
(AIN-0 to AIN-6), libpruio can also receive samples from the AIN-7
line, which is internal connected to the board power line (3V3) by a
50/50 voltage divider. This may be useful to measure the on board
voltage, in oder to control the power supply.

libpruio offers full control over the ADC subsystem configuration. Up
to 16 ADC steps can get configured to switch the required input line,
specifiy individual delay values and maybe apply avaraging. The ADC
subsystem supports analog input up to a frequency of 200 kHz. This
works for up to eight steps. The maximum frequency shrinks when

- avaraging of the samples gets applied, or
- more than eight steps are active, or
- delays (open or sample) are required, or
- a clock devider is active (see AdcUdt::ADC_CLKDIV).

Find further details on analog lines and the ADC subsystem
configurations in \ArmRef{12}.


Digital {#SecDigital}
=======

Each digital header pin can get configured either in GPIO mode or in
one of up to seven alternative modes, see \ref SecPinConfig for further
information. The matrix of the possible connections is hard-coded in
the CPU logic. Find the subset of the Beaglebone headers described in
the \BbbRef{7}. Or find the complete description in the CPU
dokumentation \MpuRef{2.2} .

Before a digital header pin gets used, libpruio checks its mode. When
the current setting matches the required feature, libpruio just
continues. Otherwise it tries the change the pinmuxing appropriately.
The later needs the libpruio-00A0.dtbo device tree overlay loaded and
the program has to be executed with admin privileges for write access
to the pinmuxing folders in /sys/devices/ocp.*/pruio-*.

The overlay contains pre-defined modes for a certain set of CPU balls.
By default the overlay claims the free pins on the BBB headers. Those
are the orange and blue pins in the above image. When you use a
Beaglebone White or you free further pins on the BBB, ie. by disabling
HDMI or other functions on the board, you can easily create an
universal overlay with adapted pin claiming by using the tool
dts_universal.bas.

If you don't want to execute the program under admin privileges, you've
to ensure that all used digital header pins are in the appropriate mode
before you start the program (so that the checks succeed). This can get
achieved by loading a customized overlay. In contrast to the universal
overlay, the customized contains only one configuration for the used
header pins and libpruio cannot change the mode at run-time. You can
easily create a customized overlay with fixed pinmuxing by using the
tool dts_custom.bas.

In any case, all digital lines operates in the range of 0 to 3V3. An
input pin returns low in the range of 0 to 0V8 and high in the range of
1V8 to 3V3. In the range inbetween the state is undefined. The maximum
current on an output pin shouldn't exceed 6 mA.

| Mode   |   LOW    |    HIGH    | Notice                    |
| -----: | :------: | :--------: | :------------------------ |
| output | 0        | 3V3        | max. 6 mA                 |
|  input | 0 to 0V8 | 1V8 to 3V3 | undefined from 0V8 to 1V8 |

Two of the Beaglebone header pins are connected to multiple CPU balls.
Those are P9_41 and P9_42. When changing the pinmuxing of any of the
related CPU balls, it must be ensured that the second CPU ball doesn't
operate in a contrary output state. Therefor the universal device tree
overlay libpruio-0A00.dtbo (and all overlays generated by the tools
dts_custom.bas and dts_universal.bas) always configures two CPU balls
for those pins at once. First, the unused CPU ball gets set in a GPIO
input mode (without resistor) and then the other ball gets set
accordingly.

Some pins are used to control the boot sequence and mustn't be
connected at boot-time.


GPIO {#SubSecGpio}
---

GPIO stands for General Purpose Input or Output. In output mode the
program can switch any connected hardware on or off. In input mode the
program can detect the state of any connected hardware. libpruio can
configure and use any digital header pin in one of the following five
GPIO modes. (Therefor the universal device tree overlay
libpruio-0A00.dtbo has to be loaded and the program has to be executed
with admin privileges.)

| PinMuxing Enumerator | Function                         | GpioUdt::Value() |
| -------------------: | :------------------------------: | :--------------- |
| \ref PRUIO_GPIO_OUT0 | output pin (no resistor)         | 0                |
| \ref PRUIO_GPIO_OUT1 | output pin (no resistor)         | 1                |
| \ref PRUIO_GPIO_IN   | input pin with no resistor       | undefined        |
| \ref PRUIO_GPIO_IN_0 | input pin with pulldown resistor | 0                |
| \ref PRUIO_GPIO_IN_1 | input pin with pullup resistor   | 1                |

An input pin can get configured with pullup or pulldown resistor, or
none of them. Those resistors (about 10 k) are incorporated in the CPU.
In contrast, libpruio configures an output pin always with no CPU
resistor connection (to minimize power consumption). So the first two
modes (PRUIO_GPIO_OUT0 and PRUIO_GPIO_OUT1) use the same pinmuxing.

Those modes are predefined in the universal overlay libpruio-00A00.dtbo for each claimed header pin.


 and the initial state must
get specified at configuration time.

Here're the GPIO pin configurations supported by the universal device
tree overlay libpruio-0A00.dtbo

In some cases it may be reasonable to use an output pin with pullup
resistor, which isn't supported by default. This either needs pinmuxing
by a customized device tree overlay or it can be achieved by adding
this new mode to the universal device tree overlay libpruio-0A00.dtbo.

Find details on GPIO hardware in \ArmRef{25}.


PWM {#SubSecPwm}
---

PWM stands for Pulse Width Modulated output. PWM is available on a
subset of header pins. The pin is configured as output pin without
resistor connection. A counter is running on a certain clock rate. When
the counter reaches a certain value, the state of the output gets
changed.

| Pin   | Subsystem      | Frequency Range    |
| ----- | :------------: | :----------------- |
| P8_07 | TIMER-4        | 0.??? to ?????? Hz |
| P8_13 | PWMSS-0, PWM A | 0.??? to ?????? Hz |
| P9_42 | PWMSS-0, CAP   | 0.??? to ?????? Hz |


CAP {#SubSecCap}
---

CAP stands for Capture and Analyse a digital Pulse train, so it's
measuring the frequency and the duty cycle of signal. It's is available
on a subset of header pins. The CAP pin is configured as input with
pulldown resistor. A counter is running on a certain clock rate. Each
transition of the input triggers the capture of the counter value. The
frequency gets measured as the difference between two positive
transitions (a period). The duty cycle gets measured as the ratio
between a period and the on-time of the signal.

Counters with CAP capability are available on several subsystems in the
CPU

- the eCAP module in the PWMSS-[0-2], and
- the timers subsystems TIMER-[4-7].


| Pin   | Subsystem      | Frequency Range    |
| ----- | :------------: | :----------------- |
| P8_07 | TIMER-4        | 0.??? to ?????? Hz |
| P9_42 | PWMSS-0, CAP   | 0.??? to ?????? Hz |
