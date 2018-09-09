/'* \file SDslot.bi
\brief Pin settings for SD slot pins.

This files gets included by dts_universal.bas. It declares the pin
settings for all CPU balls connected to the SD slot connector on
Beaglebone hardware.

Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)

Copyright 2014-\Year by \Mail

\since 0.6
'/

' Load convenience macros.
#INCLUDE ONCE "../pruio/pruio_pins.bi"

' ZCZ ball F18 (MMC0_DAT2)
M(SD_01) = CHR( _
    0 + I_O _ ' mmc0_dat2
  , 1 + I_O _ ' gpmc_a21
  , 2 + _O_ _ ' uart4_rtsn
  , 3 + I_O _ ' timer6
  , 4 + _I_ _ ' uart1_dsrn
  , 5 + _O_ _ ' pr1_pru0_pru_r30_9
  , 6 + _I_ _ ' pr1_pru0_pru_r31_9
  ) & GPIO_DEF

' ZCZ ball F17 (MMC0_DAT3)
M(SD_02) = CHR( _
    0 + I_O _ ' mmc0_dat3
  , 1 + I_O _ ' gpmc_a20
  , 2 + _I_ _ ' uart4_ctsn
  , 3 + I_O _ ' timer5
  , 4 + _I_ _ ' uart1_dcdn
  , 5 + _O_ _ ' pr1_pru0_pru_r30_8
  , 6 + _I_ _ ' pr1_pru0_pru_r31_8
  ) & GPIO_DEF

' ZCZ ball G18 (MMC0_CMD)
M(SD_03) = CHR( _
    0 + I_O _ ' mmc0_cmd
  , 1 + I_O _ ' gpmc_a25
  , 2 + _O_ _ ' uart3_rtsn
  , 3 + _O_ _ ' uart2_txd
  , 4 + _I_ _ ' dcan1_rx
  , 5 + _O_ _ ' pr1_pru0_pru_r30_13
  , 6 + _I_ _ ' pr1_pru0_pru_r31_13
  ) & GPIO_DEF

' pin 4, -

' ZCZ ball G17 (MMC0_CLK)
M(SD_05) = CHR( _
    0 + I_O _ ' mmc0_clk
  , 1 + I_O _ ' gpmc_a24
  , 2 + _I_ _ ' uart3_ctsn
  , 3 + _I_ _ ' uart2_rxd
  , 4 + _O_ _ ' dcan1_tx
  , 5 + _O_ _ ' pr1_pru0_pru_r30_12
  , 6 + _I_ _ ' pr1_pru0_pru_r31_12
  ) & GPIO_DEF

' pin 6, -

' ZCZ ball G16 (MMC0_DAT0)
M(SD_07) = CHR( _
    0 + I_O _ ' mmc0_dat0
  , 1 + I_O _ ' gpmc_a23
  , 2 + _O_ _ ' uart5_rtsn
  , 3 + _O_ _ ' uart3_txd
  , 4 + _I_ _ ' uart1_rin
  , 5 + _O_ _ ' pr1_pru0_pru_r30_11
  , 6 + _I_ _ ' pr1_pru0_pru_r31_11
  ) & GPIO_DEF

' ZCZ ball G15 (MMC0_DAT1)
M(SD_08) = CHR( _
    0 + I_O _ ' mmc0_dat1
  , 1 + I_O _ ' gpmc_a22
  , 2 + _I_ _ ' uart5_ctsn
  , 3 + _I_ _ ' uart3_rxd
  , 4 + _O_ _ ' uart1_dtrn
  , 5 + _O_ _ ' pr1_pru0_pru_r30_10
  , 6 + _I_ _ ' pr1_pru0_pru_r31_10
  ) & GPIO_DEF


' pin 9, -

' ZCZ ball C15 (SPI0_CS1)
M(SD_10) = CHR( _
    0 + I_O _ ' spi0_cs1
  , 1 + _I_ _ ' uart3_rxd
  , 2 + CAPo _ ' eCAP1_in_PWM1_out
  , 3 + _O_ _ ' mmc0_pow
  , 4 + _I_ _ ' xdma_event_intr2
  , 5 + _I_ _ ' mmc0_sdcd
  , 6 + I_O _ ' EMU4
  ) & GPIO_DEF

