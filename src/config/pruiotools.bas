/'* \file pruiotools.bas
\brief Common source code for the helper tools dts_custom.bas and dts_universal.bas.

This file contains common source code used by the device tree overlay
helper tools dts_custom.bas and dts_universal.bas. Do not edit (experts
only).

Licence: GPLv3

Copyright 2014-\Year by \Mail

\since 0.2

'/

'* The name of the pinmux folders in /sys/devices/ocp.* (must match the definition in pruio.bas).
#DEFINE PMUX_NAME "pruio-"
TYPE AS UBYTE uint8 '*< Type alias.
' Convenience declarations.
#INCLUDE ONCE "../pruio/pruio_pins.bi"

'* The start of the source file
#DEFINE ALL_START _
  "// dts file auto generated by pruio_config (don't edit)" _
  !"\n/dts-v1/;" _
  !"\n/plugin/;" _
  !"\n" _
  !"\n/ {" _
  !"\n    compatible = " & COMPATIBL & """ti,beaglebone""" _
  !"\n" _
  !"\n    // identification" _
  !"\n    board-name = """ & FILE_NAME & """;" _
  !"\n    manufacturer = ""TJF"";" _
  !"\n    part-number = ""PruIoBBB"";" _
  !"\n    version = """ & VERS_NAME & """;" _
  !"\n" _
  !"\n    // state the resources this cape uses" _
  !"\n    exclusive-use ="

'* An entry line for the `exclusive-use =` section.
#DEFINE ENTRY_EXCL(_T_) !"\n      """ & _T_ & ""","

'* The end of the source file (pinmux setting).
#DEFINE ALL_END _
  !"\n    fragment@2 {" _
  !"\n      target = <&pruss>;" _
  !"\n      __overlay__ {" _
  !"\n          status = ""okay"";"_
  !"\n      };" _
  !"\n    };" _
  USER_ADD_ON _
  !"\n  };"


'* The start of fragment0 in the source file (pinmux settings).
#DEFINE FRAG0_START _
  !"\n      ""pruss"";" _
  !"\n" _
  !"\n    fragment@0 {" _
  !"\n      target = <&am33xx_pinmux>;" _
  !"\n      __overlay__ {"

'* The end of fragment0 in the source file (pinmux settings).
#DEFINE FRAG0_END _
  !"\n      };" _
  !"\n    };"


'* The start of fragment1 in the source file (pinmux_helper).
#DEFINE FRAG1_START _
  !"\n    fragment@1 {" _
  !"\n      target = <&ocp>;" _
  !"\n      __overlay__ {"

'* The end of fragment1 in the source file (pinmux_helper).
#DEFINE FRAG1_END _
  !"\n      };" _
  !"\n    };"

'* Macro creating the files.
#MACRO CREATE()
  IF LEN(COMPATIBL) THEN COMPATIBL = """" & COMPATIBL & """, "
  VAR fnam = FILE_NAME & "-" & VERS_NAME, _ '*< The file name (without path / suffix)
       fnr = FREEFILE                       '*< The file number.
  'IF OPEN CONS(FOR OUTPUT AS #fnr) THEN '' alternative for console output
    '?"failed openig console"
  IF OPEN(fnam & ".dts" FOR OUTPUT AS fnr) THEN
    ?"failed writing file: " & fnam & ".dts"
  ELSE
    PRINT #fnr, ALL_START;
    FOR i AS LONG = 0 TO UBOUND(M)
      VAR x = IIF(LEN(M(i)), nameBall(i), 0) '*< The header pin name.
      IF x THEN PRINT #fnr, ENTRY_EXCL(*x);
    NEXT

    PRINT #fnr, FRAG0_START;
    FOR i AS LONG = 0 TO UBOUND(M)
      IF LEN(M(i)) THEN PRINT #fnr, f0entry(i);
    NEXT
    PRINT #fnr, FRAG0_END;

    PRINT #fnr, FRAG1_START;
    FOR i AS LONG = 0 TO UBOUND(M)
      IF LEN(M(i)) THEN PRINT #fnr, f1entry(i);
    NEXT
    PRINT #fnr, FRAG1_END;
    PRINT #fnr, ALL_END;
    CLOSE #fnr

    IF LEN(COMMAND(1)) THEN TARG_PATH = COMMAND(1)
    IF RIGHT(TARG_PATH, 1) <> "/" THEN TARG_PATH &= "/"
    SHELL("dtc -@ -I dts -O dtb -o " & TARG_PATH & fnam & ".dtbo " & fnam & ".dts")
  END IF
#ENDMACRO

