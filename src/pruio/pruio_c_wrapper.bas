/'* \file pruio_c_wrapper.bas
\brief The main source code of the C wrapper for libpruio.

This file provides the libpruio functions in a C compatible syntax to
use libpruio in polyglot applications or to create language bindings
for non-C languages.

Licence: LGPLv2 (http://www.gnu.org/licenses/lgpl-2.0.html)

Copyright 2014-\Year by \Mail

\since 0.0
'/


' driver header file
#INCLUDE ONCE "pruio.bi"

'* \brief Wrapper function for constructor PruIo::PruIo().
'&pruIo* pruio_new(uint16 Act, uint8 Av, uint32 OpD, uint8 SaD);/*
FUNCTION pruio_new CDECL ALIAS "pruio_new"( _
    BYVAL Act AS UInt16 = PRUIO_DEF_ACTIVE _
  , BYVAL  Av AS UInt8  = PRUIO_DEF_AVRAGE _
  , BYVAL OpD AS UInt32 = PRUIO_DEF_ODELAY _
  , BYVAL SaD AS UInt8  = PRUIO_DEF_SDELAY) AS PruIo PTR EXPORT

  RETURN NEW PruIo(Act, Av, OpD, SaD)
END FUNCTION
'&*/

'* \brief Wrapper function for destructor PruIo::~PruIo().
'&void pruio_destroy(pruIo* Io);/*
SUB pruio_destroy CDECL ALIAS "pruio_destroy"( _
    BYVAL Io AS PruIo PTR) EXPORT

  IF Io THEN DELETE Io : Io = 0
END SUB
'&*/

'* \brief Wrapper function for PruIo::config().
'&char* pruio_config(pruIo* Io, uint32 Samp, uint32 Mask, uint32 Tmr, uint16 Mds);/*
FUNCTION pruio_config CDECL ALIAS "pruio_config"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Samp AS UInt32 _
  , BYVAL Mask AS UInt32 _
  , BYVAL  Tmr AS UInt32 _
  , BYVAL  Mds AS UInt16) AS ZSTRING PTR EXPORT

  RETURN Io->config(Samp, Mask, Tmr, Mds)
END FUNCTION
'&*/

'* \brief Wrapper function for PruIo::Pin().
'&char* pruio_Pin(pruIo* Io, uint8 Ball);/*
FUNCTION pruio_Pin CDECL ALIAS "pruio_Pin"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Mo AS UInt8) AS ZSTRING PTR EXPORT

  RETURN Io->Pin(Ball, Mo)
END FUNCTION
'&*/

'* \brief Wrapper function for PruIo::mm_start().
'&char* pruio_mm_start(pruIo* Io, uint32 Trg1, uint32 Trg2, uint32 Trg3, uint32 Trg4);/*
FUNCTION pruio_mm_start CDECL ALIAS "pruio_mm_start"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Trg1 AS UInt32 _
  , BYVAL Trg2 AS UInt32 _
  , BYVAL Trg3 AS UInt32 _
  , BYVAL Trg4 AS UInt32) AS ZSTRING PTR EXPORT

  RETURN Io->mm_start(Trg1, Trg2, Trg3, Trg4)
END FUNCTION
'&*/

'* \brief Wrapper function for PruIo::rb_start().
'&char* pruio_rb_start(pruIo* Io);/*
FUNCTION pruio_rb_start CDECL ALIAS "pruio_rb_start"( _
    BYVAL Io AS PruIo PTR) AS ZSTRING PTR EXPORT

  RETURN Io->rb_start()
END FUNCTION
'&*/


