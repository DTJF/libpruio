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
    Io->Gpio->Conf(2)->CLEARDATAOUT  OR= mask
    Io->Gpio->Conf(2)->SETDATAOUT   AND= NOT mask

    WHILE Io.DRam[1] : WEND '   wait, if PRU is busy (should never happen)
    Io->DRam[4] = Io->Gpio->Conf(2)->SETDATAOUT
    Io->DRam[3] = Io->Gpio->Conf(2)->CLEARDATAOUT
    Io->DRam[2] = Io->Gpio->Conf(2)->DeAd + &h100
    Io->DRam[1] = PRUIO_COM_GPIO_OUT SHL 24

\note To get this working, the pins have to be in GPIO mode and the
      GPIO subsystems must be enabled. The most easy way to achieve
      this is to set the initial state by a call to function
      GpioUdt::setValue().


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
