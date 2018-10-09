/'* \file pruio_pins.bi
\brief Pre-defined macros to handle the beagle bone header pins.

This file contains macros to easy handle the header pins and pin groups
of the beaglebone hardware. Instead of searching the CPU ball number in
lists, you can use these macros named after the header and pin number
(ie. pin 3 on header P8 is named P8_03).

\since 0.0
'/

'* CPU ball number for pin 3 on header 8 (emmc2)
#DEFINE P8_03 &h06
'* CPU ball number for pin 4 on header 8 (emmc2)
#DEFINE P8_04 &h07
'* CPU ball number for pin 5 on header 8 (emmc2)
#DEFINE P8_05 &h02
'* CPU ball number for pin 6 on header 8 (emmc2)
#DEFINE P8_06 &h03
'* CPU ball number for pin 7 on header 8
#DEFINE P8_07 &h24' 36
'* CPU ball number for pin 8 on header 8
#DEFINE P8_08 &h25 '37
'* CPU ball number for pin 9 on header 8
#DEFINE P8_09 &h27 '39
'* CPU ball number for pin 10 on header 8
#DEFINE P8_10 &h26 '38
'* CPU ball number for pin 11 on header 8
#DEFINE P8_11 &h0D '13
'* CPU ball number for pin 12 on header 8
#DEFINE P8_12 &h0C '12
'* CPU ball number for pin 13 on header 8
#DEFINE P8_13 &h09 '9
'* CPU ball number for pin 14 on header 8
#DEFINE P8_14 &h0A '10
'* CPU ball number for pin 15 on header 8
#DEFINE P8_15 &h0F '15
'* CPU ball number for pin 16 on header 8
#DEFINE P8_16 &h0E '14
'* CPU ball number for pin 17 on header 8
#DEFINE P8_17 &h0B '11
'* CPU ball number for pin 18 on header 8
#DEFINE P8_18 &h23 '35
'* CPU ball number for pin 19 on header 8
#DEFINE P8_19 &h08 '8
'* CPU ball number for pin 20 on header 8 (emmc2)
#DEFINE P8_20 &h21 '33
'* CPU ball number for pin 21 on header 8 (emmc2)
#DEFINE P8_21 &h20 '32
'* CPU ball number for pin 22 on header 8 (emmc2)
#DEFINE P8_22 &h05 '5
'* CPU ball number for pin 23 on header 8 (emmc2)
#DEFINE P8_23 &h04 '4
'* CPU ball number for pin 24 on header 8 (emmc2)
#DEFINE P8_24 &h01 '1
'* CPU ball number for pin 25 on header 8 (emmc2)
#DEFINE P8_25 &h00 '0
'* CPU ball number for pin 26 on header 8
#DEFINE P8_26 &h1F '31
'* CPU ball number for pin 27 on header 8 (hdmi)
#DEFINE P8_27 &h38 '56
'* CPU ball number for pin 28 on header 8 (hdmi)
#DEFINE P8_28 &h3A '58
'* CPU ball number for pin 29 on header 8 (hdmi)
#DEFINE P8_29 &h39 '57
'* CPU ball number for pin 30 on header 8 (hdmi)
#DEFINE P8_30 &h3B '59
'* CPU ball number for pin 31 on header 8 (hdmi)
#DEFINE P8_31 &h36 '54
'* CPU ball number for pin 32 on header 8 (hdmi)
#DEFINE P8_32 &h37 '55
'* CPU ball number for pin 33 on header 8 (hdmi)
#DEFINE P8_33 &h35 '53
'* CPU ball number for pin 34 on header 8 (hdmi)
#DEFINE P8_34 &h33 '51
'* CPU ball number for pin 35 on header 8 (hdmi)
#DEFINE P8_35 &h34 '52
'* CPU ball number for pin 36 on header 8 (hdmi)
#DEFINE P8_36 &h32 '50
'* CPU ball number for pin 37 on header 8 (hdmi)
#DEFINE P8_37 &h30 '48
'* CPU ball number for pin 38 on header 8 (hdmi)
#DEFINE P8_38 &h31 '49
'* CPU ball number for pin 39 on header 8 (hdmi)
#DEFINE P8_39 &h2E '46
'* CPU ball number for pin 40 on header 8 (hdmi)
#DEFINE P8_40 &h2F '47
'* CPU ball number for pin 41 on header 8 (hdmi)
#DEFINE P8_41 &h2C '44
'* CPU ball number for pin 42 on header 8 (hdmi)
#DEFINE P8_42 &h2D '45
'* CPU ball number for pin 43 on header 8 (hdmi)
#DEFINE P8_43 &h2A '42
'* CPU ball number for pin 44 on header 8 (hdmi)
#DEFINE P8_44 &h2B '43
'* CPU ball number for pin 45 on header 8 (hdmi)
#DEFINE P8_45 &h28 '40
'* CPU ball number for pin 46 on header 8 (hdmi)
#DEFINE P8_46 &h29 '41

