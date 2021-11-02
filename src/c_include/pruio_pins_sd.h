/*! \file pruio_pins_sd.h
\brief Pre-defined macros to handle the SD card slot connectors.

This file contains macros to easy handle the connector pins of
the SD card slot. Instead of searching the CPU ball number
in lists, you can use these macros named after the connectors pin
number (ie pin 3 is named SD_3).

See src/pruio/pruio_pins:sd.bi for details.

Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)

Copyright 2014-\Year by \Email

\since 0.6.8
*/

//! CPU ball number for pin 1 on SD slot (F18)
#define SD_01 0x3D //61
//! CPU ball number for pin 2 on SD slot (F17)
#define SD_02 0x3C //60
//! CPU ball number for pin 3 on SD slot (G18)
#define SD_03 0x41 //65
//! CPU ball number for pin 5 on SD slot (G17)
#define SD_05 0x40 //64
//! CPU ball number for pin 7 on SD slot (G16)
#define SD_07 0x3F //63
//! CPU ball number for pin 8 on SD slot (G15)
#define SD_08 0x3E //62
//! CPU ball number for pin 10 on SD slot (C15)
#define SD_10 0x58 //88
