# header file auto generated by fb-doc and plugin py_ctypes.bas

_libs["libpruio"] = load_library("libpruio")

# pruio.hp: 97

try:
    PRUIO_IRPT = 25
except:
    pass

# pruio.hp: 98

try:
    IRPT = PRUIO_IRPT + 16
except:
    pass

# pruio.hp: 99

try:
    CTBIR = 0x22020
except:
    pass

# pruio.hp: 100

try:
    CONST_PRUCFG = C4
except:
    pass

# pruio.hp: 101

try:
    DRam = C24
except:
    pass

# pruio.hp: 103

try:
    PRUIO_AZ_BALL = 109
except:
    pass

# pruio.hp: 104

try:
    PRUIO_AZ_GPIO = 3
except:
    pass

# pruio.hp: 105

try:
    PRUIO_AZ_PWMSS = 2
except:
    pass

# pruio.hp: 106

try:
    PRUIO_AZ_TIMER = 3
except:
    pass

# pruio.hp: 108

try:
    PRUIO_COM_POKE = 10
except:
    pass

# pruio.hp: 109

try:
    PRUIO_COM_PEEK = 9
except:
    pass

# pruio.hp: 110

try:
    PRUIO_COM_GPIO_CONF = 20
except:
    pass

# pruio.hp: 111

try:
    PRUIO_COM_GPIO_OUT = 19
except:
    pass

# pruio.hp: 112

try:
    PRUIO_COM_PWM = 30
except:
    pass

# pruio.hp: 113

try:
    PRUIO_COM_CAP_PWM = 29
except:
    pass

# pruio.hp: 114

try:
    PRUIO_COM_CAP = 28
except:
    pass

# pruio.hp: 115

try:
    PRUIO_COM_QEP = 27
except:
    pass

# pruio.hp: 116

try:
    PRUIO_COM_TIM_PWM = 40
except:
    pass

# pruio.hp: 117

try:
    PRUIO_COM_TIM_CAP = 38
except:
    pass

# pruio.hp: 118

try:
    PRUIO_COM_ADC = 50
except:
    pass

# pruio.hp: 120

try:
    PRUIO_DAT_GPIO = 64
except:
    pass

# pruio.hp: 121

try:
    PRUIO_DAT_PWM = 128
except:
    pass

# pruio.hp: 122

try:
    PRUIO_DAT_TIMER = 224
except:
    pass

# pruio.hp: 123

try:
    PRUIO_DAT_ADC = 288
except:
    pass

# pruio.hp: 124

try:
    PRUIO_DAT_ALL = 512
except:
    pass

# pruio.hp: 126

try:
    PRUIO_MSG_INIT_RUN = 4294967295
except:
    pass

# pruio.hp: 127

try:
    PRUIO_MSG_CONF_RUN = 4294967294
except:
    pass

# pruio.hp: 128

try:
    PRUIO_MSG_INIT_OK = 4294967293
except:
    pass

# pruio.hp: 129

try:
    PRUIO_MSG_CONF_OK = 4294967292
except:
    pass

# pruio.hp: 130

try:
    PRUIO_MSG_ADC_ERRR = 4294967291
except:
    pass

# pruio.hp: 131

try:
    PRUIO_MSG_MM_WAIT = 4294967290
except:
    pass

# pruio.hp: 132

try:
    PRUIO_MSG_MM_TRG1 = 4294967289
except:
    pass

# pruio.hp: 133

try:
    PRUIO_MSG_MM_TRG2 = 4294967288
except:
    pass

# pruio.hp: 134

try:
    PRUIO_MSG_MM_TRG3 = 4294967287
except:
    pass

# pruio.hp: 135

try:
    PRUIO_MSG_MM_TRG4 = 4294967286
except:
    pass

# pruio.hp: 136

try:
    PRUIO_MSG_IO_OK = 4294967285
except:
    pass


# pruio_globals.bi: 14

try:
    PRUIO_DEF_AVRAGE = 4
except:
    pass

# pruio_globals.bi: 16

try:
    PRUIO_DEF_ODELAY = 183
except:
    pass

# pruio_globals.bi: 18

try:
    PRUIO_DEF_SDELAY = 0
