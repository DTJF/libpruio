/'* \file pruio_pins_blue.bi
\brief Pre-defined macros to handle the BeagleBone Blue connectors.

This file contains macros to easy handle the connector pins of
the Beaglebone Blue hardware. Instead of searching the CPU ball number
in lists, you can use these macros named after the connectors pin
number (ie pin 3 on connector E1 is named E1_3).

\since 0.6.4
'/

'* CPU ball number for E1_3 (no BB pin, ZCZ ball B12) eqep0a_in
#DEFINE E1_3   &h68 '104
'* CPU ball number for E1_4 (ZCZ ball C13) qep
#DEFINE E1_4   &h69 '105
'* CPU ball number for E2_3 (ZCZ ball V2) qep
#DEFINE E2_3   &h34 '52
'* CPU ball number for E2_4 (ZCZ ball V3) qep
#DEFINE E2_4   &h35 '53
'* CPU ball number for E3_3 (ZCZ ball T12) qep
#DEFINE E3_3   &h0C '12
'* CPU ball number for E3_4 (ZCZ ball R12) qep
#DEFINE E3_4   &h0D '13
'* CPU ball number for E4_3 (ZCZ ball V13) pruin
#DEFINE E4_3   &h0E '14
'* CPU ball number for E4_4 (ZCZ ball U13) pruin
#DEFINE E4_4   &h0F '15
'* CPU ball number for UT0_3 (ZCZ ball E15) uart
#DEFINE UT0_3  &h5C '92
'* CPU ball number for UT0_4 (ZCZ ball E16) uart
#DEFINE UT0_4  &h5D '93
'* CPU ball number for UT1_3 (ZCZ ball D16) uart
#DEFINE UT1_3  &h60 '96
'* CPU ball number for UT1_4 (ZCZ ball D15) uart
#DEFINE UT1_4  &h61 '97
'* CPU ball number for UT5_3 (ZCZ ball U2) uart
#DEFINE UT5_3  &h31 '49
'* CPU ball number for UT5_4 (ZCZ ball U1) uart
#DEFINE UT5_4  &h30 '48
'* CPU ball number for DSM2_3 (ZCZ ball T17) uart
#DEFINE DSM2_3 &h1C '28
'* CPU ball number for GP0_3 (no BB pin, ZCZ ball U16)
#DEFINE GP0_3  &h19 '25
'* CPU ball number for GP0_4 (ZCZ ball V14)
#DEFINE GP0_4  &h11 '17
'* CPU ball number for GP0_5 (no BB pin, ZCZ ball D13)
#DEFINE GP0_5  &h6A '106
'* CPU ball number for GP0_6 (ZCZ ball C12)
#DEFINE GP0_6  &h67 '103
'* CPU ball number for GP1_3 (no BB pin, ZCZ ball J15)
#DEFINE GP1_3  &h44 '68
'* CPU ball number for GP1_4 (no BB pin, ZCZ ball H17)
#DEFINE GP1_4  &h43 '67
'* CPU ball number for GP1_5 (no BB pin, ZCZ ball R7)
#DEFINE GP1_5  &h24 '36
'* CPU ball number for GP1_6 (ZCZ ball T7)
#DEFINE GP1_6  &h25 '37
'* CPU ball number for GPS_3 (ZCZ ball A17) uart
#DEFINE GPS_3  &h54 '84
'* CPU ball number for GPS_4 (ZCZ ball B17) uart
#DEFINE GPS_4  &h55 '85
'* CPU ball number for SPI1_3 (ZCZ ball D12) spi
#DEFINE SPI1_3 &h66 '102
'* CPU ball number for SPI1_4 (ZCZ ball B13) spi
#DEFINE SPI1_4 &h65 '101
'* CPU ball number for SPI1_5 (ZCZ ball A13) spi_sclk
#DEFINE SPI1_5 &h64 '100
'* CPU ball number for SPI1_6 (no BB pin, ZCZ ball H18) spi_cs
#DEFINE SPI1_6 &h51 ' 81
'* CPU ball number for SPI2_6 (ZCZ ball C18) spi_cs
#DEFINE SPI2_6 &h59 '89
