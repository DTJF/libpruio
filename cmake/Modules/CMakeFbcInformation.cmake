#
# CMakeFbc - CMake module for FreeBASIC Language
#
# Copyright (C) 2014-2015, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
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
    SET (CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE_INIT} CACHE STRING
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

# variables supplied by the generator at use time
# <TARGET>
# <TARGET_BASE> the target without the suffix
# <OBJECTS>
# <OBJECT>
# <LINK_LIBRARIES>
# <FLAGS>
# <LINK_FLAGS>

# fbc compiler information
# <CMAKE_Fbc_COMPILER>
# <CMAKE_SHARED_LIBRARY_CREATE_Fbc_FLAGS>
# <CMAKE_SHARED_MODULE_CREATE_Fbc_FLAGS>
# <CMAKE_Fbc_LINK_FLAGS>

# Static library tools
# <CMAKE_AR>
# <CMAKE_RANLIB>

SET(CMAKE_OUTPUT_Fbc_FLAG "-o ")
SET(CMAKE_SHARED_LIBRARY_Fbc_FLAGS "")
SET(CMAKE_SHARED_LIBRARY_CREATE_Fbc_FLAGS "-dylib")
SET(CMAKE_INCLUDE_FLAG_FBC "-I ")
SET(CMAKE_INCLUDE_FLAG_Fbc_SEP " ")
SET(CMAKE_LIBRARY_PATH_FLAG "-L ")
SET(CMAKE_LINK_LIBRARY_FLAG "-l ")
SET(CMAKE_LINK_LIBRARY_FILE_FLAG "-Wl")
#SET(CMAKE_Fbc_VERSION_FLAG "")

# for most systems a module is the same as a shared library
# so unless the variable CMAKE_MODULE_EXISTS is set just
# copy the values from the LIBRARY variables
IF(NOT CMAKE_MODULE_EXISTS)
  SET(CMAKE_SHARED_MODULE_Fbc_FLAGS ${CMAKE_SHARED_LIBRARY_Fbc_FLAGS})
  SET(CMAKE_SHARED_MODULE_CREATE_Fbc_FLAGS ${CMAKE_SHARED_LIBRARY_CREATE_Fbc_FLAGS})
ENDIF()

# create a shared library
IF(NOT CMAKE_Fbc_CREATE_SHARED_LIBRARY)
  SET(CMAKE_Fbc_CREATE_SHARED_LIBRARY
    "<CMAKE_Fbc_COMPILER> <CMAKE_SHARED_LIBRARY_Fbc_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_Fbc_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_Fbc_FLAG><TARGET_SONAME> -x <TARGET> <OBJECTS> <LINK_LIBRARIES>")
ENDIF()

# create a shared module just copy the shared library rule
IF(NOT CMAKE_Fbc_CREATE_SHARED_MODULE)
  SET(CMAKE_Fbc_CREATE_SHARED_MODULE ${CMAKE_Fbc_CREATE_SHARED_LIBRARY})
ENDIF()

# create a static library
IF(NOT CMAKE_Fbc_CREATE_STATIC_LIBRARY)
  IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    SET(CMAKE_Fbc_CREATE_STATIC_LIBRARY
      "<CMAKE_AR> cr <TARGET>.lib <LINK_FLAGS> <OBJECTS> "
      "<CMAKE_RANLIB> <TARGET>.lib "
      "<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS> "
      "<CMAKE_RANLIB> <TARGET> "
    )
  ELSE()
    SET(CMAKE_Fbc_CREATE_STATIC_LIBRARY
      "<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS> "
      "<CMAKE_RANLIB> <TARGET>")
  ENDIF()
ENDIF()

# compile a BAS file into an object file
IF(NOT CMAKE_Fbc_COMPILE_OBJECT)
  SET(CMAKE_Fbc_COMPILE_OBJECT
    "<CMAKE_Fbc_COMPILER> <FLAGS> -c <SOURCE> -o <OBJECT>")
ENDIF()

IF(NOT CMAKE_Fbc_LINK_EXECUTABLE)
  SET(CMAKE_Fbc_LINK_EXECUTABLE
    "<CMAKE_Fbc_COMPILER> <FLAGS> <CMAKE_Fbc_LINK_FLAGS> <LINK_FLAGS> -x <TARGET> <OBJECTS> <LINK_LIBRARIES>")
ENDIF()

MARK_AS_ADVANCED(
  CMAKE_Fbc_FLAGS
  CMAKE_Fbc_FLAGS_DEBUG
  CMAKE_Fbc_FLAGS_MINSIZEREL
  CMAKE_Fbc_FLAGS_RELEASE
  CMAKE_Fbc_FLAGS_RELWITHDEBINFO
  )

IF(NOT CMAKE_Fbc_DEPS_TOOL)
  MESSAGE(STATUS "Tool cmake_fb_deps not available -> no Fbc extensions!")
ELSE()
  # the macro to add dependencies to a native FB target
  MACRO(ADD_Fbc_SRC_DEPS Tar)
    SET(_file ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${Tar}_deps.cmake)
    GET_TARGET_PROPERTY(_src ${Tar} SOURCES)
    EXECUTE_PROCESS(
      COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_CURRENT_SOURCE_DIR} cmake_fb_deps ${_file} ${_src}
      )
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
        COMMAND ${CMAKE_Fbc_COMPILER} ${flags} -gen gcc -r ${src}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        )
      IF(${CMAKE_CURRENT_SOURCE_DIR} NOT EQUAL ${_dir})
        EXECUTE_PROCESS(
          COMMAND ${CMAKE_COMMAND} -E rename ${c_nam} ${c_file}
          WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
          )
      ENDIF()
      ADD_CUSTOM_COMMAND(OUTPUT ${c_file}
        COMMAND ${CMAKE_Fbc_COMPILER} ${flags} -gen gcc -r ${src}
        COMMAND ${CMAKE_COMMAND} -E rename ${c_nam} ${c_file}
        DEPENDS ${src}
        )
      LIST(APPEND c_src ${c_file})
    ENDFOREACH()

    IF(NOT ARG_NO_DEPS)
      EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_CURRENT_SOURCE_DIR} cmake_fb_deps ${_deps} ${fbc_src}
        )
      INCLUDE(${_deps})
      ADD_CUSTOM_TARGET(${_tar} OUTPUT ${_deps})
    ENDIF()

    SET(${CFiles} ${c_src} PARENT_SCOPE)
  ENDFUNCTION(BAS_2_C)
ENDIF()

SET(CMAKE_Fbc_INFORMATION_LOADED 1)