except:
    pass

# pruio_globals.bi: 20

try:
    PRUIO_DEF_SAMPLS = 1
except:
    pass

# pruio_globals.bi: 22

try:
    PRUIO_DEF_STPMSK = 0b111111110
except:
    pass

# pruio_globals.bi: 24

try:
    PRUIO_DEF_TIMERV = 0
except:
    pass

# pruio_globals.bi: 26

try:
    PRUIO_DEF_LSLMOD = 4
except:
    pass

# pruio_globals.bi: 28

try:
    PRUIO_DEF_CLKDIV = 0
except:
    pass

# pruio_globals.bi: 35

Int8 = c_byte

# pruio_globals.bi: 36

Int16 = c_short

# pruio_globals.bi: 37

Int32 = c_long

# pruio_globals.bi: 38

UInt8 = c_ubyte

# pruio_globals.bi: 39

UInt16 = c_ushort

# pruio_globals.bi: 40

UInt32 = c_ulong

# pruio_globals.bi: 41

Float_t = c_float

# pruio_globals.bi: 43

class = struct_PruIo(Structure):
    pass

# pruio_globals.bi: 44

class = struct_AdcUdt(Structure):
    pass

# pruio_globals.bi: 45

class = struct_GpioUdt(Structure):
    pass

# pruio_globals.bi: 46

class = struct_PwmssUdt(Structure):
    pass

# pruio_globals.bi: 47

class = struct_PwmMod(Structure):
    pass

# pruio_globals.bi: 48

class = struct_CapMod(Structure):
    pass

# pruio_globals.bi: 49

class = struct_QepMod(Structure):
    pass

# pruio_globals.bi: 50

class = struct_TimerUdt(Structure):
    pass

# pruio_globals.bi: 64

try:
    PRUIO_PULL_DOWN = 0b000000
except:
    pass

try:
    PRUIO_NO_PULL = 0b001000
except:
    pass

try:
    PRUIO_PULL_UP = 0b010000
except:
    pass

try:
    PRUIO_RX_ACTIV = 0b100000
except:
    pass

try:
    PRUIO_GPIO_OUT0 = 7 + PRUIO_NO_PULL                   
except:
    pass

try:
    PRUIO_GPIO_OUT1 = 7 + PRUIO_NO_PULL + 128             
except:
    pass

try:
    PRUIO_GPIO_IN = 7 + PRUIO_NO_PULL + PRUIO_RX_ACTIV  
except:
    pass

try:
    PRUIO_GPIO_IN_0 = 7 + PRUIO_PULL_DOWN + PRUIO_RX_ACTIV
except:
    pass

try:
    PRUIO_GPIO_IN_1 = 7 + PRUIO_PULL_UP + PRUIO_RX_ACTIV  
except:
    pass

try:
    PRUIO_PIN_RESET = 0xF
except:
    pass


# pruio_adc.bi: 29

class struct_AdcSteps(Structure):
    pass 

struct_AdcSteps.__slots__ = [
    'Confg',
    'Delay',
]

struct_AdcSteps.__fields__ = [
    ('Confg', UInt32),
    ('Delay', UInt32),
]

# pruio_adc.bi: 75

class struct_AdcSet(Structure):
    pass 

struct_AdcSet.__slots__ = [
    'DeAd',
    'ClAd',
    'ClVa',
    'REVISION',
    'SYSCONFIG',
    'IRQSTATUS_RAW',
    'IRQSTATUS',
    'IRQENABLE_SET',
    'IRQENABLE_CLR',
    'IRQWAKEUP',
    'DMAENABLE_SET',
    'DMAENABLE_CLR',
    'CTRL',
    'ADCSTAT',
    'ADCRANGE',
    'ADC_CLKDIV',
    'ADC_MISC',
    'STEPENABLE',
    'IDLECONFIG',
    'St_p',
    'FIFO0COUNT',
    'FIFO0THRESHOLD',
    'DMA0REQ',
    'FIFO1COUNT',
    'FIFO1THRESHOLD',
    'DMA1REQ',
]

