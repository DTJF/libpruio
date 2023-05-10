/'* \file pruio_intc.bi
\brief FreeBASIC header file for interrupt controller defines.

Header file containing the defines and data types used for the
interrupt controller setting.

\since 0.6
'/


'* System event PRU-0 -> PRU-1
#DEFINE PRU0_PRU1_INTERRUPT 17
'* System event PRU-1 -> PRU-0
#DEFINE PRU1_PRU0_INTERRUPT 18
'* System event PRU-0 -> ARM
#DEFINE PRU0_ARM_INTERRUPT 19
'* System event PRU-1 -> ARM
#DEFINE PRU1_ARM_INTERRUPT 20
'* System event ARM -> PRU  (R31.t30)
#DEFINE ARM_PRU0_INTERRUPT 21
'* System event ARM -> PRU  (R31.t31)
#DEFINE ARM_PRU1_INTERRUPT 22

'* ID for channel 0
#DEFINE CHANNEL0 0
'* ID for channel 1
#DEFINE CHANNEL1 1
'* ID for channel 2
#DEFINE CHANNEL2 2
'* ID for channel 3
#DEFINE CHANNEL3 3
'* ID for channel 4
#DEFINE CHANNEL4 4
'* ID for channel 5
#DEFINE CHANNEL5 5
'* ID for channel 6
#DEFINE CHANNEL6 6
'* ID for channel 7
#DEFINE CHANNEL7 7
'* ID for channel 8
#DEFINE CHANNEL8 8
'* ID for channel 9
#DEFINE CHANNEL9 9
'* ID for PRU-0
#DEFINE PRU0 0
'* ID for PRU-1
#DEFINE PRU1 1
'* ID for event 0
#DEFINE PRU_EVTOUT0 2
'* ID for event 1
#DEFINE PRU_EVTOUT1 3
'* ID for event 2
#DEFINE PRU_EVTOUT2 4
'* ID for event 3
#DEFINE PRU_EVTOUT3 5
'* ID for event 4
#DEFINE PRU_EVTOUT4 6
'* ID for event 5
#DEFINE PRU_EVTOUT5 7
'* ID for event 6
#DEFINE PRU_EVTOUT6 8
'* ID for event 7
#DEFINE PRU_EVTOUT7 9
'* Interrupt host enable mask for PRU-0
#DEFINE PRU0_HOSTEN_MASK &h0001
'* Interrupt host enable mask for PRU-1
#DEFINE PRU1_HOSTEN_MASK &h0002
'* Event 0 host enable mask
#DEFINE PRU_EVTOUT0_HOSTEN_MASK &h0004
'* Event 1 host enable mask
#DEFINE PRU_EVTOUT1_HOSTEN_MASK &h0008
'* Event 2 host enable mask
#DEFINE PRU_EVTOUT2_HOSTEN_MASK &h0010
'* Event 3 host enable mask
#DEFINE PRU_EVTOUT3_HOSTEN_MASK &h0020
'* Event 4 host enable mask
#DEFINE PRU_EVTOUT4_HOSTEN_MASK &h0040
'* Event 5 host enable mask
#DEFINE PRU_EVTOUT5_HOSTEN_MASK &h0080
'* Event 6 host enable mask
#DEFINE PRU_EVTOUT6_HOSTEN_MASK &h0100
'* Event 7 host enable mask
#DEFINE PRU_EVTOUT7_HOSTEN_MASK &h0200

'#DEFINE PRUSS_INTC_INITDATA TYPE<tpruss_intc_initdata>( _
  '{ PRU0_PRU1_INTERRUPT _
  ', PRU1_PRU0_INTERRUPT _
  ', PRU0_ARM_INTERRUPT _
  ', PRU1_ARM_INTERRUPT _
  ', ARM_PRU0_INTERRUPT _
  ', ARM_PRU1_INTERRUPT _
  ', CAST(BYTE, -1) }, _
  '{ TYPE<tsysevt_to_channel_map>(PRU0_PRU1_INTERRUPT, CHANNEL1) _
  ', TYPE<tsysevt_to_channel_map>(PRU1_PRU0_INTERRUPT, CHANNEL0) _
  ', TYPE<tsysevt_to_channel_map>(PRU0_ARM_INTERRUPT, CHANNEL2) _
  ', TYPE<tsysevt_to_channel_map>(PRU1_ARM_INTERRUPT, CHANNEL3) _
  ', TYPE<tsysevt_to_channel_map>(ARM_PRU0_INTERRUPT, CHANNEL0) _
  ', TYPE<tsysevt_to_channel_map>(ARM_PRU1_INTERRUPT, CHANNEL1) _
  ', TYPE<tsysevt_to_channel_map>(-1, -1)}, _
  '{ TYPE<tchannel_to_host_map>(CHANNEL0, PRU0) _
  ', TYPE<tchannel_to_host_map>(CHANNEL1, PRU1) _
  ', TYPE<tchannel_to_host_map>(CHANNEL2, PRU_EVTOUT0) _
  ', TYPE<tchannel_to_host_map>(CHANNEL3, PRU_EVTOUT1) _
  ', TYPE<tchannel_to_host_map>(-1, -1) }, _
  '(PRU0_HOSTEN_MASK OR PRU1_HOSTEN_MASK OR PRU_EVTOUT0_HOSTEN_MASK OR PRU_EVTOUT1_HOSTEN_MASK) _
  ')

