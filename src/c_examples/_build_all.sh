#! /bin/bash
gcc -Wall -o 1 1.c -lpruio
gcc -Wall -o button button.c -lpruio
gcc -Wall -o io_input io_input.c -lpruio
gcc -Wall -o pwm_cap pwm_cap.c -lpruio
gcc -Wall -o sos sos.c -lpruio
gcc -Wall -o stepper stepper.c -lpruio
