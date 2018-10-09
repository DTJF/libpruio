/* * \ file pruio_pins.h
\brief Pre-defined macros to handle the beagle bone header pins.

This file contains macros to easy handle the header pins and
pin groups of the beaglebone hardware. Instead of looking up the CPU
pin number in lists, you can use a macro named after the header and pin
number (ie pin 3 on header P8 is named P8_03).

See src/pruio/pruio_pins.bi for details.

Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)

Copyright 2014-\Year by \Email

\since 0.0.0
*/

#define P8_03  6  // emmc2
#define P8_04  7  // emmc2
#define P8_05  2  // emmc2
#define P8_06  3  // emmc2
#define P8_07  36
#define P8_08  37
#define P8_09  39
#define P8_10  38
#define P8_11  13
#define P8_12  12
#define P8_13  9
#define P8_14  10
#define P8_15  15
#define P8_16  14
#define P8_17  11
#define P8_18  35
#define P8_19  8
#define P8_20  33 // emmc2
#define P8_21  32 // emmc2
#define P8_22  5  // emmc2
#define P8_23  4  // emmc2
#define P8_24  1  // emmc2
#define P8_25  0  // emmc2
#define P8_26  31
#define P8_27  56 // hdmi
#define P8_28  58 // hdmi
#define P8_29  57 // hdmi
#define P8_30  59 // hdmi
#define P8_31  54 // hdmi
#define P8_32  55 // hdmi
#define P8_33  53 // hdmi
#define P8_34  51 // hdmi
#define P8_35  52 // hdmi
#define P8_36  50 // hdmi
#define P8_37  48 // hdmi
#define P8_38  49 // hdmi
#define P8_39  46 // hdmi
#define P8_40  47 // hdmi
#define P8_41  44 // hdmi
#define P8_42  45 // hdmi
#define P8_43  42 // hdmi
#define P8_44  43 // hdmi
#define P8_45  40 // hdmi
#define P8_46  41 // hdmi

#define P9_11  28
#define P9_12  30
#define P9_13  29
#define P9_14  18
#define P9_15  16
#define P9_16  19
#define P9_17  87
#define P9_18  86
#define P9_19  95 // i2c2
#define P9_20  94 // i2c2
#define P9_21  85
#define P9_22  84
#define P9_23  17
#define P9_24  97
#define P9_25  107 // mcasp0
#define P9_26  96
#define P9_27  105
#define P9_28  103 // mcasp0
#define P9_29  101 // mcasp0
#define P9_30  102
#define P9_31  100 // mcasp0
#define P9_41  109
#define P9_42  89

#define JT_04  92 // JTag header
#define JT_05  93 // JTag header

#define SD_01  61
#define SD_02  60
#define SD_03  65
#define SD_05  64
#define SD_07  63
#define SD_08  62
#define SD_10  88
