/'* \file P8.bi
\brief Pin settings for P8 header pins.

This files gets included by pruio_config.bas. It declares the pin
settings for all CPU balls connected to the header P8 connectors on
Beaglebone hardware.

'/

' Load convenience macros.
#INCLUDE ONCE "../pruio/pruio_pins.bi"

' pin 01, GND
' pin 02, GND

' ZCZ ball R9 (emmc)
M(P8_03) = CHR( _
    0 + I_O _ ' gpmc_ad6
  , 1 + I_O _ ' mmc1_dat6
  ) & GPIO_DEF

' ZCZ ball T9 (emmc)
M(P8_04) = CHR( _
    0 + I_O _ ' gpmc_ad7
  , 1 + I_O _ ' mmc1_dat7
  ) & GPIO_DEF

' ZCZ ball R8 (emmc)
M(P8_05) = CHR( _
    0 + I_O _ ' gpmc_ad2
  , 1 + I_O _ ' mmc1_dat2
  ) & GPIO_DEF

' ZCZ ball T8 (emmc)
M(P8_06) = CHR( _
    0 + I_O _ ' gpmc_ad3
  , 1 + I_O _ ' mmc1_dat3
  ) & GPIO_DEF

' ZCZ ball R7
M(P8_07) = CHR( _
    0 + _O_ _ ' gpmc_advn_ale
  , 2 + TMRi _ ' timer4_in
  , 2 + TMRo _ ' timer4_pwm_out
  ) & GPIO_DEF

' ZCZ ball T7
M(P8_08) = CHR( _
    0 + _O_ _ ' gpmc_oen_ren
  , 2 + TMRi _ ' timer7_in
  , 2 + TMRo _ ' timer7_pwm_out
  ) & GPIO_DEF

' ZCZ ball T6
M(P8_09) = CHR( _
    0 + _O_ _ ' gpmc_be0n_cle
  , 2 + TMRi _ ' timer5_in
  , 2 + TMRo _ ' timer5_pwm_out
  ) & GPIO_DEF

' ZCZ ball U6
M(P8_10) = CHR( _
    0 + _O_ _ ' gpmc_wen
  , 2 + TMRi _ ' timer6_in
  , 2 + TMRo _ ' timer6_pwm_out
  ) & GPIO_DEF

' ZCZ ball R12
M(P8_11) = CHR( _
    0 + I_O _ ' gpmc_ad13
  , 1 + _O_ _ ' lcd_data18
  , 2 + I_O _ ' mmc1_dat5
  , 3 + I_O _ ' mmc2_dat1
  , 4 + _I_ _ ' eQEP2B_in
  , 5 + _O_ _ ' pr1_mii0_txd1
  , 6 + _O_ _ ' pr1_pru0_pru_r30_15
  ) & GPIO_DEF

' ZCZ ball T12
M(P8_12) = CHR( _
    0 + I_O _ ' gpmc_ad12
  , 1 + _O_ _ ' lcd_data19
  , 2 + I_O _ ' mmc1_dat4
  , 3 + I_O _ ' mmc2_dat0
  , 4 + _I_ _ ' eQEP2A_in
  , 5 + _O_ _ ' pr1_mii0_txd2
  , 6 + _O_ _ ' pr1_pru0_pru_r30_14
  ) & GPIO_DEF

' ZCZ ball T10
M(P8_13) = CHR( _
    0 + I_O _ ' gpmc_ad9
  , 1 + _O_ _ ' lcd_data22
  , 2 + I_O _ ' mmc1_dat1
  , 3 + I_O _ ' mmc2_dat5
  , 4 + _O_ _ ' ehrpwm2B
  , 5 + _I_ _ ' pr1_mii0_col
  ) & GPIO_DEF

