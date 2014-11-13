#include "unistd.h"
#include "stdio.h"
#include "../c_wrapper/pruio.h"


//! The main function.
int main(int argc, char **argv)
{
  uint32 tSamp = 0x100000; // total no. of samples per channel
  uint32   tmr = 5000;     // '5000' ns -> 200 kHz
  uint16 cycles = 2;       // number of output files

  pruIo *io = pruio_new(PRUIO_DEF_ACTIVE, 0, 0, 0); //! create new driver structure
  if (pruio_adc_setStep(io, 9, 4, 0, 0, 0)){; // step 9 for AIN-4
    printf("step 9 config failed (%s)\n", io->Errr);}
  else if (pruio_adc_setStep(io, 10, 7, 0, 0, 0)){; // step 10 for AIN-7
    printf("step 10 config failed (%s)\n", io->Errr);}
  else if (pruio_config(io, io->ESize >> 1, 1 << 9 | 1 << 10, tmr, 0)){ // step 9 + 10 active
    printf("config failed (%s)\n", io->Errr);}
  else{
    uint32 n;
    FILE* oFile;
    char fName[12];
    uint32 half = io->ESize >> 2; // half size of the ring buffer
    uint32 tSize = tSamp * io->Adc->ChAz; // total size (no. of samples in file)
    pruio_rb_start(io);
    for(n=0; n<cycles; n++){
      uint16 *block = io->Adc->Value;
      uint32 i = half;
      sprintf(fName, "output.%u", n);
      oFile = fopen(fName, "wb");
      printf("Creating file %s\n", fName);
      while(i < tSize){

        while(io->DRam[0] < half){sleep(1);}
        printf("  writing samples %u-%u\n", i - half, i - 1);
        fwrite(block, sizeof(uint16), half, oFile);
        block += half;
        i += half;

        if (i >= tSize) break;
        while(io->DRam[0] > half){sleep(1);}
        printf("  writing samples %u-%u\n", i - half, i - 1);
        fwrite(block, sizeof(uint16), half, oFile);
        block -= half;
        i += half;
      }
      if (i != tSize) {
        uint32 rest = tSize + half - i;
        while(io->DRam[0] < rest){sleep(1);}
        printf("  writing samples %u-%u\n", tSize - rest, tSize - 1);
        fwrite(block, sizeof(uint16), rest, oFile);
      }
      fclose(oFile);
      printf("Closing file %s\n", fName);
    }
  }
  pruio_destroy(io);
  return 0;
}
