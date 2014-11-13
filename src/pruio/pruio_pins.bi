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

'/

'* CPU ball number for pin 3 on header 8 (emmc2)
#define P8_03 6
'* CPU ball number for pin 4 on header 8 (emmc2)
#define P8_04 7
'* CPU ball number for pin 5 on header 8 (emmc2)
#define P8_05 2
'* CPU ball number for pin 6 on header 8 (emmc2)
#define P8_06 3
'* CPU ball number for pin 7 on header 8
#define P8_07 36
'* CPU ball number for pin 8 on header 8
#define P8_08 37
'* CPU ball number for pin 9 on header 8
#define P8_09 39
'* CPU ball number for pin 10 on header 8
#define P8_10 38
'* CPU ball number for pin 11 on header 8
#define P8_11 13
'* CPU ball number for pin 12 on header 8
#define P8_12 12
'* CPU ball number for pin 13 on header 8
#define P8_13 9
'* CPU ball number for pin 14 on header 8
#define P8_14 10
'* CPU ball number for pin 15 on header 8
#define P8_15 15
'* CPU ball number for pin 16 on header 8
#define P8_16 14
'* CPU ball number for pin 17 on header 8
#define P8_17 11
'* CPU ball number for pin 18 on header 8
#define P8_18 35
'* CPU ball number for pin 19 on header 8
#define P8_19 8
'* CPU ball number for pin 20 on header 8 (emmc2)
#define P8_20 33
'* CPU ball number for pin 21 on header 8 (emmc2)
#define P8_21 32
'* CPU ball number for pin 22 on header 8 (emmc2)
#define P8_22 5
'* CPU ball number for pin 23 on header 8 (emmc2)
#define P8_23 4
'* CPU ball number for pin 24 on header 8 (emmc2)
#define P8_24 1
'* CPU ball number for pin 25 on header 8 (emmc2)
#define P8_25 0
'* CPU ball number for pin 26 on header 8
#define P8_26 31
'* CPU ball number for pin 27 on header 8 (hdmi)
#define P8_27 56
'* CPU ball number for pin 28 on header 8 (hdmi)
#define P8_28 58
'* CPU ball number for pin 29 on header 8 (hdmi)
#define P8_29 57
'* CPU ball number for pin 30 on header 8 (hdmi)
#define P8_30 59
'* CPU ball number for pin 31 on header 8 (hdmi)
#define P8_31 54
'* CPU ball number for pin 32 on header 8 (hdmi)
#define P8_32 55
'* CPU ball number for pin 33 on header 8 (hdmi)
#define P8_33 53
'* CPU ball number for pin 34 on header 8 (hdmi)
#define P8_34 51
'* CPU ball number for pin 35 on header 8 (hdmi)
#define P8_35 52
'* CPU ball number for pin 36 on header 8 (hdmi)
#define P8_36 50
'* CPU ball number for pin 37 on header 8 (hdmi)
#define P8_37 48
'* CPU ball number for pin 38 on header 8 (hdmi)
#define P8_38 49
'* CPU ball number for pin 39 on header 8 (hdmi)
#define P8_39 46
'* CPU ball number for pin 40 on header 8 (hdmi)
#define P8_40 47
'* CPU ball number for pin 41 on header 8 (hdmi)
#define P8_41 44
'* CPU ball number for pin 42 on header 8 (hdmi)
#define P8_42 45
'* CPU ball number for pin 43 on header 8 (hdmi)
#define P8_43 42
'* CPU ball number for pin 44 on header 8 (hdmi)
#define P8_44 43
'* CPU ball number for pin 45 on header 8 (hdmi)
#define P8_45 40
'* CPU ball number for pin 46 on header 8 (hdmi)
#define P8_46 41