'* Enumerators for pin modes.
ENUM PinModes
  NP = &b001000 '*< no resistor connected
  PU = &b010000 '*< pullup resistor connected
  PD = &b000000 '*< pulldown resistor connected
  RX = &b100000 '*< input receiver enabled

  _O_ = NP      '*< setting for an output pin.
  _I_ = RX + PD '*< setting for an input pin.
  I_O = RX + NP '*< setting for an in-/out-put pin.
  IOD = RX + NP '*< setting for an in-/out-put pin.

  TMRi = _I_ '*< setting for a TIMER input pin.
  TMRo = _O_ '*< setting for a TIMER output pin.
  CAPi = _I_ '*< setting for a CAP input pin.
  CAPo = _O_ '*< setting for a CAP output pin.
  QEPi = IOD '*< setting for a QEP input pin.
  QEPo = _O_ '*< setting for a QEP output pin (sync).
  PWMi = _I_ '*< setting for a PWM input pin (sync).
  PWMo = _O_ '*< setting for a PWM output pin.
END ENUM

'* The default settings for the GPIO modes.
#DEFINE GPIO_DEF CHR( _
    7 + RX + NP _ ' input, open (no resistor)
  , 7 + RX + PU _ ' input, pullup resistor
  , 7 + RX + PD _ ' input, pulldown resistor
  , 7 + NP  _     ' output (no resistor)
  )

'* Macro to delete the pin configuration for a pin set array.
#DEFINE PIN_DEL(_A_) FOR i AS LONG = 0 TO UBOUND(_A_) : M(_A_(i)) = "" : NEXT

'* The array to be filled with modus settings for all pins.
DIM SHARED AS STRING M(109)
'* A variable to add user fragments (starting at fragment@3 {}), in order to enable subsystems.
DIM SHARED AS STRING USER_ADD_ON


/'* \brief Create lines for `fragment@0` with all settings of a pin.
\param I The index (ball number) of the pin in global array M.
\returns A string containing several lines with pin settings for fragment0.

This function creates a buch of lines used in `fragment@0`, declaring
the DT-nodes for all the defined pinmux modes in array M(). In this
fragment the pinmux modes get declared. Each nodes is named (and
labeled) by the letter `B` and two hexadecimal numbers, concatenated by
an underscore. The first number is the CPU ball number and the second
is the pinmux mode. Ie. `B6B_2F` stands for CPU ball `6B` (= P9_25) in
modus `2F` (= GPIO input, no resistor).

'/
FUNCTION f0entry(BYVAL I AS UBYTE) AS STRING
  VAR r = "" _
    , b0 = HEX(I, 2) _
    , b4 = HEX(I * 4, 3)

  SELECT CASE AS CONST I
  CASE  89 : b4 = "1A0 0x2F  0x" & b4
  CASE 104 : b4 = "164 0x2F  0x" & b4
  CASE 106 : b4 = "1B4 0x2F  0x" & b4
  CASE 108 : b4 = "1A8 0x2F  0x" & b4
  END SELECT

  FOR j AS LONG = 0 TO LEN(M(I)) - 1
    VAR x = HEX(M(I)[j], 2) _
      , n = b0 & "_" & x
    r &= _
      !"\n        B" & n & ": " & n _
      & " {pinctrl-single,pins = <0x" & b4 & " 0x" & x & ">;};"
  NEXT : RETURN r
END FUNCTION


/'* \brief Create lines for `fragment@0` with all settings of a pin.
\param I The index (ball number) of the pin in global array M.
\returns A string containing an entry with pin settings for fragment1.

This function creates a buch of lines used in `fragment@1`, declaring
the DT-nodes for all the defined pinmux modes in array M(). In this
fragment the name entries for the status files in the sysfs get
declared. Each pinmux mode is named by a hexadecimal number. The number
represents the pinmux mode. Ie. `x2F` stands for modus `2F` (= GPIO
input, no resistor).

'/
FUNCTION f1entry(BYVAL I AS UBYTE) AS STRING
  VAR _
    j = 0 _
  , tn = HEX(I, 2) _
  , t0 = _
    !"\n        " & PMUX_NAME & tn & " {" _
    !"\n          compatible = ""bone-pinmux-helper"";" _
    !"\n          status = ""okay"";" _
    !"\n          pinctrl-names = " _
  , t1 = _
    !"\n        };" _
  , l = "" _
  , n = ""

  FOR j = 0 TO LEN(M(I)) - 2
    VAR t = HEX(M(I)[j], 2)
    n &= """x" & t & """, "
    l &= !"\n          pinctrl-" & j & " = <&B" & tn & "_" & t & ">;"
  NEXT
  VAR t = HEX(M(I)[j], 2)
  n &= """x" & t & """;"
  l &= !"\n          pinctrl-" & j & " = <&B" & tn & "_" & t & ">;"
  RETURN t0 & n & l & t1
