CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
PROJECT(libpruio Fbc C)

INCLUDE(AddFileDependencies)

ADD_SUBDIRECTORY(src/pruio)

ADD_LIBRARY(pruio SHARED $<TARGET_OBJECTS:fbcode>)

ADD_DEPENDENCIES(pruio fbcode)

#SET(CMAKE_VERBOSE_MAKEFILE 1)

SET(C_HEADERS
  "src/pruio/pruio.hp"
  "src/c_include/pruio.h"
  "src/c_include/pruio_pins.h"
  )
INSTALL(FILES ${C_HEADERS}
        DESTINATION include
        COMPONENT c_install
        )
INSTALL(TARGETS pruio
        LIBRARY DESTINATION lib
        )

SET(CPACK_GENERATOR "TBZ2")
#SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Thomas Freiherr") #required
INCLUDE(CPack)
