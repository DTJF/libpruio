/'* \file pruio_pins.bi
\brief Pre-defined macros to handle the beagle bone header pins.

This file contains macros and arrays to easy handle the header pins and
pin groups of the PocketBeaglebone hardware. Instead of searching the CPU
ball number in lists, you can use one of these macros named after the
header and pin number (ie pin 3 of header P1 is named P1_03).

\since 0.6.2
'/




'* CPU ball number for pin 29 on header 8 (hdmi)
#DEFINE P1_02 &h39 '57
'* CPU ball number for pin 30 on header 8 (hdmi)
#DEFINE P1_04 &h3B '59
'* CPU ball number for pin 17 on header 9
#DEFINE P1_06 &h57 '87
'* CPU ball number for pin 22 on header 9
#DEFINE P1_08 &h54 '84
'* CPU ball number for pin 21 on header 9
#DEFINE P1_10 &h55 '85
'* CPU ball number for pin 18 on header 9
#DEFINE P1_12 &h56 '86
'* CPU ball number for pin 41 on header 9
#DEFINE P1_20 &h6D '109
'* CPU ball number for pin 20 on header 9 (i2c2)
#DEFINE P1_26 &h5E '94
'* CPU ball number for pin 19 on header 9 (i2c2)
#DEFINE P1_28 &h5F '95
'* CPU ball number for pin 25 on header 9 (mcasp0)
#DEFINE P1_29 &h6B '107
'* CPU ball number for pin 5 on JTag header (E16)
#DEFINE P1_30 &h5D '93
'* CPU ball number for pin 42 on header 9.2
#DEFINE P1_31 &h68 '104
'* CPU ball number for pin 4 on JTag header (E15)
#DEFINE P1_32 &h5C '92
'* CPU ball number for pin 29 on header 9 (mcasp0)
#DEFINE P1_33 &h65 '101
'* CPU ball number for pin 14 on header 8
#DEFINE P1_34 &h0A '10
'* CPU ball number for pin 28 on header 8 (hdmi)
#DEFINE P1_35 &h3A '58
'* CPU ball number for pin 31 on header 9 (mcasp0)
#DEFINE P1_36 &h64 '100


'* CPU ball number for pin 14 on header 9
#DEFINE P2_01 &h12 '18
'* CPU ball number for pin 04 on header 2
#DEFINE P2_02 &h1E '27
'* CPU ball number for pin 13 on header 8
#DEFINE P2_03 &h09 '9
'* CPU ball number for pin 04 on header 2
#DEFINE P2_04 &h1D '26
'* CPU ball number for pin 11 on header 9
#DEFINE P2_05 &h1C '28
'* CPU ball number for pin 06 on header 2
#DEFINE P2_06 &h19 '25
'* CPU ball number for pin 13 on header 9
#DEFINE P2_07 &h1D '29
'* CPU ball number for pin 12 on header 9
#DEFINE P2_08 &h1E '30
'* CPU ball number for pin 24 on header 9
#DEFINE P2_09 &h61 '97
'* CPU ball number for pin 10 on header 2
#DEFINE P2_10 &h14 '20
'* CPU ball number for pin 26 on header 9
#DEFINE P2_11 &h60 '96
'* CPU ball number for pin 18 on header 8
#DEFINE P2_17 &h23 '35
'* CPU ball number for pin 15 on header 8
#DEFINE P2_18 &h0F '15
'* CPU ball number for pin 17 on header 8
#DEFINE P2_19 &h0B '11
'* CPU ball number for pin 20 on header 2
#DEFINE P2_20 &h22 '34
'* CPU ball number for pin 16 on header 8
#DEFINE P2_22 &h0E '14
'* CPU ball number for pin 12 on header 8
#DEFINE P2_24 &h0C '12
'* CPU ball number for pin 25 on header 2
#DEFINE P2_25 &h5B '91
'* CPU ball number for pin 27 on header 2
#DEFINE P2_27 &h5A '90
'* CPU ball number for pin 41 on header 9.1
#DEFINE P2_28 &h6D '109
'* CPU ball number for pin 42 on header 9.1
#DEFINE P2_29 &h59 '89
'* CPU ball number for pin 28 on header 9 (mcasp0)
#DEFINE P2_30 &h67 '103
'* CPU ball number for pin 31 on header 2 (no BB pin)
#DEFINE P2_31 &h6C '108
'* CPU ball number for pin 30 on header 9
#DEFINE P2_32 &h66 '102
'* CPU ball number for pin 11 on header 8
#DEFINE P2_33 &h0D '13
'* CPU ball number for pin 27 on header 9
#DEFINE P2_34 &h69 '105
'* CPU ball number for pin 27 on header 8 (hdmi)
#DEFINE P2_35 &h38 '56





