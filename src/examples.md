Examples  {#ChaExamples}
========
\tableofcontents

The best way to learn a new library API is to test out some examples. A
working example shows that the installation of the library components
is OK. And by adapting the example source code you can easily find out
if your understanding of the documentation matches reality.

So libpruio includes a bunch of examples, all of them less than 200
lines of code and some of them in FreeBASIC and in C syntax. Since C
doesn't support native grafics output, C examples are only available
with console text output. For all examples there're pre-compiled
executables in folder src/examples.

Some examples need wiring to work and show the desired effect. Therefor
a minimal knowlege on electronics is required to avoid damaging your
Beaglebone board when doing the wiring. The circuits are designed for
minimal hardware requirements, so you need not spend a lot of money for
testing.


Text {#SecExaText}
====

The examples in this section produce console text output. The source
code is available in FreeBASIC (folder src/examples) and C syntax
(folder src/c_examples). The output between both versions may vary a
bit, in order to keep the examples informative, but the C example code
simple.

Simple (1) {#SubSecExaSimple}
----------

\Item{Description}

  This is a minimal example printing a table of some analog samples
  from the ADC subsystem. It illustrates the principle usage of
  libpruio described in section \ref SecOperation by a minimal number
  of code lines.

\Item{Preparation}

  No preparation is required. Optionaly you can connect the analog
  ground at P9_34 (AGND) and some of the analog input lines AIN-0 to
  AIN-6 to a voltage source in the range of 0 V to 1V8 (ie. from a
  battery).

\Item{Operation}

  Start the program in the terminal by typing `./1` and press the
  Return key. The output is a table containing 13 lines of all analog
  inputs. It looks like
~~~{.txt}
D530 E0C0 DE20 CEE0 0080 0780 1850 EE20
E990 E150 DD80 D010 0000 07A0 1770 EE00
E980 E230 DE70 CEE0 0070 07B0 17A0 EE30
E9C0 E110 DD50 CF00 0090 08C0 18D0 EE40
E8D0 E0B0 DD10 CE60 0010 0880 1800 EE40
E9B0 E210 DDC0 CEC0 0090 0790 1850 EE00
E970 E220 DE40 D020 00D0 0840 17D0 EE70
E9D0 E1C0 DD90 CE90 00B0 06F0 1830 EE70
E920 E120 DC90 CD80 0040 0750 1850 EDF0
E8E0 E0D0 DD60 CEC0 00B0 0810 1780 EEB0
E8D0 E130 DD00 CE90 0000 0730 17D0 EE70
EA20 E210 DDD0 CED0 00E0 0820 1850 EEA0
E960 E0D0 DDE0 CF10 0010 0740 17B0 EE40
~~~
  The last column (AIN-7) is the on board voltage divided by 2 (`&hEE50
  / &hFFF0 * 1,8 = 1.67 V`). The fifth column is channel AIN-4, which
  is connected to ground (P9_34 = AGND) during the test. The other
  channels are open ended.


\Item{Source Code}

  src/examples/1.bas

  src/c_examples/1.c


analyse {#SubSecExaAnalyse}
-------

\Item{Description}

  This example shows how to read the subsystem configurations. It
  creates a PruIo structure and prints out all startup registers
  context (Init).

\Item{Preparation}

  No preparation is required.

\Item{Operation}

  Start the program in the terminal by typing `./analyse` and press the
  Return key. The output is a long list of text lines, like
~~~{.txt}
Header Pins:
  P8_03, mode 1: input enabled, pullup
  P8_04, mode 1: input enabled, pullup
  P8_05, mode 1: input enabled, pullup
  P8_06, mode 1: input enabled, pullup
  P8_07, GPIO 2/02: input, pullup
  P8_08, GPIO 2/03: input, pullup

...

GPIO-0 (DeAd: 44E07000, ClAd: 44E00408, ClVa: 00000002)
         REVISION: 50600801
        SYSCONFIG: 0000001D
              EOI: 00000000

...

ADC (DeAd: 44E0D000, ClAd: 44E004BC, ClVa: 00000002)
         REVISION: 47300001
        SYSCONFIG: 00000000
    IRQSTATUS_RAW: 00000407

...

PWMSS-0 (DeAd: 48300000, ClAd: 44E000D4, ClVa: 00000002)
            IDVER: 47400001
        SYSCONFIG: 00000008
        CLKCONFIG: 00000111
        CLKSTATUS: 00000111
  eCAP
            TSCTR: 00000000
           CTRPHS: 00000000
~~~
  First, all header pin configurations are shown. Then the registers of
  the GPIO subsystems (0 to 3) get listed, followed by the ADC
  subsystem registers and the registers of the PWMSS subsystems (0 to
  2). It's the context of the xyzSet strctures (BallSet, GpioSet,
  AdcSet and PwmssSet). The code may be helpful for debugging in your
  projects.

\Item{Source Code}

  src/examples/analyse.bas

  No C source available


button {#SubSecExaButton}
------

\Item{Description}

  This example shows how to get input from a digital line. It creates a
  new PruIo instance cinfigured in IO mode and continuously prints out
  the state of a single digital lines.

\Item{Preparation}

  The code uses header pin P8_07 which is configured as GPIO input with
  pullup resistor by default. We use this standard configuration (no
  pinmuxing required) and ground the pin by a button to see some
  changes. Here's the wiring diagram

  ![Wiring diagram for button example](button_circuit.png)

\Item{Operation}

  Start the program by executing `./button` and you'll see a new line
  containing a continuously updated single number. `1` gets shown when
  the button is open and `0` (zero) when the button is closed. Press
  any key om your keyboard to end the program.

\Item{Source Code}

  src/examples/button.bas

  src/c_examples/button.c


io_input {#SubSecExaIoInput}
--------

\Item{Description}

  This example shows how to get input from digital and analog
  subsystems. It creates a new PruIo instance configured in IO mode and
  prints out continuously the state of all the GPIO and ADC lines. GPIO
  data gets read from the raw data (all bits from a subsystem by a
  single operation).

\Item{Preparation}

  No preparation is required. Optionaly you can connect the analog
  ground P9_34 (AGND) and some of the analog input lines AIN-0 to AIN-6
  to a source voltage in the range of 0 to 1V8 (ie. from a battery).

\Item{Operation}

  Start the program by executing `./io_input` and you'll see
  continuously updated output like (FB version)
~~~{.txt}
   .   |   .   |   .   |   .   |
11000000000000001100000000001100
00111110100000010000001100000000
00000000000000000000000000111101
00000000000001000000000000000000
EEA0 E7D0 E630 DA00  0C80 1510 24A0 EE60
~~~
  The first line is a scale to support identifying the bit positions.
  The next four lines show the state of the GPIO subsystems 0 to 3 (1 =
  high, 0 = low). The last line is the sampled ADC data form AIN 0 to 7
  as hexadecimal values in 16 bit encoding.

  You can watch the heartbeat (user LED 0) in the third line (GPIO-1,
  bit 21). The last analog value (AIN-7) is the measured voltage on the
  board (it should be the half of 3.3 V: `&hEE60 / &hFFF0 * 1.8 V =
  1.676 V)`.

  To end the program press any key.

  The C version outputs all in one line (make sure to use a wide
  console window) like
~~~{.txt}0
C000C004 3E810300       3D        0  E6B0 D730 C9B0 B470   F0  9A0 1EB0 EDD0
~~~
  The first four columns are hexadecimal values of the GPIO subsystem
  states and the following columns are the ADC lines as in the FB
  version.

\Item{Source Code}

  src/examples/io_input.bas

  src/c_examples/io_input.c


pwm_cap {#SubSecExaPwmCap}
-------

\Item{Description}

  This examples demonstrates how to perform pulse width modulated (PWM)
  output and how to measure such a pulse train (CAP = Capture and
  Analyse a Pulsetrain) with libpruio. The code creates a PruIo
  instance configured in IO mode. One header pin (P9_21) gets
  configured as PWM output and an other (P9_42) as CAP input. The
  measured pulse train data get shown in a continously updated line.
  You can adapt the output and watch the changes in the input.

\Item{Preparation}

  Pinmuxing is required for this example, since to used pins are in
  GPIO mode by default. So make sure that you accordingly prepared your
  system, see chapter \ref SecPinConfig for details.

  Here's the wiring diagram

  ![Wiring diagram for pwm_cap example](pwm_cap_circuit.png)

\Item{Operation}

  Start the program by `sudo ./pwm_cap` and you'll see a single
  continously updated new line
~~~{.txt}
    Frequency: 31250    , Duty: 0.5003125
~~~
  which shows the measured frequency and duty cycle on the input pin,
  comming from the output pin. You can adapt the output by the
  following keystrokes.

  To change the duty cycle, use
  | Key | Duty  |
  | :-: | ----: |
  |  0  |   0 % |
  |  1  |  10 % |
  |  2  |  20 % |
  |  3  |  30 % |
  |  4  |  40 % |
  |  5  |  50 % |
  |  6  |  60 % |
  |  7  |  70 % |
  |  8  |  80 % |
  |  9  |  90 % |
  |  ,  | 100 % |
  To change the frequency (in the range of 0.5 Hz to 5.0 Hz), use
  | Key | Function                           |
  | :-: | :--------------------------------- |
  |  +  | set maximum frequency 1 000 000 Hz |
  |  -  | set manimum frequency 0.5 Hz       |
  |  *  | multiply frequency by 2 (double)   |
  |  /  | divide frequency by 2 (half)       |
  |  m  | decrease frequency by 5 (minus)    |
  |  p  | increase frequency by 5 (plus)     |
  Any other key quits the program.

  Each keystroke results in two new lines, one for the demands and the
  second is continously updated with the measured stuff. Ie. when the
  duty cycle gets changed to `30 %`, you'll see
~~~{.txt}
--> Frequency: 31250    , Duty: 0.3
    Frequency: 31250    , Duty: 0.300625
~~~
  There may be some difference between the demand and the measured
  values due to hardware limitations, which should be small in the
  middle of the possible frequency range and grows when you come to the
  upper or lower edge. When you switch to 100 % (always high) or 0 %
  (always low), there's no pulse train anymore and the frequency gets
  shown as 0 (zero). The minimal frequency is set to 2 Hz, so after 0.5
  seconds the measured values jump to 0 Hz / 0 %. Any output frequency
  below 2 Hz also results in measured 0 Hz / 0 %. And in case of 2 Hz
  output the measured value jumps between
~~~{.txt}
--> Frequency: 2        , Duty: 0.5
    Frequency: 1.999974 , Duty: 0.5
~~~
  and
~~~{.txt}
--> Frequency: 2        , Duty: 0.5
    Frequency: 0        , Duty: 0
~~~

\Item{Source Code}

  src/examples/pwm_cap.bas

  src/c_examples/pwm_cap.c


sos {#SubSecExaSos}
---

\Item{Description}

  This example shows how to control a GPIO output that is not connected
  to header pin. It creates a PruIo structure configured in IO mode and
  controls the user LED-3, which is placed near the ethernet connector.

\Item{Preparation}

  No preparation required.

\Item{Operation}

  Start the program by `./sos` and you'll see user LED-3 blinking in
  SOS code (short, short, short - long, long, long - short, short,
  short). The output looks like:
~~~{.txt}
watch SOS code on user LED 3 (near ethernet connector)

execute this command to get rid of mmc1 triggers
  sudo su && echo none > /sys/class/leds/beaglebone:green:usr3/trigger && exit

press any key to quit
~~~
  The blinking code may get disturbed by the system (kernel), which is
  also blinking the LED on mmc1 interrupts. Execute the mentioned
  command to get rid of this interferences. (Replace 'none' by 'mmc1'
  to restore the original configuration.)

  Press any key to quit the program.

\Item{Source Code}

  src/examples/sos.bas

  src/c_examples/sos.c


stepper {#SubSecExaStepper}
-------

\Item{Description}

  This example shows how to control a unipolar stepper motor by
  libpruio. It creates a PruIo structure configured in IO mode and
  prepares four GPIO lines as output. You can change motor direction
  and speed, stop the motor and switch of all pins.

\Item{Preparation}

  This example can run without any hardware preparation, but you can
  watch only some text output changing in the console window. It's
  better to prepare a simple stepper motor setting to see a shaft
  turning. The hardware (motor and driver board) is available as a set
  in good electronics stores (ie. search for ULN2003 stepper set).

  First, the header pins (P8_08, P8_10, P8_12 and P8_14) need to get
  configured as GPIO output pins, so you'll have to prepare your system
  for pinmuxing capability, see section \ref SecPinConfig for details.
  Then connect the GPIO output pins to the controler inputs, a common
  ground and a power supply (5 V) as in the following wiring diagram

  ![Wiring diagram for stepper example](stepper_circuit.png)

  Here's a photo of such a setting

  ![Setting for stepper example](stepper_foto.jpg)

\Item{Operation}

  Start the program by `sudo ./stepper` and you'll see some information
  on how to control the motor
~~~{.txt}

Controls: (other keys quit, 1 and 3 only when Direction = 0)
                       8 = faster
  4 = rotate CW        5 = stop, hold position   6 = rotate CCW
  1 = single step CW   2 = slower                3 = single step CCW
  0 = stop, power off

Pins          Direction     Sleep
1-0-0-1         0           128
~~~
  The last line gets updated continously and shows the current state of
  the pins, the direction of the motor and the number of miliseconds
  the program waits before the next update of the output pins. The
  latest is equal to the speed of the motor, a high value (long sleep)
  represents a low speed. The speed range is form 1000 steps per second
  to two steps per second (sleep range 1 to 512). Direction can be
  either 1 for clockwise, -1 for counter clockwise or 0 for no
  rotation. The pins switch for half step movements, so you may see
  either one single or two pins at high state at a time.

  The C version shows (couldn't get ride of that green block under Key)
~~~{.txt}
Pins            Key        Direction        Sleep
1-0-0-1                     0               128
~~~

\Item{Source Code}

  src/examples/stepper.bas

  src/c_examples/stepper.c


Grafic {#SecExaGrafic}
======

The examples in this section produce grafic output. The source code is
available only in FreeBASIC (folder src/examples) syntax, since C has
no native grafic.

pwm_adc {#SubSecExaPwmAdc}
-------

\Item{Description}

  This example shows how to output a pulse width modulated (PWM) signal
  on some header pins and how to receive that signals as ADC input in
  IO mode. The code opens a grafic window and creates a new PruIo
  instance in IO mode for drawing continuously the sampled analog data
  from channels AIN-0 to AIN-2 (step 1 to 3) as line grafic with
  colored lines. By default it creates a full screen window without a
  frame. You can customize the window by setting the size as command
  line option (ie like `./pwm_io 640x100` for width = 640 and hight =
  100).

  You can manipulate the frequency and duty cycles of the signals and
  choose between drawing all inputs or just the manipulated one.

\Item{Preparation}

  It needs some wiring to execute this example. The digital signals
  from the PWM pins (P9_14, P9_16 and P9_42) have to be connected to
  the analog inputs. Since digital output is 3V3 and analog inputs are
  maximum 1V8, we need to transform the signalsby voltage dividers. We
  use potentiometers (RV0, RV1 and RV2) for that purpose. The divider
  outputs get connected to the analog input pins (AIN-0 = P9_39, AIN-1
  = P9_40 and AIN-2 = P9_37). The potentionmeters should be liniear and
  at least 1 k (47 k recommended). Make sure that the wipers are placed
  in a middle position before you connect the cables.

  ![Wiring diagram for pwm_adc example](pwm_adc_circuit.png)

  Here's a photo of such a setting. The colors of the cables (red =
  P9_14 / P9_39, green = P9_16 / P9_40 and blue = P9_42 / P9_37)
  correspond to the colors of the lines in the wiring diagram and the
  lines in the graphical window output of the example. Make sure to use
  high quality potentiometers and a reliable GND connection to avoid
  damaging the ADC subsystem by overvoltage.

  ![Setting for pwm_adc example](pwm_adc_foto.jpg)

  The digital lines (P9_14, P9_16 and P9_42) need pinmuxing to operate
  in PWM mode. So you have to prepare your system for pinmuxing (see
  Section \ref SecPinConfig) and execute the binary with administrator
  privileges.

\Item{Operation}

  Execute the binary with a customized window size by
~~~{.txt}
sudo ./pwm_adc 640x150
~~~
  and you'll see grafic window with three rectangle lines like

  ![3 PWM outputs at 2.5 Hz (red = P9_14@50%, green = P9_16@20% and blue = P9_42@80%)](pwm_adc_screen.png)

  which is continously up-dating the signals. (Adjust the
  potentiometers to see three lines at different hights.)

  The frequenz and the duty cycle of each signal can get customized.
  The active channel (the one to edit) is shown in the window title
  (P9_42 at startup). To switch to another channel, use
  | Key | Channel              |
  | :-: | :------------------- |
  |  A  | P9_14 = PWMSS1-PWM-A |
  |  B  | P9_16 = PWMSS1-PWM-B |
  |  C  | P9_42 = PWMSS0-CAP   |
  To change the duty cycle, use
  | Key | Duty  |
  | :-: | ----: |
  |  0  |   0 % |
  |  1  |  10 % |
  |  2  |  20 % |
  |  3  |  30 % |
  |  4  |  40 % |
  |  5  |  50 % |
  |  6  |  60 % |
  |  7  |  70 % |
  |  8  |  80 % |
  |  9  |  90 % |
  |  ,  | 100 % |
  To change the frequency (in the range of 0.5 Hz to 5.0 Hz), use
  | Key | Function                     |
  | :-: | :--------------------------- |
  |  +  | increase frequency by 0.5 Hz |
  |  -  | decrease frequency by 0.5 Hz |
  |  *  | set frequency to 5.0 Hz      |
  |  /  | set frequency to 0.5 Hz      |
  Each of the above mentioned keys reduce the grafic to the active
  channel. To see all lines again, press
  | Key    | Function                 |
  | :----: | :----------------------- |
  | Return | Make all channels active |
  Any other key quits the program.

  You can study the differences between the available PWM subsystems.

  The blue line comes from an independend subsystem (PWMSS0-eCAP).
  Both parameters (frequency and duty) can get customzed without
  affecting the other channels. Any change becomes effective after the
  current period is finished.

  In contrast, the other channels (red = P9_14 and green = P9_16) are
  both connected to the same subsystem (PWMSS1-eHRPWM). Both signals
  may have individual duties, but they always operate at the same
  frequency. A change of the duty becomes effective after the current
  period is finished. But a change of the frequency interrupts the
  current period and starts immediately a new period with the new
  settings on both channels.

\Item{Source Code}

  src/examples/pwm_adc.bas


oszi {#SubSecExaOszi}
----

\Item{Description}

  This example shows how to sample ADC data. It creates a PruIo
  structure configured in IO mode and draws a continously updated graph
  of the analog lines AIN-0 to AIN-7. The graph gets updated column by
  column by the currently sampled values. You can switch channels on or
  off to watch just a subset. By default it creates a full screen
  window without a frame. You can customize the window by setting the
  size as command line option (ie like `./oszi 640x400` for width = 640
  and hight = 400).

\Item{Preparation}

  No preparation is required. Optionaly you can connect the analog
  ground (AGND) and some of the analog input lines AIN-0 to AIN-6 to a
  voltage source in the range of 0 to 1V8 (ie. from a battery).

\Item{Operation}

  Start the program by executing `./oszi 640x280` and you'll see a
  window like

  ![Screenshot of the oszi window (eight analog lines)](oszi_screen.png)

  The grafic is scaled 0 V at the bottom and 1.8 V at the top. You can
  toggle the channels on or off by pressing keys 0 to 7 (0 = AIN-0, ...
  7 = AIN-7). The program prevents de-activating all channels (at least
  one channel stays active). Key '+' restores the default setting (all
  channels active). Any other key quits the program.

  The less channels are activated, the faster the ADC subsystem samples
  the data. Ie. check it by connecting a constant frequency sine wave
  (0 to maximal 1.8 V) to any channel and switch off the others one by
  one.

\Item{Source Code}

  src/examples/oszi.bas


rb_oszi {#SubSecExaRbOszi}
-------

\Item{Description}

  This example shows how to sample ADC data in RB mode. It creates and
  configures a PruIo structure and draws a continously updated graph of
  the analog lines AIN-4 and AIN-7. The graph gets updated in one step
  when one half of the ring buffer is filled. By default it creates a
  full screen window without a frame. You can customize the window by
  setting the size as command line option (ie like `./rb_oszi 640x400`
  for width = 640 and hight = 400).

\Item{Preparation}

  No preparation is required. Optionaly you can connect the analog
  ground P_34 (AGND) and the analog input line AIN-4 to a voltage
  source in the range of 0 to 1V8 (ie. from a battery).

\Item{Operation}

  Start the program by executing `./rb_oszi 640x280` and you'll see a
  window like

  ![Screenshot of the rb_oszi window (two analog lines)](rb_oszi_screen.png)

  The grafic is scaled 0 V at the bottom and 1.8 V at the top. Any
  keypress quits the program.

\Item{Source Code}

  src/examples/rb_oszi.bas


triggers {#SubSecExaTriggers}
--------

\Item{Description}

  This example shows how to use triggers to start a measurement in MM
  mode and how to customize an ADC step (for the analog trigger 2). It
  opens a grafic window and creates a new PruIo instance for MM. By
  default it creates a full screen window without a frame. You can
  customize the window by setting the size as command line option (ie
  like `./triggers 640x400` for width = 640 and hight = 400).

  The example offers to choose one from of four different trigger types
  - no trigger, or
  - a digital trigger, or
  - an analog trigger at AIN-4 line, or
  - an analog pre-trigger at any of the active lines.

\Item{Preparation}

  No pinmuxing is required, since the code uses P8_07 in its default
  configuration as digital input line (GPIO input with pullup
  resistor). To make a digital trigger event happen, you'll need at
  least a cable to ground that pin.

  For analog triggers it is sufficient to handle the input signal
  (AIN-4) by a simple cable connected to header pin P9_33. The other
  end will get connected to either P9_32 (VADC) or P9_34 (AGND),
  depending on the choosen trigger event.

  Instead of using simple cables, it's best to prepare a button for the
  digital trigger event and a variable resistor (5 k to 50 k) for the
  analog triggers as shown in the following figure

  ![Wiring diagram for digital (button) and analog (variable resistor) triggers](triggers_circruit.png)

  Here's a photo of such a setting

  ![Setting for triggers example](triggers_foto.jpg)

\Item{Operation}

  First, execute the binary with a customized window size by
~~~{.txt}
./triggers 640x280
~~~
  and you'll see the following menu in an empty grafic window.
~~~{.txt}
Choose trigger type
  0 = no trigger (start immediately)
  1 = GPIO trigger (pin P8_07)
  2 = analog trigger (AIN-4 > 0.9 V)
  3 = analog pre-trigger (any AIN < 0.9 V)
~~~
  The grafic is scaled 0 V at the bottom and 1.8 V at the top. The
  sampling rate is 1 kHz. You can start a measurement of two channels
  (AIN-4 and AIN-7) immediately or by a trigger.

  After choosing a trigger type (1 to 3), the program waits for the
  trigger event. Further keystrokes (other than 0 to 3) quit the
  program.

  The next steps depend on the trigger to test:

  <b>0 = no trigger (start immediately)</b>

    -# Press key 0. After a short while (less than 1 second) a black
       and a red line show up in the window. Black = AIN-4 (open
       connector) shows any signal and red = AIN-7 (board voltage =
       1.65 V) is always near the top of the window.

    -# The menu showns up again for the next test.

  <b>1 = GPIO trigger (pin P8_07)</b>

    -# Press key 1 to start the trigger. The window gets cleared and
       you'll see a new message
~~~{.txt}
waiting for GPIO trigger (pin P8_07 low) ...
~~~
       Nothing else happens, the system is waiting for the trigger
       event.

    -# Press the button or use a cable to connect P8_02 (GRND) and
       P8_07 (trigger pin). After a short while (less than 1 second) a
       black and a red line show up in the window. Black = AIN-4
       (potentiometer or open connector) shows any signal and red =
       AIN-7 (board voltage = 1.65 V) is always at the top of the
       window.

    -# You'll see a window like following (some input on AIN-4 here)

       ![Analog input on AIN-4 (black = any signal) and AIN-7 (red = 1.65 V on board)](triggers_pin.png)

    -# The menu showns up again for the next test.

  <b>2 = analog trigger (AIN-4 > 0.9 V)</b>

    -# Adjust the variable resistor to the P9_34 side or connect a
       cable between P9_34 (AGND) and P9_33 (AIN-4).

    -# Press key 2 to start the trigger. The window gets cleared, a
       grey circle marks the trigger position (in the middle of the
       left border) and you'll see a new message
~~~{.txt}
waiting for analog trigger (AIN-4 > 0.9 V) ...
~~~
       Nothing else happens, the system is waiting for the trigger
       event.

    -# Adjust the variable resistor to the P9_32 side. After you
       reached the middle position, you'll see a window like the
       following (here AIN-4 signal is generated manually by the
       potentiometer)

       ![Analog input on AIN-4 (black = trigger signal) and AIN-7 (red = 1.65 V on board)](triggers_ain.png)

       Black = AIN-4 starts on the left side in the middle of the
       window hight (the trigger event) and shows any signal. Red =
       AIN-7 (board voltage = 1.65 V) is always at the top of the
       window. The menu showns up again for the next test.

       In case of no potentiometer, release the cable. The channel
       AIN-7 will pull up the open trigger channel AIN-4 to a voltage
       above the trigger voltage. (If this doesn't happen, connect the
       cable between P9_32 (VADC) and P9_33 (AIN-4).)

    -# The menu showns up again for the next test.

  <b>3 = analog pre-trigger (any AIN < 0.9 V)</b>

    -# Adjust the variable resistor to the P9_32 side or connect a cable
       between P9_32 (VADC) and P9_33 (AIN-4).

    -# Press key 3 to start the trigger. The window gets cleared, a
       grey circle marks the trigger position (in the middle of the
       window) and you'll see a new message
~~~{.txt}
waiting for analog pre-trigger (any AIN < 0.9 V) ...
~~~
       Nothing else happens, the system is waiting for the trigger
       event.

    -# Adjust the variable resistor to the other side. After you
       reached the middle position, you'll see a window like the
       following (here AIN-4 signal is generated manually by the
       potentiometer)

       ![Valid pre-trigger input on AIN-4 (black = trigger signal) and AIN-7 (red = 1.65 V on board)](triggers_pre_full.png)

       Black = AIN-4 starts on the left side in the upper part of the
       window and passes through the middle (the trigger event). Red =
       AIN-7 (board voltage = 1.65 V) is always at the top of the
       window.

       When any analog line is below 0.9 V at the start of the trigger,
       you'll see a window like

       ![Invalid pre-trigger samples (black = trigger signal AIN-4 below 0.9 V)](triggers_pre_empty.png)

       Here no pre-trigger samples are available (since the measurement
       starts immediately) and these samples get set to 0 (zero).

       In case of no potentionmeter, release the cable. The open
       trigger channel AIN-4 starts to swing below the trigger voltage.
       (If this doesn't happen, connect the cable between P9_34 (AGND)
       and P9_33 (AIN-4).)

    -# The menu showns up again for the next test.


\Item{Source Code}

  src/examples/triggers.bas