'* \brief Wrapper function for AdcUdt::setStep().
'&char* pruio_adc_setStep(pruIo* Io, uint8 Stp, uint8 ChN, uint8 Av, uint8 SaD, uint32 OpD);/*
FUNCTION pruio_adc_setStep CDECL ALIAS "pruio_adc_setStep"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Stp AS UInt8 _
  , BYVAL ChN AS UInt8 _
  , BYVAL SaD AS UInt8 _
  , BYVAL  Av AS UInt8 _
  , BYVAL OpD AS UInt32) AS ZSTRING PTR EXPORT

  RETURN Io->Adc->setStep(Stp, ChN, Av, SaD, OpD)
END FUNCTION
'&*/

'* \brief Wrapper function for AdcUdt::mm_trg_pin().
'&uint32 pruio_adc_mm_trg_pin(pruIo* Io, uint8 Ball, uint8 GpioV, uint16 Skip);/*
FUNCTION pruio_adc_mm_trg_pin CDECL ALIAS "pruio_adc_mm_trg_pin"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL GpioV AS UInt8 _
  , BYVAL Skip AS UInt16) AS UInt32 EXPORT

  RETURN Io->Adc->mm_trg_pin(Ball, GpioV, Skip)
END FUNCTION
'&*/

'* \brief Wrapper function for AdcUdt::mm_trg_ain().
'&uint32 pruio_adc_mm_trg_ain(pruIo* Io, uint8 Stp, int32 AdcV, uint8 Rela, uint16 Skip);/*
FUNCTION pruio_adc_mm_trg_ain CDECL ALIAS "pruio_adc_mm_trg_ain"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Stp AS UInt8 _
  , BYVAL AdcV AS Int32 _
  , BYVAL Rela AS UInt8 _
  , BYVAL Skip AS UInt16) AS UInt32 EXPORT

  RETURN Io->Adc->mm_trg_ain(Stp, AdcV, Rela, Skip)
END FUNCTION
'&*/

'* \brief Wrapper function for AdcUdt::mm_trg_pre().
'&uint32 pruio_adc_mm_trg_pre(pruIo* Io, uint8 Stp, int32 AdcV, uint16 Samp, uint8 Rela);/*
FUNCTION pruio_adc_mm_trg_pre CDECL ALIAS "pruio_adc_mm_trg_pre"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Stp AS UInt8 _
  , BYVAL AdcV AS Int32 _
  , BYVAL Samp AS UInt16 _
  , BYVAL Rela AS UInt8) AS UInt32 EXPORT

  RETURN Io->Adc->mm_trg_pre(Stp, AdcV, Samp, Rela)
END FUNCTION
'&*/


'* \brief Wrapper function for GpioUdt::config().
'&char* pruio_gpio_config(pruIo* Io, uint8 Ball, uint8 Modus);/*
FUNCTION pruio_gpio_config CDECL ALIAS "pruio_gpio_config"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Modus AS UInt8) AS ZSTRING PTR EXPORT

  RETURN Io->Gpio->config(Ball, Modus)
END FUNCTION
'&*/

'* \brief Wrapper function for GpioUdt::setValue().
'&char* pruio_gpio_setValue(pruIo* Io, uint8 Ball, uint8 Modus);/*
FUNCTION pruio_gpio_setValue CDECL ALIAS "pruio_gpio_setValue"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Modus AS UInt8) AS ZSTRING PTR EXPORT

  RETURN Io->Gpio->setValue(Ball, Modus)
END FUNCTION
'&*/

'* \brief Wrapper function for GpioUdt::Value().
'&uint32 pruio_gpio_Value(pruIo* Io, uint8 Ball);/*
FUNCTION pruio_gpio_Value CDECL ALIAS "pruio_gpio_Value"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8) AS UInt32 EXPORT

  RETURN Io->Gpio->Value(Ball)
END FUNCTION
'&*/


'* \brief Wrapper function for CapMod::config().
'&char* pruio_cap_config(pruIo* Io, uint8 Ball, float_t FLow);/*
FUNCTION pruio_cap_config CDECL ALIAS "pruio_cap_config"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL FLow AS Float_t = 0.) AS ZSTRING PTR EXPORT

  RETURN Io->Cap->config(Ball, FLow)
