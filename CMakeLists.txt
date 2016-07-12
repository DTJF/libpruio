CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

PROJECT(libpruio Fbc C)

# constants
SET(PROJ_NAME "${CMAKE_PROJECT_NAME}" CACHE STRING "project name" FORCE)
SET(PROJ_DESC "Fast and easy Input/Output driver for digital/analog lines on Beagleboard hardware" CACHE STRING "project description" FORCE)
SET(PROJ_VERS "0.4.0"   CACHE STRING "project version" FORCE)
SET(PROJ_AUTH "DTJF"    CACHE STRING "project authors" FORCE)
SET(PROJ_MAIL "Thomas{ doT ]Freiherr[ At ]gmx[ DoT }net"  CACHE STRING "project mail address" FORCE)
SET(PROJ_WEBS "https://github.com/DTJF/libpruio" CACHE STRING "project website" FORCE)
SET(PROJ_LICE "LGPLv2.1" CACHE STRING "project licence" FORCE)
#STRING(TIMESTAMP tmp "%Y" UTC) # requires CMake 2.8.11
#SET(PROJ_YEAR "${tmp}"             CACHE STRING "project year" FORCE)
SET(PROJ_YEAR "2016"   CACHE STRING "project year" FORCE)

CONFIGURE_FILE(src/doc/ReadMe.md.in ${CMAKE_SOURCE_DIR}/ReadMe.md @ONLY)
ADD_SUBDIRECTORY(doxy)

#FIND_PACKAGE(LIBPRUSSDRV REQUIRED)
FIND_PACKAGE(LIBPRUSSDRV)
ADD_SUBDIRECTORY(src/config)
ADD_SUBDIRECTORY(src/pruio)

IF(PASM_ASSEMBER_WORKS AND LIBPRUSSDRV_LIBRARY)
  ADD_LIBRARY(pruio SHARED $<TARGET_OBJECTS:pruiofbcode>)
  ADD_DEPENDENCIES(pruio pruiofbcode)

  SET(CMAKE_VERBOSE_MAKEFILE 1)

  ADD_CUSTOM_TARGET(examples)
  ADD_SUBDIRECTORY(src/examples)
  ADD_SUBDIRECTORY(src/c_examples)
  ADD_DEPENDENCIES(examples pruio)
  #SET_TARGET_PROPERTIES(examples PROPERTIES EXCLUDE_FROM_ALL 1)

  INSTALL(TARGETS pruio
    LIBRARY DESTINATION lib
    COMPONENT bin
    )
ELSE()
  MESSAGE(STATUS ">> no target all")
  #ADD_EXECUTABLE(dummy src/config/dts_custom.bas)
  #SET_TARGET_PROPERTIES(dummy PROPERTIES COMPILE_FLAGS "-m dts_custom")

  SET_TARGET_PROPERTIES(doc PROPERTIES EXCLUDE_FROM_ALL 0)
  #RETURN()
ENDIF()

SET(C_HEADERS
  "src/pruio/pruio.hp"
  "src/c_include/pruio.h"
  "src/c_include/pruio_pins.h"
  )
INSTALL(FILES ${C_HEADERS}
  DESTINATION include
  COMPONENT dev
  )


SET(CPACK_GENERATOR "DEB")
SET(CPACK_PACKAGE_VERSION "${PROJ_VERS}")
#SET(CPACK_PACKAGE_FILE_NAME "${PROJ_NAME}-${CPACK_DEB_PACKAGE_COMPONENT_PART_NAME}-${PROJ_VERS}")
SET(CPACK_PACKAGE_FILE_NAME "${PROJ_NAME}")
SET(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${PROJ_WEBS}")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER
  "Arend Lammertink <lamare@gmail.com>") #required
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJ_DESC})
SET(CPACK_PACKAGE_DESCRIPTION
  ".aif saf hgk hsgh has aghahsg.k hasgkh .kahg kasg .shg hsgkh hsgh ashgl")

#SET(CPACK_PACKAGE_DESCRIPTION_FILE ReadMe.md)
SET(CPACK_DEB_COMPONENT_INSTALL ON)
SET(CPACK_DEBIAN_PACKAGE_CONTROL_STRICT_PERMISSION TRUE)
SET(CPACK_DEBIAN_bin_PACKAGE_CONTROL_EXTRA
  "${CMAKE_CURRENT_SOURCE_DIR}/debian/postinst"
  "${CMAKE_CURRENT_SOURCE_DIR}/debian/postrm"
  )

set(CPACK_COMPONENT_dev_DEPENDS bin)
set(CPACK_COMPONENT_doc_DEPENDS bin)

# Generate required change log files
EXECUTE_PROCESS(COMMAND gzip -9 -c ${CMAKE_CURRENT_SOURCE_DIR}/debian/changelog
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
                OUTPUT_FILE "${CMAKE_BINARY_DIR}/changelog.gz"
                )
EXECUTE_PROCESS(COMMAND gzip -9 -c ${CMAKE_CURRENT_SOURCE_DIR}/debian/copyright
                WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
                OUTPUT_FILE "${CMAKE_BINARY_DIR}/copyright.gz"
                )
INSTALL(FILES   "${CMAKE_BINARY_DIR}/changelog.gz"
                "${CMAKE_BINARY_DIR}/copyright.gz"
                DESTINATION "share/doc/${PROJ_NAME}-${PROJ_VERS}"
                COMPONENT bin
                )

#SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)

INCLUDE(CPack)