'* CPU ball number for pin 11 on header 9
#DEFINE P9_11 &h1C '28
'* CPU ball number for pin 12 on header 9
#DEFINE P9_12 &h1E '30
'* CPU ball number for pin 13 on header 9
#DEFINE P9_13 &h1D '29
'* CPU ball number for pin 14 on header 9
#DEFINE P9_14 &h12 '18
'* CPU ball number for pin 15 on header 9
#DEFINE P9_15 &h10 '16
'* CPU ball number for pin 16 on header 9
#DEFINE P9_16 &h13 '19
'* CPU ball number for pin 17 on header 9
#DEFINE P9_17 &h57 '87
'* CPU ball number for pin 18 on header 9
#DEFINE P9_18 &h56 '86
'* CPU ball number for pin 19 on header 9 (i2c2)
#DEFINE P9_19 &h5F '95
'* CPU ball number for pin 20 on header 9 (i2c2)
#DEFINE P9_20 &h5E '94
'* CPU ball number for pin 21 on header 9
#DEFINE P9_21 &h55 '85
'* CPU ball number for pin 22 on header 9
#DEFINE P9_22 &h54 '84
'* CPU ball number for pin 23 on header 9
#DEFINE P9_23 &h11 '17
'* CPU ball number for pin 24 on header 9
#DEFINE P9_24 &h61 '97
'* CPU ball number for pin 25 on header 9 (mcasp0)
#DEFINE P9_25 &h6B '107
'* CPU ball number for pin 26 on header 9
#DEFINE P9_26 &h60 '96
'* CPU ball number for pin 27 on header 9
#DEFINE P9_27 &h69 '105
'* CPU ball number for pin 28 on header 9 (mcasp0)
#DEFINE P9_28 &h67 '103
'* CPU ball number for pin 29 on header 9 (mcasp0)
#DEFINE P9_29 &h65 '101
'* CPU ball number for pin 30 on header 9
#DEFINE P9_30 &h66 '102
'* CPU ball number for pin 31 on header 9 (mcasp0)
#DEFINE P9_31 &h64 '100

'* Analog line on pin 33 on header 9
#DEFINE P9_33 no_pinmuxing_for_AIN4
'* Analog line on pin 35 on header 9
#DEFINE P9_35 no_pinmuxing_for_AIN6
'* Analog line on pin 36 on header 9
#DEFINE P9_36 no_pinmuxing_for_AIN5
'* Analog line on pin 37 on header 9
#DEFINE P9_37 no_pinmuxing_for_AIN2
'* Analog line on pin 38 on header 9
#DEFINE P9_38 no_pinmuxing_for_AIN3
'* Analog line on pin 39 on header 9
#DEFINE P9_39 no_pinmuxing_for_AIN0
'* Analog line on pin 40 on header 9
#DEFINE P9_40 no_pinmuxing_for_AIN1

'* CPU ball number for pin 41 on header 9
#DEFINE P9_41 &h6D '109
'* CPU ball number for pin 42 on header 9
#DEFINE P9_42 &h59 '89

'* CPU ball number for pin 4 on JTag header (E15)
#DEFINE JT_04 &h5C '92
'* CPU ball number for pin 5 on JTag header (E16)
#DEFINE JT_05 &h5D '93

'* CPU ball number for pin 1 on SD slot (F18)
#DEFINE SD_01 &h3D '61
'* CPU ball number for pin 2 on SD slot (F17)
#DEFINE SD_02 &h3C '60
'* CPU ball number for pin 3 on SD slot (G18)
#DEFINE SD_03 &h41 '65
'* CPU ball number for pin 5 on SD slot (G17)
#DEFINE SD_05 &h40 '64
'* CPU ball number for pin 7 on SD slot (G16)
#DEFINE SD_07 &h3F '63
'* CPU ball number for pin 8 on SD slot (G15)
#DEFINE SD_08 &h3E '62
'* CPU ball number for pin 10 on SD slot (C15)
#DEFINE SD_10 &h58 '88