struct_AdcSet.__fields__ = [
    ('DeAd', UInt32),
    ('ClAd', UInt32),
    ('ClVa', UInt32),
    ('REVISION', UInt32),
    ('SYSCONFIG', UInt32),
    ('IRQSTATUS_RAW', UInt32),
    ('IRQSTATUS', UInt32),
    ('IRQENABLE_SET', UInt32),
    ('IRQENABLE_CLR', UInt32),
    ('IRQWAKEUP', UInt32),
    ('DMAENABLE_SET', UInt32),
    ('DMAENABLE_CLR', UInt32),
    ('CTRL', UInt32),
    ('ADCSTAT', UInt32),
    ('ADCRANGE', UInt32),
    ('ADC_CLKDIV', UInt32),
    ('ADC_MISC', UInt32),
    ('STEPENABLE', UInt32),
    ('IDLECONFIG', UInt32),
    ('St_p', AdcSteps * (16 + 1)),
    ('FIFO0COUNT', UInt32),
    ('FIFO0THRESHOLD', UInt32),
    ('DMA0REQ', UInt32),
    ('FIFO1COUNT', UInt32),
    ('FIFO1THRESHOLD', UInt32),
    ('DMA1REQ', UInt32),
]

# pruio_adc.bi: 139

struct_AdcUdt.__slots__ = [
    'Top',
    'Init',
    'Conf',
    'Samples',
    'TimerVal',
    'InitParA',
    'LslMode',
    'ChAz',
    'Value',
    'E0',
    'E1',
    'E2',
    'E3',
    'E4',
    'E5',
]

struct_AdcUdt.__fields__ = [
    ('Top', POINTER(Pruio_)),
    ('Init', POINTER(AdcSet)),
    ('Conf', POINTER(AdcSet)),
    ('Samples', UInt32),
    ('TimerVal', UInt32),
    ('InitParA', UInt32),
    ('LslMode', UInt16),
    ('ChAz', UInt16),
    ('Value', POINTER(UInt16)),
    ('E0', c_char_p),
    ('E1', c_char_p),
    ('E2', c_char_p),
    ('E3', c_char_p),
    ('E4', c_char_p),
    ('E5', c_char_p),
]


# pruio_gpio.bi: 57

class struct_GpioSet(Structure):
    pass 

struct_GpioSet.__slots__ = [
    'DeAd',
    'ClAd',
    'ClVa',
    'REVISION',
    'SYSCONFIG',
    'EOI',
    'IRQSTATUS_RAW_0',
    'IRQSTATUS_RAW_1',
    'IRQSTATUS_0',
    'IRQSTATUS_1',
    'IRQSTATUS_SET_0',
    'IRQSTATUS_SET_1',
    'IRQSTATUS_CLR_0',
    'IRQSTATUS_CLR_1',
    'IRQWAKEN_0',
    'IRQWAKEN_1',
    'SYSSTATUS',
    'CTRL',
    'OE',
    'DATAIN',
    'DATAOUT',
    'LEVELDETECT0',
    'LEVELDETECT1',
    'RISINGDETECT',
    'FALLINGDETECT',
    'DEBOUNCENABLE',
    'DEBOUNCINGTIME',
    'CLEARDATAOUT',
    'SETDATAOUT',
]

struct_GpioSet.__fields__ = [
    ('DeAd', UInt32),
    ('ClAd', UInt32),
    ('ClVa', UInt32),
    ('REVISION', UInt32),
    ('SYSCONFIG', UInt32),
    ('EOI', UInt32),
    ('IRQSTATUS_RAW_0', UInt32),
    ('IRQSTATUS_RAW_1', UInt32),
    ('IRQSTATUS_0', UInt32),
    ('IRQSTATUS_1', UInt32),
    ('IRQSTATUS_SET_0', UInt32),
    ('IRQSTATUS_SET_1', UInt32),
    ('IRQSTATUS_CLR_0', UInt32),
    ('IRQSTATUS_CLR_1', UInt32),
    ('IRQWAKEN_0', UInt32),
    ('IRQWAKEN_1', UInt32),
    ('SYSSTATUS', UInt32),
    ('CTRL', UInt32),
    ('OE', UInt32),
    ('DATAIN', UInt32),
    ('DATAOUT', UInt32),
    ('LEVELDETECT0', UInt32),
    ('LEVELDETECT1', UInt32),
    ('RISINGDETECT', UInt32),
    ('FALLINGDETECT', UInt32),
    ('DEBOUNCENABLE', UInt32),
    ('DEBOUNCINGTIME', UInt32),
    ('CLEARDATAOUT', UInt32),
    ('SETDATAOUT', UInt32),
]

