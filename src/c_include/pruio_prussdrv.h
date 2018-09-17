/'* \file pruio_prussdrv.h
\brief Header file for kernel drivers.

The header contains declarations to bind the user space part of the
kernel drivers. Two loadable kernel modules are in use, named:

- uio_pruss
- libpruio

The first controls memory mapping and interrupt handling, the second
supports pinmuxing and PWM features.

\since 0.6
'/


#ifndef _PRUSSDRV_H
#define _PRUSSDRV_H

#include <sys/types.h>

#if defined (__cplusplus)
extern "C" {
#endif

int prussdrv_open(unsigned int host_interrupt);

int prussdrv_pru_reset(unsigned int prunum);

int prussdrv_pru_disable(unsigned int prunum);

int prussdrv_pru_enable(unsigned int prunum);

int prussdrv_pru_write_memory(unsigned int pru_ram_id,
                              unsigned int wordoffset,
                              const unsigned int *memarea,
                              unsigned int bytelength);

int prussdrv_pruintc_init(const tpruss_intc_initdata *prussintc_init_data);

int prussdrv_map_extmem(void **address);

unsigned int prussdrv_extmem_size(void);

int prussdrv_map_prumem(unsigned int pru_ram_id, void **address);

unsigned int prussdrv_get_phys_addr(const void *address);

unsigned int prussdrv_pru_wait_event(unsigned int host_interrupt);

int prussdrv_pru_send_event(unsigned int eventnum);

int prussdrv_pru_clear_event(unsigned int host_interrupt, unsigned int sysevent);

int prussdrv_exit(void);

#if defined (__cplusplus)
}
#endif
#endif
