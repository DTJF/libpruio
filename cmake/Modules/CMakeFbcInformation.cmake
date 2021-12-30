#
# CMakeFbc - CMake module for FreeBASIC Language
#
# Copyright (C) 2014-2022, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
#
# All rights reserved.
#
# See ReadMe.md for details.
#
# Modified from CMake 2.6.5 CMakeCInformation.cmake
# See http://www.cmake.org/HTML/Copyright.html for details
#

# This file sets the basic flags for the FreeBASIC language in CMake.
# It also loads the available platform file for the system-compiler
# if it exists.

SET(CMAKE_BASE_NAME fbc)
SET(CMAKE_SYSTEM_AND_Fbc_COMPILER_INFO_FILE
  ${CMAKE_ROOT}/Modules/Platform/${CMAKE_SYSTEM_NAME}-${CMAKE_BASE_NAME}.cmake)
INCLUDE(Platform/${CMAKE_SYSTEM_NAME}-${CMAKE_BASE_NAME} OPTIONAL)

# This should be included before the _INIT variables are
# used to initialize the cache.  Since the rule variables
# have if blocks on them, users can still define them here.
# But, it should still be after the platform file so changes can
# be made to those values.

IF(CMAKE_USER_MAKE_RULES_OVERRIDE)
 INCLUDE(${CMAKE_USER_MAKE_RULES_OVERRIDE})
ENDIF()

IF(CMAKE_USER_MAKE_RULES_OVERRIDE_FBC)
 INCLUDE(${CMAKE_USER_MAKE_RULES_OVERRIDE_FBC})
ENDIF()

SET(CMAKE_Fbc_FLAGS "$ENV{FBCFLAGS} ${CMAKE_Fbc_FLAGS_INIT}"
    CACHE STRING    "Flags for fbc compiler.")

IF(NOT CMAKE_NOT_USING_CONFIG_FLAGS)
# default build type is none
  IF(NOT CMAKE_NO_BUILD_TYPE)
    SET (CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE_INIT}" CACHE STRING
      "Choose the type of build, options are: None(CMAKE_Fbc_FLAGS used) Debug Release RelWithDebInfo MinSizeRel.")
  ENDIF()
  SET (CMAKE_Fbc_FLAGS_DEBUG "${CMAKE_Fbc_FLAGS_DEBUG_INIT}" CACHE STRING
    "Flags used by the compiler during debug builds.")
  SET (CMAKE_Fbc_FLAGS_MINSIZEREL "${CMAKE_Fbc_FLAGS_MINSIZEREL_INIT}" CACHE STRING
    "Flags used by the compiler during release minsize builds.")
  SET (CMAKE_Fbc_FLAGS_RELEASE "${CMAKE_Fbc_FLAGS_RELEASE_INIT}" CACHE STRING
    "Flags used by the compiler during release builds (/MD /Ob1 /Oi /Ot /Oy /Gs will produce slightly less optimized but smaller files).")
  SET (CMAKE_Fbc_FLAGS_RELWITHDEBINFO "${CMAKE_Fbc_FLAGS_RELWITHDEBINFO_INIT}" CACHE STRING
    "Flags used by the compiler during Release with Debug Info builds.")
ENDIF()

IF(CMAKE_Fbc_STANDARD_LIBRARIES_INIT)
  SET(CMAKE_Fbc_STANDARD_LIBRARIES "${CMAKE_Fbc_STANDARD_LIBRARIES_INIT}"
    CACHE STRING "Libraries linked by defalut with all fbc applications.")
  MARK_AS_ADVANCED(CMAKE_Fbc_STANDARD_LIBRARIES)
ENDIF()

INCLUDE(CMakeCommonLanguageInclude)

# now define the following rule variables
# CMAKE_Fbc_CREATE_SHARED_LIBRARY
# CMAKE_Fbc_CREATE_SHARED_MODULE
# CMAKE_Fbc_CREATE_STATIC_LIBRARY
# CMAKE_Fbc_COMPILE_OBJECT
# CMAKE_Fbc_LINK_EXECUTABLE


# create a shared library
IF(NOT CMAKE_Fbc_CREATE_SHARED_LIBRARY)
  SET(CMAKE_Fbc_CREATE_SHARED_LIBRARY
    "<CMAKE_Fbc_COMPILER> <LINK_FLAGS> -dylib -x <TARGET> <OBJECTS> <LINK_LIBRARIES>")
ENDIF()

# create a shared module just copy the shared library rule
IF(NOT CMAKE_Fbc_CREATE_SHARED_MODULE)
  SET(CMAKE_Fbc_CREATE_SHARED_MODULE
    ${CMAKE_Fbc_CREATE_SHARED_LIBRARY})
ENDIF()

# create a static library
IF(NOT CMAKE_Fbc_CREATE_STATIC_LIBRARY)
  SET(CMAKE_Fbc_CREATE_STATIC_LIBRARY
    "<CMAKE_Fbc_COMPILER> <LINK_FLAGS> -lib -x <TARGET> <OBJECTS> <LINK_LIBRARIES>")
ENDIF()

# compile a BAS file into an object file
IF(NOT CMAKE_Fbc_COMPILE_OBJECT)
  SET(CMAKE_Fbc_COMPILE_OBJECT
    "<CMAKE_Fbc_COMPILER> <FLAGS> -c <SOURCE> -o <OBJECT>")