'* CPU ball number for pin 11 on header 9
#define P9_11 28
'* CPU ball number for pin 12 on header 9
#define P9_12 30
'* CPU ball number for pin 13 on header 9
#define P9_13 29
'* CPU ball number for pin 14 on header 9
#define P9_14 18
'* CPU ball number for pin 15 on header 9
#define P9_15 16
'* CPU ball number for pin 16 on header 9
#define P9_16 19
'* CPU ball number for pin 17 on header 9
#define P9_17 87
'* CPU ball number for pin 18 on header 9
#define P9_18 86
'* CPU ball number for pin 19 on header 9 (i2c2)
#define P9_19 95
'* CPU ball number for pin 20 on header 9 (i2c2)
#define P9_20 94
'* CPU ball number for pin 21 on header 9
#define P9_21 85
'* CPU ball number for pin 22 on header 9
#define P9_22 84
'* CPU ball number for pin 23 on header 9
#define P9_23 17
'* CPU ball number for pin 24 on header 9
#define P9_24 97
'* CPU ball number for pin 25 on header 9 (mcasp0)
#define P9_25 107
'* CPU ball number for pin 26 on header 9
#define P9_26 96
'* CPU ball number for pin 27 on header 9
#define P9_27 105
'* CPU ball number for pin 28 on header 9 (mcasp0)
#define P9_28 103
'* CPU ball number for pin 29 on header 9 (mcasp0)
#define P9_29 101
'* CPU ball number for pin 30 on header 9
#define P9_30 102
'* CPU ball number for pin 31 on header 9 (mcasp0)
#define P9_31 100
'* CPU ball number for pin 41 on header 9
#define P9_41 109
'* CPU ball number for pin 42 on header 9
#define P9_42 89

'* number of analog line on pin 39 on header 9
#define P9_39 AIN0
'* number of analog line on pin 40 on header 9
#define P9_40 AIN1
'* number of analog line on pin 37 on header 9
#define P9_37 AIN2
'* number of analog line on pin 38 on header 9
#define P9_38 AIN3
'* number of analog line on pin 33 on header 9
#define P9_33 AIN4
'* number of analog line on pin 36 on header 9
#define P9_36 AIN5
'* number of analog line on pin 35 on header 9
#define P9_35 AIN6
'* default step number of analog line AIN-0
#define AIN0 1
'* default step number of analog line AIN-1
#define AIN1 2
'* default step number of analog line AIN-2
#define AIN2 3
'* default step number of analog line AIN-3
#define AIN3 4
'* default step number of analog line AIN-4
#define AIN4 5
'* default step number of analog line AIN-5
#define AIN5 6
'* default step number of analog line AIN-6
#define AIN6 7
'* default step number of analog line AIN-7 (internal, no pin)
#define AIN7 8

'* Array of CPU ball numbers for all pins on header P8.
DIM SHARED AS UInt8 P8_Pins(...) = { _
  6  _
, 7  _
, 2  _
, 3  _
, 36 _
, 37 _
, 39 _
, 38 _
, 13 _
, 12 _
, 9  _
, 10 _
, 15 _
, 14 _
, 11 _
, 35 _
, 8  _
, 33 _
, 32 _
, 5  _
, 4  _
, 1  _
, 0  _
, 31 _
, 56 _
, 58 _
, 57 _
, 59 _
, 54 _
, 55 _
, 53 _
, 51 _
, 52 _
, 50 _
, 48 _
, 49 _
, 46 _
, 47 _
, 44 _
, 45 _
, 42 _
, 43 _
, 40 _
, 41 _
  }

'* Array of CPU ball numbers for all digital pins on header P9.
DIM SHARED AS UInt8 P9_Pins(...) = { _
  28  _
, 30  _
, 29  _
, 18  _
, 16  _
, 19  _
, 87  _
, 86  _
, 95  _
, 94  _
, 85  _
, 84  _
, 17  _
, 97  _
, 107 _
, 96  _
, 105 _
, 103 _
, 101 _
, 102 _
, 100 _
, 109 _
, 89  _
  }

'* Array of CPU ball numbers for emmc2 pin group on header P8.
DIM SHARED AS UInt8 EMMC2_Pins(...) = { _
  6  _
, 7  _
, 2  _
, 3  _
, 33 _
, 32 _
, 5  _
, 4  _
, 1  _
, 0  _
  }

'* Array of CPU ball numbers for hdmi pin group on header P8.
DIM SHARED AS UInt8 HDMI_Pins(...) = { _
  56 _
, 58 _
, 57 _
, 59 _
, 54 _
, 55 _
, 53 _
, 51 _
, 52 _
, 50 _
, 48 _
, 49 _
, 46 _
, 47 _
, 44 _
, 45 _
, 42 _
, 43 _
, 40 _
, 41 _
  }

'* Array of CPU ball numbers for i2c1 pin group on header P9.
DIM SHARED AS UInt8 I2C1_Pins(...) = { _
  87 _
, 86 _
  }

'* Array of CPU ball numbers for i2c2 pin group on header P9.
DIM SHARED AS UInt8 I2C2_Pins(...) = { _
  95 _
, 94 _
  }

'* Array of CPU ball numbers for mcasp0 pin group on header P9.
DIM SHARED AS UInt8 MCASP0_Pins(...) = { _
  107 _
, 103 _
, 101 _
, 100 _
  }