'* Number of PRU host interrupts
#DEFINE NUM_PRU_HOSTIRQS 8
'* Number of hosts mapping channels
#DEFINE NUM_PRU_HOSTS 10
'* Number of PRU interrupt channels
#DEFINE NUM_PRU_CHANNELS 10
'* Number of PRU system events
#DEFINE NUM_PRU_SYS_EVTS 64
'* ID for PRU-0 data ram
#DEFINE PRUSS0_PRU0_DRAM 0
'* ID for PRU-1 data ram
#DEFINE PRUSS0_PRU1_DRAM 1
'* ID for PRU-0 instruction ram
#DEFINE PRUSS0_PRU0_IRAM 2
'* ID for PRU-1 instruction ram
#DEFINE PRUSS0_PRU1_IRAM 3
'* ID for PRUSS shared ram
#DEFINE PRUSS0_SRAM 4
''*
'#DEFINE PRUSS0_CFG 5
''*
'#DEFINE PRUSS0_UART 6
''*
'#DEFINE PRUSS0_IEP 7
''*
'#DEFINE PRUSS0_ECAP 8
''*
'#DEFINE PRUSS0_MII_RT 9
''*
'#DEFINE PRUSS0_MDIO 10
'* ID for host interrupt 0
#DEFINE PRU_EVTOUT_0 0
'* ID for host interrupt 1
#DEFINE PRU_EVTOUT_1 1
'* ID for host interrupt 2
#DEFINE PRU_EVTOUT_2 2
'* ID for host interrupt 3
#DEFINE PRU_EVTOUT_3 3
'* ID for host interrupt 4
#DEFINE PRU_EVTOUT_4 4
'* ID for host interrupt 5
#DEFINE PRU_EVTOUT_5 5
'* ID for host interrupt 6
#DEFINE PRU_EVTOUT_6 6
'* ID for host interrupt 7
#DEFINE PRU_EVTOUT_7 7


/'* \brief Mapping from system event to interrupt channel

The stucture contains a single mapping from a system event to the
specified interrupt channel.

\since 0.6
'/
TYPE __Sysevt_to_Channel_map
  AS Int16 _
     sysevt _ '*< The number of the system event
  , channel   '*< The mapped channel number
END TYPE

'* Forward declaration for event -> channel mapping type
TYPE tsysevt_to_channel_map AS __Sysevt_to_Channel_map

/'* \brief Mapping from interrupt channel to host event

The stucture contains a single mapping from an interrupt channel to an
host event.

\since 0.6
'/
TYPE __Channel_to_Host_map
  AS Int16 _
    channel _ '*< The channel number
     , host   '*< The host interrupt
END TYPE

'* Forward declaration for mapping type
TYPE tchannel_to_host_map AS __Channel_to_Host_map

/'* \brief Init data structure for the interrupt controller setting

The stucture contains a setting for the interrupt controller. It loads
in the first call to prussdrv_open().

\since 0.6
'/
TYPE __Pruss_intc_Initdata
  AS Int8 sysevts_enabled(NUM_PRU_SYS_EVTS-1) '*< The list of enabled system events.
  AS tsysevt_to_channel_map sysevt_to_channel_map(NUM_PRU_SYS_EVTS-1) '*< Mappings event -> interrupt channel.
  AS   tchannel_to_host_map channel_to_host_map(NUM_PRU_CHANNELS-1) '*< Mappings interrupt channel -> host ???.
  AS UInt32 host_enable_bitmask '*< The mask of enabled host interrupts.
END TYPE

'* Forward declaration for interrupt controler data type
TYPE tpruss_intc_initdata AS __Pruss_intc_Initdata
'* Default interrupt controller init (we also set default interrupts, so that the other PRUSS can be used in parallel)
CONST AS tpruss_intc_initdata DEF_INTC_INIT = _
  TYPE<tpruss_intc_initdata>( _
    { PRU0_PRU1_INTERRUPT _
    , PRU1_PRU0_INTERRUPT _
    , PRU0_ARM_INTERRUPT _
    , PRU1_ARM_INTERRUPT _
    , ARM_PRU0_INTERRUPT _
    , ARM_PRU1_INTERRUPT _
    , PRUIO_IRPT _
    , CAST(BYTE, -1) }, _
    { TYPE<tsysevt_to_channel_map>(PRU0_PRU1_INTERRUPT, CHANNEL1) _
    , TYPE<tsysevt_to_channel_map>(PRU1_PRU0_INTERRUPT, CHANNEL0) _
    , TYPE<tsysevt_to_channel_map>(PRU0_ARM_INTERRUPT, CHANNEL2) _
    , TYPE<tsysevt_to_channel_map>(PRU1_ARM_INTERRUPT, CHANNEL3) _
    , TYPE<tsysevt_to_channel_map>(ARM_PRU0_INTERRUPT, CHANNEL0) _
    , TYPE<tsysevt_to_channel_map>(ARM_PRU1_INTERRUPT, CHANNEL1) _
    , TYPE<tsysevt_to_channel_map>(PRUIO_IRPT, PRUIO_CHAN) _
    , TYPE<tsysevt_to_channel_map>(-1, -1)}, _
    { TYPE<tchannel_to_host_map>(CHANNEL0, PRU0) _
    , TYPE<tchannel_to_host_map>(CHANNEL1, PRU1) _
    , TYPE<tchannel_to_host_map>(CHANNEL2, PRU_EVTOUT0) _
    , TYPE<tchannel_to_host_map>(CHANNEL3, PRU_EVTOUT1) _
    , TYPE<tchannel_to_host_map>(PRUIO_CHAN, PRUIO_EMAP) _
    , TYPE<tchannel_to_host_map>(-1, -1) }, _
    (PRU0_HOSTEN_MASK OR PRU1_HOSTEN_MASK OR _
     PRU_EVTOUT0_HOSTEN_MASK OR PRU_EVTOUT1_HOSTEN_MASK OR PRUIO_MASK) _
    )

