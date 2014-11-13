/'* \file dts_custom.bas
\brief Tool to create, compile and install a customized device tree overlay for libpruio.

This is a helper tool for an customized device tree overlay with fixed
pin configurations. Adapt this FB source code, compile it and run the
executable. This will create a device tree overlay source file in the
current directory, and, if you execute the binary with root privileges,
this overlay gets compiled and installed in /lib/firmware.

The customized overlay provides fixed pinmuxing configurations. The
libpruio code can get executed as normal user (no root privileges are
required). It claims only the configured header pins.

- to include a pin add a line like `M(P9_42) = CHR(0 + _I_)` (which
  configures pin 42 at header P9 in mode 0 as input pin)

When done,

-# Compile the tool by `fbc -w all dts_custom.bas`.

-# Execute the binary without root privileges by `./dts_custom` to
   control the generated source pruio_custom-0A00.dts, or

-# execute the binary with root privileges by `sudo ./dts_custom` to
   install the compiled overlay in /lib/firmware.

The overlay source remains in the current folder (file
pruio_custom-0A00.dts). Load the overlay by

~~~{.sh}
sudo su
echo pruio_custom > /sys/devices/bone_capemgr.*/slots
exit
~~~

(Or execute the `echo ...` command in your boot sequence. Or use
capemgr to load the overlay. See \ref SecPreconditions for further
information.)

Licence: GPLv3

Copyright 2014 by Thomas{ dOt ]Freiherr[ At ]gmx[ DoT }net


Compile by:

fbc -w all dts_custom.bas

\since 0.2
'/


#INCLUDE ONCE "pruiotools.bas"

'''''''''''''''''''''''''''''''''''''''''''''''''''''''' adapt this code

'* The file name.
#DEFINE FILE_NAME "pruio_custom"
'* The version.
#DEFINE VERS_NAME "00A0"
'* The folder to place the compiled overlay binary.
'#DEFINE PATH_NAME "/lib/firmware"
#DEFINE PATH_NAME "./"

' create settings for all required pins here
M(P8_07) = CHR(7 + _I_)  ' example: pin 7 at header P8 in mode 7 as input with pulldown resistor

M(P9_42) = CHR(0 + _I_)
''''''''''''''''''''''''''''''''''''''''''''''''''''''' end of adaptions


VAR fnam = FILE_NAME & "-" & VERS_NAME, _ '*< The file name (without path / suffix)
     fnr = FREEFILE                       '*< The file number.
IF OPEN(fnam & ".dts" FOR OUTPUT AS fnr) THEN
'IF OPEN CONS(FOR OUTPUT AS #fnr) THEN
  '?"failed openig console"
  ?"failed writing file: " & fnam & ".dts"
ELSE
  PRINT #fnr, ALL_START;

  FOR i AS LONG = 0 TO UBOUND(M)
    VAR x = IIF(LEN(M(i)), nameBall(i), 0) '*< The header pin name.
    IF x THEN PRINT #fnr, ENTRY_EXCL(*x);
  NEXT

  PRINT #fnr, FRAG0_START;
  PRINT #fnr, !"\n        " & FILE_NAME &": " & FILE_NAME & "_pins" _
             & " {pinctrl-single,pins = <";

  FOR i AS LONG = 0 TO UBOUND(M)
    IF LEN(M(i)) THEN PRINT #fnr, f0custom(i);
  NEXT

  PRINT #fnr, !"\n        >;};";
  PRINT #fnr, FRAG0_END;
  PRINT #fnr, ALL_END;
  CLOSE #fnr

  SHELL("dtc -@ -I dts -O dtb -o " & PATH_NAME & "/" & fnam & ".dtbo " & fnam & ".dts")
END IF
