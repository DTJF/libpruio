/'* \file JTag.bi
\brief Pin settings for JTag header pins.

This files gets included by dts_universal.bas. It declares the pin
settings for all CPU balls connected to the JTag header connectors on
Beaglebone hardware.

Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)

Copyright 2014-\Year by \Mail

\since 0.4
'/

' Load convenience macros.
#INCLUDE ONCE "../pruio/pruio_pins.bi"

' pin 1, DGND
' pin 2, -
' pin 3, -

' ZCZ ball E15 (RXD 5V)
M(JT_04) = CHR( _
    0 + _I_ _ ' uart0_rxd
  , 1 + I_O _ ' spi1_cs0
  , 2 + _O_ _ ' dcan0_tx
  , 3 + IOD _ ' I2C2_SDA
  , 4 + CAPi _ ' eCAP2_in_PWM2_out
  , 5 + _O_ _ ' pr1_pru1_pru_r30_14
  , 6 + _I_ _ ' pr1_pru1_pru_r31_14
  ) & GPIO_DEF

' ZCZ ball E16 (TXD 5V)
M(JT_05) = CHR( _
    0 + _O_ _ ' uart0_txd
  , 1 + I_O _ ' spi1_cs1
  , 2 + _I_ _ ' dcan0_rx
  , 3 + IOD _ ' I2C2_SCL
  , 4 + CAPo _ ' eCAP1_in_PWM1_out
  , 5 + _O_ _ ' pr1_pru1_pru_r30_15
  , 6 + _I_ _ ' pr1_pru1_pru_r31_15
  ) & GPIO_DEF

' pin 6, -
