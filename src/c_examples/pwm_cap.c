/*! \file pwm_cap.c
\brief Example: PWM output and CAP input.

This file contains an example on how to measure the frequency and duty
cycle of a pulse train with a eCAP module input. The program sets
another pin as eHRPWM output to generate a pulse width modulated signal
as source for the measurement. The output can be changed by some keys,
the frequency and duty cycle of the input is shown continously in the
terminal output.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `gcc -Wall -o pwm_cap pwm_cap.c -lpruio`

*/

//! Message for the compiler.
#define _GNU_SOURCE 1
#include "stdio.h"
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include "../c_wrapper/pruio.h"
#include "../c_wrapper/pruio_pins.h"

//! The pin for PWM output.
#define P_OUT P9_21
//! The pin for CAP input.
#define P_IN P9_42

/*! \brief Wait for keystroke or timeout.
\param mseconds Timeout value in milliseconds.
\returns 0 if timeout, 1 if input available, -1 on error.

Wait for a keystroke or timeout and return which of the events happened.

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
  pruIo *Io = pruio_new(PRUIO_DEF_ACTIVE, 0x98, 0, 1); //! create new driver structure
  do {
    if (Io->Errr) {
               printf("initialisation failed (%s)\n", Io->Errr); break;}

    if (pruio_cap_config(Io, P_IN, 2.)) { //         configure input pin
          printf("failed setting input @P_IN (%s)\n", Io->Errr); break;}

    float_t
        f1 //                         Variable for calculated frequency.
      , d1 //                        Variable for calculated duty cycle.
      , f0 = 31250 //                            The required frequency.
      , d0 = .5;   //                           The required duty cycle.
    if (pruio_pwm_setValue(Io, P_OUT, f0, d0)) {
        printf("failed setting output @P_OUT (%s)\n", Io->Errr); break;}

    //           pin config OK, transfer local settings to PRU and start
    if (pruio_config(Io, 1, 0x1FE, 0, 4)) {
                       printf("config failed (%s)\n", Io->Errr); break;}

    struct termios oldt, newt; //             make terminal non-blocking
    tcgetattr( STDIN_FILENO, &oldt );
    newt = oldt;
    newt.c_lflag &= ~( ICANON );
    newt.c_cc[VMIN] = 0;
    newt.c_cc[VTIME] = 1;
    tcsetattr( STDIN_FILENO, TCSANOW, &newt );

    while(1) { //                                       run endless loop
      if (1 == isleep(1)) {
        switch (getchar()) { //                       evaluate keystroke
          case '0' : d0 = 0.0; break;
          case '1' : d0 = 0.1; break;
          case '2' : d0 = 0.2; break;
          case '3' : d0 = 0.3; break;
          case '4' : d0 = 0.4; break;
          case '5' : d0 = 0.5; break;
          case '6' : d0 = 0.6; break;
          case '7' : d0 = 0.7; break;
          case '8' : d0 = 0.8; break;
          case '9' : d0 = 0.9; break;
          case ',' : d0 = 1.0; break;
          case 'm' : f0 = (f0 > 5.5 ? f0 - 5. : .5); break;
          case 'p' : f0 = (f0 < 999995. ? f0 + 5. : 1000000.); break;
          case '*' : f0 = (f0 < 1000000 ? f0 * 2 : 1000000.); break;
          case '/' : f0 = (f0 > .5 ? f0 / 2 : .5); break;
          case '+' : f0 = 1000000; break;
          case '-' : f0 = .5; break;
          default: goto finish;
        };
        if (pruio_pwm_setValue(Io, P_OUT, f0, d0)) { //   set new output
           printf("failed setting PWM output (%s)\n", Io->Errr); break;}

        printf("\n--> Frequency: %10f , Duty: %10f\n", f0, d0); //  info
      }

      if (pruio_cap_Value(Io, P_IN, &f1, &d1)) { //    get current input
          printf("failed reading input @P_IN (%s)\n", Io->Errr); break;}

      printf("\r    Frequency: %10f , Duty: %10f     ", f1, d1); // info
      fflush(STDIN_FILENO);
    }

finish:
    tcsetattr( STDIN_FILENO, TCSANOW, &oldt ); //         reset terminal

    printf("\n");
  } while (0);

  pruio_destroy(Io);       /* destroy driver structure */
	return 0;
}
