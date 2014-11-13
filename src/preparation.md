Preparation {#ChaPreparation}
===========
\tableofcontents

This page describes how to get libpruio working on your system. At the
bottom you'll find a step by step guide to install the complete
system. Eager users may skip the theory and jump to \ref
SecInstallation directly.


Dependencies {#SecDependencies}
============

libpruio depends on the prussdrv library (from am335x_pru_package) to
control the PRU subsystems. A further package might be required,
depending on what you intend to do:

<TABLE>
<TR>
<TH>Executing Binaries</TH>
<TH>Compiling C code</TH>
<TH>Compiling FB code (and customizing libpruio)</TH>
</TR>
<TR>
<TD>[am335x_pru_package](https://github.com/beagleboard/am335x_pru_package)</TD>
<TD>[am335x_pru_package](https://github.com/beagleboard/am335x_pru_package)</TD>
<TD>[FB prussdrv Kit](http://www.freebasic-portal.de/downloads/fb-on-arm/fb-prussdrv-kit-bbb-324.html)</TD>
</TR>
<TR>
<TD></TD>
<TD>any C compiler</TD>
<TD>[BBB-FBC](http://www.freebasic-portal.de/downloads/fb-on-arm/bbb-fbc-fbc-fuer-beaglebone-black-283.html)</TD>
</TR>
</TABLE>

The original am335x_pru_package contains libprussdrv, some examples and
the PRU assembler (pasm). It's designed for C compilers. In contrast
the FB prussdrv Kit contains the FreeBASIC headers and a modified pasm
that can output FB header files.

The BBB-FBC package contains a minimal configuration of the executable
and some essential libraries. Find the complete compiler package
including the source code, lots of library bindings and examples in the
[GIT repo](https://github.com/freebasic/fbc).


Preconditions {#SecPreconditions}
=============

To execute software based on libpruio you have to ensure that

-# the kernel driver *uio_pruss* is loaded,
-# the PRU subsystems are enabled, and
-# the user has read / write privileges to the `/dev/uio5` system interrupt.

The first and second preconditions can be reached at once by loading an
appropriate device tree overlay. Either prepare, install and load a
customized overlay with fixed pin mode configurations (created by the
dts_custom.bas tool, see section \ref SecPinConfig for details). Or
install and load the universal overlay (file
src/config/libpruio-0A00.dtbo ust get copied to folder /lib/firmware)
shipped with the libpruio package by executing

~~~{.sh}
sudo echo libpruio > /sys/devices/bone_capemgr.*/slots
~~~

It's also possible to activate one of the prepared operating systems
device tree overlays, ie. by executing

~~~{.sh}
sudo echo BB-BONE-PRU-01 > /sys/devices/bone_capemgr.*/slots
~~~

All these device tree overlays start the PRUSS and also load the kernel
driver. The kernel driver allocates external memory for the PRUSS,
which is a default of 256 kB. (See section \ref SecERam on how to
customize this.)

When your operating systems comes with *capemgr* you can use it to load
the overlay at system startup by adapting the configuration file

~~~{.sh}
sudo nano /etc/defaults/capemgr
~~~

to make it look like

~~~{.txt}
# Default settings for capemgr. This file is sourced by /bin/sh from
# /etc/init.d/capemgr.sh

# Options to pass to capemgr
CAPE=libpruio
~~~

Item 3 of the initial list (privileges) can either be reached by
running the software as user `root`. But the prefered method should be
preparing privileges for the related users:

- create a new user group (ie `addgroup pruio`)
- and make yourself (and all related users) a member of this group

Then you can apply these group to the interrupt device and activate
read / write privileges for it (execute with admin privileges)

~~~{.sh}
chgrp pruio /dev/uio5
chmod g+rw /dev/uio5
~~~

It's best to auto-execute these commands at startup (ie. in the
/etc/rc.local script).

\note Enabling the PRU subsystem may be a safety risk. A virus running
      at the PRUSS can access each device register or memory area. The
      kernel running on the host cannot protect the system.



Pin Configuration {#SecPinConfig}
=================

Beaglebone hardware contains a TI AM3359 CPU, which includes lots of
subsystems with different connectors like analog or digital lines. The
number of subsystem connectors is greater than the number of connectors
at the CPU housing (= CPU balls), in order to keep the housing small.
That's why digital lines (ie. like GPIO or PWM) have to get configured
(pinmuxed) before they can be used (in a non-default configuration).

Pinmuxing means to connect a CPU ball to

- a digital subsystem connector,

- an internal pullup or pulldown resistor (or neither of them),

- a receiver module for input pins (optional).

\note Just a subset of the CPU balls is connected to the Beaglebone
      header pins.

When a digital line should get used, libpruio checks first if the
pinmuxing matches the required configuration. If this is not the case,
libpruio tries to re-configure the CPU ball. This may fail and the API
function returns an error message

- when the universal device tree overlay (libpruio-0A00.dtbo) isn't
  loaded, or

- when the code isn't executed with write privileges for folder
  /sys/devices/ocp.* (admin privileges).

To avoid such a failure

- either pre-configure the header pins by a customized device tree
  overlay, ie. generated by the tool dts_custom.bas.

- Or load the universal device tree overlay libpruio-0A00.dtbo (shipped
  with the libpruio package) and execute the program with admin
  privileges.

During development, the later might be advantageous (although it
requires admin privileges), since a feature can easily get switched
from one pin to another. In contrast, changing a customized overlay
mostly requires re-booting the system, since unlaoding and reloading a
device tree overlay doesn't work reliable (effective September, 2014).
When you finished testing and start to use a PCB with fixed wiring,
it's time to install your customized device tree overlay and further on
work with user privileges.

Internaly, libpruio uses the CPU ball number to identify a connector.
That's why you can access all connectors, even those which are not
connected to a header pin. The (optional) header pruio_pins.bi includes
convenience macros to refer to a ball number by its header pin position
(as seen from the user point of view).

The universal device tree overlay can also get used to pre-configure
the pins before executing the program. Therefor `echo` the desired
hexadecimal value to the state file in the approprite pin folder. Ie.
to configure pin P9_14 as PWM output execute (with admin privileges)

~~~{.sh}
echo x0E > /sys/devices/ocp.*/pruio-12.*/state
~~~

where `x0E` is the hexadecimal value for the Control Module pad
register and the number after `pruio-` is the hexadecimal number of the
CPU ball. Both hexadecimal values must have two digits. See
[ARM Reference Guide, chapter 9](http://www.ti.com/lit/pdf/spruh73)
for details on the pad registers.


Compiling C {#SubPreC}
===========

To compile your C source code against libpruio you need the
[am335x_pru_package](https://github.com/beagleboard/am335x_pru_package)
and from  the libpruio package the library binary and the header files

- src/c_wrapper/libpruio.so
- src/c_wrapper/pruio.h
- src/c_wrapper/pruio_pins.h
- src/c_wrapper/pruio.hp

It's recommended to install by

~~~{.sh}
sudo su
apt-get install am335x-pru-package
wget http://www.freebasic-portal.de/dlfiles/539/libpruio-0.2.tar.bz2
tar xjf libpruio-0.2.tar.bz2
cd libpruio-0.2
cp src/c_wrapper/libpruio.so /usr/local/lib
ldconfig
cp src/c_wrapper/pruio*.h* /usr/local/include
exit
~~~

See file src/c_wrapper/pruio.h for the documentation and find examples
in folder src/c_examples.


Compiling FB {#SecPreFB}
============

To compile your FreeBASIC source code against libpruio you need the
[FB prussdrv Kit](http://www.freebasic-portal.de/downloads/fb-on-arm/fb-prussdrv-kit-bbb-324.html)
and from  the libpruio package library binary and the header files.

- src/c_wrapper/libpruio.so
- src/pruio/pruio*.bi
- src/pruio/pruio.hp

In order to avoid naming conflicts in the headers folder
(/usr/local/include/freebasic) place the Beaglebone stuff in a
subfolder called BBB. It's recommended to install by

~~~{.sh}
sudo su
mkdir /usr/local/include/freebasic/BBB
wget http://www.freebasic-portal.de/dlfiles/539/FB_prussdrv-0.0.tar.bz2
tar xjf FB_prussdrv-0.0.tar.bz2
cd FB_prussdrv-0.0
cp include/* /usr/local/include/freebasic/BBB
cp bin/pasm /usr/local/bin
cd ..
wget http://www.freebasic-portal.de/dlfiles/539/libpruio-0.2.tar.bz2
tar xjf libpruio-0.2.tar.bz2
cd libpruio-0.2
cp src/c_wrapper/libpruio.so /usr/local/lib
ldconfig
cp src/c_wrapper/pruio*.h* /usr/local/include
cp src/config/libpruio-0A00.dtbo /lib/firmware
cp src/pruio/pruio*.bi /usr/local/include/freebasic/BBB
cp src/pruio/pruio.hp /usr/local/include/freebasic/BBB
exit
~~~

In that case you've to adapt the `INCLUDE ONCE "..."` lines in your
code

~~~{.sh}
#INCLUDE ONCE "pruio.bi"
~~~
becomes
~~~{.sh}
#INCLUDE ONCE "BBB/pruio.bi"
~~~

Find example code in folder src/examples.

To customize libpruio itself, you must observe this order

-# Compile PRU code (pasm_init.p and pasm_run.p).

-# Compile libpruio code (either pruio_c_wrapper.bas or pruio.bas).

Find the command line to invoke the compilers at the top of each file.


Installation {#SecInstallation}
============

Here's a step by step guide for a complete libpruio installation on a
vanilla Debian (Ubuntu) system, based on a Rafael Vega post (find the
[original text here](http://beagleboard.org/Community/Forums?place=msg%2Fbeagleboard%2F9NYdGWOT_Mg%2F6X0v2XVEeUAJ)
).

-# Install FreeBasic compiler in BBB
 -# Download and uncompress package from [BBB-FBC (fbc für Beaglebone Black)](http://www.freebasic-portal.de/downloads/fb-on-arm/bbb-fbc-fbc-fuer-beaglebone-black-283.html)
~~~{.sh}
wget http://www.freebasic-portal.de/dlfiles/452/BBB_fbc-1.00.tar.bz2
tar xjf BBB_fbc-1.00.tar.bz2
~~~
 -# Copy files
~~~{.sh}
cd BBB_fbc-1.00
cp usr/local/bin/fbc /usr/local/bin/
cp -R usr/local/lib/freebasic /usr/local/lib/
~~~
 -# Test compiler
~~~{.sh}
fbc -version
~~~
    should result in
~~~{.sh}
FreeBASIC Compiler - Version 1.01.0 (10-14-2014), built for linux-arm (32bit)
Copyright (C) 2004-2014 The FreeBASIC development team.
~~~

-# Install pruss driver kit.
 -# Install original am335x-pru-package
~~~{.sh}
apt-get install am335x-pru-package
~~~
 -# Download and uncompress FB package from [FB prussdrv Kit (BBB)](http://www.freebasic-portal.de/downloads/fb-on-arm/fb-prussdrv-kit-bbb-324.html)
~~~{.sh}
wget http://www.freebasic-portal.de/dlfiles/539/FB_prussdrv-0.0.tar.bz2
tar xjf FB_prussdrv-0.0.tar.bz2
~~~
 -# Copy files
~~~{.sh}
cd FB_prussdrv-0.0
mkdir /usr/local/include/freebasic/BBB
cp include/* /usr/local/include/freebasic/BBB
cp bin/pasm /usr/local/bin
~~~

-# Install libpruio
 -# Download and uncompress package from [libpruio (D/A - I/O schnell und einfach)](http://www.freebasic-portal.de/downloads/fb-on-arm/libpruio-325.html)
~~~{.sh}
wget http://www.freebasic-portal.de/dlfiles/539/libpruio-0.2.tar.bz2
tar xjf libpruio-0.2.tar.bz2
~~~
 -# Copy files
~~~{.sh}
cd libpruio-0.2
cp src/c_wrapper/libpruio.so /usr/local/lib
ldconfig
cp src/c_wrapper/pruio*.h* /usr/local/include
cp src/config/libpruio-0A00.dtbo /lib/firmware
cp src/pruio/pruio*.bi /usr/local/include/freebasic/BBB
cp src/pruio/pruio.hp /usr/local/include/freebasic/BBB
~~~
 -# Activate the PRUSS by enabling the tree overlay. This must be done everytime, after each boot or before running your programs.
~~~{.sh}
echo libpruio > /sys/devices/bone_capemgr.*/slots
~~~
 -# Test example
~~~{.sh}
sudo src/examples/1
~~~
    should result in the table output (13 lines, 8 columns) described
    in section \ref SubSecExaSimple.

-# Prepare system (optional) as described in section \ref
   SecPreconditions.

\note These commands need admin privileges:
      - `apt-get ...`
      - `ldconfig`
      - `mkdir ... /usr/...`
      - `cp ... /usr/...`
      - `cp ... /lib/...`
      - `echo ... /sys/...`
