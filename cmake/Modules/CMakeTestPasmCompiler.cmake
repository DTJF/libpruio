#
# CMakePasm - CMake module for PRU assembler Language
#
# Copyright (C) 2014, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
#
# All rights reserved.
#
# See ReadMe.md for details.
#
# Modified from CMake 2.6.5 CMakeTestCCompiler.cmake
# See http://www.cmake.org/HTML/Copyright.html for details
#

# This file is used by EnableLanguage in cmGlobalGenerator to
# determine that the selected pasm compiler can actually compile
# and link the most basic of programs.   If not, a fatal error
# is set and cmake stops processing commands and will not generate
# any makefiles or projects.

IF(CMAKE_Pasm_COMPILER_FORCED)
  # The compiler configuration was forced by the user.
  # Assume the user has configured all compiler information.
  SET(CMAKE_Pasm_COMPILER_WORKS 1)
  RETURN()
ENDIF()

IF(NOT CMAKE_Pasm_COMPILER_WORKS)
  FILE(WRITE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testPasmCompiler.p
    "HALT\n")
	TRY_COMPILE(CMAKE_Pasm_COMPILER_WORKS ${CMAKE_BINARY_DIR} ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testPasmCompiler.p
    COMPILE_DEFINITIONS "-V3 -y -CPasmCode testPasmCompiler.p"
	  OUTPUT_VARIABLE OUTPUT
    )
  SET(CMAKE_Pasm_COMPILER_WORKS ${CMAKE_Pasm_COMPILER_WORKS})
  UNSET(CMAKE_Pasm_COMPILER_WORKS CACHE)
  SET(Pasm_TEST_WAS_RUN 1)
  MESSAGE(STATUS "Check for working compiler: ${CMAKE_Pasm_COMPILER} ==> ${CMAKE_Pasm_COMPILER_ID}")
ENDIF()

IF(CMAKE_Pasm_COMPILER_WORKS)
  IF(Pasm_TEST_WAS_RUN)
    MESSAGE(STATUS "Compiler: ${CMAKE_Pasm_COMPILER} -- works")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
      "Determining if the pasm compiler works passed with "
      "the following output:\n${OUTPUT}\n\n")
  ENDIF()

  # fix for cmake < 2.8.10
  IF(NOT CMAKE_PLATFORM_INFO_DIR)
    SET(CMAKE_PLATFORM_INFO_DIR ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY})
  ENDIF()

  # Re-configure to save learned information.
  CONFIGURE_FILE(
    ${CMAKE_ROOT}/Modules/CMakePasmCompiler.cmake.in
    ${CMAKE_PLATFORM_INFO_DIR}/CMakePasmCompiler.cmake
    @ONLY IMMEDIATE # IMMEDIATE must be here for compatibility mode <= 2.0
    )
  INCLUDE(${CMAKE_PLATFORM_INFO_DIR}/CMakePasmCompiler.cmake)

ELSE()
  MESSAGE(STATUS "Check for working pasm compiler: ${CMAKE_Pasm_COMPILER} -- broken")
  MESSAGE(STATUS "To force a specific pasm compiler set the PASM environment variable")
  MESSAGE(STATUS "    ie - export PASM=\"/usr/local/bin/pasm\"")
  FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
    "Determining if the pasm compiler works failed with "
    "the following output:\n${OUTPUT}\n\n")
  MESSAGE(FATAL_ERROR
    "The pasm compiler \"${CMAKE_Pasm_COMPILER}\" is not able to compile a simple test program.\n"
    "It fails with the following output:\n---8<---\n${OUTPUT}\n--->8---\n"
    "CMake will not be able to correctly generate this project.")
ENDIF()
