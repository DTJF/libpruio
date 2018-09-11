CMAKE_MINIMUM_REQUIRED(VERSION 2.8.3)

IF(NOT CMAKE_C_COMPILER_WORKS)
  MSG_LOG("!! no targets <lkm...> (C compiler problem)")
  RETURN()
ENDIF()

#check linux headers
SET(hpath /usr/src/linux-headers-${CMAKE_SYSTEM_VERSION})
IF(NOT EXISTS ${hpath})
  MSG_LOG("!! no targets <lkm...> (missing headers @ ${hpath})")
  RETURN()
ENDIF()


# use a subfolder x in order to avoid CMake overriding our Makefile
IF(${CMAKE_BINARY_DIR} STREQUAL ${CMAKE_SOURCE_DIR})
  SET(wdir ${CMAKE_CURRENT_SOURCE_DIR}/x)
ELSE()
  SET(wdir ${CMAKE_CURRENT_BINARY_DIR}/x)
ENDIF()

SET(serv_nam ${PROJ_NAME}-lkm.service)
SET(lkm ${wdir}/${PROJ_NAME}.ko)
SET(src ${CMAKE_CURRENT_SOURCE_DIR}/${PROJ_NAME}.c)
SET(serv_deb ${CMAKE_SOURCE_DIR}/debian/${serv_nam})
CONFIGURE_FILE(Makefile.in ${wdir}/Makefile @ONLY)
CONFIGURE_FILE(systemctl.service.in ${serv_deb} @ONLY)

ADD_CUSTOM_COMMAND(OUTPUT ${lkm}
  COMMAND cp ${src} ${wdir}
  COMMAND make clean && make
  WORKING_DIRECTORY ${wdir}
  #VERBATIM
  )
ADD_CUSTOM_TARGET(lkm DEPENDS
  ${lkm}
  ${src}
  Makefile.in
  )


SET(lkm_vers /lib/modules/${CMAKE_SYSTEM_VERSION}/extra/${PROJ_NAME}.ko)
SET(lkm_glob /lib/modules/${PROJ_NAME}.ko)
SET(serv_tar /etc/systemd/system/${serv_nam})
ADD_CUSTOM_COMMAND(OUTPUT ${lkm_vers}
  COMMAND "${CMAKE_COMMAND}" -E copy ${lkm} ${lkm_vers}
  COMMAND depmod
  COMMAND addgroup --system pruio > /dev/null
  COMMAND "${CMAKE_COMMAND}" -E copy ${serv_deb} ${serv_tar}
  COMMAND systemctl daemon-reload
  COMMAND systemctl enable ${serv_nam}
  COMMAND systemctl start ${serv_nam}
  #VERBATIM
  )
ADD_CUSTOM_TARGET(lkm-install DEPENDS ${lkm_vers} )
ADD_CUSTOM_TARGET(lkm-uninstall
  COMMAND systemctl stop ${serv_nam} > /dev/null
  COMMAND systemctl disable ${serv_nam} > /dev/null
  COMMAND "${CMAKE_COMMAND}" -E remove ${serv_tar}
  COMMAND systemctl daemon-reload
  COMMAND "${CMAKE_COMMAND}" -E remove ${lkm_vers}
  COMMAND depmod
  #VERBATIM
  )
ADD_DEPENDENCIES(lkm-install lkm)

INSTALL(FILES ${lkm}
  DESTINATION /lib/modules
  CONFIGURATIONS Release
  )

MSG_LOG("found linux-headers @ ${hpath}")
MSG_LOG(">> targets <lkm...> OK!")
