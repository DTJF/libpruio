Changelog & Credits {#ChaChangelog}
===================
\tableofcontents


# Further Development # {#SecFurtherVev}

- More digital triggers for MM mode (ie. CAP and QEP).

Feel free to send further ideas to the author (\Email).


# libpruio-0.6.4c # {#SecV-0-6-4c}

- fix: finetuning CAP input (freq&duty)
- fix: finetuning PWM output (freq&duty)
- fix: pinmux in setPin_lkm_bb for double pins
- fix: docs for TIMER and PWM
- fix: Timer scaling fixed [s] -> [ms]
- fix: PwmUdt::Sync LKM value 0x08 -> 0xFF
- fix: LKM case syntax (commas)
- cha: Timer PRU code starting by trigger
- cha: LKM tblck value 0x80 -> 0xFF
- cha: in GpioUdt renamed setGpio -> setGpioSs to be more clear

Released in 2019, April.

# libpruio-0.6.4b # {#SecV-0-6-4b}

- fix: DTOR does proper re-muxing again
- fix: race condition in fast setValue sequences

Released in 2019, March.

# libpruio-0.6.4a # {#SecV-0-6-4a}

- fix: BallInit/BallConf handling with LKM
- fix: ball# for double pins

# libpruio-0.6.4 # {#SecV-0-6-4}

Released in 2018, Oktober.

## New:

- Python pruss_xxx examples
- Added documentation chapter Tips and Tricks
- Pocket and Beaglebone Blue hardware supported

## Changes:

- Double pin check moved from LKM to function setPin()
- GPIO subsytem registers get written before pinmuxing
- GPIO registers now manipulated by new function setGpio()
- Removed pin arrays from files pruio_pins.[h|bi], and
- Macros AINx replaced by enumerators AdcStepMask (new values)
- Define PRUIO_COM_GPIO_OUT removed (use PRUIO_COM_GPIO_CONF instead)
- Documentation adapted for [Pocket]Beagle[Blue] (please report erata)

## Bugfixes:

- Doc chapter Messages completed
- Python apt command fixed in chapter Preparation
- Macros for AIN pins removed (avoid false pinmuxing)

Since this version the folder for C headers (`src/c_include/`) isn't
scanned by Doxygen any more. Documentation is now generated from
FreeBASIC source code only, since the double declaration of symbols for
C and FreeBASIC made reading difficult and confused Doxygen generating
graphs.


# libpruio-0.6.2 # {#SecV-0-6-2}

Released in 2018, Oktober.

## New:

- Overview table for examples requirements
- Examples pruss_add and pruss_toggle (C and FreeBASIC)
- Symbol export for prussdrv functions (use driver for second PRU)

## Changes:

- Correct ARM_PRUx_INTERRUPT usage (by new member PruIo::PruIntNo)

## Bugfixes:

- Optimized compile flags
- Paths in _2_preparation.md fixed
- Optimized CAP duty cycle computation
- Congruent types in new prussdrv files
- File src/python/libpruio/pruio.py removed from GIT
- Correct handling for symbolic link (folder BBB in src/examples)


# libpruio-0.6.0 # {#SecV-0-6-0}

Released in 2018, September.

## New:

- debian packaging
- python bindings and examples
- example button2 demonstrates pinmuxing
- in build prussdrv driver, less dependencies
- constructor mode PRUIO_ACT_FREMUX for free pinmuxing
- function PwmUdt::sync() for synchonization of PWMSS.Pwm outputs
- pinmuxing with loadable kernel module, no more overlays, easy install
- pins on SD slot added

## Changes:

- easy installation due to debian packages
- PruIo::setPin() function implemented as callback for use in C and Python
- no restrictions in case of LKM pinmuxing, smaller memory footprint, faster boot
- pinmuxing either by dtbo overlay (compatible) or by loadable kernel module (powerful)

## Bugfixes:

- examples source code reviewed
- source code documentation reviewed
- build system hierarchy and messages optimized
- kernel 4.x problem with PWMSS.Pwm outputs fixed by LKM


# libpruio-0.4.0 # {#SecV-0-4-0}

Released in 2017, Nov.

## New:

- Documentation page Pins added.
- Folder src/python and target py.
- Build management added (by CMake).
- GIT version control system implemented.
- QEP module support (function QepMod::config() and QepMod::Value() ).
- New example qep: analyse Quadrature encoder signals (and simulates such signals).
- New example performance: measure speed of different open and closed loop controllers toggling a GPIO.
- New example rb_file: use ring buffer mode to fetch ADC samples and save raw data to file(s).
- PWM configuration variables to directly influence A and B output of PWM modules.
- More links between the FB and the C documentation.
- PWM output on JTag 5 (PWMSS-1.eCAP)
- setPin works with kernels 3.8 and 4.1 now (new sysfs folder structure)

## Changes:

- Function Pin returns the current configuration by default and needs parameter Mo = 0 to show initial state.
- Function Gpio->setValue calls Gpio->config() now, in case of improper pin mode.
- New numbers for PRU commands, checking tree structure now (faster).
- Pruio_c_wrapper now in folder src/pruio.
- Folder c_wrapper renamed to c_include.
- Tools dts_custom.bas and dts_universal.bas evaluate path command line argument.
- Tool dts_custom.bas generates fragment@1 section (no export command required).
- Device tree overlay: QEP input pins have no restistor now.
- single source for all ball numbers

## Bugfixes:

- RB and MM modes are working now, even when \Proj is configured to use PRU-0.
- C-Wrapper missing enumerators pinMuxing added.
- C-Wrapper function pruio_gpio_config() implemented now.
- pruio.h: minor improvements in structure pruIo.
- Clock value for ADC subsystem corrected (higher sampling rates for multi step setup).
- Device tree overlay file name fixed (now libpruio-00A0.dtbo).
- Gpio::config() works with PRUIO_PIN_RESET now.
- PwmMod::pwm_set() no more interferences between channels A and B.
- Example pwm_adc: frequency interferences fixed for A + B channel.


# libpruio-0.2 # {#SecV-0-2}

Released in 2014 October, 26.

## New:

- Ring buffer (RB) run mode (samples analog input continuously).
- PWM output in IO and RB mode (variable frequency and duty cycles).
- CAP input in IO and RB mode (analyses frequency and duty cycles of a pulse train).
- New examples *pwm_adc*, *pwm_cap*, *rb_oszi*.
- Subsystem control (enable or disable single subsystems at run-time).
- Device tree overlay included (universal pinmuxing at run-time).
- Tools included to create, compile and install universal or customized device tree overlays.
- Advanced error messages from constructor.

## Changes:

- Completely renewed source code (modular now, for easier expansions).
- Completely renewed documentation (interferences between C and FB source solved).
- API adapted to modular structure (see file migration.txt.
- Version 0.0 examples adapted (*1*, *analyse*, *button*, *io_input*, *sos*, *stepper*, *oszi*, *triggers*).
- Adaptions for new FreeBASIC compiler fbc-1.00.
- Access to all subsystem registers supported.
- Optimized error checking in PwmMod and CapMod functions.

## Bugfixes:

- Pinmuxing now available.
- GPIO output fixed (former gpio_set sometimes skipped a setting).


# libpruio-0.0.2 # {#SecV-0-0-2}

Released on 2014 June, 6.

- New: example *button*
- Bugfix: gpio_get returns correct values now
- Cosmetic: Minor adaptions in the source code


# libpruio-0.0 # {#SecV-0-0}

Released on 2014 May, 9.


# References # {#SecReferences}

Meanwhile \Proj is used in many projects all over the world. Here're some of them

- [Using low cost single-board microcontrollers to record underwater acoustical data](http://www.acoustics.asn.au/conference_proceedings/INTERNOISE2014/papers/p236.pdf)
- [Browser controlled tank (video)](https://www.youtube.com/watch?v=3cXCUmCWQHQ)
- [Library upgrade to PRU gives Fast IO on Beaglebone](http://hackaday.com/2015/02/16/library-upgrade-to-pru-gives-fast-io-on-beaglebone/#comments)
- [Pd BeagleBone Black IO](http://java-hackers.com/p/rvega/pd-bbb-gpio)
- [How to create a very-low-cost, very-low-power, credit-card-sized and real-time-ready datalogger](http://www.adv-geosci.net/40/37/2015/adgeo-40-37-2015.pdf)
- [BeagleBone Black Communication Interface (CI-BBB), TAMPERE UNIVERSITY OF TECHNOLOGY](http://www.google.at/url?q=https://dspace.cc.tut.fi/dpub/bitstream/handle/123456789/22387/Perez.pdf%3Fsequence%3D1&sa=U&ved=0ahUKEwjatLSs5OjYAhXRalAKHWuOCP04HhAWCBgwAA&usg=AOvVaw0c_k8rGEq-Az0dEEthvlE3)
- [Desenvolvimento de uma plataforma de simulação Hardware in the Loop de baixo custo, Universidade de Brasília - UnB](http://www.google.at/url?q=http://bdm.unb.br/bitstream/10483/14953/1/2016_AlceuBernardesCastanheiraDeFarias_tcc.pdf&sa=U&ved=0ahUKEwjatLSs5OjYAhXRalAKHWuOCP04HhAWCCMwAw&usg=AOvVaw0OxGUHU47XQ5PEgfdIu4-g)
- [Prototipo de electrocardiógrafo portátil, Universidad de Sevilla](http://bibing.us.es/proyectos/abreproy/12343/fichero/Prototipo+de+electrocardi%C3%B3grafo+port%C3%A1til+-+copia.pdf)
- [bela (ultra-low latency real-time audio processing)](https://github.com/BelaPlatform/Bela/wiki)
- []()


# Credits # {#SecCredits}

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

- Arend Lammertink for providing Debian packages and hosting them on
  his server.

- The \Proj users for testing, reporting bugs and sending ideas
  to improve it. Especially

  - [Rafael Vega](http://www.freebasic.net/forum/viewtopic.php?p=198419#p198419)
  - Emir Elkholy
  - [Nils Kohrs](http://beagleboard.org/Community/Forums?place=msg%2Fbeagleboard%2FCN5qKSmPIbc%2FdHiyHP-PxcMJ)
  - [jleb](http://beagleboard.org/Community/Forums?place=msg%2Fbeagleboard%2F3AFiCNtxGis%2Fejo1qZ67ihkJ)
  - [jem](http://www.freebasic.net/forum/viewtopic.php?p=206081#p206081)
  - [Benoît](http://www.freebasic.net/forum/viewtopic.php?p=206131#p206131)

- All others I forgot to mention.