' ZCZ ball T11
M(P8_14) = CHR( _
    0 + I_O _ ' gpmc_ad10
  , 1 + _O_ _ ' lcd_data21
  , 2 + I_O _ ' mmc1_dat2
  , 3 + I_O _ ' mmc2_dat6
  , 4 + _I_ _ ' ehrpwm2_tripzone_input
  , 5 + _O_ _ ' pr1_mii0_txen
  ) & GPIO_DEF

' ZCZ ball U13
M(P8_15) = CHR( _
    0 + I_O _ ' gpmc_ad15
  , 1 + _O_ _ ' lcd_data16
  , 2 + I_O _ ' mmc1_dat7
  , 3 + I_O _ ' mmc2_dat3
  , 4 + QEPi _ ' eQEP2_strobe_in
  , 4 + QEPo _ ' eQEP2_strobe_out
  , 5 + CAPi _ ' pr1_ecap0_ecap_capin
  , 5 + CAPo _ ' pr1_ecap0_ecap_apwm_o
  , 6 + _I_ _ ' pr1_pru0_pru_r31_15
  ) & GPIO_DEF

' ZCZ ball V13
M(P8_16) = CHR( _
    0 + I_O _ ' gpmc_ad14
  , 1 + _O_ _ ' lcd_data17
  , 2 + I_O _ ' mmc1_dat6
  , 3 + I_O _ ' mmc2_dat2
  , 4 + QEPi _ ' eQEP2_index_in
  , 4 + QEPo _ ' eQEP2_index_out
  , 5 + _O_ _ ' pr1_mii0_txd0
  , 6 + _I_ _ ' pr1_pru0_pru_r31_14
  ) & GPIO_DEF

' ZCZ ball U12
M(P8_17) = CHR( _
    0 + I_O _ ' gpmc_ad11
  , 1 + _O_ _ ' lcd_data20
  , 2 + I_O _ ' mmc1_dat3
  , 3 + I_O _ ' mmc2_dat7
  , 4 + _O_ _ ' ehrpwm0_synco
  , 5 + _O_ _ ' pr1_mii0_txd3
  ) & GPIO_DEF

' ZCZ ball V12
M(P8_18) = CHR( _
    0 + I_O _ ' gpmc_clk
  , 1 + _O_ _ ' lcd_memory_clk
  , 2 + _I_ _ ' gpmc_wait1
  , 3 + I_O _ ' mmc2_clk
  , 4 + _I_ _ ' pr1_mii1_crs
  , 5 + _O_ _ ' pr1_mdio_mdclk
  , 6 + I_O _ ' mcasp0_fsr
  ) & GPIO_DEF

' ZCZ ball U10
M(P8_19) = CHR( _
    0 + I_O _ ' gpmc_ad8
  , 1 + _O_ _ ' lcd_data23
  , 2 + I_O _ ' mmc1_dat0
  , 3 + I_O _ ' mmc2_dat4
  , 4 + _O_ _ ' ehrpwm2A
  , 5 + _I_ _ ' pr1_mii_mt0_clk
  ) & GPIO_DEF

' ZCZ ball V9 (emmc)
M(P8_20) = CHR( _
    0 + _O_ _ ' gpmc_csn2
  , 1 + _O_ _ ' gpmc_be1n
  , 2 + I_O _ ' mmc1_cmd
  , 3 + _I_ _ ' pr1_edio_data_in7
  , 4 + _O_ _ ' pr1_edio_data_out7
  , 5 + _O_ _ ' pr1_pru1_pru_r30_13
  , 6 + _I_ _ ' pr1_pru1_pru_r31_13
  ) & GPIO_DEF

' ZCZ ball U9 (emmc)
M(P8_21) = CHR( _
    0 + _O_ _ ' gpmc_csn1
  , 1 + I_O _ ' gpmc_clk
  , 2 + I_O _ ' mmc1_clk
  , 3 + _I_ _ ' pr1_edio_data_in6
  , 4 + _O_ _ ' pr1_edio_data_out6
  , 5 + _O_ _ ' pr1_pru1_pru_r30_12
  , 6 + _I_ _ ' pr1_pru1_pru_r31_12
  ) & GPIO_DEF

