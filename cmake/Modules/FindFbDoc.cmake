# This script looks for fbdoc tool (http://github.com/DTJF/fbdoc) to
# generate documentation by the Doxygen generator
#
# It defines the following variables:
#
#   FbDoc_EXECUTABLE     = The path to the fbdoc command.
#   FbDoc_WORKS          = Was fbdoc found or not?
#   FbDoc_VERSION        = The version reported by fbdoc --version
#
# Copyright (C) 2014-2022, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
# License GPLv3 (see http://www.gnu.org/licenses/gpl-3.0.html)
#
# See ReadMe.md for details.

IF(NOT FbDoc_WORKS)
  SET(fbdoc "fbdoc")
  SET(minvers "1.0")

  FIND_PROGRAM(FbDoc_EXECUTABLE
    NAMES ${fbdoc}
    DOC "${fbdoc} documentation generation tool (http://github.com/DTJF/fbdoc)"
  )

  IF(FbDoc_EXECUTABLE EQUAL "")
    MESSAGE(STATUS "${fbdoc} tool not found! (tried command ${fbdoc})")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Finding the ${fbdoc} tool failed!")
    RETURN()
  ENDIF()

  EXECUTE_PROCESS(
    COMMAND ${FbDoc_EXECUTABLE} -v
    RESULT_VARIABLE result
    ERROR_VARIABLE output
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

  IF(NOT (result EQUAL "0"))
    MESSAGE(STATUS "${fbdoc} tool not executable! (tried command ${fbdoc})")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Executing the ${fbdoc} tool failed!")
    RETURN()
  ENDIF()

  STRING(REGEX MATCH "version [0-9][.][0-9][.][0-9]" FbDoc_VERSION "${output}")
  STRING(COMPARE LESS "${FbDoc_VERSION}" "${minvers}" not_working)

  IF(not_working)
    MESSAGE(STATUS "${fbdoc}-${FbDoc_VERSION} found, but required is ${minvers} ==> 'make doc' not available!")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Determining if the ${fbdoc} tool works failed with "
      "the following output:\n${output}\n\n")
    RETURN()
  ENDIF()

  MESSAGE(STATUS "Check for working ${fbdoc} tool OK ==> ${FbDoc_EXECUTABLE} (${FbDoc_VERSION})")
  SET(FbDoc_EXECUTABLE "${FbDoc_EXECUTABLE}" CACHE FILEPATH "${fbdoc} tool" FORCE)
  SET(FbDoc_VERSION "${FbDoc_VERSION}" CACHE STRING "${fbdoc} version" FORCE)
  SET(FbDoc_WORKS "1" CACHE FILEPATH "${fbdoc} tool" FORCE)
  MARK_AS_ADVANCED(
    FbDoc_EXECUTABLE
    FbDoc_WORKS
    FbDoc_VERSION
    )
  FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
    "Determining if the ${fbdoc} tool works passed with "
    "the following output:\n${output}\n\n")
ENDIF()
