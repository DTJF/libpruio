#
# CMakePasm - CMake module for PRU assembler Language
#
# Copyright (C) 2014, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
#
# All rights reserved.
#
# See ReadMe.md for details.
#
# Modified from CMake 2.6.5 CMakeDetermineCCompiler.cmake
# See http://www.cmake.org/HTML/Copyright.html for details

# determine the compiler to use for PRU assembler programs NOTE, a
# generator may set CMAKE_Pasm_COMPILER before loading this file to
# force a compiler. use environment variable PASM first if defined by
# user, next use the cmake variable CMAKE_GENERATOR_Pasm which can be
# defined by a generator as a default compiler
IF(NOT CMAKE_Pasm_COMPILER)
  # prefer the environment variable PASM
  IF($ENV{PASM} MATCHES ".+")
    GET_FILENAME_COMPONENT(CMAKE_Pasm_COMPILER_INIT $ENV{PASM} PROGRAM PROGRAM_ARGS CMAKE_Pasm_FLAGS_ENV_INIT)
    IF(CMAKE_Pasm_FLAGS_ENV_INIT)
      SET(CMAKE_Pasm_COMPILER_ARG1 "${CMAKE_Pasm_FLAGS_ENV_INIT}" CACHE STRING "First argument to pasm compiler")
    ENDIF()
    IF(EXISTS ${CMAKE_Pasm_COMPILER_INIT})
    ELSE()
      MESSAGE(FATAL_ERROR "Could not find compiler set in environment variable\n  $ENV{PASM}.")
    ENDIF()
  ENDIF()

  # next try prefer the compiler specified by the generator
  IF(CMAKE_GENERATOR_Pasm)
    IF(NOT CMAKE_Pasm_COMPILER_INIT)
      SET(CMAKE_Pasm_COMPILER_INIT ${CMAKE_GENERATOR_PASM})
    ENDIF()
  ENDIF()

  # finally list compilers to try
  IF(CMAKE_Pasm_COMPILER_INIT)
    SET(CMAKE_Pasm_COMPILER_LIST ${CMAKE_Pasm_COMPILER_INIT})
  ELSE()
    SET(CMAKE_Pasm_COMPILER_LIST pasm)
  ENDIF()

  # Find the compiler.
  FIND_PROGRAM(CMAKE_Pasm_COMPILER NAMES ${CMAKE_Pasm_COMPILER_LIST} DOC "pasm compiler")
  IF(CMAKE_Pasm_COMPILER_INIT AND NOT CMAKE_Pasm_COMPILER)
    SET(CMAKE_Pasm_COMPILER "${CMAKE_Pasm_COMPILER_INIT}" CACHE FILEPATH "pasm compiler" FORCE)
  ENDIF()
ENDIF()
MARK_AS_ADVANCED(CMAKE_Pasm_COMPILER)
GET_FILENAME_COMPONENT(COMPILER_LOCATION "${CMAKE_Pasm_COMPILER}" PATH)

#FIND_PROGRAM(CMAKE_AR NAMES ar PATHS ${COMPILER_LOCATION} )

#FIND_PROGRAM(CMAKE_RANLIB NAMES ranlib)
#IF(NOT CMAKE_RANLIB)
   #SET(CMAKE_RANLIB : CACHE INTERNAL "noop for ranlib")
#ENDIF()
#MARK_AS_ADVANCED(CMAKE_RANLIB)

SET(CMAKE_COMPILER_IS_PASM 1)
FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
  "Determining pasm compiler as ${CMAKE_Pasm_COMPILER}\n\n")

# fix for CMake < 2.8.10
IF(NOT CMAKE_PLATFORM_INFO_DIR)
  SET(CMAKE_PLATFORM_INFO_DIR ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY})
ENDIF()

# configure variables set in this file for fast reload later on
CONFIGURE_FILE(${CMAKE_ROOT}/Modules/CMakePasmCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakePasmCompiler.cmake
  @ONLY IMMEDIATE # IMMEDIATE must be here for compatibility mode <= 2.0
  )

#MARK_AS_ADVANCED(CMAKE_AR)
SET(CMAKE_Pasm_COMPILER_ENV_VAR "PASM")
