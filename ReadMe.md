Welcome to *libpruio* library,

- a driver for ARM33xx micro processors,
- designed for [Beaglebone hardware](http://www.beaglebone.org), supporting
- analog input and
- digital input and output features.

It's designed for easy configuration and data handling at high speed.
*libpruio* software runs on the host (ARM) and in parallel on a
Programmable Realtime Unit SubSystem (= PRUSS or just PRU) and controls
the CPU subsystems

- Control Module: CPU Ball configurations (pinmuxing)
- GPIO: General Purpose Input / Output
- PWMSS: Pulse-Width Modulation Subsystem
- TSC_ADC_SS: Touch Screen Controler and Analog-to-Digital Convertor SubSystem (or just ADC)
- TIMER: Timers 4 to 7

The driver supports three run modi

- IO mode: digital and analog lines, sloppy timing controlled by the host,
- RB mode: digital and analog lines, accurate ADC timing controlled by the PRU,
- MM mode: analog lines and optional triggers, accurate ADC timing controlled by the PRU.

The *libpruio* project is [hosted at GitHub](https://github.com/DTJF/libpruio). It's
developed and tested on a Beaglebone Black under Ubuntu 13.10 and
Debian Image 2014-08-05. It should run on all Beaglebone platforms with
Debian based LINUX operating system. It's compiled by the [FreeBasic
compiler](http://www.freebasic.net). Wrappers and examples code for C
programming language and Python are included.

Find more information in the online documentation at

- http://users.freebasic-portal.de/tjf/Projekte/libpruio/doc/html/index.html

or at related forum pages:

- [BeagleBoard: libpruio (fast and easy D/A - I/O)](https://groups.google.com/forum/#!category-topic/beagleboard/CN5qKSmPIbc)
- [FreeBASIC: libpruio (BB D/A - I/O fast and easy)](http://www.freebasic.net/forum/viewtopic.php?f=14&t=22501)

\note The PRUSS are powerful precessors that can access any memory at
      the host system. There's no kernel protection, the PRU can even
      access kernel space memory. Malware running on a PRU can damage
      your complete system. So be careful which software you run on,
      and enable the PRUSS only when you need them.

Licence:
========

libpruio (LGPLv2.1):
--------------------------

Copyright &copy; 2014-2018 by Thomas{ doT ]Freiherr[ At ]gmx[ DoT }net

This program is free software; you can redistribute it and/or modify it
under the terms of the Lesser GNU General Public License version 2 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-
1301, USA. For further details please refer to:
http://www.gnu.org/licenses/lgpl-2.0.html


Examples and utility programs (GPLv3):
--------------------------------------

Copyright &copy; 2014-2018 by Thomas{ doT ]Freiherr[ At ]gmx[ DoT }net

The examples of this bundle are free software as well; you can
redistribute them and/or modify them under the terms of the GNU
General Public License version 3 as published by the Free Software
Foundation.

The programs are distributed in the hope that they will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-
1301, USA. For further details please refer to:
http://www.gnu.org/licenses/gpl-3.0.html
