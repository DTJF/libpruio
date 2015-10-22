#!/bin/sh -e
# load PRU kernel driver and libpruio device tree overlay,
# make interrupt accessable for users in group pruio and
# start a custom program

grp=pruio
uio=/dev/uio5
capemgr=$(ls /sys/devices/bone_capemg*/slots 2> /dev/null || true)

if [ "x${capemgr}" = "x" ] ; then
	exit 99
fi

# load PRUSS kernel module, specify ERam size (max. 0x800000, default is 0x40000)
#modprobe uio_pruss extram_pool_sz=0x100000

# load device tree overlay
echo libpruio > ${capemgr}

# wait until kernel driver created the interrupt nodes
until test -e ${uio}; do sleep 1; done

# make interrupt available for users in group pruio
chgrp ${grp} ${uio}
chmod g+rw ${uio}

# start custom program (adapt USERNAME and COMMAND and uncomment)
#su USERNAME -c 'COMMAND &'
