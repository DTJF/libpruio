/** \file rb_file.c
\brief Example: fetch ADC samples in a ring buffer and save to file.

This file contains an example on how to use the ring buffer mode of
libpruio. A fixed step mask of AIN-0, AIN-1 and AIN-2 get configured
for maximum speed, sampled in to the ring buffer and from there saved
as raw data to some files. Find a functional description in section
\ref sSecExaRbFile.

Licence: GPLv3, Copyright 2014-\Year by \Mail

Thanks for C code translation: Nils Kohrs <nils.kohrs@gmail.com>

Compile by: `gcc -Wall -o rb_file rb_file.c -lpruio`

\since 0.4.0
*/

#include "unistd.h"
#include "time.h"
#include "stdio.h"
#include "libpruio/pruio.h"

//! The main function.
int main(int argc, char **argv)
{
  const uint32 tSamp = 123401;  //!< The number of samples in the files (per step).
  const uint32 tmr = 20000;     //!< The sampling rate in ns (20000 -> 50 kHz).
  const uint32 NoStep = 3;      //!< The number of active steps (must match setStep calls and mask).
  const uint32 NoFile = 2;      //!< The number of files to write.
  const char *NamFil = "output.%u"; //!< The output file names.
  struct timespec mSec;
  mSec.tv_nsec = 1000000;
  pruIo *io = pruio_new(PRUIO_DEF_ACTIVE, 0, 0, 0); //! create new driver
  if (io->Errr){
               printf("constructor failed (%s)\n", io->Errr); return 1;}

  do {
    if (pruio_adc_setStep(io, 9, 0, 0, 0, 0)){ //          step 9, AIN-0
        printf("step 9 configuration failed: (%s)\n", io->Errr); break;}
    if (pruio_adc_setStep(io,10, 1, 0, 0, 0)){ //         step 10, AIN-1
       printf("step 10 configuration failed: (%s)\n", io->Errr); break;}
    if (pruio_adc_setStep(io,11, 2, 0, 0, 0)){ //         step 11, AIN-2
       printf("step 11 configuration failed: (%s)\n", io->Errr); break;}

    uint32 mask = 7 << 9;         //!< The active steps (9 to 11).
    uint32 tInd = tSamp * NoStep; //!< The maximum total index.
    uint32 half = ((io->ESize >> 2) / NoStep) * NoStep; //!< The maximum index of the half ring buffer.

    if (half > tInd){ half = tInd;}  //       adapt size for small files
    uint32 samp = (half << 1) / NoStep; //!< The number of samples (per step).

    if (pruio_config(io, samp, mask, tmr, 0)){ //       configure driver
                       printf("config failed (%s)\n", io->Errr); break;}

    if (pruio_rb_start(io)){
                     printf("rb_start failed (%s)\n", io->Errr); break;}

    uint16 *p0 = io->Adc->Value;  //!< A pointer to the start of the ring buffer.
    uint16 *p1 = p0 + half;       //!< A pointer to the middle of the ring buffer.
    uint32 n;  //!< File counter.
    char fName[20];
    for(n = 0; n < NoFile; n++){
      sprintf(fName, NamFil, n);
      printf("Creating file %s\n", fName);
      FILE *oFile = fopen(fName, "wb");
      uint32 i = 0;               //!< Start index.
      while(i < tInd){
        i += half;
        if(i > tInd){         // fetch the rest(maybe no complete chunk)
          uint32 rest = tInd + half - i;
          uint32 iEnd = p1 >= p0 ? rest : rest + half;
          while(io->DRam[0] < iEnd) nanosleep(&mSec, NULL);
          printf("  writing samples %u-%u\n", tInd -rest, tInd-1);
          fwrite(p0, sizeof(uint16), rest, oFile);
          uint16 *swap = p0;
          p0 = p1;
          p1 = swap;
          break;
        }
        if(p1 > p0) while(io->DRam[0] < half) nanosleep(&mSec, NULL);
        else        while(io->DRam[0] > half) nanosleep(&mSec, NULL);
        printf("  writing samples %u-%u\n", i-half, i-1);
        fwrite(p0, sizeof(uint16), half, oFile);
        uint16 *swap = p0;
        p0 = p1;
        p1 = swap;
      }
      fclose(oFile);
      printf("Finished file %s\n", fName);
    }
  } while(0);
  pruio_destroy(io);
  return 0;
}
