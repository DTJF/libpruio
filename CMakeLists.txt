CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

#SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules/")
#SET(CMAKE_VERBOSE_MAKEFILE 1)

# constants
SET(PROJ_NAME "libpruio" CACHE STRING "project name" FORCE)
SET(PROJ_DESC "Fast and easy Digital/Analog Input/Output for Beaglebones" CACHE STRING "project description" FORCE)
SET(PROJ_VERS "0.6.6"   CACHE STRING "project version" FORCE)
SET(PROJ_AUTH "DTJF"    CACHE STRING "project authors" FORCE)
SET(PROJ_MAIL "Thomas{ doT ]Freiherr[ At ]gmx[ DoT }net"  CACHE STRING "project mail address" FORCE)
SET(PROJ_WEBS "https://github.com/DTJF/libpruio" CACHE STRING "project website" FORCE)
SET(PROJ_LICE "LGPLv2.1" CACHE STRING "project licence" FORCE)
#STRING(TIMESTAMP tmp "%Y" UTC) # requires CMake 2.8.11
#SET(PROJ_YEAR "${tmp}"             CACHE STRING "project year" FORCE)
SET(PROJ_YEAR "2019"   CACHE STRING "project year" FORCE)

PROJECT(${PROJ_NAME} Fbc C)

FUNCTION(MSG_LOG Txt)
  FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log "${Txt}\n\n")
  MESSAGE(STATUS ${Txt})
ENDFUNCTION()

CONFIGURE_FILE(src/doc/ReadMe.md.in ${CMAKE_SOURCE_DIR}/ReadMe.md @ONLY)

IF(NOT CMAKE_C_COMPILER_WORKS)
  MSG_LOG("!! no target <lkm...> (C compiler problem)")
ELSE()
  ADD_SUBDIRECTORY(src/lkm)    # target lkm
ENDIF()

ADD_CUSTOM_TARGET(examples)
IF(NOT CMAKE_Fbc_COMPILER_WORKS)
  MSG_LOG("!! no targets <all> <fb_examples> <c_examples> (fbc compiler problem)")
ELSE()
  ADD_SUBDIRECTORY(src/pruio)
  IF(NOT PASM_ASSEMBER_WORKS)
    MSG_LOG("!! no targets <all> <fb_examples> <c_examples> (missing pasm assembler)")
  ELSE()
    ADD_LIBRARY(pruio SHARED $<TARGET_OBJECTS:pruiofbcode>)
    ADD_DEPENDENCIES(pruio pruiofbcode)
    SET(CMAKE_SHARED_LINKER_FLAGS "-Wl -z,relro") # must be global
    SET_TARGET_PROPERTIES(pruio PROPERTIES
      SOVERSION "o" # adapt <Package: ...> in debian/control
      #NO_SONAME "YES"
      )
    INSTALL(TARGETS pruio
      #LIBRARY DESTINATION lib/${PROJ_NAME}-${PROJ_VERS}
      LIBRARY DESTINATION lib/
      COMPONENT bin
      )

    ADD_CUSTOM_TARGET(fb_examples DEPENDS pruio)
    ADD_SUBDIRECTORY(src/examples)
    SET_TARGET_PROPERTIES(fb_examples PROPERTIES EXCLUDE_FROM_ALL 1)
    ADD_DEPENDENCIES(examples fb_examples)

    IF(NOT CMAKE_C_COMPILER_WORKS)
      MSG_LOG("!! no target <c_examples> (C compiler problem)")
    ELSE()
      ADD_CUSTOM_TARGET(c_examples DEPENDS pruio)
      SET_TARGET_PROPERTIES(c_examples PROPERTIES EXCLUDE_FROM_ALL 1)
      ADD_DEPENDENCIES(examples c_examples)
      ADD_SUBDIRECTORY(src/c_examples)
    ENDIF()
  ENDIF()
  ADD_SUBDIRECTORY(src/config)
ENDIF()

ADD_SUBDIRECTORY(doxy)       # targets <doc> <doc_htm> <doc_pdf> <doc_www>
ADD_SUBDIRECTORY(src/python) # target <python>
ADD_SUBDIRECTORY(debian)     # target <deb>

SET_TARGET_PROPERTIES(examples PROPERTIES EXCLUDE_FROM_ALL 1)

SET(C_HEADERS
  "src/pruio/pruio.hp"
  "src/c_include/pruio.h"
  "src/c_include/pruio_intc.h"
  "src/c_include/pruio_pins.h"
  "src/c_include/pruio_pins_blue.h"
  "src/c_include/pruio_pins_pocket.h"
  "src/c_include/pruio_prussdrv.h"
  )
INSTALL(FILES ${C_HEADERS}
  DESTINATION include/${PROJ_NAME}
  COMPONENT dev
  )
