/'* \file P9.bi
\brief Pin settings for P9 header pins.

This files gets included by pruio_config.bas. It declares the pin
settings for all CPU balls connected to the header P9 connectors on
Beaglebone hardware.

'/

' Load convenience macros.
#INCLUDE ONCE "../pruio/pruio_pins.bi"

' pin 1, GND
' pin 2, GND
' pin 3, 3V3
' pin 4, 3V3
' pin 5, VDD 5V
' pin 6, VDD 5V
' pin 7, SYS 5V
' pin 8, SYS 5V
' pin 9, PWR BUT
' pin 10, ZCZ ball A10 RESETn

' ZCZ ball T17
M(P9_11) = CHR( _
    0 + _I_ _ ' gpmc_wait0
  , 1 + _I_ _ ' gmii2_crs
  , 2 + _O_ _ ' gpmc_csn4
  , 3 + _I_ _ ' rmii2_crs_dv
  , 4 + _I_ _ ' mmc1_sdcd
  , 5 + _I_ _ ' pr1_mii_col
  , 6 + _I_ _ ' uart4_rxd
  ) & GPIO_DEF

' ZCZ ball U18
M(P9_12) = CHR( _
    0 + _O_ _ ' gpmc_be1n
  , 1 + _I_ _ ' gmii2_col
  , 2 + _O_ _ ' gpmc_csn6
  , 3 + I_O _ ' mmc2_dat3
  , 4 + _O_ _ ' gpmc_dir
  , 5 + _I_ _ ' pr1_mii_rxlink
  , 6 + I_O _ ' mcasp0_aclkr
  ) & GPIO_DEF

' ZCZ ball U17
M(P9_13) = CHR( _
    0 + _O_ _ ' gpmc_wpn
  , 1 + _I_ _ ' gmii2_rxerr
  , 2 + _O_ _ ' gpmc_csn5
  , 3 + _I_ _ ' rmii2_rxerr
  , 4 + _I_ _ ' mmc2_sdcd
  , 5 + _O_ _ ' pr1_mii1_txen
  , 6 + _O_ _ ' uart4_txd
  ) & GPIO_DEF

' ZCZ ball U14
M(P9_14) = CHR( _
    0 + _O_ _ ' gpmc_a2
  , 1 + _O_ _ ' gmii2_txd3
  , 2 + _O_ _ ' rgmii2_td3
  , 3 + I_O _ ' mmc2_dat1
  , 4 + _O_ _ ' gpmc_a18
  , 5 + _O_ _ ' pr1_mii1_txd2
  , 6 + _O_ _ ' ehrpwm1A
  ) & GPIO_DEF

' ZCZ ball R13
M(P9_15) = CHR( _
    0 + _O_ _ ' gpmc_a0
  , 1 + _O_ _ ' gmii2_txen
  , 2 + _O_ _ ' rgmii2_tctl
  , 3 + _O_ _ ' rmii2_txen
  , 4 + _O_ _ ' gpmc_a16
  , 5 + _I_ _ ' pr1_mii_mt1_clk
  , 6 + _I_ _ ' ehrpwm1_tripzone_input
  ) & GPIO_DEF

' ZCZ ball T14
M(P9_16) = CHR( _
    0 + _O_ _ ' gpmc_a3
  , 1 + _O_ _ ' gmii2_txd2
  , 2 + _O_ _ ' rgmii2_td2
  , 3 + I_O _ ' mmc2_dat2
  , 4 + _O_ _ ' gpmc_a19
  , 5 + _O_ _ ' pr1_mii1_txd1
  , 6 + _O_ _ ' ehrpwm1B
  ) & GPIO_DEF

' ZCZ ball A16
M(P9_17) = CHR( _
    0 + I_O _ ' spi0_cs0
  , 1 + _I_ _ ' mmc2_sdwp
  , 2 + IOD _ ' I2C1_SCL
  , 3 + _I_ _ ' ehrpwm0_synci
  , 4 + _O_ _ ' pr1_uart0_txd
  , 5 + _I_ _ ' pr1_edio_data_in1
  , 6 + _O_ _ ' pr1_edio_data_out1
  ) & GPIO_DEF

' ZCZ ball B16
M(P9_18) = CHR( _
    0 + I_O  _ ' spi0_d1
  , 1 + _I_ _ ' mmc1_sdwp
  , 2 + IOD  _ ' I2C1_SDA
  , 3 + _I_ _ ' ehrpwm0_tripzone_input
  , 4 + _I_ _ ' pr1_uart0_rxd
  , 5 + _I_ _ ' pr1_edio_data_in0
  , 6 + _O_ _ ' pr1_edio_data_out0
  ) & GPIO_DEF

