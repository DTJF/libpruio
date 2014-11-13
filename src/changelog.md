Changelog & Credits {#ChaChangelog}
===================
\tableofcontents


Further Development {#SecFurtherVev}
===================

- Add QEP features of PWMSS.
- Add TIMER subsystem support.
- More digital triggers for MM mode (ie. CAP and QEP).

Feel free to send further ideas to the author (\Email).


libpruio-0.2 {#SecV-0-2}
============

Released in 2014, October.

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

Bugfixes:
---------

- Pinmuxing now available.
- GPIO output fixed (former gpio_set sometimes skipped a setting).


libpruio-0.0.2 {#SecV-0-0-2}
==============

Released on 2014, June 6.

- New: example *button*
- Bugfix: gpio_get returns correct values now
- Cosmetic: Minor adaptions in the source code


libpruio-0.0 {#SecV-0-0}
============

Released on 2014, May 9.



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
  to improve it.

- All others I forgot to mention.
