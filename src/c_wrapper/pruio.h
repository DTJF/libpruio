/** \file pruio.h
\brief The main header code of the C wrapper for libpruio.

This file provides the declarations of macros, types and classes in C
syntax. Include this file in your code to make use of libpruio. This
file contains a translation of the context of all FreeBASIC headers
(pruio.bi, pruio.hp, pruio_adc.bi, pruio_gpio.bi and pruio_pwm.bi) in
one file.

Feel free to translate this file in order to create language bindings
for non-C languages and use libpruio in polyglot applications. Check
also file pruio_pins.h for a convenient way to declare header pins.

\note The header pruio_pins.h is not shown in this documentation
      because it confuses Doxygen. It mixes up references with the
      original header pruio/pruio_pins.bi.

Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)

Copyright 2014 by \Email

*/

#ifdef __cplusplus
 extern "C" {
#endif /* __cplusplus */

#include "pruio.hp"

//#include "../pruio/pruio.bi" (transformed)
//! version string
#define PRUIO_VERSION "0.2"

typedef signed char int8;      //!< 8 bit signed integer data type
typedef short int16;           //!< 16 bit signed integer data type
typedef int int32;             //!< 32 bit signed integer data type
typedef unsigned char uint8;   //!< 8 bit unsigned integer data type
typedef unsigned short uint16; //!< 16 bit unsigned integer data type
typedef unsigned int uint32;   //!< 32 bit unsigned integer data type
typedef float float_t;         //!< float data type

//! tell pruss_intc_mapping.bi that we use ARM33xx
#define AM33XX

//! forward declaration
typedef struct pruIo pruIo;

//#include "pruio_adc.h"
//! the default setting for avaraging
#define PRUIO_DEF_AVRAGE 4
//! the default value for open delay in channel settings
#define PRUIO_DEF_ODELAY 183
//! the default value for sample delay in channel settings
#define PRUIO_DEF_SDELAY 0
//! the default number of samples to use (configures single mode)
#define PRUIO_DEF_SAMPLS 1
//! the default step mask (steps 1 to 8 for AIN0 to AIN7, no charge step)
#define PRUIO_DEF_STPMSK 510 // &b111111110
//! the default timer value (sampling rate)
#define PRUIO_DEF_TIMERV 0
//! the default bit mode (4 = 16 bit encoding)
#define PRUIO_DEF_LSLMOD 4
//! the default clock divisor (0 = full speed AFE = 2.4 MHz)
#define PRUIO_DEF_CLKDIV 0

/** \brief Wrapper structure for AdcSteps.

\since 0.0
*/
struct adcSteps{
  uint32
Confg,//!< context for configuration register
Delay;//!< context for delay register
};

/** \brief Wrapper structure for AdcSet.

\since 0.2
*/
typedef struct adcSet{
  uint32
DeAd,  //!< device address
ClAd,  //!< clock address
ClVa;  //!< clock value

  uint32
REVISION,      //!< Register at offset 00h (chap. 12.5.1.1).
SYSCONFIG,     //!< Register at offset 10h (chap. 12.5.1.2).
IRQSTATUS_RAW, //!< Register at offset 24h (chap. 12.5.1.3).
IRQSTATUS,     //!< Register at offset 28h (chap. 12.5.1.4).
IRQENABLE_SET, //!< Register at offset 2Ch (chap. 12.5.1.5).
IRQENABLE_CLR, //!< Register at offset 30h (chap. 12.5.1.6).
IRQWAKEUP,     //!< Register at offset 34h (chap. 12.5.1.7).
DMAENABLE_SET, //!< Register at offset 38h (chap. 12.5.1.8).
DMAENABLE_CLR, //!< Register at offset 3Ch (chap. 12.5.1.9).
CTRL,          //!< Register at offset 40h (chap. 12.5.1.10).
ADCSTAT,       //!< Register at offset 44h (chap. 12.5.1.11).
ADCRANGE,      //!< Register at offset 48h (chap. 12.5.1.12).
ADC_CLKDIV,    //!< Register at offset 4Ch (chap. 12.5.1.13).
ADC_MISC,      //!< Register at offset 50h (chap. 12.5.1.14).
STEPENABLE,    //!< Register at offset 54h (chap. 12.5.1.15).
IDLECONFIG;    //!< Register at offset 58h (chap. 12.5.1.16).

//! step configuration (chap. 12.5.1.16 ff, charge step + 16 steps, by default steps 1 to 8 are used for AIN0 to AIN7).
  struct adcSteps St_p[16 + 1];

  uint32
FIFO0COUNT,    //!< Register at offset E4h (chap. 12.5.1.51).
FIFO0THRESHOLD,//!< Register at offset E8h (chap. 12.5.1.52).
DMA0REQ,       //!< Register at offset ECh (chap. 12.5.1.53).
FIFO1COUNT,    //!< Register at offset F0h (chap. 12.5.1.54).
FIFO1THRESHOLD,//!< Register at offset F4h (chap. 12.5.1.55).
DMA1REQ;       //!< Register at offset F8h (chap. 12.5.1.56).
} adcSet;

/** \brief Wrapper structure for AdcUdt.

\since 0.2
*/
typedef struct adcUdt{
  pruIo* Top; //!< pointer to the calling PruIo instance
  adcSet
*Init,         //!< initial device configuration, used in the destructor  PruIo:~PruIo()
*Conf;         //!< current device configuration, used in  PruIo::config()
  uint32
Samples,       //!< number of samples (specifies run mode: 0 = config, 1 = IO mode, >1 = MM mode)
TimerVal,      //!< timer value in [ns]
InitParA;      //!< offset to read data block offset
  uint16
LslMode,       //!< bit shift modus (0 to 4, for 12 to 16 bits)
ChAz;          //!< the number of active steps
  uint16
*Value;        //!< fetched ADC samples
} adcUdt;

//#include "pruio_gpio.h"
/** \brief Wrapper structure for GpioSet.

\since 0.2
*/
typedef struct gpioSet{
  uint32
DeAd,            //!< device address
ClAd,            //!< clock address
ClVa;            //!< clock value

  uint32
REVISION,        //!< Register at offset 00h (chap. 25.4.1.1).
SYSCONFIG,       //!< Register at offset 10h (chap. 25.4.1.2).
EOI,             //!< Register at offset 20h (chap. 25.4.1.3).
IRQSTATUS_RAW_0, //!< Register at offset 24h (chap. 25.4.1.4).
IRQSTATUS_RAW_1, //!< Register at offset 28h (chap. 25.4.1.5).
IRQSTATUS_0,     //!< Register at offset 2Ch (chap. 25.4.1.6).
IRQSTATUS_1,     //!< Register at offset 30h (chap. 25.4.1.7).
IRQSTATUS_SET_0, //!< Register at offset 34h (chap. 25.4.1.8).
IRQSTATUS_SET_1, //!< Register at offset 38h (chap. 25.4.1.9).
IRQSTATUS_CLR_0, //!< Register at offset 3Ch (chap. 25.4.1.10).
IRQSTATUS_CLR_1, //!< Register at offset 40h (chap. 25.4.1.11).
IRQWAKEN_0,      //!< Register at offset 44h (chap. 25.4.1.12).
IRQWAKEN_1,      //!< Register at offset 48h (chap. 25.4.1.13).
SYSSTATUS,       //!< Register at offset 114h (chap. 25.4.1.14).
CTRL,            //!< Register at offset 130h (chap. 25.4.1.15).
OE,              //!< Register at offset 134h (chap. 25.4.1.16).
DATAIN,          //!< Register at offset 138h (chap. 25.4.1.17).
DATAOUT,         //!< Register at offset 13Ch (chap. 25.4.1.18).
LEVELDETECT0,    //!< Register at offset 140h (chap. 25.4.1.19).
LEVELDETECT1,    //!< Register at offset 144h (chap. 25.4.1.20).
RISINGDETECT,    //!< Register at offset 148h (chap. 25.4.1.21).
FALLINGDETECT,   //!< Register at offset 14Ch (chap. 25.4.1.22).
DEBOUNCENABLE,   //!< Register at offset 150h (chap. 25.4.1.23).
DEBOUNCINGTIME,  //!< Register at offset 154h (chap. 25.4.1.24).
CLEARDATAOUT,    //!< Register at offset 190h (chap. 25.4.1.25).
SETDATAOUT;      //!< Register at offset 194h (chap. 25.4.1.26).
} gpioSet;

/** \brief Wrapper structure for GpioArr.

\since 0.2
*/
typedef struct gpioArr{
  uint32
DeAd;    //!< base address of GPIO device + 0x100
  uint32
DATAIN,  //!< current Value of DATAIN register (IO)
DATAOUT, //!< current Value of DATAOUT register (IO)
Mix;     //!< current state of pins (IN&OUT mixed)
} gpioArr;


/** \brief Wrapper structure for GpioUdt.

\since 0.2
*/
typedef struct gpioUdt{
  pruIo* Top;//!< pointer to the calling PruIo instance
  gpioSet
*Init[PRUIO_AZ_GPIO + 1], //!< initial device configuration, used in the destructor  PruIo:~PruIo()
*Conf[PRUIO_AZ_GPIO + 1]; //!< current device configuration, used in  PruIo::config()
  gpioArr
*Raw[PRUIO_AZ_GPIO + 1];  //!< pointer to current raw device data (IO), all 32 bits
  uint32 InitParA;       //!< offset to read data block offset
} gpioUdt;




//#include "pruio_pwm.bi"
/** \brief Wrapper structure for PwmssSet.

\since 0.2
*/
typedef struct pwmssSet{
  uint32
DeAd,       //!< device address
ClAd,       //!< clock address
ClVa;       //!< clock value

  uint32
IDVER,      //!< IP Revision Register (chap. 15.1.3.1).
SYSCONFIG,  //!< System Configuration Register (chap. 15.1.3.2).
CLKCONFIG,  //!< Clock Configuration Register (chap. 15.1.3.3).
CLKSTATUS;  //!< Clock Status Register (chap. 15.1.3.4).

  uint32
TSCTR,      //!< Time-Stamp Counter Register (chap. 15.3.4.1.1).
CTRPHS,     //!< Counter Phase Offset Value Register (chap. 15.3.4.1.2).
CAP1,       //!< Capture 1 Register (chap. 15.3.4.1.3).
CAP2,       //!< Capture 2 Register (chap. 15.3.4.1.4).
CAP3,       //!< Capture 3 Register (chap. 15.3.4.1.5).
CAP4;       //!< Capture 4 Register (chap. 15.3.4.1.6).
  uint16
ECCTL1,     //!< Capture Control Register 1 (chap. 15.3.4.1.7).
ECCTL2,     //!< Capture Control Register 2 (chap. 15.3.4.1.8).
ECEINT,     //!< Capture Interrupt Enable Register (chap. 15.3.4.1.9).
ECFLG,      //!< Capture Interrupt Flag Register (chap. 15.3.4.1.10).
ECCLR,      //!< Capture Interrupt Clear Register (chap. 15.3.4.1.11).
ECFRC;      //!< Capture Interrupt Force Register (chap. 15.3.4.1.12).
  uint32
CAP_REV;    //!< Revision ID Register (chap. 15.3.4.1.13).

  uint32
QPOSCNT,    //!< Position Counter Register (chap. 15.4.3.1).
QPOSINIT,   //!< Position Counter Initialization Register (chap. 15.4.3.2).
QPOSMAX,    //!< Maximum Position Count Register (chap. 15.4.3.3).
QPOSCMP,    //!< Position-Compare Register 2/1 (chap. 15.4.3.4).
QPOSILAT,   //!< Index Position Latch Register (chap. 15.4.3.5).
QPOSSLAT,   //!< Strobe Position Latch Register (chap. 15.4.3.6).
QPOSLAT,    //!< Position Counter Latch Register (chap. 15.4.3.7).
QUTMR,      //!< Unit Timer Register (chap. 15.4.3.8).
QUPRD;      //!< Unit Period Register (chap. 15.4.3.9).
  uint16
QWDTMR,     //!< Watchdog Timer Register (chap. 15.4.3.10).
QWDPRD,     //!< Watchdog Period Register (chap. 15.4.3.11).
QDECCTL,    //!< Decoder Control Register (chap. 15.4.3.12).
QEPCTL,     //!< Control Register (chap. 15.4.3.14).
QCASCTL,    //!< Capture Control Register (chap. 15.4.3.15).
QPOSCTL,    //!< Position-Compare Control Register (chap. 15.4.3.15).
QEINT,      //!< Interrupt Enable Register (chap. 15.4.3.16).
QFLG,       //!< Interrupt Flag Register (chap. 15.4.3.17).
QCLR,       //!< Interrupt Clear Register (chap. 15.4.3.18).
QFRC,       //!< Interrupt Force Register (chap. 15.4.3.19).
QEPSTS,     //!< Status Register (chap. 15.4.3.20).
QCTMR,      //!< Capture Timer Register (chap. 15.4.3.21).
QCPRD,      //!< Capture Period Register (chap. 15.4.3.22).
QCTMRLAT,   //!< Capture Timer Latch Register (chap. 15.4.3.23).
QCPRDLAT,   //!< Capture Period Latch Register (chap. 15.4.3.24).
empty;      //!< adjust at uint32 border
  uint32
QEP_REV;    //!< Revision ID (chap. 15.4.3.25

  uint16
TBCTL,      //!< Time-Base Control Register
TBSTS,      //!< Time-Base Status Register
TBPHSHR,    //!< Extension for HRPWM Phase Register
TBPHS,      //!< Time-Base Phase Register
TBCNT,      //!< Time-Base Counter Register
TBPRD,      //!< Time-Base Period Register

CMPCTL,     //!< Counter-Compare Control Register
CMPAHR,     //!< Extension for HRPWM Counter-Compare A Register
CMPA,       //!< Counter-Compare A Register
CMPB,       //!< Counter-Compare B Register

AQCTLA,     //!< Action-Qualifier Control Register for Output A (EPWMxA)
AQCTLB,     //!< Action-Qualifier Control Register for Output B (EPWMxB)
AQSFRC,     //!< Action-Qualifier Software Force Register
AQCSFRC,    //!< Action-Qualifier Continuous S/W Force Register Set

DBCTL,     //!< Dead-Band Generator Control Register
DBRED,     //!< Dead-Band Generator Rising Edge Delay Count Register
DBFED,     //!< Dead-Band Generator Falling Edge Delay Count Register

TZSEL,     //!< Trip-Zone Select Register
TZCTL,     //!< Trip-Zone Control Register
TZEINT,    //!< Trip-Zone Enable Interrupt Register
TZFLG,     //!< Trip-Zone Flag Register
TZCLR,     //!< Trip-Zone Clear Register
TZFRC,     //!< Trip-Zone Force Register

ETSEL,     //!< Event-Trigger Selection Register
ETPS,      //!< Event-Trigger Pre-Scale Register
ETFLG,     //!< Event-Trigger Flag Register
ETCLR,     //!< Event-Trigger Clear Register
ETFRC,     //!< Event-Trigger Force Register

PCCTL,     //!< PWM-Chopper Control Register

HRCTL;     //!< HRPWM Control Register
} pwmssSet;


/** \brief Wrapper structure for PwmssArr.

\since 0.2
*/
typedef struct pwmssArr{
  uint32
DeAd;      //!< device address
  uint32
CMax,      //!< maximum counter value
C1,        //!< on time counter value
C2,        //!< period time counter value
fe1,       //!< ???
fe2,       //!< ???
fe3,       //!< ???
fe4;       //!< ???
} pwmssArr;


/** \brief Wrapper structure for PwmssUdt.

\since 0.2
*/
typedef struct pwmssUdt{
  pruIo* Top;  //!< pointer to the calling PruIo instance
  pwmssSet
*Init[PRUIO_AZ_PWMSS + 1], //!< initial device configuration, used in the destructor  PruIo:~PruIo()
*Conf[PRUIO_AZ_PWMSS + 1]; //!< current device configuration, used in  PruIo::config()
  pwmssArr
*Raw[PRUIO_AZ_PWMSS + 1];  //!< pointer to current raw subsystem data (IO)
  uint32 InitParA;         //!< offset to read data block offset
  const uint16
CapMod;                    //!< value for ECCTL2 in CAP mode (&b11010110)
} pwmssUdt;


/** \brief Wrapper structure for PwmMod.

\since 0.2
*/
typedef struct pwmMod pwmMod;

/** \brief Wrapper structure for CapMod.

\since 0.2
*/
typedef struct capMod capMod;

/** \brief Wrapper structure for QepMod.

\since 0.2
*/
typedef struct qepMod qepMod;


//! the PRUSS driver library
#include "prussdrv.h"
//! PRUSS driver interrupt settings
#include "pruss_intc_mapping.h"

/** \brief Wrapper enumerators for ActivateDevice.

\since 0.2
*/
enum activateDevice{
  PRUIO_ACT_PRU1  =   1    , //!< activate PRU-1 (= default, instead of PRU-0)
  PRUIO_ACT_ADC   = 1 << 1 , //!< activate ADC
  PRUIO_ACT_GPIO0 = 1 << 2 , //!< activate GPIO-0
  PRUIO_ACT_GPIO1 = 1 << 3 , //!< activate GPIO-1
  PRUIO_ACT_GPIO2 = 1 << 4 , //!< activate GPIO-2
  PRUIO_ACT_GPIO3 = 1 << 5 , //!< activate GPIO-3
  PRUIO_ACT_PWM0  = 1 << 6 , //!< activate PWMSS-0 (including eCAP, eQEP, ePWM)
  PRUIO_ACT_PWM1  = 1 << 7 , //!< activate PWMSS-1 (including eCAP, eQEP, ePWM)
  PRUIO_ACT_PWM2  = 1 << 8 , //!< activate PWMSS-2 (including eCAP, eQEP, ePWM)
  PRUIO_DEF_ACTIVE = 0xFFFF  //!< activate all devices
};


/** \brief Wrapper structure for BallSet.

\since 0.2
*/
typedef struct ballSet{
  uint32
DeAd;//!< base address of Control Module device
  uint8 Value[PRUIO_AZ_BALL + 1];//!< The values of the pad control registers.
} ballSet;

/** \brief Wrapper structure for PruIo.

\since 0.0
*/
typedef struct pruIo{
  adcUdt* Adc;//!< pointer to ADC device structure
  gpioUdt* Gpio;//!< pointer to GPIO device structure
  pwmssUdt* PwmSS;//!< pointer to PWMSS device structure
  pwmMod* Pwm;//!< pointer to the ePWM module structure (in PWMSS devices)
  capMod* Cap;//!< pointer to the eCAP module structure (in PWMSS devices)
  //qepMod* Qep;//!< pointer to the eQEP module structure (in PWMSS devices)

  char* Errr;//!< pointer for error messages
  uint32* DRam;//!< pointer to access PRU DRam
  ballSet
*Init,//!< The devices register data at start-up (to restore devices at the end)
*Conf;//!< The devices register data used by libpruio (current local data)
  void
*ERam,//!< pointer to read PRU external ram
*DInit,//!< pointer to block of devices initial data
*DConf,//!< pointer to block of devices configuration data
*MOffs;//!< configuration offset for modules
  uint8
*BallOrg,//!< pointer for original Ball configuration
*BallConf;//!< pointer to ball configuration (CPU pin muxing)
  uint32
EAddr,//!< the address of the external memory (PRUSS-DDR)
ESize,//!< the size of the external memory (PRUSS-DDR)
DSize,//!< the size of a data block (DInit or DConf)
PruNo,//!< the PRU number to use (defaults to 1)
PruEvtOut,//!< the interrupt channel to send commands to PRU
PruIRam,//!< the PRU instruction ram to load
PruDRam;//!< the PRU data ram
  int16
ArmPruInt,//!< the interrupt to send
ParOffs,//!< the offset for the parameters of a module
DevAct;//!< active devices

//! interrupt settings (we also set default interrupts, so that the other PRUSS can be used in parallel)
  struct __pruss_intc_initdata IntcInit;

//! list of GPIO numbers, corresponding to ball index
  uint8 BallGpio[PRUIO_AZ_BALL + 1];
} pruIo;


/** \brief Wrapper function for the constructor PruIo::PruIo().
\param Act mask for active subsystems and PRU number
\param Av avaraging for default steps (0 to 16, defaults to 0)
\param OpD open delay for default steps (0 to 0x3FFFF, defaults to 0x98)
\param SaD sample delay for default steps (0 to 255, defaults to 0)
\returns A pointer for the new instance.

Since the constructor reads the original devices configurations and the
destructor restores them, it's recommended to create and use just one
PruIo instance at the same time.

\since 0.0
*/
pruIo* pruio_new(uint16 Act, uint8 Av, uint32 OpD, uint8 SaD);

/** \brief Wrapper function for the destructor PruIo::~PruIo.
\param Io The pointer of the instance.

\since 0.0
*/
void pruio_destroy(pruIo* Io);

/** \brief Wrapper function for PruIo::config().
\param Io The pointer of the  PruIo instance
\param Samp number of samples to fetch (defaults to zero)
\param Mask mask for active steps (defaults to all 8 channels active in steps 1 to 8)
\param Tmr timer value in [ns] to specify the sampling rate (defaults to zero, MM only)
\param Mds modus for output (defaults to 4 = 16 bit)
\returns zero on success (otherwise a string with an error message)

\since 0.2
*/
char* pruio_config(pruIo* Io, uint32 Samp, uint32 Mask, uint32 Tmr, uint16 Mds);

/** \brief Wrapper function for PruIo::get_config().
\param Io The pointer of the  PruIo instance
\param Ball the CPU ball number to describe
\returns a human-readable text string (internal string, never free it)

\since 0.2
*/
char* pruio_Pin(pruIo* Io, uint8 Ball);

/** \brief Wrapper function for PruIo::mm_start().
\param Io The pointer of the  PruIo instance
\param Trg1 settings for first trigger (default = no trigger)
\param Trg2 settings for second trigger (default = no trigger)
\param Trg3 settings for third trigger (default = no trigger)
\param Trg4 settings for fourth trigger (default = no trigger)
\returns zero on success (otherwise a string with an error message)

\since 0.2
*/
char* pruio_mm_start(pruIo* Io, uint32 Trg1, uint32 Trg2, uint32 Trg3, uint32 Trg4);

/** \brief Wrapper function for PruIo::rb_start().
\param Io The pointer of the  PruIo instance
\returns zero on success (otherwise a string with an error message)

\since 0.2
*/
char* pruio_rb_start(pruIo* Io);


/** \brief Wrapper function for GpioUdt::config().
\param Io The pointer of the  PruIo instance
\param Ball the CPU ball number to set
\param Modus the mode for the GPIO
\returns zero on success (otherwise a pointer to an error message)

\since 0.2
*/
char* pruio_gpio_setValue(pruIo* Io, uint8 Ball, uint8 Modus);

/** \brief Wrapper function for GpioUdt::setValue().
\param Io The pointer of the  PruIo instance
\param Ball the CPU ball number to set
\param Modus the mode for the GPIO
\returns zero on success (otherwise a pointer to an error message)
\since 0.2

\since 0.2
*/
char* pruio_gpio_setValue(pruIo* Io, uint8 Ball, uint8 Modus);

/** \brief Wrapper function for GpioUdt::Value().
\param Io The pointer of the  PruIo instance
\param Ball the CPU ball number to test
\returns GPIO state (otherwise -1, check  PruIo::Errr for an error message)

\since 0.2
*/
uint32 pruio_gpio_Value(pruIo* Io, uint8 Ball);


/** \brief Wrapper function for AdcUdt::setStep().
\param Io The pointer of the  PruIo instance
\param Stp step index (0 = step 0 => charge step, 1 = step 1 (=> AIN0 by default),  ..., 17 = idle step)
\param ChN channel number to scan (0 = AIN0, 1 = AIN1, ...)
\param Av new value for avaraging (defaults to 4)
\param SaD new value for sample delay (defaults to 0)
\param OpD new value for open delay (defaults to 0x98)
\returns zero on success (otherwise a string with an error message)

\since 0.2
*/
char* pruio_adc_setStep(pruIo* Io, uint8 Stp, uint8 ChN, uint8 Av, uint8 SaD, uint32 OpD);

/** \brief Wrapper function for AdcUdt::mm_trg_pin().
\param Io The pointer of the  PruIo instance
\param Ball the CPU ball number to test
\param GpioV the state to check (defaults to high = 1)
\param Skip the number of samples to skip (defaults to 0 = zero, max. 1023)
\returns the trigger configuration (or zero in case of an error, check  PruIo::Errr)

\since 0.2
*/
uint32 pruio_adc_mm_trg_pin(pruIo* Io, uint8 Ball, uint8 GpioV, uint16 Skip);


/** \brief Wrapper function for AdcUdt::mm_trg_ain().
\param Io The pointer of the  PruIo instance
\param Stp the step number to use for trigger input
\param AdcV the sample value to match (positive check greater than, negative check less than)
\param Rela if AdcV is relative to the current input
\param Skip the number of samples to skip (defaults to 0 = zero, max. 1023)
\returns the trigger configuration (or zero in case of an error, check  PruIo::Errr)

\since 0.2
*/
uint32 pruio_adc_mm_trg_ain(pruIo* Io, uint8 Stp, int32 AdcV, uint8 Rela, uint16 Skip);

/** \brief Wrapper function for AdcUdt::mm_trg_pre().
\param Io The pointer of the  PruIo instance
\param Stp the step number to use for trigger input
\param AdcV the sample value to match (positive check greater than, negative check less than)
\param Samp the number of samples for the pre-trigger
\param Rela if AdcV is relative to the current input
\returns the trigger configuration (or zero in case of an error, check  PruIo::Errr)

\since 0.2
*/
uint32 pruio_adc_mm_trg_pre(pruIo* Io, uint8 Stp, int32 AdcV, uint16 Samp, uint8 Rela);


/** \brief Wrapper function for CapMod::config().
\param Io The pointer of the  PruIo instance
\param Ball The CPU ball number to configure
\param FLow Minimal frequency to measure (> .0232831)
\returns zero on success (otherwise a string with an error message)

\since 0.2
*/
char* pruio_cap_config(pruIo* Io, uint8 Ball, float_t FLow);

/** \brief Wrapper function for CapMod::Value().
\param Io The pointer of the  PruIo instance
\param Ball the CPU ball number to test
\param Hz A pointer to store the frequency value (or null)
\param Du A pointer to store the duty cycle value (or null)
\returns zero on success (otherwise a string with an error message)

\since 0.2
*/
char* pruio_cap_Value(pruIo* Io, uint8 Ball, float_t* Hz, float_t* Du);


/** \brief Wrapper function for PwmMod::Value().
\param Io The pointer of the  PruIo instance
\param Ball the CPU ball number to test
\param Hz A pointer to store the frequency value (or null)
\param Du A pointer to store the duty cycle value (or null)
\returns zero on success (otherwise a string with an error message)

\since 0.2
*/
char* pruio_pwm_Value(pruIo* Io, uint8 Ball, float_t* Hz, float_t* Du);

/** \brief Wrapper function for PwmMod::setValue().
\param Io The pointer of the PruIo instance
\param Ball the CPU ball number to set
\param Hz The frequency to set (or -1 for no change).
\param Du The duty cycle to set (0.0 to 1.0, or -1 for no change).
\returns zero on success (otherwise a string with an error message)

\since 0.2
*/
char* pruio_pwm_setValue(pruIo* Io, uint8 Ball, float_t Hz, float_t Du);

#ifdef __cplusplus
 }
#endif /* __cplusplus */
