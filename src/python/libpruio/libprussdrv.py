# header file to import in python code
from ctypes import *

# /usr/include/prussdrv.h: 92
class struct___sysevt_to_channel_map(Structure):
    pass

struct___sysevt_to_channel_map._fields_ = [
    ('sysevt', c_short),
    ('channel', c_short),
]

tsysevt_to_channel_map = struct___sysevt_to_channel_map # /usr/include/prussdrv.h: 92

# /usr/include/prussdrv.h: 96
class struct___channel_to_host_map(Structure):
    pass

struct___channel_to_host_map._fields_ = [
    ('channel', c_short),
    ('host', c_short),
]

tchannel_to_host_map = struct___channel_to_host_map # /usr/include/prussdrv.h: 96

# /usr/include/prussdrv.h: 109
class struct___pruss_intc_initdata(Structure):
    pass

struct___pruss_intc_initdata._fields_ = [
    ('sysevts_enabled', c_char * 64),
    ('sysevt_to_channel_map', tsysevt_to_channel_map * 64),
    ('channel_to_host_map', tchannel_to_host_map * 10),
    ('host_enable_bitmask', c_uint),
]

tpruss_intc_initdata = struct___pruss_intc_initdata # /usr/include/prussdrv.h: 109
