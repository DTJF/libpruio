/*! \file pruio_pins.h
\brief Pre-defined macros to handle the beagle bone header pins.

This file contains macros to easy handle the header pins and pin groups
of the beaglebone hardware (white, green, black: 2x46 headers). Instead
of searching the CPU ball number in lists, you can use these macros
named after the header and pin number (ie. pin 3 on header P8 is named
P8_03).

See src/pruio/pruio_pins.bi for details.

Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)

Copyright 2014-\Year by \Email

\since 0.0.0
*/

//* CPU ball number for pin 3 on header 8 (emmc2)
#define P8_03 0x06 //6
//* CPU ball number for pin 4 on header 8 (emmc2)
#define P8_04 0x07 //7
//* CPU ball number for pin 5 on header 8 (emmc2)
#define P8_05 0x02 //2
//* CPU ball number for pin 6 on header 8 (emmc2)
#define P8_06 0x03 //3
//* CPU ball number for pin 7 on header 8
#define P8_07 0x24 //36
//* CPU ball number for pin 8 on header 8
#define P8_08 0x25 //37
//* CPU ball number for pin 9 on header 8
#define P8_09 0x27 //39
//* CPU ball number for pin 10 on header 8
#define P8_10 0x26 //38
//* CPU ball number for pin 11 on header 8
#define P8_11 0x0D //13
//* CPU ball number for pin 12 on header 8
#define P8_12 0x0C //12
//* CPU ball number for pin 13 on header 8
#define P8_13 0x09 //9
//* CPU ball number for pin 14 on header 8
#define P8_14 0x0A //10
//* CPU ball number for pin 15 on header 8
#define P8_15 0x0F //15
//* CPU ball number for pin 16 on header 8
#define P8_16 0x0E //14
//* CPU ball number for pin 17 on header 8
#define P8_17 0x0B //11
//* CPU ball number for pin 18 on header 8
#define P8_18 0x23 //35
//* CPU ball number for pin 19 on header 8
#define P8_19 0x08 //8
//* CPU ball number for pin 20 on header 8 (emmc2)
#define P8_20 0x21 //33
//* CPU ball number for pin 21 on header 8 (emmc2)
#define P8_21 0x20 //32
//* CPU ball number for pin 22 on header 8 (emmc2)
#define P8_22 0x05 //5
//* CPU ball number for pin 23 on header 8 (emmc2)
#define P8_23 0x04 //4
//* CPU ball number for pin 24 on header 8 (emmc2)
#define P8_24 0x01 //1
//* CPU ball number for pin 25 on header 8 (emmc2)
#define P8_25 0x00 //0
//* CPU ball number for pin 26 on header 8
#define P8_26 0x1F //31
//* CPU ball number for pin 27 on header 8 (hdmi)
#define P8_27 0x38 //56
//* CPU ball number for pin 28 on header 8 (hdmi)
#define P8_28 0x3A //58
//* CPU ball number for pin 29 on header 8 (hdmi)
#define P8_29 0x39 //57
//* CPU ball number for pin 30 on header 8 (hdmi)
#define P8_30 0x3B //59
//* CPU ball number for pin 31 on header 8 (hdmi)
#define P8_31 0x36 //54
//* CPU ball number for pin 32 on header 8 (hdmi)
#define P8_32 0x37 //55
//* CPU ball number for pin 33 on header 8 (hdmi)
#define P8_33 0x35 //53
//* CPU ball number for pin 34 on header 8 (hdmi)
#define P8_34 0x33 //51
//* CPU ball number for pin 35 on header 8 (hdmi)
#define P8_35 0x34 //52
//* CPU ball number for pin 36 on header 8 (hdmi)
#define P8_36 0x32 //50
//* CPU ball number for pin 37 on header 8 (hdmi)
#define P8_37 0x30 //48
//* CPU ball number for pin 38 on header 8 (hdmi)
#define P8_38 0x31 //49
//* CPU ball number for pin 39 on header 8 (hdmi)
#define P8_39 0x2E //46
//* CPU ball number for pin 40 on header 8 (hdmi)
#define P8_40 0x2F //47
//* CPU ball number for pin 41 on header 8 (hdmi)
#define P8_41 0x2C //44
//* CPU ball number for pin 42 on header 8 (hdmi)
#define P8_42 0x2D //45
//* CPU ball number for pin 43 on header 8 (hdmi)
#define P8_43 0x2A //42
//* CPU ball number for pin 44 on header 8 (hdmi)
#define P8_44 0x2B //43
//* CPU ball number for pin 45 on header 8 (hdmi)
#define P8_45 0x28 //40
//* CPU ball number for pin 46 on header 8 (hdmi)
#define P8_46 0x29 //41

//* CPU ball number for pin 11 on header 9
#define P9_11 0x1C //28
//* CPU ball number for pin 12 on header 9
#define P9_12 0x1E //30
//* CPU ball number for pin 13 on header 9
#define P9_13 0x1D //29
//* CPU ball number for pin 14 on header 9
#define P9_14 0x12 //18
//* CPU ball number for pin 15 on header 9
#define P9_15 0x10 //16
//* CPU ball number for pin 16 on header 9
#define P9_16 0x13 //19
//* CPU ball number for pin 17 on header 9
#define P9_17 0x57 //87
//* CPU ball number for pin 18 on header 9
#define P9_18 0x56 //86
//* CPU ball number for pin 19 on header 9 (i2c2)
#define P9_19 0x5F //95
//* CPU ball number for pin 20 on header 9 (i2c2)
#define P9_20 0x5E //94
//* CPU ball number for pin 21 on header 9
#define P9_21 0x55 //85
//* CPU ball number for pin 22 on header 9
#define P9_22 0x54 //84
//* CPU ball number for pin 23 on header 9
#define P9_23 0x11 //17
//* CPU ball number for pin 24 on header 9
#define P9_24 0x61 //97
//* CPU ball number for pin 25 on header 9 (mcasp0)
#define P9_25 0x6B //107
//* CPU ball number for pin 26 on header 9
#define P9_26 0x60 //96
//* CPU ball number for pin 27 on header 9
#define P9_27 0x69 //105
//* CPU ball number for pin 28 on header 9 (mcasp0)
#define P9_28 0x67 //103
//* CPU ball number for pin 29 on header 9 (mcasp0)
#define P9_29 0x65 //101
//* CPU ball number for pin 30 on header 9
#define P9_30 0x66 //102
//* CPU ball number for pin 31 on header 9 (mcasp0)
#define P9_31 0x64 //100

//* Analog line on pin 33 on header 9
#define P9_33 no_pinmuxing_for_AIN4
//* Analog line on pin 35 on header 9
#define P9_35 no_pinmuxing_for_AIN6
//* Analog line on pin 36 on header 9
#define P9_36 no_pinmuxing_for_AIN5
//* Analog line on pin 37 on header 9
#define P9_37 no_pinmuxing_for_AIN2
//* Analog line on pin 38 on header 9
#define P9_38 no_pinmuxing_for_AIN3
//* Analog line on pin 39 on header 9
#define P9_39 no_pinmuxing_for_AIN0
//* Analog line on pin 40 on header 9
#define P9_40 no_pinmuxing_for_AIN1

//* CPU ball number for double pin 41 on header 9 (second ball is 106)
#define P9_41 0x6D //109
//* CPU ball number for double pin 42 on header 9 (second ball is 104)
#define P9_42 0x59 //89

//* CPU ball number for pin 4 on JTag header (E15)
#define JT_04 0x5C //92
//* CPU ball number for pin 5 on JTag header (E16)
#define JT_05 0x5D //93
