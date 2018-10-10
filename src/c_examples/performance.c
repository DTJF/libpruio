/*! \file performance.c
\brief Example: test execution speed of several methods to toggle a GPIO pin.

This file contains an example on measuring the execution speed of
different controllers that toggles a GPIO output. It measures the
frequency of the toggled output from open and closed loop controllers
and computes their mimimum, avarage and maximum execution speed. Find a
functional description in section \ref sSecExaPerformance.

The code performs 50 tests of each controller version and outputs the
toggling frequencies in Hz at the end. The controllers are classified
by

-# Open loop
  - Direct GPIO
  - Function Gpio->Value
-# Closed loop
  - Input direct GPIO, output direct GPIO
  - Input function Gpio->Value, output direct GPIO
  - Input function Gpio->Value, output function Gpio->setValue
  - Input Adc->Value, output direct GPIO
  - Input Adc->Value, output function Gpio->Value

Licence: GPLv3, Copyright 2014-\Year by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net

Compile by: `gcc -Wall -o performance performance.c -lpruio`

\since 0.4
*/

//! Message for the compiler.
#define _GNU_SOURCE 1
#include "stdio.h"
#include "time.h"
#include "libpruio/pruio.h"
#include "libpruio/pruio_pins.h"

//! The pin to use for CAP input.
#define C_IN P9_42
//! The pin to use for GPIO output.
#define GOUT P8_16
//! The pin to use for GPIO input.
#define G_IN P8_14

//! Macro to measure the frequency and compute statistics.
#define FREQ(_N_) \
  if(pruio_cap_Value(Io, C_IN, &f0, NULL)) { /*       get CAP input */ \
             printf("Cap->Value failed (%s)", Io->Errr); goto finish;} \
  sf[_N_] += f0; \
  if(f0 < nf[_N_]) {nf[_N_] = f0;} \
  if(f0 > xf[_N_]) {xf[_N_] = f0;} \
  printf("%f\t", f0);

//! Macro to set output pin by fast direct PRU command (no error checking).
#define DIRECT(_O_) \
  if(_O_){cd &= ~m0; sd |= m0;} else {sd &= ~m0; cd |= m0;} \
  while(Io->DRam[1]){} \
  Io->DRam[5] = oe; \
  Io->DRam[4] = sd; \
  Io->DRam[3] = cd; \
  Io->DRam[2] = ad; \
  Io->DRam[1] = PRUIO_COM_GPIO_CONF << 24;

//! Macro to set output by normal GPIO function (for better readability).
#define FUNC(_O_) \
  if(pruio_gpio_setValue(Io, GOUT, _O_)) { /* set GPIO output */ \
            printf("GPIO setValue failed (%s)", Io->Errr); goto finish;}