# pruio_gpio.bi: 75

class struct_GpioArr(Structure):
    pass 

struct_GpioArr.__slots__ = [
    'DeAd',
    'DATAIN',
    'DATAOUT',
    'Mix',
]

struct_GpioArr.__fields__ = [
    ('DeAd', UInt32),
    ('DATAIN', UInt32),
    ('DATAOUT', UInt32),
    ('Mix', UInt32),
]

# pruio_gpio.bi: 111

struct_GpioUdt.__slots__ = [
    'Top',
    'Init',
    'Conf',
    'Raw',
    'InitParA',
    'E0',
    'E1',
]

struct_GpioUdt.__fields__ = [
    ('Top', POINTER(Pruio_)),
    ('Init', POINTER(GpioSet) * (PRUIO_AZ_GPIO + 1)),
    ('Conf', POINTER(GpioSet) * (PRUIO_AZ_GPIO + 1)),
    ('Raw', POINTER(GpioArr) * (PRUIO_AZ_GPIO + 1)),
    ('InitParA', UInt32),
    ('E0', c_char_p),
    ('E1', c_char_p),
]


# pruio_pwmss.bi: 134

class struct_PwmssSet(Structure):
    pass 

struct_PwmssSet.__slots__ = [
    'DeAd',
    'ClAd',
    'ClVa',
    'IDVER',
    'SYSCONFIG',
    'CLKCONFIG',
    'CLKSTATUS',
    'TSCTR',
    'CTRPHS',
    'CAP1',
    'CAP2',
    'CAP3',
    'CAP4',
    'ECCTL1',
    'ECCTL2',
    'ECEINT',
    'ECFLG',
    'ECCLR',
    'ECFRC',
    'CAP_REV',
    'QPOSCNT',
    'QPOSINIT',
    'QPOSMAX',
    'QPOSCMP',
    'QPOSILAT',
    'QPOSSLAT',
    'QPOSLAT',
    'QUTMR',
    'QUPRD',
    'QWDTMR',
    'QWDPRD',
    'QDECCTL',
    'QEPCTL',
    'QCAPCTL',
    'QPOSCTL',
    'QEINT',
    'QFLG',
    'QCLR',
    'QFRC',
    'QEPSTS',
    'QCTMR',
    'QCPRD',
    'QCTMRLAT',
    'QCPRDLAT',
    'empty',
    'QEP_REV',
    'TBCTL',
    'TBSTS',
    'TBPHSHR',
    'TBPHS',
    'TBCNT',
    'TBPRD',
    'CMPCTL',
    'CMPAHR',
    'CMPA',
    'CMPB',
    'AQCTLA',
    'AQCTLB',
    'AQSFRC',
    'AQCSFRC',
    'DBCTL',
    'DBRED',
    'DBFED',
    'TZSEL',
    'TZCTL',
    'TZEINT',
    'TZFLG',
    'TZCLR',
    'TZFRC',
    'ETSEL',
    'ETPS',
    'ETFLG',
    'ETCLR',
    'ETFRC',
    'PCCTL',
    'HRCTL',
]