ENDIF()

# link object file[s] to executable
IF(NOT CMAKE_Fbc_LINK_EXECUTABLE)
  SET(CMAKE_Fbc_LINK_EXECUTABLE
    "<CMAKE_Fbc_COMPILER> <FLAGS> <LINK_FLAGS> -x <TARGET> <OBJECTS> <LINK_LIBRARIES>")
ENDIF()

MARK_AS_ADVANCED(
  CMAKE_Fbc_FLAGS
  CMAKE_Fbc_FLAGS_DEBUG
  CMAKE_Fbc_FLAGS_MINSIZEREL
  CMAKE_Fbc_FLAGS_RELEASE
  CMAKE_Fbc_FLAGS_RELWITHDEBINFO
  )

IF(NOT CMAKE_Fbc_DEPS_TOOL)
  MESSAGE(STATUS "Tool cmakefbc_deps not available -> no Fbc extensions!")
ELSE()
  # the macro to add dependencies to a native FB target
  MACRO(ADD_Fbc_SRC_DEPS Tar)
    SET(_file ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${Tar}_deps.cmake)
    GET_TARGET_PROPERTY(_src ${Tar} SOURCES)
    IF(CMAKE_Fbc_INST_PATH)
      SET(_args ${CMAKE_Fbc_INST_PATH} -i=${CMAKE_CURRENT_SOURCE_DIR} ${_file} ${_src})
      EXECUTE_PROCESS(COMMAND "${CMAKE_Fbc_DEPS_TOOL}" ${_args})
    ELSE()
      EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E
        chdir ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_Fbc_DEPS_TOOL} ${_file} ${_src})
    ENDIF()
    INCLUDE(${_file})
    ADD_CUSTOM_TARGET(${Tar}_deps OUTPUT ${_file})
  ENDMACRO(ADD_Fbc_SRC_DEPS)

  # the function to pre-compile FB source to C
  IF(NOT COMMAND CMAKE_PARSE_ARGUMENTS)
    INCLUDE(CMakeParseArguments)
  ENDIF()
  FUNCTION(BAS_2_C CFiles)
    CMAKE_PARSE_ARGUMENTS(ARG "NO_DEPS" "OUT_DIR;OUT_NAM" "SOURCES;COMPILE_FLAGS" ${ARGN})

    IF(ARG_OUT_DIR)
      GET_FILENAME_COMPONENT(_dir ${ARG_OUT_DIR} ABSOLUTE)
      INCLUDE_DIRECTORIES(${_dir})
      EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E make_directory ${_dir})
    ELSE()
      SET(_dir ${CMAKE_CURRENT_BINARY_DIR})
    ENDIF()

    IF(ARG_OUT_NAM)
      SET(_tar ${ARG_OUT_NAM}_deps)
      SET(_deps ${_dir}/${ARG_OUT_NAM}.cmake)
    ELSE()
      SET(_deps ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/bas2c_deps.cmake)
    ENDIF()

    SET(flags "")
    FOREACH(flag ${ARG_COMPILE_FLAGS})
      IF(UNIX)
        SEPARATE_ARGUMENTS(tmp UNIX_COMMAND ${flag})
      ELSE()
        SEPARATE_ARGUMENTS(tmp WINDOWS_COMMAND ${flag})
      ENDIF()
      LIST(APPEND flags tmp)
    ENDFOREACH()

    SET(c_src "")
    SET(fbc_src ${ARG_SOURCES} ${ARG_UNPARSED_ARGUMENTS})
    FOREACH(src ${fbc_src})
      STRING(REGEX REPLACE ".[Bb][Aa][Ss]$" ".c" c_nam ${src})
      SET(c_file "${_dir}/${c_nam}")
      EXECUTE_PROCESS(
        COMMAND ${CMAKE_Fbc_COMPILER} ${flags} ${src}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        )
      IF(${CMAKE_CURRENT_SOURCE_DIR} NOT EQUAL ${_dir})
        EXECUTE_PROCESS(
          COMMAND ${CMAKE_COMMAND} -E rename ${c_nam} ${c_file}
          WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
          )
      ENDIF()
      ADD_CUSTOM_COMMAND(OUTPUT ${c_file}
        COMMAND ${CMAKE_Fbc_COMPILER} ${flags} ${src}
        COMMAND ${CMAKE_COMMAND} -E rename ${c_nam} ${c_file}
        DEPENDS ${src}
        )
      LIST(APPEND c_src ${c_file})
    ENDFOREACH()

    IF(NOT ARG_NO_DEPS)
      IF(CMAKE_Fbc_INST_PATH)
        SET(_args ${CMAKE_Fbc_INST_PATH} -i=${CMAKE_CURRENT_SOURCE_DIR} ${_deps} ${fbc_src})
        EXECUTE_PROCESS(COMMAND "${CMAKE_Fbc_DEPS_TOOL}" ${_args})
      ELSE()
        EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E
          chdir ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_Fbc_DEPS_TOOL} ${_deps} ${fbc_src})
      ENDIF()
      INCLUDE(${_deps})
      ADD_CUSTOM_TARGET(${_tar} OUTPUT ${_deps})
    ENDIF()

    SET(${CFiles} ${c_src} PARENT_SCOPE)
  ENDFUNCTION(BAS_2_C)
ENDIF()

SET(CMAKE_Fbc_INFORMATION_LOADED 1)
