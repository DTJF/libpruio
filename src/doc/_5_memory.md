Memory Organisation  {#ChaMemory}
===================
\tableofcontents

\Proj uses three blocks of memory to organize its data

- PruIo::DInit : A memory block of variable size in user space memory,
  allocated by \Proj, containing the data arrays PruIo::Init and
  PruIo::Conf.

- PruIo::DRam : A memory block of 2 x 8 kB on the PRUSS, mapped by the
  kernel driver uio_pruss for ARM access.

- PruIo::ERam : A contingous memory block of variable size (up to 8 MB)
  in kernel space memory, allocated by the kernel driver uio_pruss.

These blocks are available after the constructor call PruIo::PruIo()
and get destroyed in the destructor PruIo::~PruIo(). The constructor
reads the initial configuration of the CPU subsystems and stores the
values in PruIo::Init. Those values are used to restore the subsystems
in the destructor. PruIo::Conf contains the current configurations,
adapted by the user code.


# DInit # {#SecDInit}

The PruIo::DInit data block holds the register context of the
subsystems. It gets allocated by the constructor PruIo::PruIo(). Its
size is twice the size of all register sets. This is

- 1 x AdcSet
- 4 x GpioSet
- 1 x BallSet
- 3 x PwmssSet
- 4 x TimerSet

The pasm_init.p instructions prepares these structures for each
subsystem and sets the member variables by the values read from the
registers. All structures are packed in a single data block that gets
stored in DRam. The constructor allocates memory and makes one copy of
the block starting at adress PruIo::DInit and a second copy starting at
adress PruIo:DConf.

The first copy is used by the destructor PruIo::~PruIo() to restore the
original configuration. The second block is used for customized
configurations and gets transfered back to the subsystem registers in
the call to function PruIo::config(). The initialize member function of
the \Proj subsystems code (like GpioUdt::initialize() or
PwmssUdt::initialize() ) prepare further pointers for direct access to
the data block sections:

|            Pointer | Description                              |
| -----------------: | : -------------------------------------- |
|       PruIo::DInit | Start of initial block (= AdcUdt::Init)  |
|       AdcUdt::Init | Initial ADC configuration                |
|  GpioUdt::Init (0) | Initial GPIO-0 configuration             |
|  GpioUdt::Init (1) | Initial GPIO-1 configuration             |
|  GpioUdt::Init (2) | Initial GPIO-2 configuration             |
|  GpioUdt::Init (3) | Initial GPIO-3 configuration             |
|    PruIo::BallInit | Initial CM-pad configuration (pinmuxing) |
| PwmssUdt::Init (0) | Initial PWMSS-0 configuration            |
| PwmssUdt::Init (1) | Initial PWMSS-1 configuration            |
| PwmssUdt::Init (2) | Initial PWMSS-2 configuration            |
| TimerUdt::Init (0) | Initial TIMER4 configuration             |
| TimerUdt::Init (1) | Initial TIMER5 configuration             |
| TimerUdt::Init (2) | Initial TIMER6 configuration             |
| TimerUdt::Init (3) | Initial TIMER7 configuration             |
|       PruIo::DConf | Start of custom block (= AdcUdt::Conf)   |
|       AdcUdt::Conf | Custom ADC configuration                 |
|  GpioUdt::Conf (0) | Custom GPIO-0 configuration              |
|  GpioUdt::Conf (1) | Custom GPIO-1 configuration              |
|  GpioUdt::Conf (2) | Custom GPIO-2 configuration              |
|  GpioUdt::Conf (3) | Custom GPIO-3 configuration              |
|    PruIo::BallConf | Custom CM-pad configuration (pinmuxing)  |
| PwmssUdt::Conf (0) | Custom PWMSS-0 configuration             |
| PwmssUdt::Conf (1) | Custom PWMSS-1 configuration             |
| PwmssUdt::Conf (2) | Custom PWMSS-2 configuration             |
| TimerUdt::Conf (0) | Custom TIMER4 configuration              |
| TimerUdt::Conf (1) | Custom TIMER5 configuration              |
| TimerUdt::Conf (2) | Custom TIMER6 configuration              |
| TimerUdt::Conf (3) | Custom TIMER7 configuration              |

In order to minimize memory consumption \Proj may generate
uncomplete subsystem sets. In such a set only the first four member
variables are valid (DeAd, ClAd, ClVa, [REVISION, IDVER]). Such reduced
sets get generated

- when a subsystem should get ignored, that is its activate bit isn't
  set in the parameter *Act* in the constructor call (member variable
  `ClAd = 0`), or

- when a subsystem didn't wake up due to a hardware failure (member
  variable `[REVISION | IDVER] = 0`).

