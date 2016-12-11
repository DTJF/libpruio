/*! \file qep.c
\brief Example: PWM output and CAP input.

This file contains an example on how to use libpruio to analyse pulse
trains from a QEP sensor. The sensor signals can either come from a
real sensor. Or, to avoid the need of a real sensor, the signals can
get simulated by PWM output which is generated by this program. Find a
description on the setup and the output in section [Examples ->
qep](ChaExamples.html#SSecExaQep).

Licence: GPLv3

Copyright 2014-\Year by \Mail

Compile by: `gcc -Wall -o qep qep.c -lpruio -lprussdrv`

\since 0.4
*/

//! Message for the compiler.
#define _GNU_SOURCE 1
#include "stdio.h"
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include "../c_include/pruio.h"
#include "../c_include/pruio_pins.h"

//! Default PMax value.
#define PMX 4095
//! The frequency for speed measurement.
#define VHz 25
//! The header pins to use for input (PWMSS-1).
static const uint8 PINS[3] = {P8_12, P8_11, P8_16};

/*! \brief Wait for keystroke or timeout.
\param mseconds Timeout value in milliseconds.
\returns 0 if timeout, 1 if input available, -1 on error.

Wait for a keystroke or timeout and return which of the events happened.

\since 0.0
*/
int
isleep(unsigned int mseconds)
{
  fd_set set;
  struct timeval timeout;

  /* Initialize the file descriptor set. */
  FD_ZERO(&set);
  FD_SET(STDIN_FILENO, &set);

  /* Initialize the timeout data structure. */
  timeout.tv_sec = 0;
  timeout.tv_usec = mseconds * 1000;

  return TEMP_FAILURE_RETRY(select(FD_SETSIZE,
                                   &set, NULL, NULL,
                                   &timeout));
}

//! The main function.
int main(int argc, char **argv)
{
  pruIo *Io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0); //! create new driver structure
  do {
    if (Io->Errr) {
               printf("initialisation failed (%s)\n", Io->Errr); break;}

    // configure PWM-1 for symetric output duty 50% and phase shift 1 / 4
    Io->Pwm->ForceUpDown = 1 << 1;
    Io->Pwm->AqCtl[0][1][1] = 0x006; //&b000000000110
    Io->Pwm->AqCtl[1][1][1] = 0x600; //&b011000000000;

    float_t freq, realfreq;
    freq = 50.;
    if (pruio_pwm_setValue(Io, P9_14, freq, .00)) {
                printf("failed setting P9_14 (%s)\n", Io->Errr); break;}

    if (pruio_pwm_setValue(Io, P9_16, freq, .25)) {
                printf("failed setting P9_16 (%s)\n", Io->Errr); break;}

    if (pruio_pwm_setValue(Io, P9_42, .5, .00000005)) {
                printf("failed setting P9_42 (%s)\n", Io->Errr); break;}

    if (pruio_pwm_Value(Io, P9_14, &realfreq, NULL)) {
            printf("failed getting PWM value (%s)\n", Io->Errr); break;}

    uint32 pmax = PMX;
    if (pruio_qep_config(Io, PINS[0], pmax, VHz, 1., 0)) {
        printf("QEP pin configuration failed (%s)\n", Io->Errr); break;}

    if (pruio_config(Io, 1, 0, 0, 4)) {
                       printf("config failed (%s)\n", Io->Errr); break;}

//printf("\n input,  Hz , PMax= %s", Io->Errr); //freq, realfreq, pmax);
    static char *t[] = {"       A", "   A & B", "A, B & I"};
    uint32 posi, m = -1, p = 0;
    float_t velo;
    //printf("\n%s input, %10f Hz (%10f), PMax=%u", t[p], freq, realfreq, pmax);

    printf("\n  p=%u", p);
    printf("\n  m=%i", m);
    printf("\n  %s input", t[p]);
    printf("\n  %s input", t[0]);
    printf("\n  %s input", t[1]);
    printf("\n  %s input", t[2]);

    struct termios oldt, newt; //             make terminal non-blocking
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON);
    newt.c_cc[VMIN] = 0;
    newt.c_cc[VTIME] = 1;
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);

    //printf("\n%s input, %10f Hz (%10f), PMax=%u", t[p], 1., 1., 0); //freq, realfreq, pmax);
 //printf("\n input,  Hz , PMax= %s", Io->Errr); //freq, realfreq, pmax);


 //printf("\n input,  Hz , PMax= %s", Io->Errr); //freq, realfreq, pmax);
    while(1) { //                                       run endless loop
      fflush(STDIN_FILENO);
      if (1 == isleep(20)) {
        switch (getchar()) { //                       evaluate keystroke
          case 'a' : case 'A' : m = 0; break;
          case 'b' : case 'B' : m = 1; break;
          case 'i' : case 'I' : m = 2; break;
          case 'p' : case 'P' : m = 3; freq = (freq < 499995.) ? freq + 5. : 500000.; break;
          case 'm' : case 'M' : m = 3; freq = (freq >     20.) ? freq - 5. :     25.; break;
          case '*'            : m = 3; freq = (freq < 250000.) ? freq * 5. : 500000.; break;
          case '/'            : m = 3; freq = (freq >     50.) ? freq / 5. :     25.; break;
          case '0' : m = p; pmax =    0; break;
          case '1' : m = p; pmax = 1023; break;
          case '4' : m = p; pmax = 4095; break;
          case '5' : m = p; pmax =  511; break;
          case '8' : m = p; pmax = 8191; break;
          case '+' : m = 3; Io->Pwm->AqCtl[0][1][1] = 0x6; break;
          case '-' : m = 3; Io->Pwm->AqCtl[0][1][1] = 0x9; break;
          case  13 : m = 3; freq = 50.;
            if (pruio_pwm_setValue(Io, P9_14, freq, -1.)) {
                printf("failed setting PWM value (%s)\n", Io->Errr);
                goto finish;}
            if (pruio_pwm_Value(Io, P9_14, &realfreq, NULL)) {
                printf("failed getting PWM value (%s)\n", Io->Errr);
                goto finish;}
            break;
          default: goto finish;
        };
        switch (m) { //                                 evaluate command
          case 3:
            if (pruio_pwm_setValue(Io, P9_14, freq, -1.)) {
              printf("failed setting PWM value (%s)\n", Io->Errr);
              goto finish;}
            if (pruio_pwm_Value(Io, P9_14, &realfreq, NULL)) {
              printf("failed getting PWM value (%s)\n", Io->Errr);
              goto finish;}
            break;
          default:
            p = m;
            if (pruio_qep_config(Io, PINS[p], pmax, VHz, 1., 0)) { //reconfigure QEP pins
              printf("QEP pin reconfiguration failed (%s)\n", Io->Errr);
              goto finish;}
        };
        printf("\n%s input, %10f Hz (%10f), PMax=%u", t[p], freq, realfreq, pmax);
      }
      if (pruio_qep_Value(Io, PINS[p], &posi, &velo)) { // get new input
            printf("failed getting QEP Value (%s)\n", Io->Errr); break;}

      printf("\r  Position: %8X , Speed: %7.2f", posi, velo); // info
    }

finish:
    tcsetattr( STDIN_FILENO, TCSANOW, &oldt ); //         reset terminal

    printf("\n");
  } while (0);

  pruio_destroy(Io);       /* destroy driver structure */
	return 0;
}
