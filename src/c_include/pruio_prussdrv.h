/*! \file pruio_prussdrv.h
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

int32 prussdrv_open(uint32 host_interrupt);

int32 prussdrv_pru_reset(uint32 prunum);

int32 prussdrv_pru_disable(uint32 prunum);

int32 prussdrv_pru_enable(uint32 prunum);

int32 prussdrv_pru_write_memory(uint32 pru_ram_id,
                                uint32 wordoffset,
                                const uint32 *memarea,
                                uint32 bytelength);

int32 prussdrv_pruintc_init(const tpruss_intc_initdata *prussintc_init_data);

void prussdrv_map_extmem(void **address);

uint32 prussdrv_extmem_size(void);

int32 prussdrv_map_prumem(uint32 pru_ram_id, void **address);

uint32 prussdrv_get_phys_addr(const void *address);

uint32 prussdrv_pru_wait_event(uint32 host_interrupt);

void prussdrv_pru_send_event(uint32 eventnum);

void prussdrv_pru_clear_event(uint32 host_interrupt, uint32 sysevent);

void prussdrv_exit(void);

#if defined (__cplusplus)
}
#endif
#endif
