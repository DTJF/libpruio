/*! \file pruio_pins_pocket.h
\brief Pre-defined macros to handle the PocketBeagle header pins.

This file contains macros to easy handle the header pins of the
PocketBeaglebone hardware (2x36 headers). Instead of searching the CPU
ball number in lists, you can use these macros named after the header
and pin number (ie pin 3 on header P1 is named P1_03).

See src/pruio/pruio_pins_pocket.bi for details.

Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)

Copyright 2014-\Year by \Email

\since 0.6.4
*/


// P1_01
//! CPU ball number for pin 2 on header 1 (+ AIN6 3V3 / P8_29 hdmi)
#define P1_02 0x39 //57
// P1_03
//! CPU ball number for pin 4 on header 1 (P8_30 hdmi)
#define P1_04 0x3B //59
// P1_05
//! CPU ball number for pin 6 on header 1 (P9_17)
#define P1_06 0x57 //87
// P1_07
//! CPU ball number for pin 8 on header 1 (P9_22)
#define P1_08 0x54 //84
// P1_09
//! CPU ball number for pin 10 on header 1 (P9_21)
#define P1_10 0x55 //85
// P1_11
//! CPU ball number for pin 12 on header 1 (P9_18)
#define P1_12 0x56 //86
// P1_13
// P1_14
// P1_15
// P1_16
// P1_17
// P1_18
//! ID for analog line 0 (1V8)
#define P1_19 no_pinmuxing_for_AIN0
//! CPU ball number for pin 20 on header 1 (P9_41)
#define P1_20 0x6D //109
//! ID for analog line 1 (1V8)
#define P1_21 no_pinmuxing_for_AIN1
// P1_22
//! ID for analog line 2 (1V8)
#define P1_23 no_pinmuxing_for_AIN2
// P1_24
//! ID for analog line 3 (1V8)
#define P1_25 no_pinmuxing_for_AIN3
//! CPU ball number for pin 26 on header 1 (P9_20 i2c2)
#define P1_26 0x5E //94
//! ID for analog line 4 (1V8)
#define P1_27 no_pinmuxing_for_AIN4
//! CPU ball number for pin 28 on header 1 (P9_19 i2c2)
#define P1_28 0x5F //95
//! CPU ball number for pin 29 on header 1 (P9_25 mcasp0)
#define P1_29 0x6B //107
//! CPU ball number for pin 30 on header 1 (JT_05)
#define P1_30 0x5D //93
//! CPU ball number for pin 31 on header 1 (P9_42)
#define P1_31 0x68 //104
//! CPU ball number for pin 32 on header 1 (JT_04)
#define P1_32 0x5C //92
//! CPU ball number for pin 33 on header 1 (P9_29 mcasp0)
#define P1_33 0x65 //101
//! CPU ball number for pin 34 on header 1 (P8_14)
#define P1_34 0x0A //10
//! CPU ball number for pin 35 on header 1 (P8_28 hdmi)
#define P1_35 0x3A //58
//! CPU ball number for pin 36 on header 1 (P9_31 mcasp0)
#define P1_36 0x64 //100


//! CPU ball number for pin 1 on header 2 (P9_14)
#define P2_01 0x12 //18
//! CPU ball number for pin 2 on header 2 (no BB pin)
#define P2_02 0x1B //27
//! CPU ball number for pin 3 on header 2 (P8_13)
#define P2_03 0x09 //9
//! CPU ball number for pin 4 on header 2 (no BB pin)
#define P2_04 0x1A //26
//! CPU ball number for pin 5 on header 2 (P9_11)
#define P2_05 0x1C //28
//! CPU ball number for pin 6 on header 2 (no BB pin)
#define P2_06 0x19 //25
//! CPU ball number for pin 7 on header 2 (P9_13)
#define P2_07 0x1D //29
//! CPU ball number for pin 8 on header 2 (P9_12)
#define P2_08 0x1E //30
//! CPU ball number for pin 9 on header 2 (P9_24)
#define P2_09 0x61 //97
//! CPU ball number for pin 10 on header 2 (no BB pin)
#define P2_10 0x14 //20
//! CPU ball number for pin 11 on header 2 (P9_26)
#define P2_11 0x60 //96
// P2_12
// P2_13
// P2_14
// P2_15
// P2_16
//! CPU ball number for pin 17 on header 2 (P8_18)
#define P2_17 0x23 //35
//! CPU ball number for pin 18 on header 2 (P8_15)
#define P2_18 0x0F //15
//! CPU ball number for pin 19 on header 2 (P8_17)
#define P2_19 0x0B //11
//! CPU ball number for pin 20 on header 2 (no BB pin)
#define P2_20 0x22 //34
//! CPU ball number for pin 22 on header 2 (P8_16)
#define P2_22 0x0E //14
// P2_23
//! CPU ball number for pin 24 on header 2 (P8_12)
#define P2_24 0x0C //12
//! CPU ball number for pin 25 on header 2 (no BB pin)
#define P2_25 0x5B //91
// P2_26
//! CPU ball number for pin 27 on header 2 (no BB pin)
#define P2_27 0x5A //90
//! CPU ball number for pin 28 on header 2 (P9_41)
#define P2_28 0x6A //106
//! CPU ball number for pin 29 on header 2 (P9_42)
#define P2_29 0x59 //89
//! CPU ball number for pin 30 on header 2 (P9_28 mcasp0)
#define P2_30 0x67 //103
//! CPU ball number for pin 31 on header 2 (no BB pin)
#define P2_31 0x6C //108
//! CPU ball number for pin 32 on header 2 (P9_30)
#define P2_32 0x66 //102
//! CPU ball number for pin 33 on header 2 (P8_11)
#define P2_33 0x0D //13
//! CPU ball number for pin 34 on header 2 (P9_27)
#define P2_34 0x69 //105
//! CPU ball number for pin 35 on header 2 (AIN5 3V3 / P8_27 hdmi)
#define P2_35 0x38 //56
//! ID for analog line 7 (1V8)
#define P2_36 no_pinmuxing_for_AIN7
