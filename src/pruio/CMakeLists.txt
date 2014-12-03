
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
    "pruio_globals.bi"
    "pruio_pins.bi"
    "pruio_adc.bi"
    "pruio_gpio.bi"
    "pruio_pwmss.bi"
    "pruio_timer.bi"
  )

SET(FBC_BI_EXTRA
    "pruio_out.bi"
  )


ADD_CUSTOM_COMMAND(OUTPUT pasm_init.bi
  COMMAND pasm ARGS -V3 -y -CPru_Init pasm_init.p
  COMMAND ${CMAKE_COMMAND} -E touch pruio.bas
  DEPENDS pasm_init.p ${PASM_SRC}
  )

ADD_CUSTOM_COMMAND(OUTPUT pasm_run.bi
  COMMAND pasm ARGS -V3 -y -CPru_Run pasm_run.p
  COMMAND ${CMAKE_COMMAND} -E touch pruio.bas
  DEPENDS pasm_run.p ${PASM_SRC}
  )

ADD_CUSTOM_TARGET(pasm
  DEPENDS pasm_init.bi pasm_run.bi
  )

  #BAS_2_C(C_SRC
    #SOURCES ${FBC_BAS}
    #OUT_DIR "CMakeFiles/ccode.dir"
    #)
  #ADD_LIBRARY(fbcode OBJECT ${C_SRC})
  #SET_TARGET_PROPERTIES(fbcode PROPERTIES
    #COMPILE_FLAGS "-fPIC"
    #)
  #ADD_DEPENDENCIES(fbcode pasm)

ADD_LIBRARY(fbcode OBJECT ${FBC_BAS})
SET_TARGET_PROPERTIES(fbcode PROPERTIES
  COMPILE_FLAGS "-Wc -fPIC"
  )
ADD_DEPENDENCIES(fbcode pasm)
ADD_Fbc_SRC_DEPS(fbcode)


INSTALL(FILES ${FBC_BI} ${FBC_BI_EXTRA}
        DESTINATION include/freebasic/BBB
        COMPONENT fb_install
        )