After the constructor call also the member variable ClVa in the *Conf*
section is set to 0 (zero) for uncomplete sets. When you intent to
access the subsystems sets directly, you must check if the set is
complete, first. This is the case when member variable `ClVa = 2`.

\note It's forbidden to write to variables in an uncomplete subsystem
      set. This can destroy the following set in the data block and may
      result in non-revisible hardware damages.


# DRam # {#SecDRam}

The DRam area (data ram) is a fixed sized block of `2 * 8` kB,
allocated by the PRUSS kernel driver. The host (ARM) can access only
the first 8 KB block, but the PRU software may use both blocks in MM
mode in case of a great number of pre-trigger samples.

The PruIo::DRam pointer (type UInt32) gets initialized by the
constructor PruIo::PruIo() and points to the DRam of the used PRUSS.
This is DRam-0 when the PRU bit of parameter *Act* is cleared and
DRam-1 when the bit is set (the default).

The first value (PruIo::DRam `[0]` is always used to report the state
of the PRUSS software. It contains either one of the message codes
defined in file pruio.hp or it contains the index of the last stored
sample (in RB or MM mode).

The rest of the DRam area is used for exchanging parameters between the
host (ARM) and the PRU software. The context changes, depending on the
current operational state of \Proj.


## Constructor ## {#sSecMemCTOR}

Before the constructor loads and executes the pasm_init.p instructions,
it calls the constructors of the subsystem structures AdcUdt, GpioUdt
and PwmssUdt. These initialize the DRam area with the adresses for the
subsystems and their Control Module (CM) clock register. So before that
instructions the DRam area contains

|   Value  | Description                                |
| -------: | : ---------------------------------------- |
|  DRam[1] | Start of the data block                    |
|  DRam[2] | Base Adress of ADC subsystem registers     |
|  DRam[3] | Adress of the ADC clock register           |
|  DRam[4] | Base Adress of GPIO-0 subsystem registers  |
|  DRam[5] | Adress of the GPIO-0 clock register        |
|  DRam[6] | Base Adress of GPIO-1 subsystem registers  |
|  DRam[7] | Adress of the GPIO-1 clock register        |
|  DRam[8] | Base Adress of GPIO-2 subsystem registers  |
|  DRam[9] | Adress of the GPIO-2 clock register        |
| DRam[10] | Base Adress of GPIO-3 subsystem registers  |
| DRam[11] | Adress of the GPIO-3 clock register        |
| DRam[12] | Base Adress of CM-pad registers            |
| DRam[13] | Base Adress of PWMSS-0 subsystem registers |
| DRam[14] | Adress of the PWMSS-0 clock register       |
| DRam[15] | Base Adress of PWMSS-1 subsystem registers |
| DRam[16] | Adress of the PWMSS-1 clock register       |
| DRam[17] | Base Adress of PWMSS-2 subsystem registers |
| DRam[18] | Adress of the PWMSS-2 clock register       |
| DRam[19] | Base Adress of TIMER4 subsystem registers  |
| DRam[20] | Adress of the TIMER4 clock register        |
| DRam[21] | Base Adress of TIMER5 subsystem registers  |
| DRam[22] | Adress of the TIMER5 clock register        |
| DRam[23] | Base Adress of TIMER6 subsystem registers  |
| DRam[24] | Adress of the TIMER6 clock register        |
| DRam[25] | Base Adress of TIMER7 subsystem registers  |
| DRam[26] | Adress of the TIMER7 clock register        |

In case of an inactive subsystem (configuration bit in parameter *Act*
cleared) the clock adress is set to 0 (zero) so that the PRU can still
read the subsystems identifier (REVISION, IDVER).

Otherwise the PRU reads the complete register context of the subsystem
and stores the context in the data block. When a block of subsystems
(ADC, 4xGPIO, CM, 3xPWMSS) is finished, the offset of the next block
gets written to the last parameter. So after the pasm_init.p
instructions, the DRam area contains the following information:

|    Value  | Description                     |
| --------: | : ----------------------------- |
|   DRam[0] | PRUIO_MSG_INIT_OK               |
|   DRam[1] | Offset of ADC register block    |
|   DRam[3] | Offset of GPIO register block   |
|  DRam[11] | Offset of CM-pad register block |
|  DRam[12] | Offset of PWMSS register block  |
|  DRam[18] | Length of complete data block   |
| DRam[128] | Data block context              |

The constructor PruIo::PruIo() generates two copies of the data block
in host memory (at PruIo::DInit and PruIo::DConf) and calls the
initialize() member functions of the subsystems (ie.
AdcUdt::initialize(), GpioSet::initialize() ), where the pointers (ie.
AdcUdt::Init and AdcUdt::Conf) to the individual register sets (ie.
AdcSet, GpioSet) get initialized.

This method allows to extend \Proj by new subsystem code with
minimal adaption in the existing source.


## config ## {#sSecMemConfig}

The function PruIo::config() uploads the customized configuration to
the subsystems and starts operation in the declared run mode. Before
the pasm_run.p instructions get executed, the DRam area contains

|     Value  | Description                       |
| ---------: | : ------------------------------- |
|    DRam[1] | Start of the data block           |
|    DRam[2] | Number of samples AdcUdt::Samples |
|    DRam[3] | Step mask AdcSet::STEPENABLE      |
|    DRam[4] | Bit encoding mode AdcUdt::LslMode |
|    DRam[5] | Timer value AdcUdt::TimerVal      |
| DRam[128-] | Conf data block context           |

The PRU software reads these parameters and writes the configuration to
the subsystem registers. Then it prepares the DRam area as follows

|    Value   | Description                        |
|   -------: | : -------------------------------- |
|    DRam[0] | PRUIO_MSG_xxx                      |
| DRam[1-15] | free for var. parameters           |
|   DRam[16] | 4 x GpioArr (4*16 bytes)           |
|   DRam[64] | 3 x PwmssArr (3*32 bytes)          |
|   DRam[72] | AdcSet::DeAd (4 bytes)             |
|   DRam[73] | 17 x AdcUdt::Value data (34 bytes) |
|   DRam[89] | 4 x TimerArr (4*16 bytes)          |

The type of PRUIO_MSG_xxx depends on the required run mode. It's either
\ref PRUIO_MSG_IO_OK in case of IO mode (parameter *Samp* = 1) or \ref
PRUIO_MSG_MM_WAIT in case of RB or MM mode (parameter *Samp* > 1).

The arrays GpioArr, PwmssArr and TimerArr are used to transfer data
from the digital subsystems to the host. In IO and RB mode the PRU
software reads some registers and writes the context in to these
arrays, where the host (ARM) software can read them.

The field `Adc data` contains the subsystem adress of the ADC subsystem
(if enabled) and 17 UInt16 values for samples (the first is unused).

- In IO mode it contains the sampled data (AdcUdt::Value).

- In RB mode it's not used.

- In MM mode it contains the ring buffer for pre-trigger samples and
  its size vary. Depending on the number of pre-trigger samples the
  DRam areas of both PRUSS may be used.

Each array entry starts with the subsystem adress. In case of a
disabled subsystem the adress entry is 0 (zero) and the PRU software
skips this subsystem.

In IO mode the PRU main loop starts immediately, while in RB or MM mode
the PRU is halted after configuration, waiting for a start command. The
main loop starts when the ARM writes a non-zero value to DRam[1]:

- Function PruIo::rb_start()
  |  Value  | Description                       |
  | ------: | : ------------------------------- |
  | DRam[1] | Number of samples AdcUdt::Samples |
  | DRam[2] | Adress of ERam PruIo::ERam        |
  | DRam[3] | Pre-trigger samples (= 0)         |
  | DRam[4] | Trigger specification (= RB mode) |
  When running in RB mode the PRU software does not stop, reporting its
  last write index endlessly (in order to stop the main loop, call
  PruIo::config() again)
  |  Value  | Description                                                |
  | ------: | : -------------------------------------------------------- |
  | DRam[0] | Last write index `0 <= i < AdcUdt::Samples * AdcUdt::ChAz` |

- Function PruIo::mm_start()
  |  Value  | Description                       |
  | ------: | : ------------------------------- |
  | DRam[1] | Number of samples AdcUdt::Samples |
  | DRam[2] | Adress of ERam PruIo::ERam        |
  | DRam[3] | Pre-trigger samples               |
  | DRam[4] | Trigger 1 specification           |
  | DRam[5] | Trigger 2 specification           |
  | DRam[6] | Trigger 3 specification           |
  | DRam[7] | Trigger 4 specification           |
  After performing a maesurement in MM mode the PRU software reports success
  |  Value  | Description       |
  | ------: | ----------------- |
  | DRam[0] | PRUIO_MSG_MM_WAIT |

Further PRU commands get executed while the main loop is running. Find
details in section \ref SecCommands.


## Destructor ## {#sSecMemDTOR}

The destructor PruIo::~PruIo() restores the subsystems before the PruIo
structure gets destroyed. It load the initial configuration data block
to the DRam and executes the configuration instruction on the PRU.
Therefor it prepares the DRam area as in the following table:

|    Value  | Description             |
| --------: | : --------------------- |
|   DRam[1] | Start of the data block |
|   DRam[2] | Number of samples (= 0) |
| DRam[128] | Init data block context |

When the PRU finished successfully the DRam area contains

|  Value  | Description       |
| ------: | : --------------- |
| DRam[0] | PRUIO_MSG_CONF_OK |


# ERam # {#SecERam}

The ERam area (external memory) is the biggest memory block in use.
It's allocated by the kernel driver when loaded. The default size is
256 kB (= 128 kSamples). \Proj uses the external memory in RB and MM
mode to store the ADC samples.

In both cases the number of total samples (`= AdcUdt::Samples x
AdcUdt::ChAz`) must not be greater than the available number of samples
in the external memory. The block size is available in member variable
PruIo::ESize. The pointer AdcUdt::Samples gets set to the start of
the ERam block.

The kernel driver allows to customize the size of the external memory.
This must be done at driver loading time. Ie. execute (with admin
privileges) `modprobe uio_pruss extram_pool_sz=0x800000` to set the
maximum size of 8 MB (= 0x800000).

\note The kernel driver also gets loaded by a device tree overlay that
      enables the PRUSS. Make sure that the above command gets executed
      before the device tree overlay loads. (Or unload the kernel
      driver by `modprobe -r uio_pruss` and reload again using the
      above command.)


# Pru Commands # {#SecCommands}

In order to send data from ARM to PRU, ie to change a GPIO output state
or the parameters of a PWM pulse train, there's a programming interface
in the DRam[1-15] area. When the PRU is running in the main loop, in
each cycle it first grabs the data from one of the (active) subsystems
(GPIO, PWM, TIMER) and then performs a command, if any.

Therefor it checks the upper most (`SHL 24`) byte in DRam[1]. When it's
greater than zero, the PRU reads the related parameters from DRam[2-15]
and performs the desired action. Finally the PRU clears the DRam[1]
data, in order to signalize the finished command execution.

From the ARM side of view this means

-# first check if (wait until) no command is pending
-# set the parameters
-# set the command to execute

The PRU executes this command at the end of the next main loop cycle in
parallel. Meanwhile the ARM can perform the next steps.

The PRU commands are (non-zero) byte values defined in file
src/pruio/pruio.hp and named like PRUIO_COM_xxx. Here's a list of the
commands and their parameters:

- GPIO \ref PRUIO_COM_GPIO_CONF (set GPIO direction and value)
  |  Value  | Description                              |
  | ------: | : -------------------------------------- |
  | DRam[1] | PRUIO_COM_GPIO_CONF `SHL 24`             |
  | DRam[2] | GPIO subsystem adress (+ &h100)          |
  | DRam[3] | Value for GpioSet::CLEARDATAOUT register |
  | DRam[4] | Value for GpioSet::SETDATAOUT register   |
  | DRam[5] | Value for GpioSet::OE register           |

- PWMSS-PWM \ref PRUIO_COM_PWM (set PWM frequency and duty cycle)
  |  Value  | Description                                             |
  | ------: | : ----------------------------------------------------- |
  | DRam[1] | PRUIO_COM_PWM `SHL 24`                                  |
  | DRam[2] | PWMSS subsystem adress (+ &h200)                        |
  | DRam[3] | Value for PwmssSet::CMPA & PwmssSet::CMPB registers     |
  | DRam[4] | Value for PwmssSet::AQCTLA & PwmssSet::AQCTLB registers |
  | DRam[5] | Value for PwmssSet::TBCNT & PwmssSet::TBPRD registers   |

- PWMSS-CAP-CAP \ref PRUIO_COM_CAP_PWM (set PWMSS-CAP module in PWM mode
  and set frequency and duty cycle)
  |  Value  | Description                                                  |
  | ------: | : ---------------------------------------------------------- |
  | DRam[1] | PRUIO_COM_CAP_PWM `SHL 24` + PwmssSet::ECCTL2 register value |
  | DRam[2] | PWMSS subsystem adress (+ &h100)                             |
  | DRam[3] | Value for PwmssSet::CAP3 register (counter shadow)           |
  | DRam[4] | Value for PwmssSet::CAP4 register (period shadow)            |

- PWMSS-CAP-PWM \ref PRUIO_COM_CAP (set PWMSS-CAP module in CAP mode)
  |  Value  | Description                                              |
  | ------: | : ------------------------------------------------------ |
  | DRam[1] | PRUIO_COM_CAP `SHL 24` + PwmssSet::ECCTL2 register value |
  | DRam[2] | PWMSS subsystem adress (+ &h100)                         |

- PWMSS-QEP \ref PRUIO_COM_QEP (set PWMSS-QEP module in QEP mode)
  |  Value  | Description                                              |
  | ------: | : ------------------------------------------------------ |
  | DRam[1] | PRUIO_COM_QEP `SHL 24`                                   |
  | DRam[2] | PWMSS subsystem adress (+ &h100)                         |
  | DRam[3] | Value for PwmssSet::QPOSMAX register                     |
  | DRam[4] | Value for PwmssSet::QUPRD register                       |
  | DRam[5] | Value for PwmssSet::.QDECCTL OR .QEPCTL SHL 16 registers |
  | DRam[6] | Value for PwmssSet::QCAPCTL register                     |

- TIMER PWM; \ref PRUIO_COM_TIM_PWM (set TIMERSS in PWM mode)
  |  Value  | Description                                                |
  | ------: | : -------------------------------------------------------- |
  | DRam[1] | PRUIO_COM_TIM_PWM `SHL 24` + TimerSet::TCLR register value |
  | DRam[2] | TIMER subsystem adress                                     |
  | DRam[3] | timer load register value                                  |
  | DRam[4] | timer match register value                                 |
  | DRam[5] | timer counter register value                               |

- ADC steps \ref PRUIO_COM_ADC (set a new step mask in IO mode)
  |  Value  | Description                                                |
  | ------: | : -------------------------------------------------------- |
  | DRam[1] | PRUIO_COM_ADC `SHL 24` + AdcSet::STEPENABLE register value |

\note PRU commands are valid in IO and RB mode. After a PRU command
      execution the DRam[1] value gets set to 0 (zero). You must wait
      for that zero value before you set a new command or write new
      parameters.


