#
# CMakeFbc - CMake module for FreeBASIC Language
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
# determine that the selected fbc compiler can actually compile
# and link the most basic of programs.   If not, a fatal error
# is set and cmake stops processing commands and will not generate
# any makefiles or projects.

IF(CMAKE_Fbc_COMPILER_FORCED)
  # The compiler configuration was forced by the user.
  # Assume the user has configured all compiler information.
  SET(CMAKE_Fbc_COMPILER_WORKS 1)
  RETURN()
ENDIF()

IF(NOT CMAKE_Fbc_COMPILER_WORKS)
  FILE(WRITE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testFbcCompiler.bas
    "?__FB_SIGNATURE__;\nEND SIZEOF(ANY PTR)\n")
	TRY_RUN(CMAKE_Fbc_SIZEOF_ANY_PTR CMAKE_Fbc_COMPILER_WORKS ${CMAKE_BINARY_DIR} ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testFbcCompiler.bas
    COMPILE_DEFINITIONS "-m testFbcCompiler"
	  RUN_OUTPUT_VARIABLE CMAKE_Fbc_COMPILER_ID
	  COMPILE_OUTPUT_VARIABLE OUTPUT
    )
  SET(CMAKE_Fbc_COMPILER_WORKS ${CMAKE_Fbc_COMPILER_WORKS})
  UNSET(CMAKE_Fbc_COMPILER_WORKS CACHE)
  SET(Fbc_TEST_WAS_RUN 1)
  MESSAGE(STATUS "Check for working compiler: ${CMAKE_Fbc_COMPILER} ==> ${CMAKE_Fbc_COMPILER_ID}")
ENDIF()

IF(CMAKE_Fbc_COMPILER_WORKS)
  IF(FBC_TEST_WAS_RUN)
    MESSAGE(STATUS "Compiler: ${CMAKE_Fbc_COMPILER} -- works")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
      "Determining if the fbc compiler works passed with "
      "the following output:\n${OUTPUT}\n\n")
  ENDIF()

  # fix for cmake < 2.8.10
  IF(NOT CMAKE_PLATFORM_INFO_DIR)
    SET(CMAKE_PLATFORM_INFO_DIR ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY})
  ENDIF()

  # Re-configure to save learned information.
  CONFIGURE_FILE(
    ${CMAKE_MODULE_PATH}/CMakeFbcCompiler.cmake.in
    ${CMAKE_PLATFORM_INFO_DIR}/CMakeFbcCompiler.cmake
    @ONLY IMMEDIATE # IMMEDIATE must be here for compatibility mode <= 2.0
    )
  INCLUDE(${CMAKE_PLATFORM_INFO_DIR}/CMakeFbcCompiler.cmake)

ELSE()
  MESSAGE(STATUS "Check for working fbc compiler: ${CMAKE_Fbc_COMPILER} -- broken")
  MESSAGE(STATUS "To force a specific fbc compiler set the FBC environment variable")
  MESSAGE(STATUS "    ie - export FBC=\"/usr/local/bin/fbc\"")
  FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
    "Determining if the fbc compiler works failed with "
    "the following output:\n${OUTPUT}\n\n")
  MESSAGE(FATAL_ERROR
    "The fbc compiler \"${CMAKE_Fbc_COMPILER}\" is not able to compile a simple test program.\n"
    "It fails with the following output:\n---8<---\n${OUTPUT}\n--->8---\n"
    "CMake will not be able to correctly generate this project.")
ENDIF()
