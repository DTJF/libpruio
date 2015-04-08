Changelog & Credits {#ChaChangelog}
===================
\tableofcontents


Further Development {#SecFurtherVev}
===================

- Add QEP features of PWMSS. ???
- Add TIMER subsystem support.
- More digital triggers for MM mode (ie. CAP and QEP).

Feel free to send further ideas to the author (\Email).


libpruio-0.2.2 {#SecV-0-2-2}
==============

Released in 2015, ???.

New:
----

- Documentation page Pins added.
- Build management added (by CMake).
- GIT version control system implemented.
- QEP module support (function QepMod::config() and QepMod::Value() ).
- New example qep: analyse Quadrature encoder signals (and simulates such signals).
- New eample performance: measure speed of different open and closed loop controllers toggling a GPIO.
- New example rb_file: use ring buffer mode to fetch ADC samples and save raw data to file(s).
- PWM configuration variables to directly influence A and B output of PWM modules.
- More links between the FB and the C documentation.

Changes:
--------

- Function Gpio->setValue calls Gpio->config() now, in case of improper pin mode.
- New numbers for PRU commands, checking tree structure now (faster).
- Pruio_c_wrapper now in folder src/pruio.
- Folder c_wrapper renamed to c_include.
- Tools dts_custom.bas and dts_universal.bas evaluate path command line argument.
- Tool dts_custom.bas generates fragment@1 section (no export command required).
- Device tree overlay: QEP input pins have no restistor now.

Bugfixes:
---------

- RB and MM modes are working now, even when libpruio is configured to use PRU-0.
- C-Wrapper missing enumerators pinMuxing added.
- C-Wrapper function pruio_gpio_config() implemented now.
- pruio.h: minor improvements in structure pruIo.
- Clock value for ADC subsystem corrected (higher sampling rates for multi step setup).
- Device tree overlay file name fixed (now libpruio-00A0.dtbo).
- Gpio::config() works with PRUIO_PIN_RESET now.
- PwmMod::pwm_set() no more interferences between channels A and B.
- Example pwm_adc: frequency interferences fixed for A + B channel.


libpruio-0.2 {#SecV-0-2}
============

Released in 2014 October, 26.

New:
----

- Ring buffer (RB) run mode (samples analog input continously).
- PWM output in IO and RB mode (variable frequency and duty cycles).
- CAP input in IO and RB mode (analyses frequency and duty cycles of a pulse train).
- New examples *pwm_adc*, *pwm_cap*, *rb_oszi*.
- Subsystem control (enable or disable single subsystems at run-time).
- Device tree overlay included (universal pinmuxing at run-time).
- Tools included to create, compile and install universal or customized device tree overlays.
- Advanced error messages from constructor.

Changes:
--------

- Completely renewed source code (modular now, for easier expansions).
- Completely renewed documentation (interferences between C and FB source solved).
- API adapted to modular structure (see file migration.txt.
- Version 0.0 examples adapted (*1*, *analyse*, *button*, *io_input*, *sos*, *stepper*, *oszi*, *triggers*).
- Adaptions for new FreeBASIC compiler fbc-1.00.
- Access to all subsystem registers supported.
- Optimized error checking in PwmMod and CapMod functions.

Bugfixes:
---------

- Pinmuxing now available.
- GPIO output fixed (former gpio_set sometimes skipped a setting).


libpruio-0.0.2 {#SecV-0-0-2}
==============

Released on 2014 June, 6.

- New: example *button*
- Bugfix: gpio_get returns correct values now
- Cosmetic: Minor adaptions in the source code


libpruio-0.0 {#SecV-0-0}
============

Released on 2014 May, 9.



Credits {#SecCredits}
=======

Thanks go to:

- Texas Instruments for creating that great ARM Sitara processors with
  PRU subsystems and related software.

- The Beagleboard developer team for building a board and operating
  system around that CPU.

- The FreeBASIC developer team for creating a great compiler and the
  support to adapt it for ARM platforms.

- Dimitri van Heesch for creating the Doxygen tool, which is used to
  generate this documentations.

- AT&T and Bell-Labs for developing the graphviz package, which is used
  to generate the graphs in this documentation.

- Charles Steinkuehler for the universal device tree overlay and the
  config-pin tool.

- The libpruio users for testing, reporting bugs and sending ideas
  to improve it. Especially

  - [Rafael Vega](http://www.freebasic.net/forum/viewtopic.php?p=198419#p198419)
  - Emir Elkholy
  - [Nils Kohrs](http://beagleboard.org/Community/Forums?place=msg%2Fbeagleboard%2FCN5qKSmPIbc%2FdHiyHP-PxcMJ)
  - [jleb](http://beagleboard.org/Community/Forums?place=msg%2Fbeagleboard%2F3AFiCNtxGis%2Fejo1qZ67ihkJ)
  - [jem](http://www.freebasic.net/forum/viewtopic.php?p=206081#p206081)
  - [Benoît](http://www.freebasic.net/forum/viewtopic.php?p=206131#p206131)

- All others I forgot to mention.
