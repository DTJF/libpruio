Memory Organisation  {#ChaMemory}
===================

libpruio uses three blocks of memory to organize its data

- PruIo::DInit : A memory block of variable size, allocated by
  libpruio, containing the data arrays PruIo::Init and PruIo::Conf.

- PruIo::DRam : A memory block of 2 x 8 kB, allocated by the kernel
  driver uio_pruss.

- PruIo::ERam : A memory block variable size (up to 8 MB), allocated by
  the kernel driver uio_pruss.

These blocks are available after the constructor PruIo::PruIo() call
and get destroyed in the destructor PruIo::~PruIo().


DInit {#SecDInit}
=====

The PruIo::DInit data block holds the register context of the
subsystems. It gets allocated by the constructor PruIo::PruIo(). Its
size is twice the size of all register sets. This is

- 1 x AdcSet
- 4 x GpioSet
- 1 x BallSet
- 3 x PwmssSet

The pasm_init.p instructions prepares these structures for each
subsystem and sets the member variables by the values read from the
registers. All structures are packed in a single data block that gets
stored in DRam. The constructor allocates memory and makes one copy of
the block starting at adress PruIo::DInit and a second copy starting at
adress PruIo:DConf.

The first copy is used by the destructor PruIo::~PruIo to restore the
original configuration. The second block is used for customized
configurations and gets transfered back to the subsystem registers in
the call to function PruIo::config(). The initialize member function of
the libpruio subsystems code (like GpioUdt::initialize() or
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

In order to minimize memory consumption libpruio may generate
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


DRam {#SecDRam}
====

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
current operational state of libpruio.


Constructor {#SubSecMemCTOR}
-----------

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

This method allows to extend libpruio by new subsystem code with
minimal adaption in the existing source.


config {#SubSecMemConfig}
------

The function PruIo::config() uploads the customized configuration to
the subsystems and starts operation in the declared run mode. Before
the pasm_run.p instructions get executed, the DRam area contains

|    Value  | Description                       |
| --------: | : ------------------------------- |
|   DRam[1] | Start of the data block           |
|   DRam[2] | Number of samples AdcUdt::Samples |
|   DRam[3] | Step mask AdcSet::STEPENABLE      |
|   DRam[4] | Bit encoding mode AdcUdt::LslMode |
|   DRam[5] | Timer value AdcUdt::TimerVal      |
| DRam[128] | Conf data block context           |

The PRU software reads these parameters and writes the configuration to
the subsystem registers. Then it prepares the DRam area as follows

|   Value  | Description           |
| -------: | : ------------------- |
|  DRam[0] | PRUIO_MSG_xxx         |
| DRam[16] | 4xGpioArr (64 bytes)  |
| DRam[32] | 3xPwmssArr (96 bytes) |
| DRam[56] | ADC data (38 bytes)   |

The type of PRUIO_MSG_xxx depends on the required run mode. It's either
\ref PRUIO_MSG_IO_OK in case of IO mode (parameter *Samp* = 1) or \ref
PRUIO_MSG_MM_WAIT in case of RB or MM mode (parameter *Samp* > 1).

The arrays GpioArr and PwmssArr are used to transfer data from the
digital subsystems to the host. In IO and RB mode the PRU software
reads some registers and writes the context in to these arrays, where
the host (ARM) software can read them.

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

Furthermore the beginning of the DRam area is used to pass parameters
to the running PRU software

- Function PruIo::rb_start()
  |  Value  | Description                       |
  | ------: | : ------------------------------- |
  | DRam[1] | Number of samples AdcUdt::Samples |
  | DRam[2] | Adress of ERam PruIo::ERam        |
  | DRam[3] | Pre-trigger samples (= 0)         |
  | DRam[4] | Trigger specification (= RB mode) |
  When running in RB mode the PRU software reports its last write index
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

- PRU command \ref PRUIO_COM_GPIO_CONF (set GPIO direction and value)
  |  Value  | Description                              |
  | ------: | : -------------------------------------- |
  | DRam[1] | PRUIO_COM_GPIO_CONF `shl 24`             |
  | DRam[2] | GPIO subsystem adress (+ &h100)          |
  | DRam[3] | Value for GpioSet::CLEARDATAOUT register |
  | DRam[4] | Value for GpioSet::SETDATAOUT register   |
  | DRam[5] | Value for GpioSet::OE register           |

- PRU command \ref PRUIO_COM_GPIO_OUT (set GPIO outputs)
  |  Value  | Description                              |
  | ------: | : -------------------------------------- |
  | DRam[1] | PRUIO_COM_GPIO_OUT `shl 24`              |
  | DRam[2] | GPIO subsystem adress (+ &h100)          |
  | DRam[3] | Value for GpioSet::CLEARDATAOUT register |
  | DRam[4] | Value for GpioSet::SETDATAOUT register   |

- PRU command \ref PRUIO_COM_PWM (set PWM frequency and duty cycle)
  |  Value  | Description                                             |
  | ------: | : ----------------------------------------------------- |
  | DRam[1] | PRUIO_COM_PWM `shl 24`                                  |
  | DRam[2] | PWMSS subsystem adress (+ &h200)                        |
  | DRam[3] | Value for PwmssSet::CMPA & PwmssSet::CMPB registers     |
  | DRam[4] | Value for PwmssSet::AQCTLA & PwmssSet::AQCTLB registers |
  | DRam[5] | Value for PwmssSet::TBCNT & PwmssSet::TBPRD registers   |

- PRU command \ref PRUIO_COM_PWM_CAP (switch PWMSS-CAP module in PWM mode
  and set frequency and duty cycle)
  |  Value  | Description                                                  |
  | ------: | : ---------------------------------------------------------- |
  | DRam[1] | PRUIO_COM_PWM_CAP `shl 24` + PwmssSet::ECCTL2 register value |
  | DRam[2] | PWMSS subsystem adress (+ &h100)                             |
  | DRam[3] | Value for PwmssSet::CAP3 register (counter shadow)           |
  | DRam[4] | Value for PwmssSet::CAP4 register (period shadow)            |

- PRU command \ref PRUIO_COM_CAP (switch PWMSS-CAP module in CAP mode)
  |  Value  | Description                                              |
  | ------: | : ------------------------------------------------------ |
  | DRam[1] | PRUIO_COM_CAP `shl 24` + PwmssSet::ECCTL2 register value |
  | DRam[2] | PWMSS subsystem adress (+ &h100)                         |

- PRU command \ref PRUIO_COM_ADC (set a new step mask in IO mode)
  |  Value  | Description                                                |
  | ------: | : -------------------------------------------------------- |
  | DRam[1] | PRUIO_COM_ADC `shl 24` + AdcSet::STEPENABLE register value |

\note PRU commands are valid in IO and RB mode. After a PRU command
      execution the DRam[1] value gets set to 0 (zero). You must wait
      for that zero value before you set a new command or write new
      parameters.


Destructor {#SubSecMemDTOR}
----------

The destructor PruIo::~PruIo restores the subsystems before the PruIo
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


ERam {#SecERam}
====

The ERam area (external memory) is the biggest memory block in use.
It's allocated by the kernel driver when loaded. The default size is
256 kB (= 128 kSamples). libpruio uses the external memory in RB and MM
mode to store the ADC samples.

- In RB mode the size of the ring buffer is limited by the size of the
  external ram.

- And in MM mode the number of total samples (`= AdcUdt::Samples x
  AdcUdt::ChAz`) must not be greater than the available number of
  samples in the external memory.

The kernel driver allows to customize the size of the external memory.
This must be done at the first driver loading. Ie. execute (with admin
privileges) `modprobe uio_pruss extram_pool_sz=0x800000` to set the
maximum size of 8 MB (= 0x800000).

\note The kernel driver also gets loaded by a device tree overlay that
      enables the PRUSS. Make sure that the above command gets executed
      before the device tree overlay loads. (Or unload the kernel
      driver by `modprobe -r uio_pruss` and reload again using the
      above command.)