' ZCZ ball D17 (i2c)
M(P9_19) = CHR( _
    0 + _O_ _ ' uart1_rtsn
  , 1 + TMRi _ ' timer5_in
  , 1 + TMRo _ ' timer5_pwm_out
  , 2 + _I_ _ ' dcan0_rx
  , 3 + IOD _ ' I2C2_SCL
  , 4 + I_O _ ' spi1_cs1
  , 5 + _O_ _ ' pr1_uart0_rts_n
  , 6 + _I_ _ ' pr1_edc_latch_in
  ) & GPIO_DEF

' ZCZ ball D18 (i2c)
M(P9_20) = CHR( _
    0 + _I_ _ ' uart1_ctsn
  , 1 + TMRi _ ' timer6_in
  , 1 + TMRo _ ' timer6pwm_out
  , 2 + _O_ _ ' dcan0_tx
  , 3 + IOD _ ' I2C2_SDA
  , 4 + I_O _ ' spi1_cs0
  , 5 + _I_ _ ' pr1_uart0_cts_n
  , 6 + _I_ _ ' pr1_edc_latch0_in
  ) & GPIO_DEF

' ZCZ ball B17
M(P9_21) = CHR( _
    0 + I_O _ ' spi0_d0
  , 1 + _O_ _ ' uart2_txd
  , 2 + IOD _ ' I2C2_SCL
  , 3 + _O_ _ ' ehrpwm0B
  , 4 + _O_ _ ' pr1_uart0_rts_n
  , 5 + _I_ _ ' pr1_edio_latch_in
  , 6 + I_O _ ' EMU3
  ) & GPIO_DEF

' ZCZ ball A17
M(P9_22) = CHR( _
    0 + I_O _ ' spi0_sclk
  , 1 + _I_ _ ' uart2_rxd
  , 2 + IOD _ ' I2C2_SDA
  , 3 + _O_ _ ' ehrpwm0A
  , 4 + _I_ _ ' pr1_uart0_cts_n
  , 5 + _O_ _ ' pr1_edio_sof
  , 6 + I_O _ ' EMU2
  ) & GPIO_DEF

' ZCZ ball V14
M(P9_23) = CHR( _
    0 + _O_ _ ' gpmc_a1
  , 1 + _I_ _ ' gmii2_rxdv
  , 2 + _I_ _ ' rgmii2_rctl
  , 3 + I_O _ ' mmc2_dat0
  , 4 + _O_ _ ' gpmc_a17
  , 5 + _O_ _ ' pr1_mii1_txd3
  , 6 + _O_ _ ' ehrpwm0_synco
  ) & GPIO_DEF

' ZCZ ball d15
M(P9_24) = CHR( _
    0 + _O_ _ ' uart1_txd
  , 1 + _I_ _ ' mmc2_sdwp
  , 2 + _I_ _ ' dcan1_rx
  , 3 + IOD _ ' I2C1_SCL
  , 5 + _O_ _ ' pr1_uart0_txd
  , 6 + _I_ _ ' pr1_pru0_pru_r31_16
  ) & GPIO_DEF

' ZCZ ball a14 (AUDIO)
M(P9_25) = CHR( _
    0 + I_O _ ' mcasp0_ahclkx
  , 1 + QEPi _ ' eQEP0_strobe_in
  , 1 + QEPo _ ' eQEP0_strobe_out
  , 2 + I_O _ ' mcasp0_axr3
  , 3 + I_O _ ' mcasp1_axr1
  , 4 + I_O _ ' EMU4
  , 5 + _O_ _ ' pr1_pru0_pru_r30_7
  , 6 + _I_ _ ' pr1_pru0_pru_r31_7
  ) & GPIO_DEF

' ZCZ ball D16
M(P9_26) = CHR( _
    0 + _I_ _ ' uart1_rxd
  , 1 + _I_ _ ' mmc1_sdwp
  , 2 + _O_ _ ' dcan1_tx
  , 3 + IOD _ ' I2C1_SDA
  , 5 + _I_ _ ' pr1_uart0_rxd
  , 6 + _I_ _ ' pr1_pru1_pru_r31_16
  ) & GPIO_DEF

' ZCZ ball C13
M(P9_27) = CHR( _
    0 + I_O _ ' mcasp0_fsr
  , 1 + _I_ _ ' eQEP0B_in
  , 2 + I_O _ ' mcasp0_axr3
  , 3 + I_O _ ' mcasp1_fsx
  , 4 + I_O _ ' EMU2
  , 5 + _O_ _ ' pr1_pru0_pru_r30_5
  , 6 + _I_ _ ' pr1_pru0_pru_r31_5
  ) & GPIO_DEF