' ZCZ ball V8 (emmc)
M(P8_22) = CHR( _
    0 + I_O _ ' gpmc_ad5
  , 1 + I_O _ ' mmc1_dat5
  ) & GPIO_DEF

' ZCZ ball U8 (emmc)
M(P8_23) = CHR( _
    0 + I_O _ ' gpmc_ad4
  , 1 + I_O _ ' mmc1_dat4
  ) & GPIO_DEF

' ZCZ ball V7 (emmc)
M(P8_24) = CHR( _
    0 + I_O _ ' gpmc_ad1
  , 1 + I_O _ ' mmc1_dat1
  ) & GPIO_DEF

' ZCZ ball U7 (emmc)
M(P8_25) = CHR( _
    0 + I_O _ ' gpmc_ad0
  , 1 + I_O _ ' mmc1_dat0
  ) & GPIO_DEF

' ZCZ ball V6
M(P8_26) = CHR( _
    0 + _O_ _ ' gpmc_csn0
  ) & GPIO_DEF

' ZCZ ball U5 (hdmi)
M(P8_27) = CHR( _
    0 + _O_ _ ' lcd_vsync
  , 1 + _O_ _ ' gpmc_a8
  , 2 + _O_ _ ' gpmc_a1
  , 3 + _I_ _ ' pr1_edio_data_in2
  , 4 + _O_ _ ' pr1_edio_data_out2
  , 5 + _O_ _ ' pr1_pru1_pru_r30_8
  , 6 + _I_ _ ' pr1_pru1_pru_r31_8
  ) & GPIO_DEF

' ZCZ ball V5 (hdmi)
M(P8_28) = CHR( _
    0 + _O_ _ ' lcd_pclk
  , 1 + _O_ _ ' gpmc_a10
  , 2 + _I_ _ ' pr1_mii0_crs
  , 3 + _I_ _ ' pr1_edio_data_in4
  , 4 + _O_ _ ' pr1_edio_data_out4
  , 5 + _O_ _ ' pr1_pru1_pru_r30_10
  , 6 + _I_ _ ' pr1_pru1_pru_r31_10
  ) & GPIO_DEF

' ZCZ ball R5
M(P8_29) = CHR( _
    0 + _O_ _ ' lcd_hsync
  , 1 + _O_ _ ' gpmc_a9
  , 2 + _O_ _ ' gpmc_a2
  , 3 + _I_ _ ' pr1_edio_data_in3
  , 4 + _O_ _ ' pr1_edio_data_out3
  , 5 + _O_ _ ' pr1_pru1_pru_r30_9
  , 6 + _I_ _ ' pr1_pru1_pru_r31_9
  ) & GPIO_DEF

' ZCZ ball R6 (hdmi)
M(P8_30) = CHR( _
    0 + _O_ _ ' lcd_ac_bias_en
  , 1 + _O_ _ ' gpmc_a11
  , 2 + _I_ _ ' pr1_mii1_crs
  , 3 + _I_ _ ' pr1_edio_data_in5
  , 4 + _O_ _ ' pr1_edio_data_out5
  , 5 + _O_ _ ' pr1_pru1_pru_r30_11
  , 6 + _I_ _ ' pr1_pru1_pru_r30_11
  ) & GPIO_DEF

' ZCZ ball V4 (hdmi)
M(P8_31) = CHR( _
    0 + I_O _ ' lcd_data14
  , 1 + _O_ _ ' gpmc_a18
  , 2 + QEPi _ ' eQEP1_index_in
  , 2 + QEPo _ ' eQEP1_index_out
  , 3 + I_O _ ' mcasp0_axr1
  , 4 + _I_ _ ' uart5_rxd
  , 5 + _I_ _ ' pr1_mii_mr0_clk
  , 6 + _I_ _ ' uart5_ctsn
  ) & GPIO_DEF

