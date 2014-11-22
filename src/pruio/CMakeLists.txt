
SET(PASM_SRC
    "pruio.hp"
    "pruio_ball.p"
    "pruio_adc.p"
    "pruio_gpio.p"
    "pruio_pwmss.p"
    "pruio_timer.p"
  )

SET(FBC_BAS
    "pruio.bas"
    "pruio_adc.bas"
    "pruio_gpio.bas"
    "pruio_pwmss.bas"
    "pruio_timer.bas"
    "pruio_c_wrapper.bas"
  )

SET(FBC_BI
    "pruio.hp"
    "pruio.bi"
    "pruio_pins.bi"
    "pruio_adc.bi"
    "pruio_gpio.bi"
    "pruio_pwmss.bi"
    "pruio_timer.bi"
  )

SET(FBC_BI_EXTRA
    "src/pruio/pruio_out.bi"
  )

ADD_CUSTOM_COMMAND(OUTPUT pasm_init.bi
  COMMAND pasm ARGS -V3 -y -CPru_Init pasm_init.p
  COMMAND ${CMAKE_COMMAND} -E touch pruio.bas
  DEPENDS pasm_init.p ${PASM_SRC}
  #COMMENT "COMMAND pasm_init.bi"
  )

ADD_CUSTOM_COMMAND(OUTPUT pasm_run.bi
  COMMAND pasm ARGS -V3 -y -CPru_Run pasm_run.p
  COMMAND ${CMAKE_COMMAND} -E touch pruio.bas
  DEPENDS pasm_run.p ${PASM_SRC}
  #COMMENT "COMMAND pasm_run.bi"
  )


MACRO(ADD_Fbc_BAS_DEPS Tar)
  get_target_property(_src ${Tar} SOURCES)
  #message(STATUS "Sources: "${_src}" target: "${Tar})

  SET(${Tar}DEPS ${CMAKE_CURRENT_LIST_DIR}/CMakeFiles/${Tar}_deps.cmake)
  #message(STATUS ${DEPS})
  ADD_CUSTOM_COMMAND(OUTPUT ${${Tar}DEPS}
    COMMAND fb_depends ${Tar}DEPS ${_src}
    DEPENDS ${FBC_BI}
    #COMMENT "Rebuilding dependencies"
    )

  message(STATUS "EXECUTE_PROCESS: "fb_depends ${${Tar}DEPS} ${_src})
  EXECUTE_PROCESS(
    COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_CURRENT_SOURCE_DIR} fb_depends ${${Tar}DEPS} ${_src}
    #OUTPUT_VARIABLE ERRORS
    )
  INCLUDE(${${Tar}DEPS})

  ADD_CUSTOM_TARGET(OUTPUT ${${Tar}DEPS}
    DEPENDS ${${Tar}DEPS}
    #COMMENT "TARGET pasm_init.bi pasm_run.bi"
    )
ENDMACRO(ADD_Fbc_BAS_DEPS)



#SET(DEPS ${CMAKE_CURRENT_LIST_DIR}/CMakeFiles/fb_depends.cmake)
##message(STATUS ${DEPS})
#ADD_CUSTOM_COMMAND(OUTPUT ${DEPS}
  #COMMAND fb_depends ${DEPS} ${FBC_BAS}
  #DEPENDS ${FBC_BI}
  ##COMMENT "Rebuilding dependencies"
  #)

#EXECUTE_PROCESS(
  #COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_CURRENT_SOURCE_DIR} fb_depends ${DEPS} ${FBC_BAS}
  #OUTPUT_VARIABLE ERRORS
  #)
##INCLUDE(${DEPS} OPTIONAL)
##message(STATUS "fb_depends:\n"${ERRORS})
#INCLUDE(${DEPS})


ADD_CUSTOM_TARGET(pasm
  DEPENDS pasm_init.bi pasm_run.bi #${DEPS}
  #COMMENT "TARGET pasm_init.bi pasm_run.bi"
  )

ADD_LIBRARY(fbcode OBJECT ${FBC_BAS})
SET_TARGET_PROPERTIES(fbcode PROPERTIES
  COMPILE_FLAGS "-Wc -fPIC"
  )
ADD_DEPENDENCIES(fbcode pasm)
ADD_Fbc_BAS_DEPS(fbcode)

#ADD_CUSTOM_COMMAND(OUTPUT ${DEPS}
  ##COMMAND /home/tom/Projekte/fb/make_depend_fb/mdfb ARGS ${FBC_BAS} > ${DEPS}
  #COMMAND ${CMAKE_COMMAND} -E cmake_depends /home/tom/Projekte/fb/make_depend_fb/mdfb ${FBC_BAS} > ${DEPS}
  #DEPENDS ${FBC_BAS} ${FBC_BI}
  #COMMENT "COMMAND depends.make"
  #)
#ADD_CUSTOM_COMMAND(OUTPUT pruio.bas
  #COMMAND touch ARGS pruio.bas
  #DEPENDS ${FBC_BI}
  #COMMENT "COMMAND pasm_run.bi"
  #)



#SET(TIMESTAMP ${<TARGET_PROPERTY:LIBRARY_OUTPUT_DIRECTORY:pasm>}/timestamp)
#SET(TIMESTAMP ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/timestamp)
#ADD_CUSTOM_COMMAND(OUTPUT ${TIMESTAMP}
  #COMMAND touch ARGS ${TIMESTAMP}
  ##COMMAND touch ARGS pruio.bas
  #DEPENDS ${FBC_BI}
  #COMMENT "COMMAND FBC_BI"
  #)

#set_source_files_properties(${FBC_BAS} PROPERTIES
  #OBJECT_DEPENDS ${FBC_BI}
  #GENERATED 0
  #HEADER_FILE_ONLY 1
  #)

INSTALL(FILES ${FBC_BI} ${FBC_BI_EXTRA}
        DESTINATION include/freebasic/BBB
        COMPONENT fb_install
        )