' ZCZ ball C12
M(P9_28) = CHR( _
    0 + I_O _ ' mcasp0_ahclkr
  , 1 + _I_ _ ' ehrpwm0_synci
  , 2 + I_O _ ' mcasp0_axr2
  , 3 + I_O _ ' spi1_cs0
  , 4 + CAPo _ ' eCAP2_PWM2_out
  , 4 + CAPi _ ' eCAP2_in
  , 5 + _O_ _ ' pr1_pru0_pru_r30_3
  , 6 + _I_ _ ' pr1_pru0_pru_r31_3
  ) & GPIO_DEF

' ZCZ ball B13 (audio)
M(P9_29) = CHR( _
    0 + I_O _ ' mcasp0_fsx
  , 1 + _O_ _ ' ehrpwm0B
  , 3 + I_O _ ' spi1_d0
  , 4 + _I_ _ ' mmc1_sdcd
  , 5 + _O_ _ ' pr1_pru0_pru_r30_1
  , 6 + _I_ _ ' pr1_pru0_pru_r31_1
  ) & GPIO_DEF

' ZCZ ball D12
M(P9_30) = CHR( _
    0 + I_O _ ' mcasp0_axr0
  , 1 + _I_ _ ' ehrpwm0_tripzone_input
  , 3 + I_O _ ' spi1_d1
  , 4 + _I_ _ ' mmc2_sdcd
  , 5 + _O_ _ ' pr1_pru0_pru_r30_2
  , 6 + _I_ _ ' pr1_pru0_pru_r31_2
  ) & GPIO_DEF

' ZCZ ball A13 (audio)
M(P9_31) = CHR( _
    0 + I_O _ ' mcasp0_aclkx
  , 1 + _O_ _ ' ehrpwm0A
  , 3 + I_O _ ' spi1_sclk
  , 4 + _I_ _ ' mmc0_sdcd
  , 5 + _O_ _ ' pr1_pru0_pru_r30_0
  , 6 + _I_ _ ' pr1_pru0_pru_r31_0
  ) & GPIO_DEF

 'pin 32, (ADC VAC)
 'pin 33, ZCZ ball C8 (ADC AIN-4)
 'pin 34, (ADC AGND)
 'pin 35, ZCZ ball A8 (ADC AIN-6)
 'pin 36, ZCZ ball B8 (ADC AIN-5)
 'pin 37, ZCZ ball B7 (ADC AIN-2)
 'pin 38, ZCZ ball A7 (ADC AIN-3)
 'pin 39, ZCZ ball B6 (ADC AIN-0)
 'pin 40, ZCZ ball C7 (ADC AIN-1)

' ZCZ ball D14 (mcasp)
M(P9_41) = CHR( _
    0 + _I_ _ ' xdma_event_intr1
  , 2 + _I_ _ ' tclkin
  , 3 + _O_ _ ' clkout2
  , 4 + TMRi _ ' timer7_in
  , 4 + TMRo _ ' timer7_pwm_out
  , 5 + _I_ _ ' pr1_pru0_pru_r31_16
  , 6 + I_O _ ' EMU3
  ) & GPIO_DEF

' ZCZ ball C18
M(P9_42) = CHR( _
    0 + CAPo _ ' eCAP0_PWM0_out
  , 0 + CAPi _ ' eCAP0_in
  , 1 + _O_ _ ' uart3_txd
  , 2 + I_O _ ' spi1_cs1
  , 3 + CAPi _ ' pr1_ecap0_ecap_capin
  , 3 + CAPo _ ' pr1_ecap0_ecap_apwm_o
  , 4 + I_O _ ' spi1_sclk
  , 5 + _I_ _ ' mmc0_sdwp
  , 6 + _I_ _ ' xdma_event_intr2
  ) & GPIO_DEF

' pin 41, ZCZ ball D13 (mcasp)
M(106) = CHR( _
    0 + I_O _ ' mcasp0_axr1
  , 1 + QEPi _ ' eQEP0_index_in
  , 1 + QEPo _ ' eQEP0_index_out
  , 3 + I_O _ ' mcasp1_axr0
  , 4 + I_O _ ' EMU3
  , 5 + _O_ _ ' pr1_pru0_pru_r30_6
  , 6 + _I_ _ ' pr1_pru0_pru_r31_6
  ) & GPIO_DEF

' pin 42, ZCZ ball B12
M(104) = CHR( _
    0 + I_O _ ' mcasp0_aclkr
  , 1 + _I_ _ ' eQEP0A_in
  , 2 + I_O _ ' mcasp0_axr2
  , 3 + I_O _ ' mcasp1_aclkx
  , 4 + _I_ _ ' mmc0_sdwp
  , 5 + _O_ _ ' pr1_pru0_pru_r30_4
  , 6 + _I_ _ ' pr1_pru0_pru_r31_4
  ) & GPIO_DEF

 'pin 43, GND
 'pin 44, GND
 'pin 45, GND
 'pin 46, GND