struct_PwmssSet.__fields__ = [
    ('DeAd', UInt32),
    ('ClAd', UInt32),
    ('ClVa', UInt32),
    ('IDVER', UInt32),
    ('SYSCONFIG', UInt32),
    ('CLKCONFIG', UInt32),
    ('CLKSTATUS', UInt32),
    ('TSCTR', UInt32),
    ('CTRPHS', UInt32),
    ('CAP1', UInt32),
    ('CAP2', UInt32),
    ('CAP3', UInt32),
    ('CAP4', UInt32),
    ('ECCTL1', UInt16),
    ('ECCTL2', UInt16),
    ('ECEINT', UInt16),
    ('ECFLG', UInt16),
    ('ECCLR', UInt16),
    ('ECFRC', UInt16),
    ('CAP_REV', UInt32),
    ('QPOSCNT', UInt32),
    ('QPOSINIT', UInt32),
    ('QPOSMAX', UInt32),
    ('QPOSCMP', UInt32),
    ('QPOSILAT', UInt32),
    ('QPOSSLAT', UInt32),
    ('QPOSLAT', UInt32),
    ('QUTMR', UInt32),
    ('QUPRD', UInt32),
    ('QWDTMR', UInt16),
    ('QWDPRD', UInt16),
    ('QDECCTL', UInt16),
    ('QEPCTL', UInt16),
    ('QCAPCTL', UInt16),
    ('QPOSCTL', UInt16),
    ('QEINT', UInt16),
    ('QFLG', UInt16),
    ('QCLR', UInt16),
    ('QFRC', UInt16),
    ('QEPSTS', UInt16),
    ('QCTMR', UInt16),
    ('QCPRD', UInt16),
    ('QCTMRLAT', UInt16),
    ('QCPRDLAT', UInt16),
    ('empty', UInt16),
    ('QEP_REV', UInt32),
    ('TBCTL', UInt16),
    ('TBSTS', UInt16),
    ('TBPHSHR', UInt16),
    ('TBPHS', UInt16),
    ('TBCNT', UInt16),
    ('TBPRD', UInt16),
    ('CMPCTL', UInt16),
    ('CMPAHR', UInt16),
    ('CMPA', UInt16),
    ('CMPB', UInt16),
    ('AQCTLA', UInt16),
    ('AQCTLB', UInt16),
    ('AQSFRC', UInt16),
    ('AQCSFRC', UInt16),
    ('DBCTL', UInt16),
    ('DBRED', UInt16),
    ('DBFED', UInt16),
    ('TZSEL', UInt16),
    ('TZCTL', UInt16),
    ('TZEINT', UInt16),
    ('TZFLG', UInt16),
    ('TZCLR', UInt16),
    ('TZFRC', UInt16),
    ('ETSEL', UInt16),
    ('ETPS', UInt16),
    ('ETFLG', UInt16),
    ('ETCLR', UInt16),
    ('ETFRC', UInt16),
    ('PCCTL', UInt16),
    ('HRCTL', UInt16),
]

# pruio_pwmss.bi: 157

class struct_PwmssArr(Structure):
    pass 

struct_PwmssArr.__slots__ = [
    'DeAd',
    'CMax',
    'C1',
    'C2',
    'QPos',
    'NPos',
    'OPos',
    'PLat',
]

struct_PwmssArr.__fields__ = [
    ('DeAd', UInt32),
    ('CMax', UInt32),
    ('C1', UInt32),
    ('C2', UInt32),
    ('QPos', UInt32),
    ('NPos', UInt32),
    ('OPos', UInt32),
    ('PLat', UInt32),
]

# pruio_pwmss.bi: 224

struct_PwmssUdt.__slots__ = [
    'Top',
    'Init',
    'Conf',
    'Raw',
    'InitParA',
    'PwmMode',
    'CapMode',
    'E0',
    'E1',
    'E2',
    'E3',
    'E4',
    'E5',
    'E6',
    'E7',
    'E8',
    'E9',
]

struct_PwmssUdt.__fields__ = [
    ('Top', POINTER(Pruio_)),
    ('Init', POINTER(PwmssSet) * (PRUIO_AZ_PWMSS + 1)),
    ('Conf', POINTER(PwmssSet) * (PRUIO_AZ_PWMSS + 1)),
    ('Raw', POINTER(PwmssArr) * (PRUIO_AZ_PWMSS + 1)),
    ('InitParA', UInt32),
    ('PwmMode', UInt16),
    ('CapMode', UInt16),
    ('E0', c_char_p),
    ('E1', c_char_p),
    ('E2', c_char_p),
    ('E3', c_char_p),
    ('E4', c_char_p),
    ('E5', c_char_p),
    ('E6', c_char_p),
    ('E7', c_char_p),
    ('E8', c_char_p),
    ('E9', c_char_p),
]

