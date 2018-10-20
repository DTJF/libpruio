/'* \file pin_arrays.bi
\brief Pin groups for BB boards

The file contains pre-defined arrays for the pin groups of the
beaglebone black hardware. The arrays include all CPU ball numbers that
belong to a subsystem like the EMMC2 or HDMI and can be used to adress
all related pins as one group.

File src/pruio/pruio_pins.bi contained that data before it was moved to
that separate file in version 0.6.4.

\since 0.6.4
'/

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
, 106 _
, P9_42 _
, 104 _
  }

'* Array of CPU ball numbers for all digital pins on header P9.
DIM SHARED AS UInt8 JT_Pins(...) = { _
  JT_04 _
, JT_05 _
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
