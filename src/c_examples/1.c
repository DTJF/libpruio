/*! \file 1.c
\brief Example: minimal code for ADC input.

This file contains an short and simple example for text output of the
analog input lines. It's designed for the description pages and shows
the basic usage of libpruio with a minimum of source code, translatable
between FreeBASIC and C. Find a functional description in section \ref
sSecExaSimple.

Licence: GPLv3, Copyright 2014-\Year by \Mail

Compile by: `gcc -Wall -o 1 1.c -lpruio`

\since 0.0
*/


#include "stdio.h"
#include "libpruio/pruio.h" // include header

//! The main function.
int main(int argc, char **argv)
{
  int i, n;
  pruIo *io = pruio_new(PRUIO_DEF_ACTIVE, 4, 0x98, 0); //! create new driver structure
  if (pruio_config(io, 1, 0x1FE, 0, 4)){ // upload (default) settings, start IO mode
                              printf("config failed (%s)\n", io->Errr);}
  else {

/* now current ADC samples are available for AIN-0 to AIN-7 in array io->Adc->Value[] */
    for(n = 1; n <= 13; n++) { //                       print some lines
      for(i = 1; i < 9; i++) //                                all steps
        printf(" %4X", io->Adc->Value[i]); //  output one channel in hex
      printf("\n"); //                                         next line
    }
  }
/* we're done */

  pruio_destroy(io);        /* destroy driver structure */
	return 0;
}