//! The main function.
int main(int argc, char **argv)
{
  pruIo *Io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0); //! create new driver structure
  do {
    if (Io->Errr) {
               printf("initialisation failed (%s)\n", Io->Errr); break;}

    if (pruio_gpio_setValue(Io, GOUT, 0)) { //configure GPIO output GOUT
           printf("GOUT configuration failed (%s)\n", Io->Errr); break;}

    if (pruio_gpio_config(Io, G_IN, PRUIO_GPIO_IN)) { //conf. GPIO input G_IN
           printf("G_IN configuration failed (%s)\n", Io->Errr); break;}

    if (pruio_cap_config(Io, C_IN, 1000)) { //  configure CAP input C_IN
           printf("C_IN configuration failed (%s)\n", Io->Errr); break;}

    if (pruio_adc_setStep(Io, 1, 0, 0, 0, 0)) { //configure fast Adc step
                  printf("ADC setStep failed (%s)\n", Io->Errr); break;}

    if (pruio_config(Io, 1, 1 << 1, 0, 4)) {
                       printf("config failed (%s)\n", Io->Errr); break;}

    const char *desc[] = {
      "Open loop, direct GPIO"
    , "Open loop, function Gpio->Value"
    , "Closed loop, direct GPIO to direct GPIO"
    , "Closed loop, function Gpio->Value to direct GPIO"
    , "Closed loop, function Gpio->Value to function Gpio->setValue"
    , "Closed loop, Adc->Value to direct GPIO"
    , "Closed loop, Adc->Value to function Gpio->Value"
    };

    uint32
      i       //!< The counter for test loops.
    , n       //!< The counter for test cycles.
    , c = 3   //!< The number of cycles for each test.
    , r1 = Io->BallGpio[G_IN] //!< Resulting input GPIO (index and bit number).
    , g1 = r1 >> 5            //!< Index of input GPIO.
    , m1 = 1 << (r1 & 31)     //!< The bit number of input bit.
    , r0 = Io->BallGpio[GOUT] //!< Resulting output GPIO (index and bit number).
    , g0 = r0 >> 5            //!< Index of output GPIO.
    , m0 = 1 << (r0 & 31)     //!< Mask for output bit.  , sd
    , cd = 0                  //!< Register value for CLEARDATAOUT.
    , sd = 0                  //!< Register value for SETDATAOUT.
    , ad = Io->Gpio->Conf[g0]->DeAd + 0x100 //!< Subsystem adress.
    , oe = Io->Gpio->Conf[g0]->OE; //!< Output enable register.
    float_t
      f0     //!< The current measurement result.
    , nf[7]  //!< The minimum frequencies.
    , xf[7]  //!< The maximum frequencies.
    , sf[7]; //!< The summe of measured frequencies (to compute avarage).

    for(n = 0; n < 7; n++) {
      nf[n] = 100e6;
      sf[n] = 0.;
      xf[n] = 0.;
    }

    struct timespec mSec;
    mSec.tv_sec=0;
    mSec.tv_nsec=1000000;

    for(n = 0; n < 50; n++) {
      nanosleep(&mSec, NULL);
      for(i = 0; i <= c; i++) {
        DIRECT(1)
        DIRECT(0)
      }
      FREQ(0)

      nanosleep(&mSec, NULL);
      for(i = 0; i <= c; i++) {
        FUNC(1)
        FUNC(0)
      }
      FREQ(1)

      nanosleep(&mSec, NULL);
      for(i = 0; i <= c; i++) {
        DIRECT(1)
        while( 0 == (m1 & Io->Gpio->Raw[g1]->Mix)) {}

        DIRECT(0)
        while(m1 == (m1 & Io->Gpio->Raw[g1]->Mix)) {}
      }
      FREQ(2)

      nanosleep(&mSec, NULL);
      for(i = 0; i <= c; i++) {
        DIRECT(1)
        while(pruio_gpio_Value(Io, G_IN) < 1) {}

        DIRECT(0)
        while(pruio_gpio_Value(Io, G_IN) > 0) {}
      }
      FREQ(3)

      nanosleep(&mSec, NULL);
      for(i = 0; i <= c; i++) {
        FUNC(1)
        while(pruio_gpio_Value(Io, G_IN) < 1) {}

        FUNC(0)
        while(pruio_gpio_Value(Io, G_IN) > 0) {}
      }
      FREQ(4)

      nanosleep(&mSec, NULL);
      for(i = 0; i <= c; i++) {
        DIRECT(1)
        while(Io->Adc->Value[1] <= 0x7FFF) {}

        DIRECT(0)
        while(Io->Adc->Value[1]  > 0x7FFF) {}
      }
      FREQ(5)

      nanosleep(&mSec, NULL);
      for(i = 0; i <= c; i++) {
        FUNC(1)
        while(Io->Adc->Value[1] <= 0x7FFF) {}

        FUNC(0)
        while(Io->Adc->Value[1]  > 0x7FFF) {}
      }
      FREQ(6)
      printf("\n");
    }
    printf("Results:\n");
    for(i = 0; i < 7; i++) {
      printf("%s:\n", desc[i]);
      printf("  Minimum: %f\n", nf[i]);
      printf("  Avarage: %f\n", (sf[i] / n));
      printf("  Maximum: %f\n", xf[i]);
    }
printf("%X %X %X %X %X\n", sd, cd, ad, m0, r0);
  } while(0);

finish:
  pruio_destroy(Io);       /* destroy driver structure */
	return 0;
}
