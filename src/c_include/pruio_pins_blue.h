/*! \file pruio_pins_blue.h
\brief Pre-defined macros to handle the BeagleBone Blue connectors.

This file contains macros to easy handle the connector pins of
the Beaglebone Blue hardware. Instead of searching the CPU ball number
in lists, you can use these macros named after the connectors pin
number (ie pin 3 on connector E1 is named E1_3).

See src/pruio/pruio_pins_blue.bi for details.

Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)

Copyright 2014-\Year by \Email

\since 0.6.4
*/

//! CPU ball number for E1_3 (ZCZ ball B12) eqep0a_in
#define E1_3   0x68 //104
//! CPU ball number for E1_4 (ZCZ ball C13) qep
#define E1_4   0x69 //105
//! CPU ball number for E2_3 (ZCZ ball V2) qep
#define E2_3   0x34 //52
//! CPU ball number for E2_4 (ZCZ ball V3) qep
#define E2_4   0x35 //53
//! CPU ball number for E3_3 (ZCZ ball T12) qep
#define E3_3   0x0C //12
//! CPU ball number for E3_4 (ZCZ ball R12) qep
#define E3_4   0x0D //13
//! CPU ball number for E4_3 (ZCZ ball V13) pruin
#define E4_3   0x0E //14
//! CPU ball number for E4_4 (ZCZ ball U13) pruin
#define E4_4   0x0F //15
//! CPU ball number for UT0_3 (ZCZ ball E15) uart
#define UT0_3  0x5C //92
//! CPU ball number for UT0_4 (ZCZ ball E16) uart
#define UT0_4  0x5D //93
//! CPU ball number for UT1_3 (ZCZ ball D16) uart
#define UT1_3  0x60 //96
//! CPU ball number for UT1_4 (ZCZ ball D15) uart
#define UT1_4  0x61 //97
//! CPU ball number for UT5_3 (ZCZ ball U2) uart
#define UT5_3  0x31 //49
//! CPU ball number for UT5_4 (ZCZ ball U1) uart
#define UT5_4  0x30 //48
//! CPU ball number for DSM2_3 (ZCZ ball T17) uart
#define DSM2_3 0x1C //28
//! CPU ball number for GP0_3 (ZCZ ball U16)
#define GP0_3  0x19 //25
//! CPU ball number for GP0_4 (ZCZ ball V14)
#define GP0_4  0x11 //17
//! CPU ball number for GP0_5 (ZCZ ball D13)
#define GP0_5  0x6A //106
//! CPU ball number for GP0_6 (ZCZ ball C12)
#define GP0_6  0x67 //103
//! CPU ball number for GP1_3 (ZCZ ball J15)
#define GP1_3  0x44 //68
//! CPU ball number for GP1_4 (ZCZ ball H17)
#define GP1_4  0x43 //67
//! CPU ball number for GP1_5 (ZCZ ball R7)
#define GP1_5  0x24 // 36
//! CPU ball number for GP1_6 (ZCZ ball T7)
#define GP1_6  0x25 //37
//! CPU ball number for GPS_3 (ZCZ ball A17) uart
#define GPS_3  0x54 //84
//! CPU ball number for GPS_4 (ZCZ ball B17) uart
#define GPS_4  0x55 //85
//! CPU ball number for SPI1_3 (ZCZ ball D12) spi
#define SPI1_3 0x66 //102
//! CPU ball number for SPI1_4 (ZCZ ball B13) spi
#define SPI1_4 0x65 //101
//! CPU ball number for SPI1_5 (ZCZ ball A13) spi_sclk
#define SPI1_5 0x64 //100
//! CPU ball number for S1.1_6 (ZCZ ball H18) spi_cs
#define SPI1_6 0x51 // 81
//! CPU ball number for S1.2_6 (ZCZ ball C18) spi_cs
#define SPI2_6 0x59 //89
