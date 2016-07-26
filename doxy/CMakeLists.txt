# Note: this script needs an fb-doc version (0.4), which may not be published yet.

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

IF(NOT COMMAND FB_DOCUMENTATION)
  INCLUDE(UseFb-Doc)
  IF(NOT COMMAND FB_DOCUMENTATION)
    RETURN()
  ENDIF()
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

INSTALL(
  DIRECTORY "${CMAKE_BINARY_DIR}/doxy/html"
  DESTINATION "share/doc/${PROJ_NAME}"
  COMPONENT doc
  )
