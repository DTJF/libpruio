Tips and Tricks  {#ChaTNT}
===============
\tableofcontents


# Pinmuxing for other programms # {#SecPinmuxOther}

The Debian images for Beaglebone hardware ship with the tool
`config-pin`, which is used to mux a digital header pin in to a custom
mode. Sometimes the desired mode isn't prepared in the cape-universal
settings, ie. when you need a PRU-GPIO pin with a pull-up resistor. You
can use \Proj to mux that custom mode.

By default the constructor PruIo::PruIo() determines the initial
setting, which you can override for your custom needs while your code
is running. At the end the destructor PruIo::~PruIo() restores the
initial pinmux setting. Restoration can get disabled by making
PruIo::BallInit equal to PruIo::BallConf. The destructor doesn't
restore, and the custom pinmuxing remains after programm exit.

Example

    VAR Io = NEW PruIo()
    Io->setPin(Io, P8_11, 6 + PRUIO_PULL_UP) ' set PRU-0-r30 bit 15 output (mode 6)
    Io->BallInit = Io->BallConf '              no destructor pinmux restoring
    DELETE Io


# Simultaneous GPIO # {#SecSimuGpio}

The functions GpioUdt::Value() and GpioUdt::setValue() read or set the
value of a single GPIO pin. When you call them for multiple GPIO pins,
there's a certain delay since the functions need some time to execute.
\Proj supports to read or set multiple GPIO pins at the same time, when
the pins are controlled by the same GPIO subsystem.

Instead of using function GpioUdt::Value() you can read the value of
GpioArr::Mix. Then mask the bits you need.

Example

    Io->Gpio->Raw(2)->Mix AND &b10010

reads the values of GPIO2_01 (P8_18) in bit 1 and GPIO2_04 (P8_10) in
bit 4.

Instead of using function GpioUdt::setValue() you can set the values of
GpioSet::CLEARDATAOUT and GpioSet::SETDATAOUT directly and transfer
them to the PRU. The first contains the bitmask for low output pins and
the second the mask for the high state pins.

The following example sets the output of GPIO2_01 (P8_18) and GPIO2_04
(P8_10) to high state

    VAR mask = &b10010
    Io->Gpio->Conf(2)->SETDATAOUT    OR= mask
    Io->Gpio->Conf(2)->CLEARDATAOUT AND= NOT mask

    WHILE Io->DRam[1] : WEND ' wait, if PRU is busy (should never happen)
    Io->DRam[5] = Io->Gpio->Conf(2)->OE
    Io->DRam[4] = Io->Gpio->Conf(2)->SETDATAOUT
    Io->DRam[3] = Io->Gpio->Conf(2)->CLEARDATAOUT
    Io->DRam[2] = Io->Gpio->Conf(2)->DeAd + &h100
    Io->DRam[1] = PRUIO_COM_GPIO_CONF SHL 24

\note To get this working, the pins have to be in GPIO mode and the
      GPIO subsystems must be enabled. The most easy way to achieve
      this is to set the initial state by a call to function
      GpioUdt::setValue().

\note A high bit in register OE means input, a low bit is for output.
      Find Details in \ArmRef{25}.


# Second PRU # {#Sec2ndPru}

Once the measurement setup is prepared by code running on ARM, you can
access the raw \Proj data from firmware running on the other PRU. The
examples \ref sSecExaPruAdd and \ref sSecExaPruToggle show how to load
and start firmware. The second PRU can access the \Proj DRam at
adress 0x2000. Find details on memory organisation in section \ref
SecDRam.

The following example shows PRU assembler code for reading the current
ADC value of step 3 in to PRU register r7, when \Proj is running in IO
mode

    MOV  r0, 0x2000          // load DRam address
    MOV  r7, PRUIO_DAT_ADC   // load offset for Adc data block (pruio.hp)
    ADD  r0, r7, 4           // add offset for AdcUdt::Value
    SBBO r7, r0, (3+1)*2, 2  // read current Value (step 0 = charge step)

In a real life project you can first prepare and test your measurements
in a comfortable manner with ARM code. After the proof of concept phase
is finished, move only the inner controller loop to the second PRU to
fulfill hard real-time requirements. Re-coding in assembler code is an
additional development step, but it's worth the effort since usually
the quality of the prototype controller loop increases a lot.

\note Simple controllers can run on the ARM CPU up to a frequency of
      &asymp; 10 kHz with reasonable latency. Consider to use the
      second PRU for hard real-time requirements, higher frequencies,
      or heavy load on the ARM CPU (ie. network transfers, or user
      actions with heavy GUI and grafic loads).

\note You can test the ARM CPU load on your system by executing the
      example \ref sSecExaPerformance.


# PRU fast GPIO 16 bit # {#SecPruGpio}

\Proj controlls the GPIO input or output lines by the GPIO subsystems,
since every GPIO pin can get handled that way. The registers get
accessed over L3 port with a latency of at least 3 cycles. For fast
access some GPIOs are connected directly to the PRU registers R30
(output) and R31 (input). They operate fast with low latency (one
cycle).

On Beaglebone boards (2x46 headers) custom firmware can use all fast
GPIOs on both PRUSS, when both, the JT header and the SD card slot, are
free. Therefor you have to operate from the on-board memory (EMC) and
use a special connector to wire some SD slot pins. Here's a table of
the fast GPIO pins for both PRUSS:

| Bit# | Out-0 (R30) | In-0 (R31) | Out-1 (R30) | In-1 (R31) |
| :--: | :---: | :---: | :---: | :---: |
|   0  | P9_31 | P9_31 | P8_45 | P8_45 |
|   1  | P9_29 | P9_29 | P8_46 | P8_46 |
|   2  | P9_30 | P9_30 | P8_43 | P8_43 |
|   3  | P9_28 | P9_28 | P8_44 | P8_44 |
|   4  | BA104 | BA104 | P8_41 | P8_41 |
|   5  | P9_27 | P9_27 | P8_42 | P8_42 |
|   6  | BA106 | BA106 | P8_39 | P8_39 |
|   7  | P9_25 | P9_25 | P8_40 | P8_40 |
|   8  | SD_02 | SD_02 | P8_27 | P8_27 |
|   9  | SD_01 | SD_01 | P8_29 | P8_29 |
|  10  | SD_08 | SD_08 | P8_28 | P8_28 |
|  11  | SD_07 | SD_07 | P8_30 | P8_30 |
|  12  | SD_05 | SD_05 | P8_21 | P8_21 |
|  13  | SD_03 | SD_03 | P8_20 | P8_20 |
|  14  | P8_12 | P8_16 |       | JT_04 |
|  15  | P8_11 | P8_15 | JT_05 |       |
|  16  |       | P9_24 |       | P9_26 |

\note The `BAxxx` entries are the ball numbers of the double pins on
      header connectors P9_41 and P9_42. The JT pins are unidirectional.


# Auto Starting an Application # {#SecAutoStart}

In order to auto start a program compiled against \Proj (ie. by a
systemd service), you've to care about some kind of race conditions.
Before the CTOR call PruIo::PruIo() your code needs the kernel driver
`uio_pruss` loaded in any case, and perhaps it also needs the LKM for
pinmuxing. You've to make sure that both drivers are properly loaded
before your code starts.

To find out the loading status you can check if some sysfs files exists

\Item{uio_pruss} check for `/dev/uio5`

\Item{LKM} check for `/sys/devices/platform/libpruio/state`

This can either get done by a loop halting your code until the files
are created. Or you can use a bash script to wait for the files being
up, like

    until test -e /dev/uio5; do sleep 1; done
    until test -e /sys/devices/platform/libpruio/state; do sleep 1; done

\note When your code starts before the `uio_pruss` driver is loaded,
      the CTOR call creates the file `/dev/uio5`, and that file is
      blocking proper loading of the driver. You can check this race
      condition ie. by using the output of command `ls -l /dev/uio*`.
      When the file is mistakenly created by the CTOR, the file `uio5`
      is different. Ie. since kernel 4.14 the owner is `root root`,
      while the proper files are owned by `root users`.
