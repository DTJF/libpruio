# Note: this script needs an fb-doc version (0.4), which may not be published yet.

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

IF(NOT DEFINED DOXYGEN_FOUND)
  FIND_PACKAGE(Doxygen)
  SET(DOXYGEN_FOUND "${DOXYGEN_FOUND}" CACHE STRING "skip target doc" FORCE)
  IF(NOT DOXYGEN_FOUND)
    MESSAGE(STATUS "=> no target 'make doc'")
  ENDIF()
ENDIF()

IF(NOT DOXYGEN_FOUND)
  RETURN()
ENDIF()


SET(inp ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile)
SET(lfn ${CMAKE_CURRENT_SOURCE_DIR}/fb-doc.lfn)
SET(res ${CMAKE_CURRENT_BINARY_DIR}/html/index.html)
SET(MD_SRC
    "../src/_features.md"
    "../src/_preparation.md"
    "../src/_exampleses.md"
    "../src/_pins.md"
    "../src/_memory.md"
    "../src/_messages.md"
    "../src/_changelog.md"
  )

IF(CMAKE_CURRENT_BINARY_DIR STREQUAL
   CMAKE_CURRENT_SOURCE_DIR)
  SET(doxyconf ${CMAKE_BINARY_DIR}/CMakeFiles/Doxyfile)
ELSE()
  SET(doxyconf ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)
ENDIF()

IF(UNIX)
SET(com cat)
ELSE()
SET(com type)
ENDIF()

ADD_CUSTOM_COMMAND(OUTPUT ${lfn}
  COMMAND fbdoc -l
  #DEPENDS ../cmake_fb_deps/cmake_fb_deps.bas
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

ADD_CUSTOM_COMMAND(OUTPUT ${doxyconf}
  COMMAND ${CMAKE_COMMAND} -E copy ${inp} ${doxyconf}
  COMMAND ${com} DoxyExtension >> ${doxyconf}
  DEPENDS ${inp} ${CMAKE_CURRENT_SOURCE_DIR}/DoxyExtension.in
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )

ADD_CUSTOM_COMMAND(OUTPUT ${res}
  COMMAND ${DOXYGEN_EXECUTABLE} ${doxyconf}
  COMMAND fbdoc -s
  DEPENDS ${lfn} ${inp} ${doxyconf} ${MD_SRC}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )


# declare the target name and the source file[s]
ADD_CUSTOM_TARGET(doc DEPENDS ${lfn} ${doxyconf} ${res})

# declare installation rule
#INSTALL(
  #DIRECTORY ${tar}
  #DESTINATION share/doc/${CMAKE_PROJECT_NAME}
  #)

CONFIGURE_FILE(DoxyExtension.in DoxyExtension @ONLY)
