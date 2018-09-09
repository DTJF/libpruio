/'* \file pruio_pins.bi
\brief Pre-defined macros to handle the beagle bone header pins.

This file contains macros and arrays to easy handle the header pins and
pin groups of the beaglebone hardware. Instead of searching the CPU
ball number in lists, you can use one of these macros named after the
header and pin number (ie pin 3 of header P8 is named P8_03).

The file also contains pre-defined arrays for the pin groups of the
beaglebone black hardware. The arrays include all CPU ball numbers that
belong to a subsystem like the EMMC2 or HDMI and can be used to adress
all related pins as one group.

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
#DEFINE P9_39 AIN0
'* number of analog line on pin 40 on header 9
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
DIM SHARED AS UInt8 P8_Pins(...) = { _
  P8_03 _
, P8_04 _
, P8_05 _
, P8_06 _
, P8_07 _
, P8_08 _
, P8_09 _
, P8_10 _
, P8_11 _
, P8_12 _
, P8_13 _
, P8_14 _
, P8_15 _
, P8_16 _
, P8_17 _
, P8_18 _
, P8_19 _
, P8_20 _
, P8_21 _
, P8_22 _
, P8_23 _
, P8_24 _
, P8_25 _
, P8_26 _
, P8_27 _
, P8_28 _
, P8_29 _
, P8_30 _
, P8_31 _
, P8_32 _
, P8_33 _
, P8_34 _
, P8_35 _
, P8_36 _
, P8_37 _
, P8_38 _
, P8_39 _
, P8_40 _
, P8_41 _
, P8_42 _
, P8_43 _
, P8_44 _
, P8_45 _
, P8_46 _
  }

'* Array of CPU ball numbers for all digital pins on header P9.
DIM SHARED AS UInt8 P9_Pins(...) = { _
  P9_11 _
, P9_12 _
, P9_13 _
, P9_14 _
, P9_15 _
, P9_16 _
, P9_17 _
, P9_18 _
, P9_19 _
, P9_20 _
, P9_21 _
, P9_22 _
, P9_23 _
, P9_24 _
, P9_25 _
, P9_26 _
, P9_27 _
, P9_28 _
, P9_29 _
, P9_30 _
, P9_31 _
, P9_41 _
, P9_42 _
  }

'* Array of CPU ball numbers for all digital pins on header P9.
DIM SHARED AS UInt8 JT_Pins(...) = { _
  JT_04 _
, JT_05
  }

'* Array of CPU ball numbers for all digital pins on header P9.
DIM SHARED AS UInt8 SD_Pins(...) = { _
  SD_01 _
, SD_02 _
, SD_03 _
, SD_05 _
, SD_07 _
, SD_08 _
, SD_10
  }

'* Array of CPU ball numbers for emmc2 pin group on header P8.
DIM SHARED AS UInt8 EMMC2_Pins(...) = { _
  P8_03 _
, P8_04 _
, P8_05 _
, P8_06 _
, P8_20 _
, P8_21 _
, P8_22 _
, P8_23 _
, P8_24 _
, P8_25 _
  }

'* Array of CPU ball numbers for hdmi pin group on header P8.
DIM SHARED AS UInt8 HDMI_Pins(...) = { _
  P8_27 _
, P8_28 _
, P8_29 _
, P8_30 _
, P8_31 _
, P8_32 _
, P8_33 _
, P8_34 _
, P8_35 _
, P8_36 _
, P8_37 _
, P8_38 _
, P8_39 _
, P8_40 _
, P8_41 _
, P8_42 _
, P8_43 _
, P8_44 _
, P8_45 _
, P8_46 _
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