'* default step number of analog line AIN-0
#DEFINE AIN0 1
'* default step number of analog line AIN-1
#DEFINE AIN1 2
'* default step number of analog line AIN-2
#DEFINE AIN2 3
'* default step number of analog line AIN-3
#DEFINE AIN3 4
'* default step number of analog line AIN-4
#DEFINE AIN4 5
'* default step number of analog line AIN-5
#DEFINE AIN5 6
'* default step number of analog line AIN-6
#DEFINE AIN6 7
'* default step number of analog line AIN-7 (internal, no pin)
#DEFINE AIN7 8
'* number of analog line on pin 39 on header 9
#DEFINE P1_19 AIN0
'* number of analog line on pin 39 on header 9
#DEFINE P1_21 AIN1
'* number of analog line on pin 39 on header 9
#DEFINE P1_23 AIN2
'* number of analog line on pin 39 on header 9
#DEFINE P1_25 AIN3
'* number of analog line on pin 39 on header 9
#DEFINE P1_27 AIN4
'* number of analog line on pin 39 on header 9 (3V3)
#DEFINE P2_35 AIN5
'* number of analog line on pin 39 on header 9 (3V3)
#DEFINE P1_02 AIN6
'* number of analog line on pin 39 on header 9
#DEFINE P2_36 AIN7









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

'* CPU ball number for pin 15 on header 9
#DEFINE P9_15 &h10 '16
'* CPU ball number for pin 16 on header 9
#DEFINE P9_16 &h13 '19
'* CPU ball number for pin 23 on header 9
#DEFINE P9_23 &h11 '17

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

#DEFINE P9_40 AIN1
'* number of analog line on pin 37 on header 9
#DEFINE P9_37 AIN2
'* number of analog line on pin 38 on header 9
#DEFINE P9_38 AIN3
'* number of analog line on pin 33 on header 9
#DEFINE P9_33 AIN4
'* number of analog line on pin 36 on header 9
#DEFINE P9_36 AIN5
'* number of analog line on pin 35 on header 9
#DEFINE P9_35 AIN6

'* Array of CPU ball numbers for all pins on header P8.
DIM SHARED AS UInt8 P1_Pins(...) = { _
  P1_01 _
, P1_02 _
, P1_03 _
, P1_04 _
, P1_05 _
, P1_06 _
, P1_07 _
, P1_08 _
, P1_09 _
, P1_10 _
, P1_11 _
, P1_12 _
, P1_13 _
, P1_14 _
, P1_15 _
, P1_16 _
, P1_17 _
, P1_18 _
, P1_19 _
, P1_20 _
, P1_21 _
, P1_22 _
, P1_23 _
, P1_24 _
, P1_25 _
, P1_26 _
, P1_27 _
, P1_28 _
, P1_29 _
, P1_30 _
, P1_31 _
, P1_32 _
, P1_33 _
, P1_34 _
, P1_35 _
, P1_36 _
  }

'* Array of CPU ball numbers for all digital pins on header P9.
DIM SHARED AS UInt8 P9_Pins(...) = { _
  P2_11 _
, P2_12 _
, P2_13 _
, P2_14 _
, P2_15 _
, P2_16 _
, P2_17 _
, P2_18 _
, P2_19 _
, P2_20 _
, P2_21 _
, P2_22 _
, P2_23 _
, P2_24 _
, P2_25 _
, P2_26 _
, P2_27 _
, P2_28 _
, P2_29 _
, P2_30 _
, P2_31 _
, P2_41 _
, P2_42 _
  }

'* Array of CPU ball numbers for all digital pins on header P9.
DIM SHARED AS UInt8 SD_Pins(...) = { _
  SD_01 _
, SD_02 _
, SD_03 _
, SD_05 _
, SD_07 _
, SD_08 _
, SD_10 _
  }

'* Array of CPU ball numbers for i2c1 pin group on header P9.
DIM SHARED AS UInt8 I2C1_Pins(...) = { _
  P9_17 _
, P9_18 _
  }

'* Array of CPU ball numbers for i2c2 pin group on header P9.
DIM SHARED AS UInt8 I2C2_Pins(...) = { _
  P9_19 _
, P9_20 _
  }

'* Array of CPU ball numbers for mcasp0 pin group on header P9.
DIM SHARED AS UInt8 MCASP0_Pins(...) = { _
  P9_25 _
, P9_28 _
, P9_29 _
, P9_31 _
  }
