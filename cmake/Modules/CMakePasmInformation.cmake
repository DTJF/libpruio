#
# CMakeFbc - CMake module for FreeBASIC Language
#
# Copyright (C) 2014, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
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

SET(CMAKE_BASE_NAME pasm)
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

IF(CMAKE_USER_MAKE_RULES_OVERRIDE_PASM)
 INCLUDE(${CMAKE_USER_MAKE_RULES_OVERRIDE_PASM})
ENDIF()

SET(CMAKE_Pasm_FLAGS "$ENV{PASMFLAGS} ${CMAKE_Pasm_FLAGS_INIT}"
    CACHE STRING    "Flags for pasm compiler.")

IF(NOT CMAKE_NOT_USING_CONFIG_FLAGS)
# default build type is none
  IF(NOT CMAKE_NO_BUILD_TYPE)
    SET (CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE_INIT} CACHE STRING
      "Choose the type of build, options are: None(CMAKE_Pasm_FLAGS used) Debug Release RelWithDebInfo MinSizeRel.")
  ENDIF()
  SET (CMAKE_Pasm_FLAGS_DEBUG "${CMAKE_Pasm_FLAGS_DEBUG_INIT}" CACHE STRING
    "Flags used by the compiler during debug builds.")
  SET (CMAKE_Pasm_FLAGS_MINSIZEREL "${CMAKE_Pasm_FLAGS_MINSIZEREL_INIT}" CACHE STRING
    "Flags used by the compiler during release minsize builds.")
  SET (CMAKE_Pasm_FLAGS_RELEASE "${CMAKE_Pasm_FLAGS_RELEASE_INIT}" CACHE STRING
    "Flags used by the compiler during release builds (/MD /Ob1 /Oi /Ot /Oy /Gs will produce slightly less optimized but smaller files).")
  SET (CMAKE_Pasm_FLAGS_RELWITHDEBINFO "${CMAKE_Pasm_FLAGS_RELWITHDEBINFO_INIT}" CACHE STRING
    "Flags used by the compiler during Release with Debug Info builds.")
ENDIF()

IF(CMAKE_Pasm_STANDARD_LIBRARIES_INIT)
  SET(CMAKE_Pasm_STANDARD_LIBRARIES "${CMAKE_Pasm_STANDARD_LIBRARIES_INIT}"
    CACHE STRING "Libraries linked by defalut with all pasm applications.")
  MARK_AS_ADVANCED(CMAKE_Pasm_STANDARD_LIBRARIES)
ENDIF()

INCLUDE(CMakeCommonLanguageInclude)

# now define the following rule variables

# CMAKE_Pasm_CREATE_SHARED_LIBRARY
# CMAKE_Pasm_CREATE_SHARED_MODULE
# CMAKE_Pasm_CREATE_STATIC_LIBRARY
# CMAKE_Pasm_COMPILE_OBJECT
# CMAKE_Pasm_LINK_EXECUTABLE

# variables supplied by the generator at use time
# <TARGET>
# <TARGET_BASE> the target without the suffix
# <OBJECTS>
# <OBJECT>
# <LINK_LIBRARIES>
# <FLAGS>
# <LINK_FLAGS>

# pasm compiler information
# <CMAKE_Pasm_COMPILER>
# <CMAKE_SHARED_LIBRARY_CREATE_Pasm_FLAGS>
# <CMAKE_SHARED_MODULE_CREATE_Pasm_FLAGS>
# <CMAKE_Pasm_LINK_FLAGS>

# Static library tools
# <CMAKE_AR>
# <CMAKE_RANLIB>

#SET(CMAKE_OUTPUT_Pasm_FLAG "-o")
SET(CMAKE_SHARED_LIBRARY_Pasm_FLAGS "")
SET(CMAKE_SHARED_LIBRARY_CREATE_Pasm_FLAGS "-dylib")
#SET(CMAKE_INCLUDE_FLAG_PASM "-I")
#SET(CMAKE_INCLUDE_FLAG_Pasm_SEP " ")
#SET(CMAKE_LIBRARY_PATH_FLAG "-L")
#SET(CMAKE_LINK_LIBRARY_FLAG "-l")
#SET(CMAKE_Pasm_VERSION_FLAG "")

# for most systems a module is the same as a shared library
# so unless the variable CMAKE_MODULE_EXISTS is set just
# copy the values from the LIBRARY variables
IF(NOT CMAKE_MODULE_EXISTS)
  SET(CMAKE_SHARED_MODULE_Pasm_FLAGS ${CMAKE_SHARED_LIBRARY_Pasm_FLAGS})
  SET(CMAKE_SHARED_MODULE_CREATE_Pasm_FLAGS ${CMAKE_SHARED_LIBRARY_CREATE_Pasm_FLAGS})
ENDIF()

# create a shared library
IF(NOT CMAKE_Pasm_CREATE_SHARED_LIBRARY)
	SET(CMAKE_Pasm_CREATE_SHARED_LIBRARY
  	"<CMAKE_Pasm_COMPILER> <CMAKE_SHARED_LIBRARY_Pasm_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_Pasm_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_Pasm_FLAG><TARGET_SONAME> -x <TARGET> <OBJECTS> <LINK_LIBRARIES>")
ENDIF()

# create a shared module just copy the shared library rule
IF(NOT CMAKE_Pasm_CREATE_SHARED_MODULE)
  SET(CMAKE_Pasm_CREATE_SHARED_MODULE ${CMAKE_Pasm_CREATE_SHARED_LIBRARY})
ENDIF()

# create a static library
IF(NOT CMAKE_Pasm_CREATE_STATIC_LIBRARY)
	IF(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    		SET(CMAKE_Pasm_CREATE_STATIC_LIBRARY
	      	"<CMAKE_AR> cr <TARGET>.lib <LINK_FLAGS> <OBJECTS> "
	      	"<CMAKE_RANLIB> <TARGET>.lib "
      		"<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS> "
		      "<CMAKE_RANLIB> <TARGET> "
	      )
	ELSE()
    SET(CMAKE_Pasm_CREATE_STATIC_LIBRARY
  		"<CMAKE_AR> cr <TARGET> <LINK_FLAGS> <OBJECTS> "
		  "<CMAKE_RANLIB> <TARGET>")
	ENDIF()
ENDIF()

# compile a BAS file into an object file
IF(NOT CMAKE_Pasm_COMPILE_OBJECT)
  SET(CMAKE_Pasm_COMPILE_OBJECT
    "<CMAKE_Pasm_COMPILER> <FLAGS> -c <SOURCE> -o <OBJECT>")
ENDIF()

IF(NOT CMAKE_Pasm_LINK_EXECUTABLE)
  SET(CMAKE_Pasm_LINK_EXECUTABLE
    "<CMAKE_Pasm_COMPILER> <FLAGS> <CMAKE_Pasm_LINK_FLAGS> <LINK_FLAGS> -x <TARGET> <OBJECTS> <LINK_LIBRARIES>")
ENDIF()

MARK_AS_ADVANCED(
CMAKE_Pasm_FLAGS
CMAKE_Pasm_FLAGS_DEBUG
CMAKE_Pasm_FLAGS_MINSIZEREL
CMAKE_Pasm_FLAGS_RELEASE
CMAKE_Pasm_FLAGS_RELWITHDEBINFO
)

SET(CMAKE_Pasm_INFORMATION_LOADED 1)
