/'* \file pruio_pins_pocket.bi
\brief Pre-defined macros to handle the PocketBeagle header pins.

This file contains macros to easy handle the header pins of the
PocketBeaglebone hardware (2x36 headers). Instead of searching the CPU
ball number in lists, you can use these macros named after the header
and pin number (ie pin 3 on header P1 is named P1_03).

\since 0.6.4
'/


' P1_01
'* CPU ball number for double pin 2 on header 1 (+ AIN6 3V3 / P8_29 hdmi, ZCZ ball R5) gpio2_23
#DEFINE P1_02 &h39 '57
' P1_03
'* CPU ball number for pin 4 on header 1 (P8_30 hdmi, ZCZ ball R6) gpio2_25
#DEFINE P1_04 &h3B '59
' P1_05
'* CPU ball number for pin 6 on header 1 (P9_17, ZCZ ball A16) spi0_cs0
#DEFINE P1_06 &h57 '87
' P1_07
'* CPU ball number for pin 8 on header 1 (P9_22, ZCZ ball A17) spi0_sclk
#DEFINE P1_08 &h54 '84
' P1_09
'* CPU ball number for pin 10 on header 1 (P9_21, ZCZ ball B17) spi0_d0
#DEFINE P1_10 &h55 '85
' P1_11
'* CPU ball number for pin 12 on header 1 (P9_18, ZCZ ball B16) spi0_d1
#DEFINE P1_12 &h56 '86
' P1_13
' P1_14
' P1_15
' P1_16
' P1_17
' P1_18
'* Analog line 0 (1V8)
#DEFINE P1_19 no_pinmuxing_for_AIN0
'* CPU ball number for pin 20 on header 1 (P9_41, ZCZ ball D14) gpio0_20
#DEFINE P1_20 &h6D '109
'* Analog line 1 (1V8)
#DEFINE P1_21 no_pinmuxing_for_AIN1
' P1_22
'* Analog line 2 (1V8)
#DEFINE P1_23 no_pinmuxing_for_AIN2
' P1_24
'* Analog line 3 (1V8)
#DEFINE P1_25 no_pinmuxing_for_AIN3
'* CPU ball number for pin 26 on header 1 (P9_20 i2c2, ZCZ ball D18) i2c2_sda
#DEFINE P1_26 &h5E '94
'* Analog line 4 (1V8)
#DEFINE P1_27 no_pinmuxing_for_AIN4
'* CPU ball number for pin 28 on header 1 (P9_19 i2c2, ZCZ ball D17) i2c2_scl
#DEFINE P1_28 &h5F '95
'* CPU ball number for pin 29 on header 1 (P9_25 mcasp0, ZCZ ball A14) pru0_in7
#DEFINE P1_29 &h6B '107
'* CPU ball number for pin 30 on header 1 (JT_05, ZCZ ball E16) uart0_txd
#DEFINE P1_30 &h5D '93
'* CPU ball number for pin 31 on header 1 (P9_42, ZCZ ball B12) pru0_in4
#DEFINE P1_31 &h68 '104
'* CPU ball number for pin 32 on header 1 (JT_04, ZCZ ball E15) uart0_rxd
#DEFINE P1_32 &h5C '92
'* CPU ball number for pin 33 on header 1 (P9_29 mcasp0, ZCZ ball B13) pru0_in1
#DEFINE P1_33 &h65 '101
'* CPU ball number for pin 34 on header 1 (P8_14, ZCZ ball T11) gpio0_26
#DEFINE P1_34 &h0A '10
'* CPU ball number for pin 35 on header 1 (P8_28 hdmi, ZCZ ball V5) pru1_in10
#DEFINE P1_35 &h3A '58
'* CPU ball number for pin 36 on header 1 (P9_31 mcasp0, ZCZ ball A13) ehrpwm0a
#DEFINE P1_36 &h64 '100

