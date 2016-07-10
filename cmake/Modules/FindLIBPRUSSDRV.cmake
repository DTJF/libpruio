# - Try to find libprussdrv
# Copyright (C) 2014-2016, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
#
# All rights reserved.
#
# Once done this will define
#  LIBPRUSSDRV_FOUND - System has LibPrussdrv
#  LIBPRUSSDRV_INCLUDE_DIRS - The LibPrussdrv include directories
#  LIBPRUSSDRV_LIBRARIES - The libraries needed to use LibPrussdrv
#  LIBPRUSSDRV_DEFINITIONS - Compiler switches required for using LibPrussdrv

FIND_PACKAGE(PkgConfig)
pkg_check_modules(PC_LIBPRUSSDRV QUIET libprussdrv)
SET(LIBPRUSSDRV_DEFINITIONS ${PC_LIBPRUSSDRV_CFLAGS_OTHER})

FIND_PATH(LIBPRUSSDRV_INCLUDE_DIR prussdrv.bi
          HINTS ${PC_LIBPRUSSDRV_INCLUDEDIR} ${PC_LIBPRUSSDRV_INCLUDE_DIRS}
          PATH_SUFFIXES freebasic/BBB)

FIND_LIBRARY(LIBPRUSSDRV_LIBRARY NAMES prussdrv libprussdrv
             HINTS ${PC_LIBPRUSSDRV_LIBDIR} ${PC_LIBPRUSSDRV_LIBRARY_DIRS} )

SET(LIBPRUSSDRV_LIBRARIES ${LIBPRUSSDRV_LIBRARY} )
SET(LIBPRUSSDRV_INCLUDE_DIRS ${LIBPRUSSDRV_INCLUDE_DIR} )

INCLUDE(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set LIBPRUSSDRV_FOUND to TRUE
# if all listed variables are TRUE
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
  libprussdrv DEFAULT_MSG
  LIBPRUSSDRV_LIBRARIES LIBPRUSSDRV_INCLUDE_DIR)

MARK_AS_ADVANCED(LIBPRUSSDRV_INCLUDE_DIR LIBPRUSSDRV_LIBRARY)
