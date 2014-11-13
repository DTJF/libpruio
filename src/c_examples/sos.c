/*! \file sos.c
\brief Example: blink user LED 3.

This file contains an example on how to use libpruio to control the
user LED 3 (near ethernet connector) on the beaglebone board. It shows
how to unlock a CPU ball that is used by the system. And it shows how
to control the unlocked ball.

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by: `gcc -Wall -o sos sos.c -lpruio`

*/

//! Message for the compiler.
#define _GNU_SOURCE 1
#include "stdio.h"
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/time.h>
#include "../c_wrapper/pruio.h"  /* include header */


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

  /* select returns 0 if timeout, 1 if input available, -1 if error. */
  return TEMP_FAILURE_RETRY(select(FD_SETSIZE,
                                   &set, NULL, NULL,
                                   &timeout));
}

//! The CPU ball to control (user LED 3).
#define PIN 24
//! Output a short blink.
#define OUT_K pruio_gpio_setValue(io, PIN, 128 + pinmode) ; isleep(150) ; pruio_gpio_setValue(io, PIN, pinmode) ; isleep(100) ;
//! Output a long blink.
#define OUT_L pruio_gpio_setValue(io, PIN, 128 + pinmode) ; isleep(350) ; pruio_gpio_setValue(io, PIN, pinmode) ; isleep(100) ;
//! Output a 'S' (short - short - short).
#define OUT_S OUT_K ; OUT_K ; OUT_K ; isleep(150)
//! Output an 'O' (long - long - long).
#define OUT_O OUT_L ; OUT_L ; OUT_L ; isleep(150)

//! The main function.
int main(int argc, char **argv)
{
  pruIo *io = pruio_new(PRUIO_DEF_ACTIVE, 0x98, 0, 1); //!< Create a PruIo structure, wakeup subsystems.
  do { //                                      pseudo loop to avoid goto
    if (io->Errr) {
               printf("initialisation failed (%s)\n", io->Errr); break;}

    uint8 pinmode = io->BallConf[PIN]; //!< The current pin mode.

    if (pruio_config(io, 1, 0x1FE, 0, 4)) {
                       printf("config failed (%s)\n", io->Errr); break;}

    printf("watch SOS code on user LED 3 (near ethernet connector)\n\n");
    printf("execute the following command to get rid of mmc1 triggers\n");
    printf("  sudo su && echo none > /sys/class/leds/beaglebone:green:usr3/trigger && exit\n\n");
    printf("press any key to quit");

    struct termios oldt, newt;          /* make terminal non-blocking */
    tcgetattr( STDIN_FILENO, &oldt );
    newt = oldt;
    newt.c_lflag &= ~( ICANON | ECHO );
    newt.c_cc[VMIN] = 0;
    newt.c_cc[VTIME] = 1;
    tcsetattr( STDIN_FILENO, TCSANOW, &newt );

    while(0 >= getchar()) {               /* run loop until keystroke */
      OUT_S;
      OUT_O;
      OUT_S;
      isleep(1500);
    }

    tcsetattr( STDIN_FILENO, TCSANOW, &oldt );      /* reset terminal */

    pruio_gpio_setValue(io, PIN, pinmode);    /* reset LED (cosmetic) */
  } while (0);
  printf("\n");

  pruio_destroy(io);       /* destroy driver structure */
	return 0;
}
