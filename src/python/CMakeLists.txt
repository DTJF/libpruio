CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

IF(NOT FbDoc_WORKS)
  MSG_LOG("!! no target <python>! (tool fb-doc missing)")
  RETURN()
ENDIF()

# search the plugin (adapt PATHS/PATH_SUFFIXES in case of failure).
SET(csd ${CMAKE_SOURCE_DIR}/..)
FIND_LIBRARY(CType_BINARY
  NAMES libpy_ctypes.so libpy_ctypes.dll
  PATHS ${csd} ${csd}/.. ${csd}/../.. ${csd}/../../.. ${csd}/../../../.. ${csd}/../../../../..
  PATH_SUFFIXES fb-doc/build/src/bas/plugins fb-doc/src/bas/plugins
  DOC "py_ctypes plugin for fb-doc"
  NO_DEFAULT_PATH
)
IF(NOT CType_BINARY)
  MSG_LOG("!! no target <python> (py_ctypes plugin missing in fb-doc project)")
  RETURN()
ENDIF()


SET(PluginDir)
GET_FILENAME_COMPONENT(PluginDir ${CType_BINARY} PATH)
SET(ResFile ${CMAKE_CURRENT_SOURCE_DIR}/libpruio/pruio.py)
SET(InFiles
  ${CMAKE_CURRENT_SOURCE_DIR}/../pruio/pruio_pins.bi
  ${CMAKE_CURRENT_SOURCE_DIR}/../pruio/pruio_c_wrapper.bas
)

SET(bidep)
FOREACH(bi ${SRC_BI})
  LIST(APPEND bidep ../pruio/${bi})
ENDFOREACH()

ADD_CUSTOM_COMMAND(OUTPUT ${ResFile}
  COMMAND echo 'from libprussdrv import tpruss_intc_initdata' > ${ResFile}
  COMMAND ${FbDoc_EXECUTABLE} ARGS -e "py_ctypes" -t -pylib="pruio" ${InFiles} >> ${ResFile}
  DEPENDS ${bidep} ${CType_BINARY}
  COMMENT "creating file ${ResFile}"
  WORKING_DIRECTORY ${PluginDir}
  #VERBATIM
  )
ADD_CUSTOM_TARGET(python DEPENDS ${ResFile})

MSG_LOG(">> target <python> OK! (${CType_BINARY})")
