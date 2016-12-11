SET(ename py_ctypes)
SET(ofile ${CMAKE_BINARY_DIR}/${PROJ_NAME}.py)

FIND_LIBRARY(plugin ${ename} HINTS
  ../../../fb-doc/build/src/bas/plugins
  ../../../../fb-doc/build/src/bas/plugins
  ../../../fb-doc/src/bas/plugins
  ../../../../fb-doc/src/bas/plugins
  )
IF(NOT plugin)
  MSG_LOG(">> no target py (plugin ${ename} not found)")
  RETURN()
ENDIF()

GET_FILENAME_COMPONENT(mpath ${plugin} DIRECTORY)
ADD_CUSTOM_TARGET(py_wrapper
  COMMAND ${CMAKE_COMMAND} -E env LD_LIBRARY_PATH=${mpath} ${FbDoc_EXECUTABLE} -e ${ename} -t -pylib=${PROJ_NAME} pruio.bi > ${ofile}
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src/pruio
  COMMENT "generating file ${ofile} ..."
  )
