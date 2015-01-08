CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

PROJECT(libpruio Fbc C)

FIND_PACKAGE(LIBPRUSSDRV REQUIRED)

ADD_SUBDIRECTORY(src/config)
ADD_SUBDIRECTORY(src/pruio)

ADD_LIBRARY(pruio SHARED $<TARGET_OBJECTS:fbcode>)

ADD_DEPENDENCIES(pruio fbcode)

#SET(CMAKE_VERBOSE_MAKEFILE 1)

ADD_CUSTOM_TARGET(examples)
ADD_DEPENDENCIES(examples pruio)
SET_TARGET_PROPERTIES(examples PROPERTIES EXCLUDE_FROM_ALL 1)
ADD_SUBDIRECTORY(src/examples)
ADD_SUBDIRECTORY(src/c_examples)

INSTALL(TARGETS pruio
  LIBRARY DESTINATION lib
  COMPONENT bin
  )

SET(C_HEADERS
  "src/pruio/pruio.hp"
  "src/c_include/pruio.h"
  "src/c_include/pruio_pins.h"
  )
INSTALL(FILES ${C_HEADERS}
  DESTINATION include
  COMPONENT dev
  )


#SET(CPACK_GENERATOR "TBZ2")
SET(CPACK_GENERATOR "DEB")

set(CPACK_PACKAGE_NAME "libpruio")
set(CPACK_PACKAGE_VENDOR "TJF")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "libpruio - fast and easy digital I/O and analog I for BeagleboneBlack")
set(CPACK_PACKAGE_DESCRIPTION "libpruio offers functions to operate fast and easy digital input and output and analog input on the BeagleboneBlack")
set(CPACK_PACKAGE_VERSION "0.2.2")
set(CPACK_PACKAGE_VERSION_MAJOR "0")
set(CPACK_PACKAGE_VERSION_MINOR "2")
set(CPACK_PACKAGE_VERSION_PATCH "2")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "libpruio")
SET(CPACK_PACKAGE_CONTACT "Thomas Freiherr <Thomas.Freiherr@gmx.net>")

#set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")
set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")

SET(CPACK_COMPONENTS_ALL
  bin
  devfb
  dev
  )

#set(CPACK_COMPONENT_BIN_DISPLAY_NAME "library binary and device tree overlay")
#set(CPACK_COMPONENT_BIN_DESCRIPTION "The library binary and the device tree overlay to be used at run-time.")
#set(CPACK_COMPONENT_BIN_REQUIRED TRUE)

#set(CPACK_COMPONENT_DEV_DISPLAY_NAME "C headers")
#set(CPACK_COMPONENT_DEV_DESCRIPTION "The header files for development using C compiler.")
#set(CPACK_COMPONENT_DEV_DEPENDS libpruio)

#set(CPACK_COMPONENT_DEVFB_DISPLAY_NAME "FreeBASIC headers")
#set(CPACK_COMPONENT_DEVFB_DESCRIPTION "The header files for development using FreeBASIC compiler.")
#set(CPACK_COMPONENT_DEVFB_DEPENDS libpruio)

# autogenerate dependency information
#SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
#SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Thomas Freiherr") #required
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "am335x-pru-package")
set(CPACK_DEBIAN_USE_DISPLAY_NAME_IN_FILENAME OFF)
set(CPACK_DEB_COMPONENT_INSTALL ON)

#set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_MONOLITHIC_INSTALL OFF)
#set(CPACK_COMPONENTS_IGNORE_GROUPS IGNORE)
set(CPACK_COMPONENTS_GROUPING IGNORE)

#set(CPACK_DEB_PACKAGE_COMPONENT ON)

#SET(CPACK_INSTALL_CMAKE_PROJECTS ".;libpruio;libpruio;/")
#LIST(APPEND CPACK_INSTALL_CMAKE_PROJECTS ".;libpruiocdev;libpruiocdev;/")
#LIST(APPEND CPACK_INSTALL_CMAKE_PROJECTS ".;libpruiodev;libpruiodev;/")
INCLUDE(CPack)

cpack_add_component(bin
  DISPLAY_NAME "library binary and device tree overlay"
  DESCRIPTION "The library binary and the device tree overlay to be used at run-time."
  REQUIRED
  #DEPENDS
  #GROUP
  #[INSTALL_TYPES type1 type2 ... ]
  #[DOWNLOADED]
  #ARCHIVE_FILE filename1
  )

cpack_add_component(dev
  DISPLAY_NAME "C headers"
  DESCRIPTION "The header files for development using C compiler."
  #REQUIRED
  DEPENDS bin
  #GROUP
  #[INSTALL_TYPES type1 type2 ... ]
  #[DOWNLOADED]
  #ARCHIVE_FILE filename2
  )

cpack_add_component(devfb
  DISPLAY_NAME "FreeBASIC headers"
  DESCRIPTION "The header files for development using FreeBASIC compiler."
  #REQUIRED
  DEPENDS bin
  #GROUP
  #[INSTALL_TYPES type1 type2 ... ]
  #[DOWNLOADED]
  #ARCHIVE_FILE filename3
  )
