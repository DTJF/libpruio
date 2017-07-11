/'* \file dts_universal.bas
\brief Tool to create, compile and install an universal device tree overlay for libpruio for run-time pinmuxing.

This is a helper tool for an universal device tree overlay. Adapt this
FB source code, compile it and run the executable. This will create a
device tree overlay source file in the current directory, and, if you
execute the binary with root privileges, this overlay gets compiled and
installed in /lib/firmware.

The universal overlay provides pinmuxing capability at run-time. Root
privileges are required to achieve this. It claims all header pins and
prepares configurations for all modes. By default the free header pins
on a Beaglebone Black are declared. Customizing can be done to include
more pins (ie. the HDMI pins when not used) or to reduce the number of
pins (ie. when they interfere with other capes).

- To include a pins group uncomment the matching `PIN_DEL(...)` line, or

- to drop a pin add a code line like `M(P8_08) = ""` right below the
  `PIN_DEL(...)` lines.

When done,

-# compile the tool by `fbc -w all dts_universal.bas`, and

-# execute the binary with root privileges by `sudo ./dts_universal`

to install the compiled overlay in /lib/firmware. The overlay source
remains in the current folder (file libpruio-00A0.dts). Load the
overlay by

~~~{.txt}
sudo su
echo libpruio > /sys/devices/bone_capemgr.*/slots
exit
~~~

or on kernel versions > 3.8

~~~{.txt}
sudo su
echo libpruio > /sys/devices/platform/bone_capemgr.*/slots
exit
~~~

(Or execute the `echo ...` command in your boot sequence. Or use
capemgr to load the overlay. See \ref SecPreconditions for further
information.)

Licence: GPLv3

Copyright 2014-\Year by \Mail


Compile by:

fbc -w all dts_universal.bas

\since 0.2
'/


#INCLUDE ONCE "pruiotools.bas"

'''''''''''''''''''''''''''''''''''''''''''''''''''''''' adapt this code

'* The file name.
#DEFINE FILE_NAME "libpruio"
'* The version.
#DEFINE VERS_NAME "00A0"
'* The folder to place the compiled overlay binary.
VAR PATH_NAME = "."

' quick & dirty: first create settings for all pins ...
#INCLUDE ONCE "P8.bi"
#INCLUDE ONCE "P9.bi"
#INCLUDE ONCE "JTag.bi"
' ... then delete unwanted pin groups (or single pins)
SELECT CASE COMMAND(2)
CASE "BBW"
  PIN_DEL(EMMC2_Pins)
  'PIN_DEL(I2C1_Pins)
CASE "BBG"
  PIN_DEL(EMMC2_Pins)
  'PIN_DEL(I2C1_Pins)
CASE "BBB"
  PIN_DEL(HDMI_Pins)
  PIN_DEL(EMMC2_Pins)
  'PIN_DEL(I2C1_Pins)
  'PIN_DEL(I2C2_Pins)
  PIN_DEL(MCASP0_Pins)
  M(P8_25) = "" ' #4:BB-BONE-EMMC-2G
CASE ELSE ' all pins
END SELECT
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

  IF LEN(COMMAND(1)) THEN PATH_NAME = COMMAND(1)
  IF RIGHT(PATH_NAME, 1) <> "/" THEN PATH_NAME &= "/"
  SHELL("dtc -@ -I dts -O dtb -o " & PATH_NAME & fnam & ".dtbo " & fnam & ".dts")
END IF
