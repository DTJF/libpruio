#
# CMakeFbc - CMake module for FreeBASIC Language
#
# Copyright (C) 2014-2015, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
#
# All rights reserved.
#
# See Copyright.txt for details.
#
# Modified from CMake 2.6.5 gcc.cmake
# See http://www.cmake.org/HTML/Copyright.html for details
#

SET (CMAKE_Fbc_FLAGS_INIT "")
SET (CMAKE_Fbc_FLAGS_DEBUG_INIT "-g")
SET (CMAKE_Fbc_FLAGS_MINSIZEREL_INIT "-O s")
SET (CMAKE_Fbc_FLAGS_RELEASE_INIT "-O 2")
SET (CMAKE_Fbc_FLAGS_RELWITHDEBINFO_INIT "-O 2 -g")
#SET (CMAKE_Fbc_CREATE_PREPROCESSED_SOURCE "<CMAKE_Fbc_COMPILER> <FLAGS> -r <SOURCE>")
#SET (CMAKE_Fbc_CREATE_ASSEMBLY_SOURCE "<CMAKE_Fbc_COMPILER> <FLAGS> -rr <SOURCE> -o <ASSEMBLY_SOURCE>")
#SET (CMAKE_INCLUDE_SYSTEM_FLAG_FBC "")
