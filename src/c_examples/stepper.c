/*! \file stepper.c
\brief Example: control a stepper motor.

This file contains an example on how to use libpruio to control a
4-wire stepper motor:

- configure 4 pins as output
- receive user action in loop
- inform user about the current state
- change motor direction
- change motor speed
- stop holded or in power off mode
- move a single step (in holded mode)
- quit

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `gcc -Wall -o stepper stepper.c -lpruio`

*/

//! Message for the compiler.
#define _GNU_SOURCE 1
#include "stdio.h"
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/time.h>
#include "../c_wrapper/pruio.h"
#include "../c_wrapper/pruio_pins.h"

//! The first pin of the stepper.
#define P1 P8_08
//! The second pin of the stepper.
#define P2 P8_10
//! The third pin of the stepper.
#define P3 P8_12
//! The fourth pin of the stepper.
#define P4 P8_14


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

//! Set values of all four output pins.
#define PIN_OUT(a, b, c, d) \
  if (pruio_gpio_setValue(Io, P1, a)) {printf("setValue P1 error (%s)\n", Io->Errr); break;} \
  if (pruio_gpio_setValue(Io, P2, b)) {printf("setValue P2 error (%s)\n", Io->Errr); break;} \
  if (pruio_gpio_setValue(Io, P3, c)) {printf("setValue P3 error (%s)\n", Io->Errr); break;} \
  if (pruio_gpio_setValue(Io, P4, d)) {printf("setValue P4 error (%s)\n", Io->Errr); break;}

/*! \brief Make the motor move the next step.
\param Io Pointer to PruIo structure.
\param Rot Rotation direction (1 or -1).

This function sets 4 output pins for a stepper motor driver. It
remembers the last step as static variable (starting at 0 = zero) and
adds the new position to it. So the Rot parameter should either be 1 or
-1 to make the motor move one step in any direction.

*/
void
move(pruIo *Io, int Rot) {
  static int p = 0;

  p += Rot;
  p &= Rot & 1 ? 7 : 6 ;

  switch (p){
    case 1:  PIN_OUT(1,0,0,0); break;
    case 2:  PIN_OUT(1,1,0,0); break;
    case 3:  PIN_OUT(0,1,0,0); break;
    case 4:  PIN_OUT(0,1,1,0); break;
    case 5:  PIN_OUT(0,0,1,0); break;
    case 6:  PIN_OUT(0,0,1,1); break;
    case 7:  PIN_OUT(0,0,0,1); break;
    default: PIN_OUT(1,0,0,1)
  }
}

//! The main function.
int main(int argc, char **argv)
{
  pruIo *Io = pruio_new(PRUIO_DEF_ACTIVE, 0x98, 0, 1); //! create new driver structure
  do {
    if (Io->Errr) {
               printf("initialisation failed (%s)\n", Io->Errr); break;}

    PIN_OUT(1,0,0,1) //                            initialize pin config

    //' pin config OK, transfer local settings to PRU and start PRU driver
    if (pruio_config(Io, 1, 0x1FE, 0, 4)) {
                       printf("config failed (%s)\n", Io->Errr); break;}

    //                                           print user informations
    printf("Controls: (other keys quit, 1 and 3 only when Direction = 0)\n");
    printf("                       8 = faster\n");
    printf("  4 = rotate CW        5 = stop, hold position   6 = rotate CCW\n");
    printf("  1 = single step CW   2 = slower                3 = single step CCW\n");
    printf("  0 = stop, power off\n\n");
    printf("Pins\t\tKey\t\tDirection\tSleep\n");

    struct termios oldt, newt; //             make terminal non-blocking
    tcgetattr( STDIN_FILENO, &oldt );
    newt = oldt;
    newt.c_lflag &= ~( ICANON );
    newt.c_cc[VMIN] = 0;
    newt.c_cc[VTIME] = 1;
    tcsetattr( STDIN_FILENO, TCSANOW, &newt );

    int w = 128, d = 0;
    printf("%1d-%1d-%1d-%1d\t\t%s\t\t%2d\t\t%3d",
           pruio_gpio_Value(Io, P1), pruio_gpio_Value(Io, P2), pruio_gpio_Value(Io, P3), pruio_gpio_Value(Io, P4),
           "", d, w); //                                user information
    fflush(STDIN_FILENO);
    while(1) { //                                       run endless loop
      if (1 == isleep(w)) {
        switch (getchar()) { //                       evaluate keystroke
          case '2': if (w < 512) w <<= 1; break;
          case '8': if (w >   1) w >>= 1; break;
          case '4': d =  1; break;
          case '7': d =  2; break;
          case '9': d = -2; break;
          case '6': d = -1; break;
          case '0': d =  0; PIN_OUT(0,0,0,0); break;
          case '5': d =  0; move(Io, d); break;
          case '1': if (d == 0) move(Io,  1); break;
          case '3': if (d == 0) move(Io, -1); break;
          default: goto finish;
        };
        printf("\t\t%2d\t\t%3d", d, w); //              user information
      }

      if (d) move(Io, d); //                              move the motor

      printf("\r%1d-%1d-%1d-%1d\t\t"
           , pruio_gpio_Value(Io, P1)
           , pruio_gpio_Value(Io, P2)
           , pruio_gpio_Value(Io, P3)
           , pruio_gpio_Value(Io, P4)); //              user information
      fflush(STDIN_FILENO);
    }

finish:
    tcsetattr( STDIN_FILENO, TCSANOW, &oldt ); //         reset terminal

    PIN_OUT(0,0,0,0) //                                  switch off pins

    printf("\n");
  } while (0);

  pruio_destroy(Io);       /* destroy driver structure */
	return 0;
}
