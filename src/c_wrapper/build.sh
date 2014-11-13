#! /bin/bash

fbc -w all -dylib -x libpruio.so pruio_c_wrapper.bas
#fbc -w all -lib -x libpruio.a pruio_c_wrapper.bas

# Anybody keen on handling this by cmake? Comments are welcome:
#   Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net
