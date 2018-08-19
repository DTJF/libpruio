/'* \file pruio_prussdrv.bi
\brief Header file for kernel drivers.

The header contains declarations to bind the user space part of the
kernel drivers. Two loadable kernel modules are in use, named:

- uio_pruss
- libpruio

The first controls memory mapping and interrupt handling, the second
supports pinmuxing and PWM features.

\since 0.6
'/


#INCLUDE ONCE "pruio.bi"
#INCLUDE ONCE "pruio_intc.bi"

#DEFINE PAGE_SIZE 4096

'//PRUSS INTC register offsets
#DEFINE PRU_INTC_GER_REG     &h010
#DEFINE PRU_INTC_HIEISR_REG  &h034
#DEFINE PRU_INTC_SRSR1_REG   &h200
#DEFINE PRU_INTC_SRSR2_REG   &h204
#DEFINE PRU_INTC_SECR1_REG   &h280
#DEFINE PRU_INTC_SECR2_REG   &h284
#DEFINE PRU_INTC_ESR1_REG    &h300
#DEFINE PRU_INTC_ESR2_REG    &h304
#DEFINE PRU_INTC_CMR1_REG    &h400
#DEFINE PRU_INTC_HMR1_REG    &h800
#DEFINE PRU_INTC_SIPR1_REG   &hD00
#DEFINE PRU_INTC_SIPR2_REG   &hD04
#DEFINE PRU_INTC_SITR1_REG   &hD80
#DEFINE PRU_INTC_SITR2_REG   &hD84

#DEFINE MAX_HOSTS_SUPPORTED 10

'//UIO driver expects user space to map PRUSS_UIO_MAP_OFFSET_XXX to
'//access corresponding memory regions - region offset is N*PAGE_SIZE

#DEFINE PRUSS_UIO_MAP_OFFSET_PRUSS 0*PAGE_SIZE
#DEFINE PRUSS_UIO_DRV_PRUSS_BASE "/sys/class/uio/uio0/maps/map0/addr"
#DEFINE PRUSS_UIO_DRV_PRUSS_SIZE "/sys/class/uio/uio0/maps/map0/size"

#DEFINE PRUSS_UIO_MAP_OFFSET_EXTRAM 1*PAGE_SIZE
#DEFINE PRUSS_UIO_DRV_EXTRAM_BASE "/sys/class/uio/uio0/maps/map1/addr"
#DEFINE PRUSS_UIO_DRV_EXTRAM_SIZE "/sys/class/uio/uio0/maps/map1/size"


/'* \brief Date structure for the `uio_pruss` kernel driver.

FIXME

\since 0.6
'/
TYPE __prussdrv
  AS LONG _
      mmap_fd _ '*< file descriptor for memory mappings.
    , fd(0 TO NUM_PRU_HOSTIRQS - 1) '*< Array for Irq file descriptors.
  AS ANY PTR _
      pru0_dataram_base _  '*< Mapped start address DRam PRU0
    , pru1_dataram_base _  '*< Mapped start address DRam PRU1
    , intc_base _          '*< Mapped start address interrupt controller
    , pru0_control_base _  '*< Mapped start address control register PRU0
    , pru1_control_base _  '*< Mapped start address control register PRU1
    , pru0_iram_base _     '*< Mapped start address instruction ram PRU0
    , pru1_iram_base _     '*< Mapped start address instruction ram PRU1
    , extram_base _        '*< Mapped start address external memory block
    , pruss_sharedram_base '*< Mapped start address shared memory
  AS ULONG _
    pru0_dataram_phy_base = &h4a300000 _ '*< Physical address DRam PRU0
  , pru1_dataram_phy_base = &h4a302000 _ '*< Physical address DRam PRU1
  ,         intc_phy_base = &h4a320000 _ '*< Physical address interrupt controller
  , pru0_control_phy_base = &h4a322000 _ '*< Physical address control registers PRU0
  , pru1_control_phy_base = &h4a324000 _ '*< Physical address control registers PRU1
  ,    pru0_iram_phy_base = &h4a334000 _ '*< Physical address instruction ram PRU0
  ,    pru1_iram_phy_base = &h4a338000 _ '*< Physical address instruction ram PRU1
  ,   pruss_sram_phy_base = &h4a310000 _ '*< Physical address shared memory
  , pruss_map_size _   '*< Size of PRUSS memory mapping block
  , extram_phys_base _ '*< Physical address of external memory
  , extram_map_size    '*< Size of external memory from `uio_pruss`
  AS tpruss_intc_initdata intc_data
END TYPE

TYPE AS __prussdrv tprussdrv

DECLARE FUNCTION prussdrv_open(BYVAL AS ULONG) AS LONG
DECLARE FUNCTION prussdrv_pru_enable(BYVAL AS ULONG) AS LONG
DECLARE FUNCTION prussdrv_pru_disable(BYVAL AS ULONG) AS LONG
DECLARE FUNCTION prussdrv_pru_reset(BYVAL AS ULONG) AS LONG
DECLARE FUNCTION prussdrv_pru_write_memory( _
  BYVAL AS ULONG _
, BYVAL AS ULONG _
, BYVAL AS CONST ULONG PTR _
, BYVAL AS ULONG) AS LONG
DECLARE FUNCTION prussdrv_pruintc_init(BYVAL AS CONST tpruss_intc_initdata PTR) AS LONG
DECLARE SUB prussdrv_pru_send_event(BYVAL AS ULONG)
DECLARE FUNCTION prussdrv_pru_wait_event(BYVAL AS ULONG) AS ULONG
DECLARE SUB prussdrv_pru_clear_event(BYVAL AS ULONG, BYVAL AS ULONG)
DECLARE SUB prussdrv_map_extmem(BYVAL AS ANY PTR PTR)
DECLARE FUNCTION prussdrv_extmem_size() AS ULONG
DECLARE FUNCTION prussdrv_map_prumem(BYVAL AS ULONG, BYVAL AS ANY PTR PTR) AS LONG
DECLARE FUNCTION prussdrv_get_phys_addr(BYVAL AS CONST ANY PTR) AS ULONG
DECLARE SUB prussdrv_exit()

DECLARE FUNCTION setPin_save( _
    BYVAL AS PruIo_ PTR _
  , BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR
DECLARE FUNCTION setPin_lkm( _
    BYVAL AS PruIo_ PTR _
  , BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR
DECLARE FUNCTION setPin_dtbo( _
    BYVAL AS PruIo_ PTR _
  , BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR
DECLARE FUNCTION setPin_nogo( _
    BYVAL AS PruIo_ PTR _
  , BYVAL AS UInt8 _
  , BYVAL AS UInt8) AS ZSTRING PTR