END FUNCTION


/'* \brief Get header pin connected to CPU ball.
\param Ball The CPU ball number.
\returns A string pointer (don't free it) on success (otherwise zero).
\since 0.2

This function creates a text description of the header pin connected to
a CPU ball. The returned string is owned by this function and must not
be freed.

When the CPU ball is not connected to a header pin, this function
returns 0 (zero).

'/
FUNCTION nameBall CDECL(BYVAL Ball AS UBYTE) AS ZSTRING PTR
  SELECT CASE AS CONST Ball '                                  find name
  CASE P8_03 : RETURN @"P8.03"
  CASE P8_04 : RETURN @"P8.04"
  CASE P8_05 : RETURN @"P8.05"
  CASE P8_06 : RETURN @"P8.06"
  CASE P8_07 : RETURN @"P8.07"
  CASE P8_08 : RETURN @"P8.08"
  CASE P8_09 : RETURN @"P8.09"
  CASE P8_10 : RETURN @"P8.10"
  CASE P8_11 : RETURN @"P8.11"
  CASE P8_12 : RETURN @"P8.12"
  CASE P8_13 : RETURN @"P8.13"
  CASE P8_14 : RETURN @"P8.14"
  CASE P8_15 : RETURN @"P8.15"
  CASE P8_16 : RETURN @"P8.16"
  CASE P8_17 : RETURN @"P8.17"
  CASE P8_18 : RETURN @"P8.18"
  CASE P8_19 : RETURN @"P8.19"
  CASE P8_20 : RETURN @"P8.20"
  CASE P8_21 : RETURN @"P8.21"
  CASE P8_22 : RETURN @"P8.22"
  CASE P8_23 : RETURN @"P8.23"
  CASE P8_24 : RETURN @"P8.24"
  CASE P8_25 : RETURN @"P8.25"
  CASE P8_26 : RETURN @"P8.26"
  CASE P8_27 : RETURN @"P8.27"
  CASE P8_28 : RETURN @"P8.28"
  CASE P8_29 : RETURN @"P8.29"
  CASE P8_30 : RETURN @"P8.30"
  CASE P8_31 : RETURN @"P8.31"
  CASE P8_32 : RETURN @"P8.32"
  CASE P8_33 : RETURN @"P8.33"
  CASE P8_34 : RETURN @"P8.34"
  CASE P8_35 : RETURN @"P8.35"
  CASE P8_36 : RETURN @"P8.36"
  CASE P8_37 : RETURN @"P8.37"
  CASE P8_38 : RETURN @"P8.38"
  CASE P8_39 : RETURN @"P8.39"
  CASE P8_40 : RETURN @"P8.40"
  CASE P8_41 : RETURN @"P8.41"
  CASE P8_42 : RETURN @"P8.42"
  CASE P8_43 : RETURN @"P8.43"
  CASE P8_44 : RETURN @"P8.44"
  CASE P8_45 : RETURN @"P8.45"
  CASE P8_46 : RETURN @"P8.46"
  CASE P9_11 : RETURN @"P9.11"
  CASE P9_12 : RETURN @"P9.12"
  CASE P9_13 : RETURN @"P9.13"
  CASE P9_14 : RETURN @"P9.14"
  CASE P9_15 : RETURN @"P9.15"
  CASE P9_16 : RETURN @"P9.16"
  CASE P9_17 : RETURN @"P9.17"
  CASE P9_18 : RETURN @"P9.18"
  CASE P9_19 : RETURN @"P9.19"
  CASE P9_20 : RETURN @"P9.20"
  CASE P9_21 : RETURN @"P9.21"
  CASE P9_22 : RETURN @"P9.22"
  CASE P9_23 : RETURN @"P9.23"
  CASE P9_24 : RETURN @"P9.24"
  CASE P9_25 : RETURN @"P9.25"
  CASE P9_26 : RETURN @"P9.26"
  CASE P9_27 : RETURN @"P9.27"
  CASE P9_28 : RETURN @"P9.28"
  CASE P9_29 : RETURN @"P9.29"
  CASE P9_30 : RETURN @"P9.30"
  CASE P9_31 : RETURN @"P9.31"
  CASE P9_41 : RETURN @"P9.41"
  CASE P9_42 : RETURN @"P9.42"
  CASE JT_04 : RETURN @"JT.04"
  CASE JT_05 : RETURN @"JT.05"
  END SELECT : RETURN 0
END FUNCTION
