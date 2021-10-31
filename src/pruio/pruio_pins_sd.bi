/'* \file pruio_pins_sd.bi
\brief Pre-defined macros to handle the SD card slot connectors.

This file contains macros to easy handle the connector pins of
the SD card slot. Instead of searching the CPU ball number
in lists, you can use these macros named after the connectors pin
number (ie pin 3 is named SD_3).

\since 0.6.8
'/

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