# pruio_pwmss.bi: 272

struct_PwmMod.__slots__ = [
    'Top',
    'ForceUpDown',
    'Cntrl',
    'AqCtl',
]

struct_PwmMod.__fields__ = [
    ('Top', POINTER(Pruio_)),
    ('ForceUpDown', UInt16),
    ('Cntrl', UInt16 * (PRUIO_AZ_PWMSS + 1)),
    ('AqCtl', UInt16 * ((1 + 1) * (PRUIO_AZ_PWMSS + 1) * (2 + 1))),
]

# pruio_pwmss.bi: 299

struct_CapMod.__slots__ = [
    'Top',
]

struct_CapMod.__fields__ = [
    ('Top', POINTER(Pruio_)),
]

# pruio_pwmss.bi: 332

struct_QepMod.__slots__ = [
    'Top',
    'FVh',
    'FVl',
    'Prd',
]

struct_QepMod.__fields__ = [
    ('Top', POINTER(Pruio_)),
    ('FVh', Float_T * (PRUIO_AZ_PWMSS + 1)),
    ('FVl', Float_T * (PRUIO_AZ_PWMSS + 1)),
    ('Prd', UInt32 * (PRUIO_AZ_PWMSS + 1)),
]


# pruio_timer.bi: 45

class struct_TimerSet(Structure):
    pass 

struct_TimerSet.__slots__ = [
    'DeAd',
    'ClAd',
    'ClVa',
    'TIDR',
    'TIOCP_CFG',
    'IRQ_EOI',
    'IRQSTATUS_RAW',
    'IRQSTATUS',
    'IRQENABLE_SET',
    'IRQENABLE_CLR',
    'IRQWAKEEN',
    'TCLR',
    'TCRR',
    'TLDR',
    'TTGR',
    'TWPS',
    'TMAR',
    'TCAR1',
    'TSICR',
    'TCAR2',
]

struct_TimerSet.__fields__ = [
    ('DeAd', UInt32),
    ('ClAd', UInt32),
    ('ClVa', UInt32),
    ('TIDR', UInt32),
    ('TIOCP_CFG', UInt32),
    ('IRQ_EOI', UInt32),
    ('IRQSTATUS_RAW', UInt32),
    ('IRQSTATUS', UInt32),
    ('IRQENABLE_SET', UInt32),
    ('IRQENABLE_CLR', UInt32),
    ('IRQWAKEEN', UInt32),
    ('TCLR', UInt32),
    ('TCRR', UInt32),
    ('TLDR', UInt32),
    ('TTGR', UInt32),
    ('TWPS', UInt32),
    ('TMAR', UInt32),
    ('TCAR1', UInt32),
    ('TSICR', UInt32),
    ('TCAR2', UInt32),
]

# pruio_timer.bi: 61

class struct_TimerArr(Structure):
    pass 

struct_TimerArr.__slots__ = [
    'DeAd',
    'CMax',
    'TCAR1',
    'TCAR2',
]

struct_TimerArr.__fields__ = [
    ('DeAd', UInt32),
    ('CMax', UInt32),
    ('TCAR1', UInt32),
    ('TCAR2', UInt32),
]

# pruio_timer.bi: 117

struct_TimerUdt.__slots__ = [
    'Top',
    'Init',
    'Conf',
    'Raw',
    'InitParA',
    'PwmMode',
    'TimMode',
    'TimHigh',
    'Tim_Low',
    'CapMode',
    'E0',
    'E1',
    'E2',
]

struct_TimerUdt.__fields__ = [
    ('Top', POINTER(Pruio_)),
    ('Init', POINTER(TimerSet) * (PRUIO_AZ_TIMER + 1)),
    ('Conf', POINTER(TimerSet) * (PRUIO_AZ_TIMER + 1)),
    ('Raw', POINTER(TimerArr) * (PRUIO_AZ_TIMER + 1)),
    ('InitParA', UInt32),
    ('PwmMode', UInt32),
    ('TimMode', UInt32),
    ('TimHigh', UInt32),
    ('Tim_Low', UInt32),
    ('CapMode', UInt32),
    ('E0', c_char_p),
    ('E1', c_char_p),
    ('E2', c_char_p),
]


