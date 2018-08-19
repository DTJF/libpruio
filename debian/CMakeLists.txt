# check for Debian packaging tools
FIND_PROGRAM(deb_exe debuild)
IF(NOT deb_exe)
  MSG_LOG(">> no target <deb> (Debian tools missing - tried command debuild)")
  RETURN()
ENDIF()
MSG_LOG(">> target <deb> OK!")

##SET(exam ${CMAKE_SOURCE_DIR}/debian/tmp/usr/src/${PROJ_NAME})
#SET(exam ${CMAKE_SOURCE_DIR}/debian/tmp/usr/src/${PROJ_NAME})
#ADD_CUSTOM_TARGET(exportexam mkdir -p ${exam}
  #COMMAND cd ${CMAKE_SOURCE_DIR}/src/examples && cp *.bas ${exam}
  #COMMAND cd ${CMAKE_SOURCE_DIR}/src/c_examples && cp *.c ${exam}
  #COMMAND cd ${CMAKE_SOURCE_DIR}/src/python && cp *.py ${exam}
  #)

# in-source: create target deb for in-source debuild
IF(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  ADD_CUSTOM_TARGET(deb cd ${CMAKE_SOURCE_DIR} && ${deb_exe} ${DEBUILD_FLAGS})

  INSTALL(FILES ${CMAKE_BINARY_DIR}/src/lkm/x/${PROJ_NAME}.ko
    DESTINATION /lib/modules/
    )

  CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/src/lkm/systemctl.service.in ${PROJ_NAME}.service @ONLY)

  #EXECUTE_PROCESS(
    #COMMAND
  #)

  SET(dest src/${PROJ_NAME}.examples)
  INSTALL(DIRECTORY ${CMAKE_SOURCE_DIR}/src/c_examples/
    DESTINATION ${dest}
    FILES_MATCHING PATTERN "src/c_examples/*.c"
    PATTERN "CMakeFiles" EXCLUDE
    )

  INSTALL(DIRECTORY ${CMAKE_SOURCE_DIR}/src/examples/
    DESTINATION ${dest}
    FILES_MATCHING PATTERN "src/examples/*.bas"
    PATTERN "CMakeFiles" EXCLUDE
    )

  SET(dest src/python)
  INSTALL(DIRECTORY ${CMAKE_SOURCE_DIR}/src/python/
    DESTINATION ${dest}
    FILES_MATCHING PATTERN "src/python/*.py"
    PATTERN "CMakeFiles" EXCLUDE
    )
  INSTALL(DIRECTORY ${CMAKE_SOURCE_DIR}/src/python/${PROJ_NAME}/
    DESTINATION ${dest}/${PROJ_NAME}
    FILES_MATCHING PATTERN "src/python/${PROJ_NAME}/*.py"
    PATTERN "*.py?" EXCLUDE
    )
  RETURN()
ENDIF()

# out-of-source: create clean build subfolder
SET(src # files & dirs to copy from root dir
  CMakeLists.txt
  *.md
  cmake
  debian
  doxy
  src
  )
# create target deb for out-of-source debuild
SET(fold packages/${PROJ_NAME})
ADD_CUSTOM_TARGET(deb rm -rf ${fold}
  COMMAND mkdir -p ${fold}
  COMMAND cd ${CMAKE_SOURCE_DIR} && cp -r ${src} ${CMAKE_CURRENT_BINARY_DIR}/${fold}
  COMMAND cd ${fold} && ${deb_exe} ${DEBUILD_FLAGS}
  )

