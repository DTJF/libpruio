CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

IF(NOT FbDoc_WORKS)
  MSG_LOG("!! no target <python>! (missing fbdoc tool)")
  RETURN()
ENDIF()

# search the plugin (adapt PATHS/PATH_SUFFIXES in case of failure).
SET(csd ${CMAKE_SOURCE_DIR}/..)
FIND_LIBRARY(CType_BINARY
  NAMES libpy_ctypes.so libpy_ctypes.dll
  PATHS ${csd} ${csd}/.. ${csd}/../.. ${csd}/../../.. ${csd}/../../../.. ${csd}/../../../../..
  PATH_SUFFIXES fbdoc/build/src/bas/plugins fbdoc/src/bas/plugins
  DOC "py_ctypes plugin for fbdoc"
  NO_DEFAULT_PATH
)
IF(NOT CType_BINARY)
  MSG_LOG("!! no target <python> (py_ctypes plugin missing in fbdoc project)")
  RETURN()
ENDIF()


SET(PluginDir)
GET_FILENAME_COMPONENT(PluginDir ${CType_BINARY} PATH)
SET(ResFile ${CMAKE_CURRENT_SOURCE_DIR}/libpruio/pruio.py)
SET(InFiles
  ${CMAKE_CURRENT_SOURCE_DIR}/../pruio/pruio_pins.bi
  ${CMAKE_CURRENT_SOURCE_DIR}/../pruio/pruio_prussdrv.bi
  ${CMAKE_CURRENT_SOURCE_DIR}/../pruio/pruio_c_wrapper.bas
)

SET(bidep)
FOREACH(bi ${SRC_BI})
  LIST(APPEND bidep ../pruio/${bi})
ENDFOREACH()

ADD_CUSTOM_COMMAND(OUTPUT ${ResFile}
  COMMAND ${FbDoc_EXECUTABLE} ARGS -e "py_ctypes" -t -pylib="pruio" ${InFiles} > ${ResFile}
  DEPENDS ${bidep} ${CType_BINARY}
  COMMENT "creating file ${ResFile}"
  WORKING_DIRECTORY ${PluginDir}
  #VERBATIM
  )
ADD_CUSTOM_TARGET(python DEPENDS ${ResFile})

MSG_LOG(">> target <python> OK! (${CType_BINARY})")