#INSTALL(DIRECTORY src/c_examples/
  #DESTINATION src/${PROJ_NAME}
  #CONFIGURATIONS Release
  #FILES_MATCHING PATTERN "src/c_examples/*.c"
  #PATTERN "CMakeFiles" EXCLUDE
  #)

#INSTALL(DIRECTORY src/examples/
  #DESTINATION src/${PROJ_NAME}
  #CONFIGURATIONS Release
  #FILES_MATCHING PATTERN "src/examples/*.bas"
  #PATTERN "CMakeFiles" EXCLUDE
  #)

#INSTALL(DIRECTORY src/python/
  #DESTINATION src/${PROJ_NAME}
  #CONFIGURATIONS Release
  #FILES_MATCHING PATTERN "src/python/*.py"
  #PATTERN "CMakeFiles" EXCLUDE
  #)
#INSTALL(DIRECTORY src/python/libpruio/
  #DESTINATION lib/${PROJ_NAME}
  #CONFIGURATIONS Release
  #FILES_MATCHING PATTERN "src/python/libpruio/*.py"
  #)


#SET(CPACK_GENERATOR "DEB")
#SET(CPACK_PACKAGE_VERSION "${PROJ_VERS}")
##SET(CPACK_PACKAGE_FILE_NAME "${PROJ_NAME}-${CPACK_DEB_PACKAGE_COMPONENT_PART_NAME}-${PROJ_VERS}")
#SET(CPACK_PACKAGE_NAME "${PROJ_NAME}")
#SET(CPACK_PACKAGE_FILE_NAME "${PROJ_NAME}")
#SET(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${PROJ_WEBS}")
#SET(CPACK_DEBIAN_PACKAGE_MAINTAINER
  #"Arend Lammertink <lamare@gmail.com>") #required
#SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJ_DESC})
#SET(CPACK_DEBIAN_PACKAGE_DESCRIPTION
    #"${PROJ_DESC}"
  #"\n ${PROJ_NAME} is a driver to handle input and output on"
  #"\n digital and analog lines on Beaglebone hardware."
  #"\n The driver bypasses the kernel driver and provides direct"
  #"\n access to the hardware, supported by the PRU subsystems."
     #)

## Generate required change log file
#EXECUTE_PROCESS(
  #COMMAND gzip -9 -c -n ${CMAKE_CURRENT_SOURCE_DIR}/debian/changelog
  #WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
  #OUTPUT_FILE "${CMAKE_BINARY_DIR}/changelog.gz"
  #)

##SET(CPACK_PACKAGE_DESCRIPTION_FILE ReadMe.md)
#SET(CPACK_DEB_COMPONENT_INSTALL ON)
#SET(CPACK_DEBIAN_PACKAGE_CONTROL_STRICT_PERMISSION TRUE)

#SET(CPACK_COMPONENT_DEV_DEPENDS bin)
#SET(CPACK_COMPONENT_DOC_DEPENDS bin)

#SET(CPACK_DEBIAN_BIN_PACKAGE_SHLIBDEPS ON)
##SET(CPACK_DEBIAN_BIN_PACKAGE_NAME "${PROJ_NAME}") # since 3.5!
#INSTALL(FILES   "${CMAKE_BINARY_DIR}/changelog.gz"
                #"${CMAKE_SOURCE_DIR}/debian/copyright"
                #DESTINATION "share/doc/${PROJ_NAME}"
                #COMPONENT bin
                #)
#SET(CPACK_DEBIAN_BIN_PACKAGE_CONTROL_EXTRA
  #"${CMAKE_CURRENT_SOURCE_DIR}/debian/postinst"
  #"${CMAKE_CURRENT_SOURCE_DIR}/debian/postrm"
  #)

#SET(CPACK_DEBIAN_DEV_PACKAGE_SECTION libdevel) # since 3.5!
#INSTALL(FILES   "${CMAKE_BINARY_DIR}/changelog.gz"
                #"${CMAKE_SOURCE_DIR}/debian/copyright"
                #DESTINATION "share/doc/${PROJ_NAME}-dev"
                #COMPONENT dev
                #)
#SET(CPACK_DEBIAN_DOC_PACKAGE_SECTION doc)
#INSTALL(FILES   "${CMAKE_BINARY_DIR}/changelog.gz"
                #"${CMAKE_SOURCE_DIR}/debian/copyright"
                #DESTINATION "share/doc/${PROJ_NAME}-doc"
                #COMPONENT doc
                #)

#SET(CMAKE_INSTALL_RPATH /usr/local/lib)
#SET(CPACK_DEBIAN_PACKAGE_DEBUG ON)

#INCLUDE(CPack)