' ZCZ ball T5 (hdmi)
M(P8_32) = CHR( _
    0 + I_O _ ' lcd_data15
  , 1 + _O_ _ ' gpmc_a19
  , 2 + QEPi _ ' eQEP1_strobe_in
  , 2 + QEPo _ ' eQEP1_strobe_out
  , 3 + I_O _ ' mcasp0_ahclkx
  , 4 + I_O _ ' mcasp0_axr3
  , 5 + _I_ _ ' pr1_mii0_rxdv
  , 6 + _O_ _ ' uart5_rtsn
  ) & GPIO_DEF

' ZCZ ball V3 (hdmi)
M(P8_33) = CHR( _
    0 + I_O _ ' lcd_data13
  , 1 + _O_ _ ' gpmc_a17
  , 2 + _I_ _ ' eQEP1B_in
  , 3 + I_O _ ' mcasp0_fsr
  , 4 + I_O _ ' mcasp0_axr3
  , 5 + _I_ _ ' pr1_mii0_rxer
  , 6 + _O_ _ ' uart4_rtsn
  ) & GPIO_DEF

' ZCZ ball U4 (hdmi)
M(P8_34) = CHR( _
    0 + I_O _ ' lcd_data11
  , 1 + _O_ _ ' gpmc_a15
  , 2 + _O_ _ ' ehrpwm1B
  , 3 + I_O _ ' mcasp0_ahclkr
  , 4 + I_O _ ' mcasp0_axr2
  , 5 + _I_ _ ' pr1_mii0_rxd0
  , 6 + _O_ _ ' uart3_rtsn
  ) & GPIO_DEF

' ZCZ ball V2 (hdmi)
M(P8_35) = CHR( _
    0 + I_O _ ' lcd_data12
  , 1 + _O_ _ ' gpmc_a16
  , 2 + _I_ _ ' eQEP1A_in
  , 3 + I_O _ ' mcasp0_aclkr
  , 4 + I_O _ ' mcasp0_axr2
  , 5 + _I_ _ ' pr1_mii0_rxlink
  , 6 + _I_ _ ' uart4_ctsn
  ) & GPIO_DEF

' ZCZ ball U3 (hdmi)
M(P8_36) = CHR( _
    0 + I_O _ ' lcd_data10
  , 1 + _O_ _ ' gpmc_a14
  , 2 + _O_ _ ' ehrpwm1A
  , 3 + I_O _ ' mcasp0_axr0
  , 5 + _I_ _ ' pr1_mii0_rxd1
  , 6 + _I_ _ ' uart3_ctsn
  ) & GPIO_DEF

' ZCZ ball U1 (hdmi)
M(P8_37) = CHR( _
    0 + I_O _ ' lcd_data8
  , 1 + _O_ _ ' gpmc_a12
  , 2 + _I_ _ ' ehrpwm1_tripzone_input
  , 3 + I_O _ ' mcasp0_aclkx
  , 4 + _O_ _ ' uart5_txd
  , 5 + _I_ _ ' pr1_mii0_rxd3
  , 6 + _I_ _ ' uart2_ctsn
  ) & GPIO_DEF

' ZCZ ball U2 (hdmi)
M(P8_38) = CHR( _
    0 + I_O _ ' lcd_data9
  , 1 + _O_ _ ' gpmc_a13
  , 2 + _O_ _ ' ehrpwm0_synco
  , 3 + I_O _ ' mcasp0_fsx
  , 4 + _I_ _ ' uart5_rxd
  , 5 + _I_ _ ' pr1_mii0_rxd2
  , 6 + _O_ _ ' uart2_rtsn
  ) & GPIO_DEF

