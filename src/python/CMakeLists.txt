CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

IF(NOT COMMAND FB_DOCUMENTATION)
  MSG_LOG(">> no target python!")
  RETURN()
ENDIF()

# search the plugin (adapt PATHS/PATH_SUFFIXES in case of failure).
FIND_LIBRARY(CType_BINARY
  NAMES libpy_ctypes.so libpy_ctypes.dll
  PATHS ../../../../ ../../../../../
  PATH_SUFFIXES fb-doc/build/src/bas/plugins fb-doc/src/bas/plugins
  DOC "py_ctypes plugin for fb-doc"
  NO_DEFAULT_PATH
)
IF(NOT CType_BINARY)
  MSG_LOG(">> no target py (py_ctypes plugin missing)!")
  RETURN()
ENDIF()
MSG_LOG(">> target py OK! (${CType_BINARY})")

SET(PluginDir)
GET_FILENAME_COMPONENT(PluginDir ${CType_BINARY} DIRECTORY)
SET(ResFile ${CMAKE_CURRENT_SOURCE_DIR}/libpruio/pruio.py)
SET(InFiles
  ${CMAKE_CURRENT_SOURCE_DIR}/../pruio/pruio_pins.bi
  ${CMAKE_CURRENT_SOURCE_DIR}/../pruio/pruio_c_wrapper.bas
)

SET(bidep)
FOREACH(bi ${SRC_BI})
  LIST(APPEND bideb ../pruio/${bi})
ENDFOREACH()

ADD_CUSTOM_COMMAND(OUTPUT ${ResFile}
  COMMAND ${FbDoc_EXECUTABLE} ARGS -e "py_ctypes" -t -pylib=${PROJ_NAME} ${InFiles} > ${ResFile}
  #${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/post.cmake
  DEPENDS ${bidep} ${CType_BINARY}
  COMMENT "creating file ${ResFile}"
  VERBATIM
  WORKING_DIRECTORY ${PluginDir}
  )
ADD_CUSTOM_TARGET(py DEPENDS ${ResFile})


#https://gitlab.kitware.com/cmake/cmake/commit/5bd48ac5348885e15ebb23ea825a1ea777985b97:
#SET(tmpi)
#SET(tmpo)
#FILE(READ "${ResFile}" tmpi)
#STRING(REGEX REPLACE "POINTER(Pruio_)" "POINTER(PruIo)" tmpo "${tmpi}")
#FILE(WRITE "${ResFile}" tmpo)
