/* ! \ file pruio_prussdrv.h
\brief Header file for kernel drivers.

The header contains declarations to bind the user space part of the
kernel drivers. Two loadable kernel modules are in use, named:

- uio_pruss
- libpruio

The first controls memory mapping and interrupt handling, the second
supports pinmuxing and PWM features.

\since 0.6
*/


#ifndef _PRUSSDRV_H
#define _PRUSSDRV_H

#include <sys/types.h>

#if defined (__cplusplus)
extern "C" {
#endif
//! See prussdrv_open(BYVAL_AS_UInt32 Irq)
int32 prussdrv_open(uint32 host_interrupt);
//! See prussdrv_pru_reset(BYVAL_AS_UInt32 PruId)
int32 prussdrv_pru_reset(uint32 prunum);
//! See prussdrv_pru_resume(BYVAL_AS_UInt32 PruId)
char* prussdrv_pru_resume(uint32 prunum);
//! See prussdrv_pru_disable(BYVAL_AS_UInt32 PruId)
int32 prussdrv_pru_disable(uint32 prunum);
//! See prussdrv_pru_enable(BYVAL_AS_UInt32 PruId, BYVAL_AS_UInt32 PCnt)
int32 prussdrv_pru_enable(uint32 prunum, uint32 pcnt);
#define prussdrv_pru_enable(N) prussdrv_pru_enable(N, 0)
//! See prussdrv_pru_write_memory(BYVAL_AS_UInt32 RamId, BYVAL_AS_UInt32 Offs, BYVAL_AS_CONST_UInt32_PTR Dat, BYVAL_AS_UInt32 Size)
int32 prussdrv_pru_write_memory(uint32 pru_ram_id,
                                uint32 wordoffset,
                                const uint32 *memarea,
                                uint32 bytelength);
//! See prussdrv_pruintc_init(BYVAL_AS_CONST_tpruss_intc_initdata_PTR DatIni)
int32 prussdrv_pruintc_init(const tpruss_intc_initdata *prussintc_init_data);
//! See prussdrv_map_extmem(BYVAL_AS_ANY_PTR_PTR Addr)
void prussdrv_map_extmem(void **address);
//! See prussdrv_extmem_sIze()
uint32 prussdrv_extmem_size(void);
//! See prussdrv_map_prumem(BYVAL_AS_UInt32 RamId, BYVAL_AS_ANY_PTR_PTR Addr)
int32 prussdrv_map_prumem(uint32 pru_ram_id, void **address);
//! See prussdrv_get_phys_addr(BYVAL_AS_CONST_ANY_PTR Addr)
uint32 prussdrv_get_phys_addr(const void *address);
//! See prussdrv_pru_wait_event(BYVAL_AS_UInt32 Irq)
uint32 prussdrv_pru_wait_event(uint32 host_interrupt);
//! See prussdrv_pru_send_event(BYVAL_AS_UInt32 Event)
void prussdrv_pru_send_event(uint32 eventnum);
//! See prussdrv_pru_clear_event(BYVAL_AS_UInt32 Irq, BYVAL_AS_UInt32 Event)
void prussdrv_pru_clear_event(uint32 host_interrupt, uint32 sysevent);
//! See prussdrv_exIt()
void prussdrv_exit(void);

#if defined (__cplusplus)
}
#endif
#endif