# pruio.bi: 36

try:
    PRUIO_CHAN = CHANNEL5
except:
    pass

# pruio.bi: 38

try:
    PRUIO_MASK = PRU_EVTOUT5_HOSTEN_MASK
except:
    pass

# pruio.bi: 40

try:
    PRUIO_EMAP = PRU_EVTOUT5
except:
    pass

# pruio.bi: 42

try:
    PRUIO_EVNT = PRU_EVTOUT_5
except:
    pass

# pruio.bi: 86

try:
    PRUIO_ACT_PRU1 = 0b0000000000001
except:
    pass

try:
    PRUIO_ACT_ADC = 0b0000000000010
except:
    pass

try:
    PRUIO_ACT_GPIO0 = 0b0000000000100
except:
    pass

try:
    PRUIO_ACT_GPIO1 = 0b0000000001000
except:
    pass

try:
    PRUIO_ACT_GPIO2 = 0b0000000010000
except:
    pass

try:
    PRUIO_ACT_GPIO3 = 0b0000000100000
except:
    pass

try:
    PRUIO_ACT_PWM0 = 0b0000001000000
except:
    pass

try:
    PRUIO_ACT_PWM1 = 0b0000010000000
except:
    pass

try:
    PRUIO_ACT_PWM2 = 0b0000100000000
except:
    pass

try:
    PRUIO_ACT_TIM4 = 0b0001000000000
except:
    pass

try:
    PRUIO_ACT_TIM5 = 0b0010000000000
except:
    pass

try:
    PRUIO_ACT_TIM6 = 0b0100000000000
except:
    pass

try:
    PRUIO_ACT_TIM7 = 0b1000000000000
except:
    pass

try:
    PRUIO_DEF_ACTIVE = 0b1111111111111
except:
    pass

# pruio.bi: 102

class struct_BallSet(Structure):
    pass 

struct_BallSet.__slots__ = [
    'DeAd',
    'Value',
]

struct_BallSet.__fields__ = [
    ('DeAd', UInt32),
    ('Value', UInt8 * (PRUIO_AZ_BALL + 1)),
]

# pruio.bi: 221

struct_PruIo.__slots__ = [
    'Errr',
    'Adc',
    'Gpio',
    'PwmSS',
    'TimSS',
    'Pwm',
    'Cap',
    'Qep',
    'Tim',
    'DRam',
    'Init',
    'Conf',
    'ERam',
    'DInit',
    'DConf',
    'MOffs',
    'BallInit',
    'BallConf',
    'EAddr',
    'ESize',
    'DSize',
    'PruNo',
    'PruIRam',
    'PruDRam',
    'ParOffs',
    'DevAct',
    'BallGpio',
    'IntcInit',
    'MuxAcc',
]

struct_PruIo.__fields__ = [
    ('Errr', c_char_p),
    ('Adc', POINTER(AdcUdt)),
    ('Gpio', POINTER(GpioUdt)),
    ('PwmSS', POINTER(PwmssUdt)),
    ('TimSS', POINTER(TimerUdt)),
    ('Pwm', POINTER(PwmMod)),
    ('Cap', POINTER(CapMod)),
    ('Qep', POINTER(QepMod)),
    ('Tim', POINTER(TimerUdt)),
    ('DRam', POINTER(UInt32)),
    ('Init', POINTER(BallSet)),
    ('Conf', POINTER(BallSet)),
    ('ERam', c_void_p),
    ('DInit', c_void_p),
    ('DConf', c_void_p),
    ('MOffs', c_void_p),
    ('BallInit', POINTER(UInt8)),
    ('BallConf', POINTER(UInt8)),
    ('EAddr', UInt32),
    ('ESize', UInt32),
    ('DSize', UInt32),
    ('PruNo', UInt32),
    ('PruIRam', UInt32),
    ('PruDRam', UInt32),
    ('ParOffs', Int16),
    ('DevAct', Int16),
    ('BallGpio', UInt8 * (PRUIO_AZ_BALL + 1)),
    ('IntcInit', tpruss_intc_initdata),
    ('MuxAcc', STRING),
]
