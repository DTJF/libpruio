# Note: this script needs an fb-doc version (0.4), which may not be published yet.

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

IF(NOT COMMAND FB_DOCUMENTATION)
  INCLUDE(UseFb-Doc)
ENDIF()

FB_DOCUMENTATION(
BAS_SRC
  ${SRC_BAS}
  ${SRC_BI}
  #${PASM_SRC}
DEPENDS
    "../src/doc/_1_features.md"
    "../src/doc/_2_preparation.md"
    "../src/doc/_3_pins.md"
    "../src/doc/_4_examples.md"
    "../src/doc/_5_memory.md"
    "../src/doc/_6_messages.md"
    "../src/doc/_z_changelog.md"
  ../CMakeLists.txt
  ../ReadMe.md
  Doxyfile
  libpruio.css
  libpruio.xml
  )



#IF(NOT DEFINED DOXYGEN_FOUND)
  #FIND_PACKAGE(Doxygen)
  #SET(DOXYGEN_FOUND "${DOXYGEN_FOUND}" CACHE STRING "skip target doc" FORCE)
  #IF(NOT DOXYGEN_FOUND)
    #MESSAGE(STATUS "=> no target 'make doc'")
    #FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      #"Determining if doxygen works failed\n\n")
  #ENDIF()
#ENDIF()
#IF(NOT DOXYGEN_FOUND)
  #RETURN()
#ENDIF()

## check for fbdoc tool (note: not fb-doc)
#IF(NOT DEFINED FBDOC_WORKS)
  #EXECUTE_PROCESS(
    #COMMAND fbdoc -v
    #RESULT_VARIABLE result
    #ERROR_VARIABLE output
    #OUTPUT_STRIP_TRAILING_WHITESPACE
    #)

  #IF(NOT (result EQUAL "0"))
    #MESSAGE(FATAL_ERROR "fbdoc tool not found! (tried command fbdoc)")
    #FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      #"Finding the fbdoc tool failed!")
    #RETURN()
  #ENDIF()

  #STRING(REGEX MATCH "[0-9][.][0-9][.][0-9]" FBDOC_ID "${output}")
  #STRING(COMPARE LESS "${FBDOC_ID}" "0.3.9" not_working)

  #IF(not_working)
    #MESSAGE(STATUS "fbdoc-${FBDOC_ID} found, but required is 0.3.9 ==> 'make doc' not available!")
    #FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      #"Determining if the fbdoc tool works failed with "
      #"the following output:\n${output}\n\n")
    #RETURN()
  #ENDIF()

  #MESSAGE(STATUS "Check for working fbdoc tool OK ==> ${FBDOC_ID}")
  #SET(FBDOC_WORKS "1" CACHE FILEPATH "fbdoc tool" FORCE)
  #MARK_AS_ADVANCED(FBDOC_WORKS)
  #FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
    #"Determining if the fbdoc tool works passed with "
    #"the following output:\n${output}\n\n")
#ENDIF()
#IF(NOT FBDOC_WORKS)
  #RETURN()
#ENDIF()


## All OK, so let's start
#SET(inp ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile)
#SET(lfn ${CMAKE_CURRENT_SOURCE_DIR}/fb-doc.lfn)
#SET(res ${CMAKE_CURRENT_BINARY_DIR}/html/index.html)
#SET(MD_SRC
    #"../src/_features.md"
    #"../src/_preparation.md"
    #"../src/_exampleses.md"
    #"../src/_pins.md"
    #"../src/_memory.md"
    #"../src/_messages.md"
    #"../src/_changelog.md"
  #)

#IF(CMAKE_CURRENT_BINARY_DIR STREQUAL
   #CMAKE_CURRENT_SOURCE_DIR)
  #SET(doxyconf ${CMAKE_BINARY_DIR}/CMakeFiles/Doxyfile)
#ELSE()
  #SET(doxyconf ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)
#ENDIF()

#IF(UNIX)
#SET(com cat)
#ELSE()
#SET(com type)
#ENDIF()

#ADD_CUSTOM_COMMAND(OUTPUT ${lfn}
  #COMMAND fbdoc -l
  ##DEPENDS ../cmake_fb_deps/cmake_fb_deps.bas
  #WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  #)

#ADD_CUSTOM_COMMAND(OUTPUT ${doxyconf}
  #COMMAND ${CMAKE_COMMAND} -E copy ${inp} ${doxyconf}
  #COMMAND ${com} DoxyExtension >> ${doxyconf}
  #DEPENDS ${inp} ${CMAKE_CURRENT_SOURCE_DIR}/DoxyExtension.in
  #WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  #)

#ADD_CUSTOM_COMMAND(OUTPUT ${res}
  #COMMAND ${DOXYGEN_EXECUTABLE} ${doxyconf}
  #COMMAND fbdoc -s
  #DEPENDS ${lfn} ${inp} ${doxyconf} ${MD_SRC}
  #WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  #)


## declare the target name and the source file[s]
#ADD_CUSTOM_TARGET(doc DEPENDS ${lfn} ${doxyconf} ${res})

## declare installation rule
##INSTALL(
  ##DIRECTORY ${tar}
  ##DESTINATION share/doc/${CMAKE_PROJECT_NAME}
  ##)

#CONFIGURE_FILE(DoxyExtension.in DoxyExtension @ONLY)
