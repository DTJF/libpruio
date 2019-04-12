/** \ file pruio.h
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

Copyright 2014-\Year by \Email

\since 0.0
*/

#ifdef __cplusplus
 extern "C" {
#endif /* __cplusplus */

// common declarations
#include "pruio.hp"

//! version string
#define PRUIO_VERSION "0.6.4"

//#include "../pruio/pruio.bi" (transformed)
typedef signed char int8;      //!< 8 bit signed integer data type.
typedef short int16;           //!< 16 bit signed integer data type.
typedef int int32;             //!< 32 bit signed integer data type.
typedef unsigned char uint8;   //!< 8 bit unsigned integer data type.
typedef unsigned short uint16; //!< 16 bit unsigned integer data type.
typedef unsigned int uint32;   //!< 32 bit unsigned integer data type.
typedef float float_t;         //!< float data type.

//! Tell pruss_intc_mapping.bi that we use ARM33xx.
#define AM33XX

//! forward declaration
typedef struct pruIo pruIo;

//#include "pruio_adc.h"
//! The default setting for avaraging.
#define PRUIO_DEF_AVRAGE 4
//! The default value for open delay in channel settings.
#define PRUIO_DEF_ODELAY 183
//! The default value for sample delay in channel settings.
#define PRUIO_DEF_SDELAY 0
//! The default number of samples to use (configures single mode).
#define PRUIO_DEF_SAMPLS 1
//! The default step mask (steps 1 to 8 for AIN0 to AIN7, no charge step).
#define PRUIO_DEF_STPMSK 510 // &b111111110
//! The default timer value (sampling rate).
#define PRUIO_DEF_TIMERV 0
//! The default bit mode (4 = 16 bit encoding).
#define PRUIO_DEF_LSLMOD 4
//! The default clock divisor (0 = full speed AFE = 2.4 MHz).
#define PRUIO_DEF_CLKDIV 0

/** \brief Wrapper structure for AdcSteps.

\since 0.0
*/
struct adcSteps{
  uint32
    Confg,//!< Context for configuration register.
    Delay;//!< Context for delay register.
};

/** \brief Wrapper structure for AdcSet.

\since 0.2
*/
typedef struct adcSet{
  uint32
    DeAd,  //!< Subsystem address.
    ClAd,  //!< Clock address.
    ClVa;  //!< Clock value.

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
  pruIo* Top; //!< Pointer to the calling PruIo instance.
  adcSet
    *Init,    //!< Initial subsystem configuration, used in the destructor  PruIo::~PruIo().
    *Conf;    //!< Current subsystem configuration, used in  PruIo::config().
  uint32
    Samples,  //!< Number of samples (specifies run mode: 0 = config, 1 = IO mode, >1 = MM mode).
    TimerVal, //!< Timer value in [ns].
    InitParA; //!< Offset to read data block offset.
  uint16
    LslMode,  //!< Bit shift modus (0 to 4, for 12 to 16 bits).
    ChAz;     //!< The number of active steps.
  uint16
    *Value;   //!< Fetched ADC samples.
} adcUdt;

//#include "pruio_gpio.h"
/** \brief Wrapper structure for GpioSet.

\since 0.2
*/
typedef struct gpioSet{
  uint32
    DeAd,            //!< Subsystem address.
    ClAd,            //!< Clock address.
    ClVa;            //!< Clock value.

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
    DeAd;    //!< Base address of GPIO subsystem + 0x100.
  uint32
    DATAIN,  //!< Current Value of DATAIN register (IO).
    DATAOUT, //!< Current Value of DATAOUT register (IO).
    Mix;     //!< Current state of pins (IN&OUT mixed).
} gpioArr;


/** \brief Wrapper structure for GpioUdt.

\since 0.2
*/
typedef struct gpioUdt{
  pruIo* Top;//!< pointer to the calling PruIo instance
  gpioSet
    *Init[PRUIO_AZ_GPIO + 1], //!< Initial subsystem configuration, used in the destructor  PruIo::~PruIo().
    *Conf[PRUIO_AZ_GPIO + 1]; //!< Current subsystem configuration, used in  PruIo::config().
  gpioArr
    *Raw[PRUIO_AZ_GPIO + 1];  //!< Pointer to current raw subsystem data (IO), all 32 bits.
  uint32
    InitParA, //!< Offset to read data block offset.
    Mask;     //!< The bit mask to manipulate.
  uint8
    Mode, //!< The mode for pinmuxing
    Indx, //!< The GPIO subsystem index
    Fe1,  //!< Future expansion
    Fe2;  //!< Future expansion
} gpioUdt;




//#include "pruio_timer.bi"
/** \brief Wrapper structure for TimerSet.

\since 0.4
*/
typedef struct timerSet{
  uint32
    DeAd, //!< Subsystem address.
    ClAd, //!< Clock address.
    ClVa; //!< Clock value.

  uint32
    TIDR         //!< Register at offset  00h (see \ArmRef{20.1.5.1} ).
  , TIOCPCFG     //!< Timer OCP Configuration Register (offset 10h, see \ArmRef{20.1.5.2} ).
  , IRQEOI       //!< Timer IRQ End-of-Interrupt Register (offset 20h, see \ArmRef{20.1.5.3} ).
  , IRQSTATUSRAW //!< Timer Status Raw Register (offset 24h, see \ArmRef{20.1.5.4} ).
  , IRQSTATUS    //!< Timer Status Register (offset 28h, see \ArmRef{20.1.5.5} ).
  , IRQENABLESET //!< Timer Interrupt Enable Set Register (offset 2Ch, see \ArmRef{20.1.5.6} ).
  , IRQENABLECLR //!< Timer Interrupt Enable Clear Register (offset 30h, see \ArmRef{20.1.5.7} ).
  , IRQWAKEEN    //!< Timer IRQ Wakeup Enable Register (offset 34h, see \ArmRef{20.1.5.8} ).
  , TCLR   //!< Timer Control Register (offset 38h, see \ArmRef{20.1.5.9} ).
  , TCRR   //!< Timer Counter Register (offset 3Ch, see \ArmRef{20.1.5.10} ).
  , TLDR   //!< Timer Load Register (offset 40h, see \ArmRef{20.1.5.11} ).
  , TTGR   //!< Timer Trigger Register (offset 44h, see \ArmRef{20.1.5.12} ).
  , TWPS   //!< Timer Write Posting Bits Register (offset 48h, see \ArmRef{20.1.5.13} ).
  , TMAR   //!< Timer Match Register (offset 4Ch, see \ArmRef{20.1.5.14} ).
  , TCAR1  //!< Timer Capture Register (offset 50h, see \ArmRef{20.1.5.15} ).
  , TSICR  //!< Timer Synchronous Interface Control Register (offset 54h, see \ArmRef{20.1.5.16} ).
  , TCAR2; //!< Timer Capture Register (offset 58h, see \ArmRef{20.1.5.17} ).
} timerSet;


/** \brief Wrapper structure for TimerArr.

\since 0.4
*/
typedef struct timerArr{
  uint32
    DeAd; //!< Subsystem address.

  uint32
    CMax   //!< Maximum counter value.
  , TCAR1  //!< Current value of TCAR2 register (IO, RB).
  , TCAR2; //!< Current value of TCRR register (IO, RB).
} timerArr;


/** \brief Wrapper structure for TimerUdt.

\since 0.4
*/
typedef struct timerUdt{
  pruIo* Top;                 //!< Pointer to the calling PruIo instance.
  timerSet
    *Init[PRUIO_AZ_GPIO + 1], //!< Initial subsystem configuration, used in the destructor  PruIo::~PruIo().
    *Conf[PRUIO_AZ_GPIO + 1]; //!< Current subsystem configuration, used in  PruIo::config().
  timerArr
    *Raw[PRUIO_AZ_GPIO + 1];  //!< Pointer to current raw subsystem data (IO), all 32 bits.
  uint32
    InitParA  //!< Offset to read data block offset.
  , PwmMode   //!< Control register for PWM output mode.
  , TimMode   //!< Control register for Timer mode.
  , TimHigh   //!< Control register for Timer high.
  , Tim_Low   //!< Control register for Timer low.
  , CapMode;  //!< Control register for CAP input mode.
  char*
    E0  //!< Common error message.
  , E1  //!< Common error message.
  , E2; //!< Common error message.
} timerUdt;


//#include "pruio_pwm.bi"
/** \brief Wrapper structure for PwmssSet.

\since 0.2
*/
typedef struct pwmssSet{
  uint32
    DeAd,       //!< Subsystem address.
    ClAd,       //!< Clock address.
    ClVa;       //!< Clock value.

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
    QCAPCTL,    //!< Capture Control Register (chap. 15.4.3.15).
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
    empty;      //!< Adjust at uint32 border.
  uint32
    QEP_REV;    //!< Revision ID (chap. 15.4.3.25).

  uint16
    TBCTL,      //!< Time-Base Control Register.
    TBSTS,      //!< Time-Base Status Register.
    TBPHSHR,    //!< Extension for HRPWM Phase Register.
    TBPHS,      //!< Time-Base Phase Register.
    TBCNT,      //!< Time-Base Counter Register.
    TBPRD,      //!< Time-Base Period Register.

    CMPCTL,     //!< Counter-Compare Control Register.
    CMPAHR,     //!< Extension for HRPWM Counter-Compare A Register.
    CMPA,       //!< Counter-Compare A Register.
    CMPB,       //!< Counter-Compare B Register.

    AQCTLA,     //!< Action-Qualifier Control Register for Output A (EPWMxA).
    AQCTLB,     //!< Action-Qualifier Control Register for Output B (EPWMxB).
    AQSFRC,     //!< Action-Qualifier Software Force Register.
    AQCSFRC,    //!< Action-Qualifier Continuous S/W Force Register Set.

    DBCTL,     //!< Dead-Band Generator Control Register.
    DBRED,     //!< Dead-Band Generator Rising Edge Delay Count Register.
    DBFED,     //!< Dead-Band Generator Falling Edge Delay Count Register.

    TZSEL,     //!< Trip-Zone Select Register.
    TZCTL,     //!< Trip-Zone Control Register.
    TZEINT,    //!< Trip-Zone Enable Interrupt Register.
    TZFLG,     //!< Trip-Zone Flag Register.
    TZCLR,     //!< Trip-Zone Clear Register.
    TZFRC,     //!< Trip-Zone Force Register.

    ETSEL,     //!< Event-Trigger Selection Register.
    ETPS,      //!< Event-Trigger Pre-Scale Register.
    ETFLG,     //!< Event-Trigger Flag Register.
    ETCLR,     //!< Event-Trigger Clear Register.
    ETFRC,     //!< Event-Trigger Force Register.

    PCCTL,     //!< PWM-Chopper Control Register.

    HRCTL;     //!< HRPWM Control Register.
} pwmssSet;


/** \brief Wrapper structure for PwmssArr.

\since 0.2
*/
typedef struct pwmssArr{
  uint32
    DeAd; //!< Subsystem address.
  uint32
    CMax  //!< Maximum counter value (CAP).
  , C1    //!< On time counter value (CAP).
  , C2    //!< Period time counter value (CAP).
  , QPos  //!< Current position counter (QEP).
  , NPos  //!< New position latch (QEP).
  , OPos  //!< Old position latch (QEP).
  , PLat; //!< New period timer latch (QEP).
} pwmssArr;


/** \brief Wrapper structure for PwmssUdt.

\since 0.2
*/
typedef struct pwmssUdt{
  pruIo* Top;  //!< pointer to the calling PruIo instance
  pwmssSet
    *Init[PRUIO_AZ_PWMSS + 1], //!< Initial subsystem configuration, used in the destructor  PruIo::~PruIo().
    *Conf[PRUIO_AZ_PWMSS + 1]; //!< Current subsystem configuration, used in  PruIo::config().
  pwmssArr
    *Raw[PRUIO_AZ_PWMSS + 1];  //!< Pointer to current raw subsystem data (IO).
  uint32 InitParA;             //!< Offset to read data block offset.
  const uint16
    PwmMod                     //!< Value for ECCTL2 in PWM mode (&b1011010000).
  , CapMod;                    //!< Value for ECCTL2 in CAP mode (&b0011010110).
} pwmssUdt;


/** \brief Wrapper structure for PwmMod.

\since 0.2
*/
typedef struct pwmMod{
  pruIo* Top;  //!< pointer to the calling PruIo instance
  uint16
    ForceUpDown               //!< Switch to force up-down counter for ePWM modules.
  , Cntrl[PRUIO_AZ_PWMSS + 1] //!< Initializers TBCTL register for ePWM modules (see \ref sSecPwm).
  , AqCtl[1 + 1][PRUIO_AZ_PWMSS + 1][2 + 1]; //!< Initializers for Action Qualifier for ePWM modules (see \ref sSecPwm).
  char
    *E0  //!< Common error message.
  , *E1  //!< Common error message.
  , *E2  //!< Common error message.
  , *E3  //!< Common error message.
  , *E4; //!< Common error message.
} pwmMod;

/** \brief Wrapper structure for CapMod.

\since 0.2
*/
typedef struct capMod capMod;

/** \brief Wrapper structure for QepMod.

\since 0.4
*/
typedef struct qepMod{
  pruIo* Top;  //!< pointer to the calling PruIo instance
  float_t
    FVh[PRUIO_AZ_PWMSS + 1]  //!< Factor for high velocity measurement.
  , FVl[PRUIO_AZ_PWMSS + 1]; //!< Factor for low velocity measurement.
  uint32
    Prd[PRUIO_AZ_PWMSS + 1]; //!< Period value to switch velocity measurement.
  char
    *E0  //!< Common error message.
  , *E1  //!< Common error message.
  , *E2; //!< Common error message.
} qepMod;


// PRUSS driver interrupt settings
#include "pruio_intc.h"

/** \brief Wrapper enumerators for ::PinMuxing.

\since 0.2
*/
enum pinMuxing{
  PRUIO_PULL_DOWN = 0,      //!< Pulldown resistor connected (&b000000).
  PRUIO_NO_PULL   = 1 << 3, //!< No resistor connected (&b001000).
  PRUIO_PULL_UP   = 1 << 4, //!< Pullup resistor connected (&b010000).
  PRUIO_RX_ACTIV  = 1 << 5, //!< Input receiver enabled (&b100000).
  PRUIO_GPIO_OUT0 = 7 + PRUIO_NO_PULL,                    //!< GPIO output low (no resistor).
  PRUIO_GPIO_OUT1 = 7 + PRUIO_NO_PULL + 128,              //!< GPIO output high (no resistor).
  PRUIO_GPIO_IN   = 7 + PRUIO_NO_PULL + PRUIO_RX_ACTIV,   //!< GPIO input (no resistor).
  PRUIO_GPIO_IN_0 = 7 + PRUIO_PULL_DOWN + PRUIO_RX_ACTIV, //!< GPIO input (pulldown resistor).
  PRUIO_GPIO_IN_1 = 7 + PRUIO_PULL_UP + PRUIO_RX_ACTIV,   //!< GPIO input (pullup resistor).
  PRUIO_PIN_RESET = 0xFF
};

/** \brief Wrapper enumerators for ::AdcStepMask.

\since 0.6.4
*/
enum adcStepmask{
  AIN0 = 1 << 1   //!< Activate Step 1 (default config: AIN0)
, AIN1 = 1 << 2   //!< Activate Step 2 (default config: AIN1)
, AIN2 = 1 << 3   //!< Activate Step 3 (default config: AIN2)
, AIN3 = 1 << 4   //!< Activate Step 4 (default config: AIN3)
, AIN4 = 1 << 5   //!< Activate Step 5 (default config: AIN4)
, AIN5 = 1 << 6   //!< Activate Step 6 (default config: AIN5)
, AIN6 = 1 << 7   //!< Activate Step 7 (default config: AIN6)
, AIN7 = 1 << 8   //!< Activate Step 8 (default config: AIN7)
};

/** \brief Wrapper enumerators for ::ActivateDevice.

\since 0.2
*/
enum activateDevice{
  PRUIO_ACT_PRU1  =   1      //!< Activate PRU-1 (= default, instead of PRU-0).
, PRUIO_ACT_ADC   = 1 << 1   //!< Activate ADC.
, PRUIO_ACT_GPIO0 = 1 << 2   //!< Activate GPIO-0.
, PRUIO_ACT_GPIO1 = 1 << 3   //!< Activate GPIO-1.
, PRUIO_ACT_GPIO2 = 1 << 4   //!< Activate GPIO-2.
, PRUIO_ACT_GPIO3 = 1 << 5   //!< Activate GPIO-3.
, PRUIO_ACT_PWM0  = 1 << 6   //!< Activate PWMSS-0 (including eCAP, eQEP, ePWM).
, PRUIO_ACT_PWM1  = 1 << 7   //!< Activate PWMSS-1 (including eCAP, eQEP, ePWM).
, PRUIO_ACT_PWM2  = 1 << 8   //!< Activate PWMSS-2 (including eCAP, eQEP, ePWM).
, PRUIO_ACT_TIM4  = 1 << 9   //!< Activate TIMER-4.
, PRUIO_ACT_TIM5  = 1 << 10  //!< Activate TIMER-5.
, PRUIO_ACT_TIM6  = 1 << 11  //!< Activate TIMER-6.
, PRUIO_ACT_TIM7  = 1 << 12  //!< Activate TIMER-7.
, PRUIO_DEF_ACTIVE = 0x1FFF  //!< Activate all subsystems.
, PRUIO_ACT_FREMUX = 0xFFF8   //!< Activate free LKM muxing
};


/** \brief Wrapper structure for BallSet.

\since 0.2
*/
typedef struct ballSet{
  uint32
    DeAd;  //!< Base address of Control Module subsystem.
  uint8 Value[PRUIO_AZ_BALL + 1];//!< The values of the pad control registers.
} ballSet;

/** \brief Wrapper structure for PruIo.

\since 0.0
*/
typedef struct pruIo{
  char* Errr;      //!< Pointer for error messages.

  adcUdt* Adc;     //!< Pointer to ADC subsystem structure.
  gpioUdt* Gpio;   //!< Pointer to GPIO subsystem structure.
  pwmssUdt* PwmSS; //!< Pointer to PWMSS subsystem structure.
  timerUdt* TimSS; //!< Pointer to TIMER subsystem structure.
  pwmMod* Pwm;     //!< Pointer to ePWM module structure (in PWMSS subsystem).
  capMod* Cap;     //!< Pointer to eCAP module structure (in PWMSS subsystem).
  qepMod* Qep;     //!< pointer to eQEP module structure (in PWMSS subsystem)
  timerUdt* Tim;   //!< Pointer to the TimSS structure (for homogenous API).

  uint32* DRam;    //!< Pointer to access PRU DRam.
  ballSet
    *Init,         //!< The subsystems register data at start-up (to restore subsystems at the end).
    *Conf;         //!< The subsystems register data used by libpruio (current local data).
  void
    *ERam,         //!< Pointer to read PRU external ram.
    *DInit,        //!< Pointer to block of subsystems initial data.
    *DConf,        //!< Pointer to block of subsystems configuration data.
    *MOffs;        //!< Configuration offset for modules.
  uint8
    *BallInit,     //!< Pointer for original Ball configuration.
    *BallConf;     //!< Pointer to ball configuration (CPU pin muxing).
  uint32
    EAddr,         //!< The address of the external memory (PRUSS-DDR).
    ESize,         //!< The size of the external memory (PRUSS-DDR).
    DSize,         //!< The size of a data block (DInit or DConf).
    PruNo,         //!< The PRU number to use (defaults to 1).
    PruIRam,       //!< The PRU instruction ram to load.
    PruDRam,       //!< The PRU data ram.
    PruIntNo;      //!< The PRU interrupt number.
  int16
    ParOffs,       //!< The offset for the parameters of a module.
    DevAct;        //!< Active subsystems.
  uint32
    BbType, //!< Type of Beaglebone board (1 = Pocket-, 0 = others)
    MuxFnr; //!< FreeBASIC file number for LKM pinmuxing
  char
    *MuxAcc,     //!< pathfile for dtbo pinmuxing
    (*setPin)(pruIo*, uint8, uint8); //!< callback function for LKM/dtbo pinmuxing
//! List of GPIO numbers, corresponding to ball index.
  uint8 BallGpio[PRUIO_AZ_BALL + 1];
//! Interrupt settings (we also set default interrupts, so that the other PRUSS can be used in parallel).
  struct __pruss_intc_initdata IntcInit;
} pruIo;

/** \brief Wrapper function for the constructor PruIo::PruIo().
\param Act The mask for active subsystems and PRU number.
\param Av The avaraging for default steps (0 to 16, defaults to 0).
\param OpD The open delay for default steps (0 to 0x3FFFF, defaults to 0x98).
\param SaD The sample delay for default steps (0 to 255, defaults to 0).
\returns A pointer for the new instance.

Since the constructor reads the original subsystem configurations and
the destructor restores them, it's recommended to create and use just
one PruIo instance at the same time.

\since 0.0
*/
pruIo* pruio_new(uint16 Act, uint8 Av, uint32 OpD, uint8 SaD);

/** \brief Wrapper function for the destructor PruIo::~PruIo().
\param Io The pointer of the instance.

\since 0.0
*/
void pruio_destroy(pruIo* Io);

/** \brief Wrapper function for PruIo::config().
\param Io The pointer of the  PruIo instance.
\param Samp The number of samples to fetch (defaults to zero).
\param Mask The mask for active steps (defaults to all 8 channels active in steps 1 to 8).
\param Tmr The timer value in [ns] to specify the sampling rate (defaults to zero, MM only).
\param Mds The modus for output bit encoding (defaults to 4 = 16 bit).
\returns Zero on success (otherwise a string with an error message).

\since 0.2
*/
char* pruio_config(pruIo* Io, uint32 Samp, uint32 Mask, uint32 Tmr, uint16 Mds);

/** \brief Wrapper function for PruIo::Pin().
\param Io The pointer of the  PruIo instance.
\param Ball The CPU ball number to describe.
\returns A human-readable text string (internal string, never free it).

\since 0.2
*/
char* pruio_Pin(pruIo* Io, uint8 Ball);

/** \brief Wrapper function for PruIo::mm_start().
\param Io The pointer of the  PruIo instance.
\param Trg1 Settings for first trigger (default = no trigger).
\param Trg2 Settings for second trigger (default = no trigger).
\param Trg3 Settings for third trigger (default = no trigger).
\param Trg4 Settings for fourth trigger (default = no trigger).
\returns Zero on success (otherwise a string with an error message).

\since 0.2
*/
char* pruio_mm_start(pruIo* Io, uint32 Trg1, uint32 Trg2, uint32 Trg3, uint32 Trg4);

/** \brief Wrapper function for PruIo::rb_start().
\param Io The pointer of the  PruIo instance.
\returns Zero on success (otherwise a string with an error message).

\since 0.2
*/
char* pruio_rb_start(pruIo* Io);


/** \brief Wrapper function for GpioUdt::config().
\param Io The pointer of the  PruIo instance.
\param Ball The CPU ball number to set.
\param Modus The mode for the GPIO.
\returns Zero on success (otherwise a pointer to an error message).

\since 0.2
*/
char* pruio_gpio_config(pruIo* Io, uint8 Ball, uint8 Modus);

/** \brief Wrapper function for GpioUdt::setValue().
\param Io The pointer of the  PruIo instance.
\param Ball The CPU ball number to set.
\param Modus The mode for the GPIO output.
\returns Zero on success (otherwise a pointer to an error message).

\since 0.2
*/
char* pruio_gpio_setValue(pruIo* Io, uint8 Ball, uint8 Modus);

/** \brief Wrapper function for GpioUdt::Value().
\param Io The pointer of the  PruIo instance.
\param Ball The CPU ball number to test.
\returns The GPIO state (otherwise -1, check  PruIo::Errr for an error message).

\since 0.2
*/
uint32 pruio_gpio_Value(pruIo* Io, uint8 Ball);


/** \brief Wrapper function for AdcUdt::setStep().
\param Io The pointer of the  PruIo instance.
\param Stp Step index (0 = step 0 => charge step, 1 = step 1 (=> AIN0 by default),  ..., 17 = idle step).
\param ChN Channel number to scan (0 = AIN0, 1 = AIN1, ...).
\param Av New value for avaraging (defaults to 4).
\param SaD New value for sample delay (defaults to 0).
\param OpD New value for open delay (defaults to 0x98).
\returns Zero on success (otherwise a string with an error message).

\since 0.2
*/
char* pruio_adc_setStep(pruIo* Io, uint8 Stp, uint8 ChN, uint8 Av, uint8 SaD, uint32 OpD);

/** \brief Wrapper function for AdcUdt::mm_trg_pin().
\param Io The pointer of the  PruIo instance.
\param Ball The CPU ball number to test.
\param GpioV The state to check (defaults to high = 1).
\param Skip The number of samples to skip (defaults to 0 = zero, max. 1023).
\returns The trigger configuration (or zero in case of an error, check  PruIo::Errr).

\since 0.2
*/
uint32 pruio_adc_mm_trg_pin(pruIo* Io, uint8 Ball, uint8 GpioV, uint16 Skip);


/** \brief Wrapper function for AdcUdt::mm_trg_ain().
\param Io The pointer of the  PruIo instance.
\param Stp The step number to use for trigger input.
\param AdcV The sample value to match (positive check greater than, negative check less than).
\param Rela If AdcV is relative to the current input.
\param Skip The number of samples to skip (defaults to 0 = zero, max. 1023).
\returns The trigger configuration (or zero in case of an error, check  PruIo::Errr).

\since 0.2
*/
uint32 pruio_adc_mm_trg_ain(pruIo* Io, uint8 Stp, int32 AdcV, uint8 Rela, uint16 Skip);

/** \brief Wrapper function for AdcUdt::mm_trg_pre().
\param Io The pointer of the  PruIo instance.
\param Stp The step number to use for trigger input.
\param AdcV The sample value to match (positive check greater than, negative check less than).
\param Samp The number of samples for the pre-trigger.
\param Rela If AdcV is relative to the current input.
\returns The trigger configuration (or zero in case of an error, check  PruIo::Errr).

\since 0.2
*/
uint32 pruio_adc_mm_trg_pre(pruIo* Io, uint8 Stp, int32 AdcV, uint16 Samp, uint8 Rela);


/** \brief Wrapper function for QepMod::config().
\param Io The pointer of the  PruIo instance.
\param Ball The CPU ball number (either input A, B or I).
\param PMax The maximum position counter value (defaults to &h7FFFFFFF).
\param VHz The frequency to compute velocity values (defaults to 25 Hz).
\param Scale The Scale factor for velocity values (defaults to 1.0).
\param Mo The modus to use for pinmuxing (0 or PRUIO_PIN_RESET).
\returns Zero on success (otherwise a string with an error message).

\since 0.4
*/
char* pruio_qep_config(pruIo* Io, uint8 Ball, uint32 PMax, float_t VHz, float_t Scale, uint8 Mo);

/** \brief Wrapper function for QepMod::Value().
\param Io The pointer of the  PruIo instance.
\param Ball The CPU ball number (as in QepMod::config() call).
\param Posi A pointer to store the position value (or NULL).
\param Velo A pointer to store the valocity value (or NULL).
\returns Zero on success (otherwise a string with an error message).

\since 0.4
*/
char* pruio_qep_Value(pruIo* Io, uint8 Ball, uint32* Posi, float_t* Velo);


/** \brief Wrapper function for CapMod::config().
\param Io The pointer of the  PruIo instance.
\param Ball The CPU ball number to configure.
\param FLow Minimal frequency to measure (> .0232831).
\returns Zero on success (otherwise a string with an error message).

\since 0.2
*/
char* pruio_cap_config(pruIo* Io, uint8 Ball, float_t FLow);

/** \brief Wrapper function for CapMod::Value().
\param Io The pointer of the  PruIo instance.
\param Ball The CPU ball number to test.
\param Hz A pointer to store the frequency value (or null).
\param Du A pointer to store the duty cycle value (or null).
\returns Zero on success (otherwise a string with an error message).

\since 0.2
*/
char* pruio_cap_Value(pruIo* Io, uint8 Ball, float_t* Hz, float_t* Du);


/** \brief Wrapper function for PwmMod::Value().
\param Io The pointer of the  PruIo instance.
\param Ball The CPU ball number to test.
\param Hz A pointer to store the frequency value (or null).
\param Du A pointer to store the duty cycle value (or null).
\returns Zero on success (otherwise a string with an error message).

\since 0.2
*/
char* pruio_pwm_Value(pruIo* Io, uint8 Ball, float_t* Hz, float_t* Du);

/** \brief Wrapper function for PwmMod::setValue().
\param Io The pointer of the PruIo instance
\param Ball the CPU ball number to set
\param Hz The frequency to set (or -1 for no change).
\param Du The duty cycle to set (0.0 to 1.0, or -1 for no change).
\returns Zero on success (otherwise a string with an error message).

\since 0.2
*/
char* pruio_pwm_setValue(pruIo* Io, uint8 Ball, float_t Hz, float_t Du);

/** \brief Wrapper function for TimerUdt::Value().
\param Io The pointer of the  PruIo instance.
\param Ball The header pin to configure.
\param Dur1 The duration in [ms] before state change (or 0 to stop timer).
\param Dur2 The duration in [ms] for the state change (or 0 for minimal duration).
\returns Zero on success, an error string otherwise.

\since 0.4
*/
char* pruio_tim_Value(pruIo* Io, uint8 Ball, float_t* Dur1, float_t* Dur2);

/** \brief Wrapper function for TimerUdt::setValue().
\param Io The pointer of the PruIo instance.
\param Ball The header pin to configure.
\param Dur1 The duration in [ms] before state change (or 0 to stop timer).
\param Dur2 The duration in [ms] for the state change (or 0 for minimal duration).
\param Mode The modus to set (defaults to 0 = one cycle positive pulse).
\returns Zero on success, an error string otherwise.

\since 0.4
*/
char* pruio_tim_setValue(pruIo* Io, uint8 Ball, float_t Dur1, float_t Dur2, uint16 Mode);

#ifdef __cplusplus
 }
#endif /* __cplusplus */
