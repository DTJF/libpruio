/*! \file pruio_intc.h
\brief C header file for interrupt controller defines.

Header file containing the defines and data types used for the
interrupt controller setting. See src/pruio/pruio_intc.bi for details.

Copyright 2018-\Year by \Email

\since 0.6.0
*/

#ifdef __cplusplus
 extern "C" {
#endif /* __cplusplus */

#define PRU0_PRU1_INTERRUPT 17 //!< System event PRU-0 -> PRU-1
#define PRU1_PRU0_INTERRUPT 18 //!< System event PRU-1 -> PRU-0
#define PRU0_ARM_INTERRUPT  19 //!< System event PRU-0 -> ARM
#define PRU1_ARM_INTERRUPT  20 //!< System event PRU-1 -> ARM
#define ARM_PRU0_INTERRUPT  21 //!< System event ARM -> PRU (R31.t30)
#define ARM_PRU1_INTERRUPT  22 //!< System event ARM -> PRU (R31.t31)
#define CHANNEL0 0 //!< ID for channel 0
#define CHANNEL1 1 //!< ID for channel 1
#define CHANNEL2 2 //!< ID for channel 2
#define CHANNEL3 3 //!< ID for channel 3
#define CHANNEL4 4 //!< ID for channel 4
#define CHANNEL5 5 //!< ID for channel 5
#define CHANNEL6 6 //!< ID for channel 6
#define CHANNEL7 7 //!< ID for channel 7
#define CHANNEL8 8 //!< ID for channel 8
#define CHANNEL9 9 //!< ID for channel 9

#define PRU0 0 //!< ID for PRU-0
#define PRU1 1 //!< ID for PRU-1
#define PRU_EVTOUT0 2 //!< ID for event 0
#define PRU_EVTOUT1 3 //!< ID for event 1
#define PRU_EVTOUT2 4 //!< ID for event 2
#define PRU_EVTOUT3 5 //!< ID for event 3
#define PRU_EVTOUT4 6 //!< ID for event 4
#define PRU_EVTOUT5 7 //!< ID for event 5
#define PRU_EVTOUT6 8 //!< ID for event 6
#define PRU_EVTOUT7 9 //!< ID for event 7

#define PRU0_HOSTEN_MASK        0x0001 //!< Interrupt host enable mask for PRU-0
#define PRU1_HOSTEN_MASK        0x0002 //!< Interrupt host enable mask for PRU-1
#define PRU_EVTOUT0_HOSTEN_MASK 0x0004 //!< Event 0 host enable mask
#define PRU_EVTOUT1_HOSTEN_MASK 0x0008 //!< Event 1 host enable mask
#define PRU_EVTOUT2_HOSTEN_MASK 0x0010 //!< Event 2 host enable mask
#define PRU_EVTOUT3_HOSTEN_MASK 0x0020 //!< Event 3 host enable mask
#define PRU_EVTOUT4_HOSTEN_MASK 0x0040 //!< Event 4 host enable mask
#define PRU_EVTOUT5_HOSTEN_MASK 0x0080 //!< Event 5 host enable mask
#define PRU_EVTOUT6_HOSTEN_MASK 0x0100 //!< Event 6 host enable mask
#define PRU_EVTOUT7_HOSTEN_MASK 0x0200 //!< Event 7 host enable mask


//#define PRUSS_INTC_INITDATA { \
//{ PRU0_PRU1_INTERRUPT, PRU1_PRU0_INTERRUPT, PRU0_ARM_INTERRUPT, PRU1_ARM_INTERRUPT, ARM_PRU0_INTERRUPT, ARM_PRU1_INTERRUPT,  (char)-1  }, \
//{ {PRU0_PRU1_INTERRUPT,CHANNEL1}, {PRU1_PRU0_INTERRUPT, CHANNEL0}, {PRU0_ARM_INTERRUPT,CHANNEL2}, {PRU1_ARM_INTERRUPT, CHANNEL3}, {ARM_PRU0_INTERRUPT, CHANNEL0}, {ARM_PRU1_INTERRUPT, CHANNEL1},  {-1,-1}}, \
 //{  {CHANNEL0,PRU0}, {CHANNEL1, PRU1}, {CHANNEL2, PRU_EVTOUT0}, {CHANNEL3, PRU_EVTOUT1}, {-1,-1} }, \
 //(PRU0_HOSTEN_MASK | PRU1_HOSTEN_MASK | PRU_EVTOUT0_HOSTEN_MASK | PRU_EVTOUT1_HOSTEN_MASK) /*Enable PRU0, PRU1, PRU_EVTOUT0 */ \
//} \

#define NUM_PRU_HOSTIRQS  8 //!< Number of PRU host interrupts
#define NUM_PRU_HOSTS    10 //!< Number of hosts mapping channels
#define NUM_PRU_CHANNELS 10 //!< Number of PRU interrupt channels
#define NUM_PRU_SYS_EVTS 64 //!< Number of PRU system events

#define PRUSS0_PRU0_DRAM 0 //!< ID for PRU-0 data ram
#define PRUSS0_PRU1_DRAM 1 //!< ID for PRU-1 data ram
#define PRUSS0_PRU0_IRAM 2 //!< ID for PRU-0 instruction ram
#define PRUSS0_PRU1_IRAM 3 //!< ID for PRU-1 instruction ram
#define PRUSS0_SRAM      4 //!< ID for PRUSS shared ram
//#define	PRUSS0_CFG     5 //!<
//#define	PRUSS0_UART    6 //!<
//#define	PRUSS0_IEP     7 //!<
//#define	PRUSS0_ECAP    8 //!<
//#define	PRUSS0_MII_RT  9 //!<
//#define	PRUSS0_MDIO   10 //!<
#define PRU_EVTOUT_0 0 //!< ID for host interrupt 0
#define PRU_EVTOUT_1 1 //!< ID for host interrupt 1
#define PRU_EVTOUT_2 2 //!< ID for host interrupt 2
#define PRU_EVTOUT_3 3 //!< ID for host interrupt 3
#define PRU_EVTOUT_4 4 //!< ID for host interrupt 4
#define PRU_EVTOUT_5 5 //!< ID for host interrupt 5
#define PRU_EVTOUT_6 6 //!< ID for host interrupt 6
#define PRU_EVTOUT_7 7 //!< ID for host interrupt 7
//! Mapping from system event to interrupt channel
typedef struct __sysevt_to_channel_map {
  int16 sysevt;  //!< The number of the system event
  int16 channel; //!< The mapped channel number
} tsysevt_to_channel_map;
//! Mapping from interrupt channel to host event
typedef struct __channel_to_host_map {
  int16 channel; //!< The channel number
  int16 host;    //!< The host interrupt
} tchannel_to_host_map;
//! Init data structure for the interrupt controller setting
typedef struct __pruss_intc_initdata {
  int8 sysevts_enabled[NUM_PRU_SYS_EVTS]; //!< The list of enabled system events
  tsysevt_to_channel_map sysevt_to_channel_map[NUM_PRU_SYS_EVTS]; //!< Mapping from system event to interrupt channel.
  tchannel_to_host_map channel_to_host_map[NUM_PRU_CHANNELS]; //!< Mapping from interrupt channel to host
  uint32 host_enable_bitmask; //!< The mask of enabled host interrupts
} tpruss_intc_initdata;

#if defined (__cplusplus)
}
#endif
