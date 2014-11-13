#! /bin/bash
#pasm -V3 -y -CPru_Init pruio__init.p
#pasm -V3 -y -CPru_Run pruio__run.p
fbc -w all -dylib pruio.bas

# Anybody keen on handling this by cmake? Comments are welcome:
#   Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net
