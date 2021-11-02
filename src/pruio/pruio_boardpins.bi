/'* \file pruio_boardpins.bi
\brief Pin lists for board types

This header file contains pin lists for the differend board designs. The
lists are used in function find_claims() to distinguish between
external header pins and internal CPU balls.

\since 0.6.4
'/

#INCLUDE ONCE "pruio_pins_sd.bi"

#INCLUDE ONCE "pruio_pins_pocket.bi"

'* List of header pins on Pocket BeagleBone boards
#DEFINE HEADERPINS_POCKET _
   CHR(P1_02, P1_04, P1_06, P1_08, P1_10, P1_12, P1_20) _
 & CHR(P1_26, P1_28, P1_29, P1_30, P1_31, P1_32, P1_33, P1_34, P1_35, P1_36) _
 & CHR(P2_01, P2_02, P2_03, P2_04, P2_05, P2_06, P2_07, P2_08, P2_09, P2_10, P2_11) _
 & CHR(P2_17, P2_18, P2_19, P2_20, P2_22, P2_24, P2_25) _
 & CHR(P2_27, P2_28, P2_29, P2_30, P2_31, P2_32, P2_33, P2_34, P2_35) _
 & CHR(SD_01, SD_02, SD_03, SD_05, SD_07, SD_08, SD_10)

#INCLUDE ONCE "pruio_pins_blue.bi"

'* List of header pins on BeagleBone Blue boards
#DEFINE HEADERPINS_BLUE _
   CHR(E1_3, E1_4, E2_3, E2_4, E3_3, E3_4, E4_3, E4_4) _
 & CHR(UT0_3, UT0_4, UT1_3, UT1_4, UT5_3, UT5_4, DSM2_3) _
 & CHR(GP0_3, GP0_4, GP0_5, GP0_6, GP1_3, GP1_4, GP1_5, GP1_6, GPS_3, GPS_4) _
 & CHR(SPI1_3, SPI1_4, SPI1_5, SPI1_6, SPI2_6) _
 & CHR(SD_01, SD_02, SD_03, SD_05, SD_07, SD_08, SD_10)

#INCLUDE ONCE "pruio_pins.bi"

'* List of header pins on BeagleBone boards (White, Green, Black)
#DEFINE HEADERPINS_BB _
   CHR(P8_03, P8_04, P8_05, P8_06, P8_07, P8_08, P8_09, P8_10, P8_11, P8_12) _
 & CHR(P8_13, P8_14, P8_15, P8_16, P8_17, P8_18, P8_19, P8_20, P8_21, P8_22) _
 & CHR(P8_23, P8_24, P8_25, P8_26, P8_27, P8_28, P8_29, P8_30, P8_31, P8_32) _
 & CHR(P8_33, P8_34, P8_35, P8_36, P8_37, P8_38, P8_39, P8_40, P8_41, P8_42) _
 & CHR(P8_43, P8_44, P8_45, P8_46) _
 & CHR(P9_11, P9_12, P9_13, P9_14, P9_15, P9_16, P9_17, P9_18, P9_19, P9_20) _
 & CHR(P9_21, P9_22, P9_23, P9_24, P9_25, P9_26, P9_27, P9_28, P9_29, P9_30) _
 & CHR(P9_31, P9_41, 106, P9_42, 104) _
 & CHR(SD_01, SD_02, SD_03, SD_05, SD_07, SD_08, SD_10, JT_04, JT_05)