END FUNCTION
'&*/

'* \brief Wrapper function for CapMod::Value().
'&char* pruio_cap_Value(pruIo* Io, uint8 Ball, float_t* Hz, float_t* Du);/*
FUNCTION pruio_cap_Value CDECL ALIAS "pruio_cap_Value"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0) AS ZSTRING PTR EXPORT

  RETURN Io->Cap->Value(Ball, Hz, Du)
END FUNCTION
'&*/


'* \brief Wrapper function for QepMod::config().
'&char* pruio_qep_config(pruIo* Io, uint8 Ball, uint32 PMax, float_t VHz, float_t Scale, uint8 Mo);/*
FUNCTION pruio_qep_config CDECL ALIAS "pruio_qep_config"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL PMax AS UInt32 = 0 _
  , BYVAL VHz AS Float_t = 25. _
  , BYVAL Scale AS Float_t = 1. _
  , BYVAL Mo AS UInt8 = 0) AS ZSTRING PTR EXPORT

  RETURN Io->Qep->config(Ball, PMax, VHz, Scale, Mo)
END FUNCTION
'&*/

'* \brief Wrapper function for QepMod::Value().
'&char* pruio_qep_Value(pruIo* Io, uint8 Ball, uint32* Posi, float_t* Velo);/*
FUNCTION pruio_qep_Value CDECL ALIAS "pruio_qep_Value"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Posi AS UInt32 PTR = 0 _
  , BYVAL Velo AS Float_t PTR = 0) AS ZSTRING PTR EXPORT

  RETURN Io->Qep->Value(Ball, Posi, Velo)
END FUNCTION
'&*/


'* \brief Wrapper function for PwmMod::Value().
'&char* pruio_pwm_Value(pruIo* Io, uint8 Ball, float_t* Hz, float_t* Du);/*
FUNCTION pruio_pwm_Value CDECL ALIAS "pruio_pwm_Value"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t PTR = 0 _
  , BYVAL Du AS Float_t PTR = 0) AS ZSTRING PTR EXPORT

  RETURN Io->Pwm->Value(Ball, Hz, Du)
END FUNCTION
'&*/

'* \brief Wrapper function for PwmMod::setValue().
'&char* pruio_pwm_setValue(pruIo* Io, uint8 Ball, float_t Hz, float_t Du);/*
FUNCTION pruio_pwm_setValue CDECL ALIAS "pruio_pwm_setValue"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Hz AS Float_t _
  , BYVAL Du AS Float_t) AS ZSTRING PTR EXPORT

  RETURN Io->Pwm->setValue(Ball, Hz, Du)
END FUNCTION
'&*/


'* \brief Wrapper function for TimerUdt::Value().
'&char* pruio_tim_Value(pruIo* Io, uint8 Ball, float_t* Dur1, float_t* Dur2);/*
FUNCTION pruio_tim_Value CDECL ALIAS "pruio_tim_Value"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Dur1 AS Float_t PTR _
  , BYVAL Dur2 AS Float_t PTR) AS ZSTRING PTR EXPORT

  RETURN Io->Tim->Value(Ball, Dur1, Dur2)
END FUNCTION
'&*/

'* \brief Wrapper function for TimerUdt::setValue().
'&char* pruio_tim_setValue(pruIo* Io, uint8 Ball, float_t Dur1, float_t Dur2, uint16 Mode);/*
FUNCTION pruio_tim_setValue CDECL ALIAS "pruio_tim_setValue"( _
    BYVAL Io AS PruIo PTR _
  , BYVAL Ball AS UInt8 _
  , BYVAL Dur1 AS Float_t _
  , BYVAL Dur2 AS Float_t _
  , BYVAL Mode AS UInt16) AS ZSTRING PTR EXPORT

  RETURN Io->Tim->setValue(Ball, Dur1, Dur2, Mode)
END FUNCTION
'&*/


