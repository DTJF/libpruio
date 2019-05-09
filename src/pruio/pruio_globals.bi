/'* \file pruio_globals.bi
\brief FreeBASIC header file for global libpruio declares.

Header file for including global libpruio definitions and declarations.

\since 0.4.0
'/

' Common macros, shared with PRU pasm compiler
#INCLUDE ONCE "pruio.hp"

'* The NULL pointer
'#DEFINE NULL CAST(ANY PTR, 0)
#DEFINE NULL 0

'* The default setting for avaraging
#DEFINE PRUIO_DEF_AVRAGE 4
'* The default value for open delay in channel settings
#DEFINE PRUIO_DEF_ODELAY 183
'* The default value for sample delay in channel settings
#DEFINE PRUIO_DEF_SDELAY 0
'* The default number of samples to use (configures single mode)
#DEFINE PRUIO_DEF_SAMPLS 1
'* The default step mask (steps 1 to 8 for AIN-0 to AIN-7, no charge step)
#DEFINE PRUIO_DEF_STPMSK &b111111110
'* The default timer value (sampling rate in MM or RB mode)
#DEFINE PRUIO_DEF_TIMERV 0
'* The default bit mode (4 = 16 bit encoding)
#DEFINE PRUIO_DEF_LSLMOD 4
'* The default clock divisor (0 = full speed AFE = 24 MHz)
#DEFINE PRUIO_DEF_CLKDIV 0

'* Macro to check a CPU ball mode (ball must be in valid range, 0 to 109).
#DEFINE ModeCheck(_B_,_M_) (.BallConf[_B_] AND &b111) <> _M_
'* Macro to check a CPU ball mode.
#DEFINE ModeSet(_B_,_M_) IF .setPin(Top, _B_, _M_) THEN RETURN .Errr
'* Macro to start a PRU command.
#DEFINE PruReady(_I_) WHILE .DRam[1] : .WaitCycles += _I_ : WEND

TYPE AS   BYTE Int8    '*< 8 bit signed integer data type
TYPE AS  SHORT Int16   '*< 16 bit signed integer data type
TYPE AS   LONG Int32   '*< 32 bit signed integer data type
TYPE AS  UBYTE UInt8   '*< 8 bit unsigned integer data type
TYPE AS USHORT UInt16  '*< 16 bit unsigned integer data type
TYPE AS  ULONG UInt32  '*< 32 bit unsigned integer data type
TYPE AS SINGLE Float_t '*< float data type

TYPE AS    PruIo Pruio_    '*< Forward declaration
TYPE AS   AdcUdt AdcUdt_   '*< Forward declaration
TYPE AS  GpioUdt GpioUdt_  '*< Forward declaration
TYPE AS PwmssUdt PwmssUdt_ '*< Forward declaration
TYPE AS   PwmMod PwmMod_   '*< Forward declaration
TYPE AS   CapMod CapMod_   '*< Forward declaration
TYPE AS   QepMod QepMod_   '*< Forward declaration
TYPE AS TimerUdt TimerUdt_ '*< Forward declaration

'* Constants for pinmuxing: pullup/-down resistors and GPIO states
ENUM PinMuxing
  PRUIO_PULL_DOWN = &b000000 '*< Pulldown resistor connected
  PRUIO_NO_PULL   = &b001000 '*< No resistor connected
  PRUIO_PULL_UP   = &b010000 '*< Pullup resistor connected
  PRUIO_RX_ACTIV  = &b100000 '*< Input receiver enabled
  PRUIO_GPIO_OUT0 = 7 + PRUIO_NO_PULL                    '*< GPIO output low (no resistor)
  PRUIO_GPIO_OUT1 = 7 + PRUIO_NO_PULL + 128              '*< GPIO output high (no resistor)
  PRUIO_GPIO_IN   = 7 + PRUIO_NO_PULL + PRUIO_RX_ACTIV   '*< GPIO input (no resistor)
  PRUIO_GPIO_IN_0 = 7 + PRUIO_PULL_DOWN + PRUIO_RX_ACTIV '*< GPIO input (pulldown resistor)
  PRUIO_GPIO_IN_1 = 7 + PRUIO_PULL_UP + PRUIO_RX_ACTIV   '*< GPIO input (pullup resistor)
  PRUIO_PIN_RESET = &hFF
END ENUM
