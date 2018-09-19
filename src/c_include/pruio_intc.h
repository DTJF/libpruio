/*! \file pruio_intc.h
\brief FreeBASIC header file for interrupt controller defines.

Header file containing the defines and data types used for the
interrupt controller setting.

\since 0.6
*/


#define PRU0_PRU1_INTERRUPT 17
#define PRU1_PRU0_INTERRUPT 18
#define PRU0_ARM_INTERRUPT  19
#define PRU1_ARM_INTERRUPT  20
#define ARM_PRU0_INTERRUPT  21
#define ARM_PRU1_INTERRUPT  22
#define CHANNEL0 0
#define CHANNEL1 1
#define CHANNEL2 2
#define CHANNEL3 3
#define CHANNEL4 4
#define CHANNEL5 5
#define CHANNEL6 6
#define CHANNEL7 7
#define CHANNEL8 8
#define CHANNEL9 9

#define PRU0 0
#define PRU1 1
#define PRU_EVTOUT0 2
#define PRU_EVTOUT1 3
#define PRU_EVTOUT2 4
#define PRU_EVTOUT3 5
#define PRU_EVTOUT4 6
#define PRU_EVTOUT5 7
#define PRU_EVTOUT6 8
#define PRU_EVTOUT7 9

#define PRU0_HOSTEN_MASK        0x0001
#define PRU1_HOSTEN_MASK        0x0002
#define PRU_EVTOUT0_HOSTEN_MASK 0x0004
#define PRU_EVTOUT1_HOSTEN_MASK 0x0008
#define PRU_EVTOUT2_HOSTEN_MASK 0x0010
#define PRU_EVTOUT3_HOSTEN_MASK 0x0020
#define PRU_EVTOUT4_HOSTEN_MASK 0x0040
#define PRU_EVTOUT5_HOSTEN_MASK 0x0080
#define PRU_EVTOUT6_HOSTEN_MASK 0x0100
#define PRU_EVTOUT7_HOSTEN_MASK 0x0200


//#define PRUSS_INTC_INITDATA { \
//{ PRU0_PRU1_INTERRUPT, PRU1_PRU0_INTERRUPT, PRU0_ARM_INTERRUPT, PRU1_ARM_INTERRUPT, ARM_PRU0_INTERRUPT, ARM_PRU1_INTERRUPT,  (char)-1  }, \
//{ {PRU0_PRU1_INTERRUPT,CHANNEL1}, {PRU1_PRU0_INTERRUPT, CHANNEL0}, {PRU0_ARM_INTERRUPT,CHANNEL2}, {PRU1_ARM_INTERRUPT, CHANNEL3}, {ARM_PRU0_INTERRUPT, CHANNEL0}, {ARM_PRU1_INTERRUPT, CHANNEL1},  {-1,-1}}, \
 //{  {CHANNEL0,PRU0}, {CHANNEL1, PRU1}, {CHANNEL2, PRU_EVTOUT0}, {CHANNEL3, PRU_EVTOUT1}, {-1,-1} }, \
 //(PRU0_HOSTEN_MASK | PRU1_HOSTEN_MASK | PRU_EVTOUT0_HOSTEN_MASK | PRU_EVTOUT1_HOSTEN_MASK) /*Enable PRU0, PRU1, PRU_EVTOUT0 */ \
//} \

#define NUM_PRU_HOSTIRQS  8
#define NUM_PRU_HOSTS    10
#define NUM_PRU_CHANNELS 10
#define NUM_PRU_SYS_EVTS 64

#define PRUSS0_PRU0_DRAM 0
#define PRUSS0_PRU1_DRAM 1
#define PRUSS0_PRU0_IRAM 2
#define PRUSS0_PRU1_IRAM 3
#define PRUSS0_SRAM      4
//#define	PRUSS0_CFG     5
//#define	PRUSS0_UART    6
//#define	PRUSS0_IEP     7
//#define	PRUSS0_ECAP    8
//#define	PRUSS0_MII_RT  9
//#define	PRUSS0_MDIO   10
#define PRU_EVTOUT_0 0
#define PRU_EVTOUT_1 1
#define PRU_EVTOUT_2 2
#define PRU_EVTOUT_3 3
#define PRU_EVTOUT_4 4
#define PRU_EVTOUT_5 5
#define PRU_EVTOUT_6 6
#define PRU_EVTOUT_7 7

typedef struct __sysevt_to_channel_map {
  int16 sysevt; //!< The number of the system event
  int16 channel; //!< The mapped channel number
} tsysevt_to_channel_map;

typedef struct __channel_to_host_map {
  int16 channel; //!< The channel number
  int16 host; //!< The host interrupt
} tchannel_to_host_map;

typedef struct __pruss_intc_initdata {
  int8 sysevts_enabled[NUM_PRU_SYS_EVTS]; //!< The list of enabled system events
  tsysevt_to_channel_map sysevt_to_channel_map[NUM_PRU_SYS_EVTS]; //!< Mapping from system event to interrupt channel.
  tchannel_to_host_map channel_to_host_map[NUM_PRU_CHANNELS]; //!< Mapping from interrupt channel to host
  uint32 host_enable_bitmask; //!< The mask of enabled host interrupts
} tpruss_intc_initdata;