' ZCZ ball T3 (hdmi)
M(P8_39) = CHR( _
    0 + I_O _ ' lcd_data6
  , 1 + _O_ _ ' gpmc_a6
  , 2 + _I_ _ ' pr1_edio_data_in6
  , 3 + QEPi _ ' eQEP2_index_in
  , 3 + QEPo _ ' eQEP2_index_out
  , 4 + _O_ _ ' pr1_edio_data_out6
  , 5 + _O_ _ ' pr1_pru1_pru_r30_6
  , 6 + _I_ _ ' pr1_pru1_pru_r31_6
  ) & GPIO_DEF

' ZCZ ball T4 (hdmi)
M(P8_40) = CHR( _
    0 + I_O _ ' lcd_data7
  , 1 + _O_ _ ' gpmc_a7
  , 2 + _I_ _ ' pr1_edio_data_in7
  , 3 + QEPi _ ' eQEP2_strobe_in
  , 3 + QEPo _ ' eQEP2_strobe_out
  , 4 + _O_ _ ' pr1_edio_data_out7
  , 5 + _O_ _ ' pr1_pru1_pru_r30_7
  , 6 + _I_ _ ' pr1_pru1_pru_r31_7
  ) & GPIO_DEF

' ZCZ ball T1 (hdmi)
M(P8_41) = CHR( _
    0 + I_O _ ' lcd_data4
  , 1 + _O_ _ ' gpmc_a4
  , 2 + _O_ _ ' pr1_mii0_txd1
  , 3 + _I_ _ ' eQEP2A_in
  , 5 + _O_ _ ' pr1_pru1_pru_r30_4
  , 6 + _I_ _ ' pr1_pru1_pru_r31_4
  ) & GPIO_DEF

' ZCZ ball T2 (hdmi)
M(P8_42) = CHR( _
    0 + I_O _ ' lcd_data5
  , 1 + _O_ _ ' gpmc_a5
  , 2 + _O_ _ ' pr1_mii0_txd0
  , 3 + _I_ _ ' eQEP2B_in
  , 5 + _O_ _ ' pr1_pru1_pru_r30_5
  , 6 + _I_ _ ' pr1_pru1_pru_r31_5
  ) & GPIO_DEF

' ZCZ ball R3 (hdmi)
M(P8_43) = CHR( _
    0 + I_O _ ' lcd_data2
  , 1 + _O_ _ ' gpmc_a2
  , 2 + _O_ _ ' pr1_mii0_txd3
  , 3 + _I_ _ ' ehrpwm2_tripzone_input
  , 5 + _O_ _ ' pr1_pru1_pru_r30_2
  , 6 + _I_ _ ' pr1_pru1_pru_r31_2
  ) & GPIO_DEF

' ZCZ ball R4 (hdmi)
M(P8_44) = CHR( _
    0 + I_O _ ' lcd_data3
  , 1 + _O_ _ ' gpmc_a3
  , 2 + _O_ _ ' pr1_mii0_txd2
  , 3 + _O_ _ ' ehrpwm0_synco
  , 5 + _O_ _ ' pr1_pru1_pru_r30_3
  , 6 + _I_ _ ' pr1_pru1_pru_r31_3
  ) & GPIO_DEF

' ZCZ ball R1 (hdmi)
M(P8_45) = CHR( _
    0 + I_O _ ' lcd_data0
  , 1 + _O_ _ ' gpmc_a0
  , 2 + _I_ _ ' pr1_mii_mt0_clk
  , 3 + _O_ _ ' ehrpwm2A
  , 5 + _O_ _ ' pr1_pru1_pru_r30_0
  , 6 + _I_ _ ' pr1_pru1_pru_r31_0
  ) & GPIO_DEF

' ZCZ ball R2 (hdmi)
M(P8_46) = CHR( _
    0 + I_O _ ' lcd_data1
  , 1 + _O_ _ ' gpmc_a1
  , 2 + _O_ _ ' pr1_mii0_txen
  , 3 + _O_ _ ' ehrpwm2B
  , 5 + _O_ _ ' pr1_pru1_pru_r30_1
  , 6 + _I_ _ ' pr1_pru1_pru_r31_1
  ) & GPIO_DEF

