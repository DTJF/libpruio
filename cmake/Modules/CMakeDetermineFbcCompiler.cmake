#
# CMakeFbc - CMake module for FreeBASIC Language
#
# Copyright (C) 2014-2015, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
#
# All rights reserved.
#
# See ReadMe.md for details.
#
# Modified from CMake 2.6.5 CMakeDetermineCCompiler.cmake
# See http://www.cmake.org/HTML/Copyright.html for details
#

# determine the compiler to use for FreeBASIC programs NOTE, a generator
# may set CMAKE_Fbc_COMPILER before loading this file to force a
# compiler. use environment variable FBC first if defined by user, next
# use the cmake variable CMAKE_GENERATOR_Fbc which can be defined by a
# generator as a default compiler
IF(NOT CMAKE_Fbc_COMPILER)
  # prefer the environment variable FBC
  IF($ENV{FBC} MATCHES ".+")
    GET_FILENAME_COMPONENT(CMAKE_Fbc_COMPILER_INIT $ENV{FBC} PROGRAM PROGRAM_ARGS CMAKE_Fbc_FLAGS_ENV_INIT)
    IF(CMAKE_Fbc_FLAGS_ENV_INIT)
      SET(CMAKE_Fbc_COMPILER_ARG1 "${CMAKE_Fbc_FLAGS_ENV_INIT}" CACHE STRING "First argument to fbc compiler")
    ENDIF()
    IF(EXISTS ${CMAKE_Fbc_COMPILER_INIT})
    ELSE()
      MESSAGE(FATAL_ERROR "Could not find compiler set in environment variable\n  $ENV{FBC}.")
    ENDIF()
  ENDIF()

  # next try prefer the compiler specified by the generator
  IF(CMAKE_GENERATOR_Fbc)
    IF(NOT CMAKE_Fbc_COMPILER_INIT)
      SET(CMAKE_Fbc_COMPILER_INIT ${CMAKE_GENERATOR_Fbc})
    ENDIF()
  ENDIF()

  # finally list compilers to try
  IF(CMAKE_Fbc_COMPILER_INIT)
    SET(CMAKE_Fbc_COMPILER_LIST ${CMAKE_Fbc_COMPILER_INIT})
  ELSE()
    SET(CMAKE_Fbc_COMPILER_LIST fbc)
  ENDIF()

  # Find the compiler.
  FIND_PROGRAM(CMAKE_Fbc_COMPILER NAMES ${CMAKE_Fbc_COMPILER_LIST} DOC "fbc compiler")
  IF(CMAKE_Fbc_COMPILER_INIT AND NOT CMAKE_Fbc_COMPILER)
    SET(CMAKE_Fbc_COMPILER "${CMAKE_Fbc_COMPILER_INIT}" CACHE FILEPATH "fbc compiler" FORCE)
  ENDIF()
ENDIF()
GET_FILENAME_COMPONENT(COMPILER_LOCATION "${CMAKE_Fbc_COMPILER}" PATH)

IF(NOT CMAKE_Fbc_DEPS_TOOL)
  FIND_PROGRAM(CMAKE_Fbc_DEPS_TOOL cmake_fb_deps DOC "FreeBASIC dependencies tool.")
  IF(CMAKE_Fbc_DEPS_TOOL)
    SET(CMAKE_Fbc_DEPS_TOOL "${CMAKE_Fbc_DEPS_TOOL}" CACHE FILEPATH "cmake FB dependency tool" FORCE)
    MESSAGE(STATUS "Check for working cmake_fb_deps tool OK ==> ${CMAKE_Fbc_DEPS_TOOL}")
  ENDIF()
ENDIF()

FIND_PROGRAM(CMAKE_AR NAMES ar PATHS ${COMPILER_LOCATION} )

FIND_PROGRAM(CMAKE_RANLIB NAMES ranlib)
IF(NOT CMAKE_RANLIB)
   SET(CMAKE_RANLIB : CACHE INTERNAL "noop for ranlib")
ENDIF()

SET(CMAKE_COMPILER_IS_FBC 1)
FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
  "Determining fbc compiler as ${CMAKE_Fbc_COMPILER}\n\n")

# fix for CMake < 2.8.10
IF(NOT CMAKE_PLATFORM_INFO_DIR)
  SET(CMAKE_PLATFORM_INFO_DIR ${CMAKE_BINARY_DIR}/${CMAKE_FILES_DIRECTORY})
ENDIF()

# configure variables set in this file for fast reload later on
GET_FILENAME_COMPONENT(modpath ${CMAKE_CURRENT_LIST_FILE} PATH)
CONFIGURE_FILE(
  ${modpath}/CMakeFbcCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakeFbcCompiler.cmake
  @ONLY IMMEDIATE # IMMEDIATE must be here for compatibility mode <= 2.0
  )

MARK_AS_ADVANCED(
  CMAKE_AR
  CMAKE_RANLIB
  CMAKE_Fbc_COMPILER
  )
SET(CMAKE_Fbc_COMPILER_ENV_VAR "FBC")
