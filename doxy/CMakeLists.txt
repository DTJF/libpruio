  # Note: this script needs an fbdoc version (1.0.0), which may not be published yet.

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

IF(NOT COMMAND FB_DOCUMENTATION)
  INCLUDE(UseFbDoc)
  IF(NOT COMMAND FB_DOCUMENTATION)
    MSG_LOG("!! no targets <doc...> (UseFbDoc.cmake failed)")
    RETURN()
  ENDIF()
ENDIF()

SET(basdep)
FOREACH(bas ${SRC_BAS})
  LIST(APPEND basdeb ../src/pruio/${bas})
ENDFOREACH()
SET(bidep)
FOREACH(bi ${SRC_BI})
  LIST(APPEND bideb ../src/pruio/${bi})
ENDFOREACH()


FB_DOCUMENTATION(
BAS_SRC
  ${basdeb}
  ${bideb}
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
  ${C_HEADERS}
  )

#INSTALL(
  #DIRECTORY "${CMAKE_BINARY_DIR}/doxy/html"
  #DESTINATION "share/doc/${PROJ_NAME}"
  #COMPONENT doc
  #OPTIONAL
  #)

MSG_LOG(">> targets <doc...> OK!")
