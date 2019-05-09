/'* \file pruio_prussdrv.bas
\brief Source code for kernel driver handling.

In previous versions \Proj was dependant on libprussdrv, a driver
library for the `uio_pruss` kernel module. Since this driver isn't
available in the upstream Debian repositories, compiling from source
was required for users. Once I started to fix some downsides in the
original library code, I came up with this code here, reduced to the
bare minimum and mostly compatible to the original API. Find further
information on the PRUSS, the pasm assembler and the original prussdrv
function in the [am335x_pru_package at
GitHub.](https://github.com/beagleboard/am335x_pru_package/tree/master/Documentation)

In the second part the utility functions for the new loadable kernel
module are included.

\since 0.6
'/

' Basic header
#INCLUDE ONCE "dir.bi"
' The header for kernel drivercode.
#INCLUDE ONCE "pruio_prussdrv.bi"
' Header file with pin arrays.
#INCLUDE ONCE "pruio_boardpins.bi"


'* \brief The data structure, global at module level.
DIM SHARED AS tprussdrv PRUSSDRV

'* The page size for memory maps
#DEFINE PAGE_SIZE 4096

' PRUSS INTC register offsets
'* Global interrupt enable register
#DEFINE PRU_INTC_GER_REG     &h010
'* Host interrupt enable indexed set register
#DEFINE PRU_INTC_HIEISR_REG  &h034
'* System event status register 0-31
#DEFINE PRU_INTC_SRSR0_REG   &h200
'* System event status register 32-63
#DEFINE PRU_INTC_SRSR1_REG   &h204
'* System event enable/clear register 0-31
#DEFINE PRU_INTC_SECR0_REG   &h280
'* System event enable/clear register 32-63
#DEFINE PRU_INTC_SECR1_REG   &h284
'* System event enable set register 0-31
#DEFINE PRU_INTC_ESR0_REG    &h300
'* System event enable set register 0-31
#DEFINE PRU_INTC_ESR1_REG    &h304
'* The channel map register
#DEFINE PRU_INTC_CMR0_REG    &h400
'* Host interrupt map register, channels 0 to 3
#DEFINE PRU_INTC_HMR0_REG    &h800
'* System event polarity register, events 0 to 31
#DEFINE PRU_INTC_SIPR0_REG   &hD00
'* System event polarity register, events 32 to 63
#DEFINE PRU_INTC_SIPR1_REG   &hD04
'* System event type register, events 0 to 31
#DEFINE PRU_INTC_SITR0_REG   &hD80
'* System event type register, events 31 to 63
#DEFINE PRU_INTC_SITR1_REG   &hD84

'* The maximal number of host events
#DEFINE MAX_HOSTS_SUPPORTED 10

'* The size of the read buffer.
#DEFINE PRUSS_UIO_PARAM_VAL_LEN 20
'* The file with pinmux information.
#DEFINE KERNEL_PINMUX_PINS "/sys/kernel/debug/pinctrl/44e10800.pinmux/pinmux-pins"

'#include once "crt/fcntl.bi" ' from: bits/fnctl-linux.h
'* The size type
TYPE AS UInt32 size_t
'* The signed size type
TYPE AS Int32 ssize_t

'* File acess mode
#DEFINE O_ACCMODE  &o003
'* File read only mode
#DEFINE O_RDONLY   &o0
'* File write only mode
#DEFINE O_WRONLY   &o1
'* File read/write mode
#DEFINE O_RDWR     &o2
'* File create mode
#DEFINE O_CREAT    &o100  ' Not fcntl.
'* Fail if file exists
#DEFINE O_EXCL     &o200  ' Not fcntl.
'* No tty mode
#DEFINE O_NOCTTY   &o400  ' Not fcntl.
'* File truncate to 0
#DEFINE O_TRUNC    &o1000 ' Not fcntl.
'* File append mode
#DEFINE O_APPEND   &o2000
'* File non blocking mode
#DEFINE O_NONBLOCK &o4000
'* File no delay mode
#DEFINE O_NDELAY   O_NONBLOCK
'* File write IO mode
#DEFINE O_SYNC     &o4010000

' from: bits/mman-linux.h
'* Page can be read
#DEFINE PROT_READ      &h1 '
'* Page can be written
#DEFINE PROT_WRITE     &h2
'* Page can be executed
#DEFINE PROT_EXEC      &h4
'* Page can not be accessed
#DEFINE PROT_NONE      &h0
'*Extend change to start of growsdown vma (mprotect only)
#DEFINE PROT_GROWSDOWN &h01000000
'*Extend change to start of growsup vma (mprotect only)
#DEFINE PROT_GROWSUP   &h02000000

'* Share changes
#DEFINE  MAP_SHARED &h01
'* Changes are private
#DEFINE MAP_PRIVATE &h02
#IFDEF __USE_MISC
 '* Mask for type of mapping
 #DEFINE   MAP_TYPE &h0f
#ENDIF

'* The offset type
TYPE AS Int32 off_t
'* The adress type
TYPE AS ANY PTR addr_t
'* The character adress type
TYPE AS UInt8 PTR caddr_t

'* \brief Internal: declaration for C runtime function mmap().
DECLARE FUNCTION mmap CDECL ALIAS "mmap"(BYVAL AS addr_t, BYVAL AS size_t, BYVAL AS Int32, BYVAL AS Int32, BYVAL AS Int32, BYVAL AS off_t) AS caddr_t
'* \brief Internal: declaration for C runtime function memcpy().
DECLARE FUNCTION memcpy CDECL ALIAS "memcpy"(BYVAL AS ANY PTR, BYVAL AS ANY PTR, BYVAL AS size_t) AS ANY PTR
'* \brief Internal: declaration for C runtime function munmap().
DECLARE FUNCTION munmap CDECL ALIAS "munmap"(BYVAL AS ANY PTR, BYVAL AS size_t) AS Int32
'* \brief Internal: declaration for C runtime function open().
DECLARE FUNCTION open_ CDECL ALIAS "open"(BYVAL AS CONST ZSTRING PTR, BYVAL AS Int32, ...) AS Int32
'* \brief Internal: declaration for C runtime function read().
DECLARE FUNCTION read_ CDECL ALIAS "read"(BYVAL AS Int32, BYVAL AS ANY PTR, BYVAL AS size_t) AS ssize_t
'* \brief Internal: declaration for C runtime function close().
DECLARE FUNCTION close_ CDECL ALIAS "close"(BYVAL AS Int32) AS Int32


/'* \brief Internal: set CMR register.
\param Intc The interrupt controller number.
\param Event The event number.
\param Ch The channel to set

This is an internal service function.

\since 0.6
'/
SUB __prussintc_set_cmr CDECL(BYVAL Intc AS UInt32 PTR, BYVAL Event AS UInt16, BYVAL Ch AS UInt16)
  Intc[(PRU_INTC_CMR0_REG + (Event AND NOT(&b11))) SHR 2] _
      OR= ((Ch AND &b1111) SHL ((Event AND &b11) SHL 3))
END SUB


/'* \brief Internal: set HMR register.
\param Intc The interrupt controller number.
\param Ch The channel to set
\param Host The host number.

This is an internal service function.

\since 0.6
'/
SUB __prussintc_set_hmr CDECL(BYVAL Intc AS UInt32 PTR, BYVAL Ch AS UInt16, BYVAL Host AS UInt16)
  Intc[(PRU_INTC_HMR0_REG     + (Ch AND NOT(&b11))) SHR 2] _
    = Intc[(PRU_INTC_HMR0_REG + (Ch AND NOT(&b11))) SHR 2] _
     OR (((Host) AND &b1111) SHL (((Ch) AND &b11) SHL 3))
END SUB


/'* \brief Internal: initialize memory pointers.
\returns 0 (zero) on success, otherwise a negative error number.

This internal function reads the files from `uio_pruss` kernel driver
and computes pointers to the different memory areas. In contrast to the
original libprussdrv code, the function here gets called only once.

\since 0.6
'/
FUNCTION __prussdrv_memmap_init CDECL(BYVAL IrqFd AS Int32) AS Int32
  WITH PRUSSDRV
    DIM AS STRING*PRUSS_UIO_PARAM_VAL_LEN buff = ""

    VAR fd = open_("/sys/class/uio/uio0/maps/map0/size", O_RDONLY) : IF fd < 0 THEN RETURN -11
    read_(fd, @buff, PRUSS_UIO_PARAM_VAL_LEN)
    .pruss_map_size = VALINT("&h" + MID(buff, 3))
    close_(fd)

    fd = open_("/sys/class/uio/uio0/maps/map1/addr", O_RDONLY) : IF fd < 0 THEN RETURN -12
    read_(fd, @buff, PRUSS_UIO_PARAM_VAL_LEN)
    .extram_phys_base = VALINT("&h" + MID(buff, 3))
    close_(fd)

    fd = open_("/sys/class/uio/uio0/maps/map1/size", O_RDONLY) : IF fd < 0 THEN RETURN -13
    read_(fd, @buff, PRUSS_UIO_PARAM_VAL_LEN)
    .extram_map_size = VALINT("&h" + MID(buff, 3))
    close_(fd)

    .mmap_fd = IrqFd

    .pru0_dataram_base = mmap( _
        0, .pruss_map_size, PROT_READ OR PROT_WRITE, _
        MAP_SHARED, .mmap_fd, 0 * PAGE_SIZE)

    .pru1_dataram_base = .pru0_dataram_base _
                       + .pru1_dataram_phy_base - .pru0_dataram_phy_base
            .intc_base = .pru0_dataram_base _
                       + .intc_phy_base         - .pru0_dataram_phy_base
    .pru0_control_base = .pru0_dataram_base _
                       + .pru0_control_phy_base - .pru0_dataram_phy_base
    .pru1_control_base = .pru0_dataram_base _
                       + .pru1_control_phy_base - .pru0_dataram_phy_base
       .pru0_iram_base = .pru0_dataram_base _
                       + .pru0_iram_phy_base    - .pru0_dataram_phy_base
       .pru1_iram_base = .pru0_dataram_base _
                       + .pru1_iram_phy_base    - .pru0_dataram_phy_base
    .pruss_sharedram_base = .pru0_dataram_base _
                       + .pruss_sram_phy_base   - .pru0_dataram_phy_base

    .extram_base = mmap( _
         0, .extram_map_size, PROT_READ OR PROT_WRITE, _
         MAP_SHARED, .mmap_fd, 1 * PAGE_SIZE)
  END WITH : RETURN 0
END FUNCTION


/'* \brief Open an kernel driver interrupt file.
\param Irq The interrupt number.
\returns 0 (zero) on success, otherwise a negative error number

The function tries to open an interrupt file `dev/uio[0-7]`,
corresponding to Host[2-9] of the PRU INTC. In case of a problem a
negative error number gets returned.

At least one call to that function is mandatory, since it initializes
the memory. Call it again for each interrupt you need. A single call to
prussdrv_exIt() closes all open files.

\since 0.6
'/
FUNCTION prussdrv_open CDECL ALIAS "prussdrv_open"(BYVAL Irq AS UInt32) AS Int32 EXPORT
  WITH PRUSSDRV                                 : IF .fd(Irq) THEN RETURN -1 ' already open
    ' ToDo: find correct /dev/uioX in case of multiple uio drivers
    VAR nam = "/dev/uio" & HEX(Irq, 1)
    .fd(Irq) = open_(nam, O_RDWR OR O_SYNC) : IF .fd(Irq) < 0 THEN RETURN -2 ' open failed
    RETURN IIF(.mmap_fd, 0, __prussdrv_memmap_init(.fd(Irq)))
  END WITH
END FUNCTION


/'* \brief Enable one PRU subsystem.
\param PruId The PRU number.
\param PCnt The byte adress where to start (defaults to 0 = zero).
\returns 0 (zero) in case of success, otherwise -1

The function enables a PRU subsystem by starting its clock. Parameter
`PCnt` specifies a byte address where to start, as used in function
prussdrv_pru_write_memory().

\note When the PASM code contains `.origin 7` the matching `PCnt` value
      is 28 = 7 * 4.

\since 0.6
'/
FUNCTION prussdrv_pru_enable CDECL ALIAS "prussdrv_pru_enable"(BYVAL PruId AS UInt32, BYVAL PCnt AS UInt32 = 0) AS Int32 EXPORT
  IF PCnt > &h1FFC                                        THEN RETURN -2
  DIM AS UInt32 v = (((PCnt + 3) SHR 2) SHL 16) OR 2
  SELECT CASE AS CONST PruId
  CASE 0 : *CAST(UInt32 PTR, PRUSSDRV.pru0_control_base) = v : RETURN 0
  CASE 1 : *CAST(UInt32 PTR, PRUSSDRV.pru1_control_base) = v : RETURN 0
  END SELECT                                                 : RETURN -1
END FUNCTION


/'* \brief Disable one PRU.
\param PruId The PRUSS number.
\returns 0 (zero) in case of success, otherwise -1

The function disables a PRU subsystem by stopping its clock.

\since 0.6
'/
FUNCTION prussdrv_pru_disable CDECL ALIAS "prussdrv_pru_disable"(BYVAL PruId AS UInt32) AS Int32 EXPORT
  SELECT CASE AS CONST PruId
  CASE 0 : *CAST(UInt32 PTR, PRUSSDRV.pru0_control_base) = 1 : RETURN 0
  CASE 1 : *CAST(UInt32 PTR, PRUSSDRV.pru1_control_base) = 1 : RETURN 0
  END SELECT : RETURN -1
END FUNCTION


/'* \brief Reset one PRU.
\param PruId The PRUSS number.
\returns 0 (zero) in case of success, otherwise -1

The function forces a reset at a PRU subsystem by writing 0 (zero) to
the control register.

\since 0.6
'/
FUNCTION prussdrv_pru_reset CDECL ALIAS "prussdrv_pru_reset"(BYVAL PruId AS UInt32) AS Int32 EXPORT
  SELECT CASE AS CONST PruId
  CASE 0 : *CAST(UInt32 PTR, PRUSSDRV.pru0_control_base) = 0 : RETURN 0
  CASE 1 : *CAST(UInt32 PTR, PRUSSDRV.pru1_control_base) = 0 : RETURN 0
  END SELECT : RETURN -1
END FUNCTION


/'* \brief Resume one PRU.
\param PruId The PRUSS number.
\returns 0 (zero) in case of success, otherwise -1

The function restarts a PRUSS after `SLP 1` or `HALT` command. The
PRU re-starts executing the next instruction.

\since 0.6.6
'/
FUNCTION prussdrv_pru_resume CDECL ALIAS "prussdrv_pru_resume"(BYVAL PruId AS UInt32) AS ZSTRING PTR EXPORT
  DIM AS UInt32 PTR p
  SELECT CASE AS CONST PruId
  CASE 0 : p = PRUSSDRV.pru0_control_base
  CASE 1 : p = PRUSSDRV.pru1_control_base
  CASE ELSE                                                   : RETURN @"invalid PRU#"
  END SELECT : IF p[0] AND &h8000 /' test bit 15 '/        THEN RETURN @"PRU is running"
                              p[0] = ((1 + p[1]) SHL 16) OR 2 : RETURN 0
END FUNCTION


/'* \brief Write data to PRUSS memory.
\param RamId The ID of the memory.
\param Offs The offset to start at.
\param Dat A pointer to the data.
\param Size The size of data in bytes.
\returns The number of bytes written, or -1 in case of failure

The function writes a chunk of data to PRUSS memory (DRam, IRam or
SRam), depending on parameter RamId. The start writing position gets
specified by parameter Offs.

\since 0.6
'/
FUNCTION prussdrv_pru_write_memory CDECL ALIAS "prussdrv_pru_write_memory"( _
  BYVAL RamId AS UInt32 _
, BYVAL Offs AS UInt32 _
, BYVAL Dat AS CONST UInt32 PTR _
, BYVAL Size AS UInt32) AS Int32 EXPORT

  DIM AS UInt32 PTR m
  SELECT CASE AS CONST RamId
  CASE PRUSS0_PRU0_DRAM : m = CAST(UInt32 PTR, PRUSSDRV.pru0_dataram_base   ) + Offs
  CASE PRUSS0_PRU1_DRAM : m = CAST(UInt32 PTR, PRUSSDRV.pru1_dataram_base   ) + Offs
  CASE PRUSS0_PRU0_IRAM : m = CAST(UInt32 PTR, PRUSSDRV.pru0_iram_base      ) + Offs
  CASE PRUSS0_PRU1_IRAM : m = CAST(UInt32 PTR, PRUSSDRV.pru1_iram_base      ) + Offs
  CASE PRUSS0_SRAM      : m = CAST(UInt32 PTR, PRUSSDRV.pruss_sharedram_base) + Offs
  CASE ELSE : RETURN -1
  END SELECT : VAR l = (Size + 3) SHR 2 ' Adjust length as multiple of 4 bytes
  FOR i AS Int32 = 0 TO l - 1
    m[i] = Dat[i]
  NEXT : RETURN l
END FUNCTION


/'* \brief Initialize the interrupt controller.
\param DatIni Data structure to initialize
\returns 0 (zero) on success, otherwise -1

The function initializes and enables the PRU interrupt controller. The
input is a structure of arrays that determine which system events are
enabled and how each is mapped to a host event. This structure is
defined in PruIo::IntcInit in file `src/pruio/pruio.bi`. Currently a
custom configuration must get compiled in the binary.

\since 0.6
'/
FUNCTION prussdrv_pruintc_init CDECL ALIAS "prussdrv_pruintc_init"(BYVAL DatIni AS CONST tpruss_intc_initdata PTR) AS Int32 EXPORT
  WITH PRUSSDRV
    VAR intc = CAST(UInt32 PTR, .intc_base)
    DIM AS UInt32 i, mask1, mask2

    intc[PRU_INTC_SIPR0_REG SHR 2] = &hFFFFFFFFuL
    intc[PRU_INTC_SIPR1_REG SHR 2] = &hFFFFFFFFuL

    FOR i = 0 TO ((NUM_PRU_SYS_EVTS + 3) SHR 2) - 1
      intc[(PRU_INTC_CMR0_REG SHR 2) + i] = 0
    NEXT

    i = 0
    WHILE DatIni->sysevt_to_channel_map(i).sysevt <> -1 ANDALSO _
          DatIni->sysevt_to_channel_map(i).channel <> -1
      __prussintc_set_cmr(intc _
                        , DatIni->sysevt_to_channel_map(i).sysevt _
                        , DatIni->sysevt_to_channel_map(i).channel)
      i += 1
    WEND
    FOR i = 0 TO ((NUM_PRU_HOSTS + 3) SHR 2) - 1
      intc[(PRU_INTC_HMR0_REG SHR 2) + i] = 0
    NEXT

    i = 0
    WHILE (DatIni->channel_to_host_map(i).channel <> -1) ANDALSO _
          (DatIni->channel_to_host_map(i).host <> -1)
      __prussintc_set_hmr(intc, _
                          DatIni->channel_to_host_map(i).channel, _
                          DatIni->channel_to_host_map(i).host)
      i += 1
    WEND

    intc[PRU_INTC_SITR0_REG SHR 2] = 0
    intc[PRU_INTC_SITR1_REG SHR 2] = 0

    i = 0 : mask1 = 0 : mask2 = 0
    WHILE DatIni->sysevts_enabled(i) <> -1
      SELECT CASE DatIni->sysevts_enabled(i)
      CASE IS < 32 : mask1 = mask1 + (1 SHL (DatIni->sysevts_enabled(i)))
      CASE IS < 64 : mask2 = mask2 + (1 SHL (DatIni->sysevts_enabled(i) - 32))
      CASE ELSE                                                 : RETURN -1
      END SELECT : i += 1
    WEND

    intc[PRU_INTC_ESR0_REG  SHR 2] = mask1
    intc[PRU_INTC_SECR0_REG SHR 2] = mask1
    intc[PRU_INTC_ESR1_REG  SHR 2] = mask2
    intc[PRU_INTC_SECR1_REG SHR 2] = mask2

    FOR i = 0 TO MAX_HOSTS_SUPPORTED - 1
      IF DatIni->host_enable_bitmask AND (1 SHL i) _
        THEN intc[PRU_INTC_HIEISR_REG SHR 2] = i
    NEXT

    intc[PRU_INTC_GER_REG SHR 2] = &h1
    memcpy( @.intc_data, CAST(ANY PTR, DatIni), SIZEOF(.intc_data) )
  END WITH : RETURN 0
END FUNCTION


/'* \brief Send a system event to PRUSS.
\param Event The interrupt number to send.

The procedure sets the interrupt registers to send an event to the
PRUSS.

\since 0.6
'/
SUB prussdrv_pru_send_event CDECL ALIAS "prussdrv_pru_send_event"(BYVAL Event AS UInt32) EXPORT
  VAR intc = CAST(UInt32 PTR, PRUSSDRV.intc_base)
  IF Event < 32 THEN intc[PRU_INTC_SRSR0_REG SHR 2] = 1 SHL Event _
                ELSE intc[PRU_INTC_SRSR1_REG SHR 2] = 1 SHL (Event - 32)
END SUB


/'* \brief Wait for an event.
\param Irq The event number to wait for.
\returns The kernel counter for the event number.

The function blocks the calling thread until the corresponding event
input occurs.

\since 0.6
'/
FUNCTION prussdrv_pru_wait_event CDECL ALIAS "prussdrv_pru_wait_event"(BYVAL Irq AS UInt32) AS UInt32 EXPORT
  DIM AS UInt32 event_count
  read_(PRUSSDRV.fd(Irq), @event_count, SIZEOF(UInt32))
  RETURN event_count
END FUNCTION


/'* \brief Clear a pending system event.
\param Irq The host interrupt.
\param Event The system event.

The procedure clears an event, previously sent from PRU to ARM. Once a
system event occurs, the registers have to get released, in order to
get ready for the next event.

\since 0.6
'/
SUB prussdrv_pru_clear_event CDECL ALIAS "prussdrv_pru_clear_event"(BYVAL Irq AS UInt32, BYVAL Event AS UInt32) EXPORT
  VAR intc = CAST(UInt32 PTR, PRUSSDRV.intc_base)
  IF Event < 32 THEN intc[PRU_INTC_SECR0_REG SHR 2] = 1 SHL Event _
                ELSE intc[PRU_INTC_SECR1_REG SHR 2] = 1 SHL (Event - 32)
  intc[PRU_INTC_HIEISR_REG SHR 2] = Irq + 2 ' after clear Event!
END SUB


/'* \brief Map external ram (ERam).
\param Addr The pointer to set.

The procedure maps the external memory allocated by the `uio_pruss`
kernel driver to pointer parameter. Memory is then accessed by an array.

\since 0.6
'/
SUB prussdrv_map_extmem CDECL ALIAS "prussdrv_map_extmem"(BYVAL Addr AS ANY PTR PTR) EXPORT
  *Addr = PRUSSDRV.extram_base
END SUB ' -> property


/'* \brief Get size of external memory
\returns The memory size.

The procedure returns the size of the external memory. The kernel
driver `uio_pruss` allocates a block of coherent memory. This function
returns the size if this block. See section \ref SecERam for details.

\since 0.6
'/
FUNCTION prussdrv_extmem_sIze CDECL ALIAS "prussdrv_extmem_size"() AS UInt32 EXPORT
  RETURN PRUSSDRV.extram_map_size
END FUNCTION ' -> property


/'* \brief Adress pointer mapping
\param RamId The memory ID.
\param Addr The pointer to set.
\returns 0 (zero) on success, otherwise -1.

The procedure maps PRU memory (DRAM, IRAM, SHARED) to the pointer
parameter. Memory is then accessed by an array.

\note  Call this function after the prussdrv_open() function. Minimum
       one event needs to be opened to access memory map.

\since 0.6
'/
FUNCTION prussdrv_map_prumem CDECL ALIAS "prussdrv_map_prumem"(BYVAL RamId AS UInt32, BYVAL Addr AS ANY PTR PTR) AS Int32 EXPORT
  SELECT CASE AS CONST RamId
  CASE PRUSS0_PRU0_DRAM : *Addr = PRUSSDRV.pru0_dataram_base    : RETURN 0
  CASE PRUSS0_PRU1_DRAM : *Addr = PRUSSDRV.pru1_dataram_base    : RETURN 0
  CASE PRUSS0_PRU0_IRAM : *Addr = PRUSSDRV.pru0_iram_base       : RETURN 0
  CASE PRUSS0_PRU1_IRAM : *Addr = PRUSSDRV.pru1_iram_base       : RETURN 0
  CASE PRUSS0_SRAM      : *Addr = PRUSSDRV.pruss_sharedram_base : RETURN 0
  END SELECT : *Addr = 0 : RETURN -1
END FUNCTION


/'* \brief Compute physical adress
\param Addr Memory pointer or mmap value
\returns The physical Addr associated with the mmap value input if
         successful, otherwise 0 (zero).

The function computes the physical adress from a prussdrv memory
pointer or from an value returned form a mmap() call.

\since 0.6
'/
FUNCTION prussdrv_get_phys_addr CDECL ALIAS "prussdrv_get_phys_addr"(BYVAL Addr AS CONST ANY PTR) AS UInt32 EXPORT
  WITH PRUSSDRV
    SELECT CASE Addr
    CASE .pru0_dataram_base TO .pru0_dataram_base + .pruss_map_size - 1
      RETURN CAST(UInt32, Addr - .pru0_dataram_base) + .pru0_dataram_phy_base
    CASE       .extram_base TO .extram_base + .extram_map_size - 1
      RETURN CAST(UInt32, Addr - .extram_base) + .extram_phys_base
    END SELECT : RETURN 0
  END WITH
END FUNCTION ' -> property


/'* \brief End the driver session

The procedure unmaps all memory and closes the interrupt file.

\note It doesn't disable the PRUSS.

\since 0.6
'/
SUB prussdrv_exIt CDECL ALIAS "prussdrv_exit"() EXPORT
  WITH PRUSSDRV
    munmap(.pru0_dataram_base, .pruss_map_size)
    munmap(.extram_base, .extram_map_size)
    FOR i AS INTEGER = 0 TO NUM_PRU_HOSTIRQS - 1
      IF .fd(i) THEN close_(.fd(i)) : .fd(i) = 0
    NEXT
    .mmap_fd = 0
  END WITH
END SUB


/'* \brief Fetch pinmuxing claims from kernel
\returns A structure containing pin array and names of owners (or zero in case of failure)

The function greps the kernel claim for CPU balls by parsing the output
from `/sys/kernel/debug/pinctrl/44e10800.pinmux/pinmux-pins`. Free and
claimed CPU balls (named pins by kernel) get identified, and the owners
of claimed balls get collected in a `STRING` variable in a condensed
form. Each owner name is stored only once, no double entries.

\since 0.6.0
'/
FUNCTION find_claims CDECL(BYVAL Typ AS UInt32) AS ZSTRING PTR
#DEFINE TBUFF_SIZE 32768
  STATIC AS STRING mux
  DIM AS STRING*TBUFF_SIZE t
  VAR fd = open_(KERNEL_PINMUX_PINS, O_RDONLY) : IF fd < 0   THEN RETURN 0
  VAR r = read_(fd, @t, TBUFF_SIZE)
  close_(fd)
  VAR toffs = (PRUIO_AZ_BALL + 1) SHL 1
  mux = STRING(toffs, 0) & "internal CPU ball" & CHR(0)
  VAR x = "", m = CAST(Int16 PTR, SADD(mux))
  FOR i AS INTEGER = 0 TO PRUIO_AZ_BALL : m[i] = toffs : NEXT ' all internal
  SELECT CASE AS CONST Typ
  CASE 1    : x = HEADERPINS_POCKET ' 2x36 headers
  CASE 2    : x = HEADERPINS_BLUE ' single connectors
  CASE ELSE : x = HEADERPINS_BB ' BeagleBone 2x46 headers
  END SELECT : FOR i AS INTEGER = 0 TO LEN(x) - 1 : m[x[i]] = 0 : NEXT ' external
' to parse: "pin 105 (PIN105): (MUX UNCLAIMED) (GPIO UNCLAIMED)"
  VAR p = CAST(ZSTRING PTR, SADD(t) + 3) _
    , c = CVL("pin ") _
    , a = 1, e = INSTR(t, !"\n")
  WHILE e
    IF *CAST(Int32 PTR, p + a - 4) = c THEN ' check "pin "
      VAR n = VALINT(*(p + a)) : IF n > PRUIO_AZ_BALL    THEN EXIT WHILE
      VAR p1 = INSTR(a, t, "): ") + 3
      IF p1 > 3 THEN ' muxline
        IF t[p1 - 1] <> ASC("(") THEN ' not "(MUX UNCLAIM..."
          VAR p2 = INSTR(p1, t, " ") _
           , own = MID(t, p1, IIF(p2, p2, e) - p1) & CHR(0) _
             , x = INSTRREV(mux, CHR(0) & own)
          IF x < toffs THEN x = LEN(mux) : mux &= own ' new entry
          CAST(Int16 PTR, SADD(mux))[n] = x '           add owner
        END IF
      END IF
    END IF : a = e + 1 : e = INSTR(a, t, !"\n") ' next line
  WEND                                                          : RETURN SADD(mux)
END FUNCTION


/'* \brief Set a new pin configuration for Pocket BeagleBone(internal).
\param Top The toplevel PruIo instance.
\param Ball The CPU ball number (use macros from pruio_pins.bi).
\param Mo The new modus to set.
\returns Zero on success (otherwise a string with an error message).

Callback function for PruIo::setPin() interface to set a new pin (or
CPU ball) configuration on PocketBeagleBone hardware, using the new
style LKM (loadable kernel module) method.

Since the double pins at this hardware are connections between digital
and analog pins, no special action is required regarding pinmuxing (as
in for BeagleBone hardware).

It's used when the constructor PruIo::PruIo() finds the SysFs entry
from the LKM, and has write access (needs administrator privileges =
`sudo ...`). Since

There're no restriction for pinmuxing. Each CPU ball in the range zero
to PRUIO_AZ_BALL can get set to any mode. Even claimed pins or CPU
balls can get set to defined or undefined modes. The function executes
faster than device tree pinmuxing (no `OPEN ... CLOSE`), boot-time is
shorter (no overlay loading) and less memory is used.

\since 0.6.0
'/
FUNCTION setPin_lkm CDECL( _
    BYVAL Top AS Pruio_ PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Mo AS UInt8) AS ZSTRING PTR
  WITH *Top
    IF Ball > PRUIO_AZ_BALL THEN .Errr = @"unknown ball number" : RETURN .Errr

    VAR m = IIF(Mo = PRUIO_PIN_RESET, .BallInit[Ball], Mo)
    SELECT CASE m
    CASE .BallConf[Ball] :                                        RETURN 0 ' nothing to do
    CASE .BallInit[Ball] : IF 24 = (.BallConf[Ball] AND 24)  THEN RETURN 0 ' nothing to do
    END SELECT
    PUT  #.MuxFnr, , HEX((Ball SHL 8) + (m AND &b1111111), 4)
    SEEK #.MuxFnr, 1 : .BallConf[Ball] = m                      : RETURN 0
  END WITH
END FUNCTION


/'* \brief Set a new pin configuration for BeagleBone boards(internal).
\param Top The toplevel PruIo instance.
\param Ball The CPU ball number (use macros from pruio_pins.bi).
\param Mo The new modus to set.
\returns Zero on success (otherwise a string with an error message).

Callback function for PruIo::setPin() interface to set a new pin (or
CPU ball) configuration on BeagleBone hardware (Black, BlackWireless,
Green, White), using the new style LKM (loadable kernel module) method.

Since this hardware has some digital header pins with double CPU ball
connections, both CPU balls have to be set. First, the unused CPU ball
gets configured to gpio input mode without pull-up/pull-down resistor,
before the other pin gets set to the desired mode.

\since 0.6.4
'/
FUNCTION setPin_lkm_bb CDECL( _
    BYVAL Top AS Pruio_ PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Mo AS UInt8) AS ZSTRING PTR

  WITH *Top
    STATIC AS UInt8 b, r
    SELECT CASE AS CONST Ball
    CASE P9_41 : b = 106
    CASE P9_42 : b = 104
    CASE   106 : b = P9_41
    CASE   104 : b = P9_41
    CASE ELSE                                                   : RETURN setPin_lkm(Top, Ball, Mo)
    END SELECT : r = .BallGpio(b)
    WITH *.Gpio
      .Indx = r SHR 5
      .Mode = PRUIO_GPIO_IN_0
      .Mask = 1 SHL (r AND 31)
      .setGpioSs()
    END WITH
    VAR m = IIF(Mo = PRUIO_PIN_RESET, .BallInit[Ball], Mo)
    SELECT CASE m
    CASE .BallConf[Ball] :                                        RETURN 0 ' nothing to do
    CASE .BallInit[Ball] : IF 24 = (.BallConf[Ball] AND 24)  THEN RETURN 0 ' nothing to do
    END SELECT

    PUT  #.MuxFnr, , HEX(   b, 2) & "27" _
                   & HEX(Ball, 2) & HEX(m AND &b1111111, 2)
    SEEK #.MuxFnr, 1
    .BallConf[b] = PRUIO_GPIO_IN_0        : .BallConf[Ball] = m : RETURN 0
  END WITH
END FUNCTION


/'* \brief Set a new pin configuration (internal).
\param Top The PruIo instance.
\param Ball The CPU ball number (use macros from pruio_pins.bi).
\param Mo The new modus to set, or PRUIO_PIN_RESET to reset
\returns Zero on success (otherwise a string with an error message).

Callback function for the PruIo::setPin() interface. It's a wrapper
around setPin_lkm() functions, that checks the pin claiming of the
kernel first. Only mode changes for unclaimed pins (or CPU balls) get
executed.

Claims from the kernel get fetched once by calling the function with an
invalid Ball parameter (> `PRUIO_AZ_BALL`). This gets executed by the
constructor PruIo::PruIo(). The function doesn't notice changes in
kernel claiming at runtime. You can re-fetch the claims when needed.

\since 0.6.0
'/
FUNCTION setPin_save CDECL( _
    BYVAL Top AS Pruio_ PTR _
  , BYVAL Ball AS UInt8, BYVAL Mo AS UInt8) AS ZSTRING PTR
  STATIC AS ZSTRING PTR m
  STATIC set_func AS setPinFunc
  STATIC AS STRING e

  WITH *Top
    IF 0 = m ORELSE Ball > PRUIO_AZ_BALL THEN ' init
      set_func = IIF(Top->BbType, @setPin_lkm(), @setPin_lkm_bb())
      m = find_claims(.BbType)
                    .Errr = IIF(m, 0, @"parsing kernel claims") : RETURN .Errr
    END IF

    VAR o = CAST(Int16 PTR, m) : IF 0 = o[Ball]              THEN RETURN set_func(Top, Ball, Mo)
    VAR x = .nameBall(Ball)
    IF x THEN e = "pin " & *x ELSE e = "ball" & Ball
    e &= " claimed by: " & *(m + o[Ball])     : .Errr = SADD(e) : RETURN .Errr
  END WITH
END FUNCTION



/'* \brief Pinmuxing callback for setPin interface (internal).
\param Top The PruIo instance.
\param Ball The CPU ball number (use macros from pruio_pins.bi).
\param Mo The new modus to set, or PRUIO_PIN_RESET to reset
\returns A string with an error message.

This function is a dummy for the setPin interface in PruIo structure.
It gets used when no pinmuxing capability was found on the system:
neither a universal device tree overlay was loaded, nor the loadable
kernel module is available (may be loaded, but no administrator
privileges). The function does nothing, but returns an error message.

\since 0.6.0
'/
FUNCTION setPin_nogo CDECL( _
    BYVAL Top AS Pruio_ PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Mo AS UInt8) AS ZSTRING PTR

                                  Top->Errr = @"pinmux missing" : RETURN Top->Errr
END FUNCTION


/'* \brief Pinmuxing for old style device tree multipins (internal).
\param Top The PruIo instance.
\param Ball The CPU ball number (use macros from pruio_pins.bi).
\param Mo The new modus to set, or PRUIO_PIN_RESET to reset
\returns Zero on success (otherwise a string with an error message).

Like function setPin_lkm(), this function sets a new pin mode for a CPU
ball. Therefor the SysFs files from the OCP pinmux helper are used.
That means the pinmux capabilities are handled by the kernel. You have
to load an overlay blob and export the pins, before you can set one of
the prepared configurations.

The SysFs folder tree changed between kernel versions 3.8 and 4.x. This
function handles either of the folder structures. When the desired
pin (ball) isn't available in the overlay blob, an error message
gets returned, containing the pin number (or CPU ball#) and the missing
state.

\since 0.6.0
'/
FUNCTION setPin_dtbo CDECL( _
    BYVAL Top AS Pruio_ PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Mo AS UInt8) AS ZSTRING PTR
  WITH *Top
    IF Ball > PRUIO_AZ_BALL THEN _
                          .Errr = @"unknown setPin ball number" : RETURN .Errr

    VAR m = IIF(Mo = PRUIO_PIN_RESET, .BallInit[Ball], Mo)
    IF .BallConf[Ball] = m                                   THEN RETURN 0 ' nothing to do

    SELECT CASE AS CONST .MuxFnr
    CASE 256 ' kernel 3.8
      VAR fnam = *.MuxAcc & HEX(Ball, 2)
      VAR p = DIR(fnam & ".*", fbDirectory)
      fnam &= MID(p, INSTR(p, "."))
      VAR fnr = FREEFILE
      IF OPEN(fnam & "/state" FOR OUTPUT AS fnr)        THEN EXIT SELECT
      PRINT #fnr, "x" & HEX(m, 2)
      CLOSE #fnr : .BallConf[Ball] = m :                          RETURN 0
    CASE 257 '   kernel 4.x
      VAR fnam = *.MuxAcc & HEX(Ball, 2), fnr = FREEFILE
      IF OPEN(fnam & "/state" FOR OUTPUT AS fnr)        THEN EXIT SELECT
      PRINT #fnr, "x" & HEX(m, 2)
      CLOSE #fnr : .BallConf[Ball] = m :                          RETURN 0
    CASE ELSE :                        .Errr = @"no ocp access" : RETURN .Errr
    END SELECT

    STATIC AS STRING*30 e = "pinmux failed: P._.. -> x.."
    VAR x = .nameBall(Ball)
    IF x THEN MID(e, 16, 5) = *x ELSE MID(e, 16, 5) = "bal" & HEX(Ball, 2)
    MID(e, 26, 2) = HEX(m, 2) :                 .Errr = SADD(e) : RETURN .Errr
  END WITH
END FUNCTION