'* CPU ball number for pin 1 on header 2 (P9_14, ZCZ ball U14) ehrpwm1a
#DEFINE P2_01 &h12 '18
'* CPU ball number for pin 2 on header 2 (no BB pin, ZCZ ball V17) gpio1_27
#DEFINE P2_02 &h1B '27
'* CPU ball number for pin 3 on header 2 (P8_13, ZCZ ball T10) gpio0_23
#DEFINE P2_03 &h09 '9
'* CPU ball number for pin 4 on header 2 (no BB pin, ZCZ ball T16) gpio1_26
#DEFINE P2_04 &h1A '26
'* CPU ball number for pin 5 on header 2 (P9_11, ZCZ ball T17) uart4_rxd
#DEFINE P2_05 &h1C '28
'* CPU ball number for pin 6 on header 2 (no BB pin, ZCZ ball U16) gpio1_25
#DEFINE P2_06 &h19 '25
'* CPU ball number for pin 7 on header 2 (P9_13, ZCZ ball U17) uart4_txd
#DEFINE P2_07 &h1D '29
'* CPU ball number for pin 8 on header 2 (P9_12, ZCZ ball U18) gpio1_28
#DEFINE P2_08 &h1E '30
'* CPU ball number for pin 9 on header 2 (P9_24, ZCZ ball D15) i2c1_scl
#DEFINE P2_09 &h61 '97
'* CPU ball number for pin 10 on header 2 (no BB pin, ZCZ ball R14) gpio1_20
#DEFINE P2_10 &h14 '20
'* CPU ball number for pin 11 on header 2 (P9_26, ZCZ ball D16) i2c1_sda
#DEFINE P2_11 &h60 '96
' P2_12
' P2_13
' P2_14
' P2_15
' P2_16
'* CPU ball number for pin 17 on header 2 (P8_18, ZCZ ball V12) gpio2_1
#DEFINE P2_17 &h23 '35
'* CPU ball number for pin 18 on header 2 (P8_15, ZCZ ball U13) gpio1_15
#DEFINE P2_18 &h0F '15
'* CPU ball number for pin 19 on header 2 (P8_17, ZCZ ball U12) gpio0_27
#DEFINE P2_19 &h0B '11
'* CPU ball number for pin 20 on header 2 (no BB pin, ZCZ ball T13) gpio2_0
#DEFINE P2_20 &h22 '34
'* CPU ball number for pin 22 on header 2 (P8_16, ZCZ ball V13) gpio1_14
#DEFINE P2_22 &h0E '14
' P2_23
'* CPU ball number for pin 24 on header 2 (P8_12, ZCZ ball T12) gpio1_12
#DEFINE P2_24 &h0C '12
'* CPU ball number for pin 25 on header 2 (no BB pin, ZCZ ball E17) spi1_d1
#DEFINE P2_25 &h5B '91
' P2_26
'* CPU ball number for pin 27 on header 2 (no BB pin, ZCZ ball E18) spi1_d0
#DEFINE P2_27 &h5A '90
'* CPU ball number for pin 28 on header 2 (P9_41, ZCZ ball D13) pru0_in6
#DEFINE P2_28 &h6A '106
'* CPU ball number for pin 29 on header 2 (P9_42, ZCZ ball C18) spi1_sclk
#DEFINE P2_29 &h59 '89
'* CPU ball number for pin 30 on header 2 (P9_28 mcasp0, ZCZ ball C12) pru0_in3)
#DEFINE P2_30 &h67 '103
'* CPU ball number for pin 31 on header 2 (no BB pin, ZCZ ball A15) spi1_cs1
#DEFINE P2_31 &h6C '108
'* CPU ball number for pin 32 on header 2 (P9_30, ZCZ ball D12) pru0_in2
#DEFINE P2_32 &h66 '102
'* CPU ball number for pin 33 on header 2 (P8_11, ZCZ ball R12) gpio1_13
#DEFINE P2_33 &h0D '13
'* CPU ball number for pin 34 on header 2 (P9_27, ZCZ ball C13) pru0_in5
#DEFINE P2_34 &h69 '105
'* CPU ball number for double pin 35 on header 2 (AIN5 3V3 / P8_27 hdmi, ZCZ ball U5) gpio2_22
#DEFINE P2_35 &h38 '56
'* Analog line 7 (1V8, ZCZ ball C9)  AIN7
#DEFINE P2_36 no_pinmuxing_for_AIN7
