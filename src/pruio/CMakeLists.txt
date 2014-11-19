#SET(MAIN_SRC "../c_wrapper/pruio_c_wrapper.bas")
#SET(TIMESTAMP ${CMAKE_CURRENT_BINARY_DIR}/timestamp)

SET(PASM_SRC
    "pruio.hp"
    "pruio_ball.p"
    "pruio_adc.p"
    "pruio_gpio.p"
    "pruio_pwmss.p"
    "pruio_timer.p"
  )

SET(FBC_SRC
    "pruio.bas"
    "pruio_adc.bas"
    "pruio_gpio.bas"
    "pruio_pwmss.bas"
    "pruio_timer.bas"
  )

SET(FB_HEADERS
    "pruio.hp"
    "pruio.bi"
    "pruio_adc.bi"
    "pruio_gpio.bi"
    "pruio_pwmss.bi"
    "pruio_timer.bi"
  )

SET(FB_HEADERS_EXT
    "pruio_pins.bi"
    "pruio_out.bi"
  )

ADD_CUSTOM_COMMAND(OUTPUT pasm_init.bi
  COMMAND pasm ARGS -V3 -y -CPru_Init pasm_init.p
  COMMAND touch ARGS ${MAIN_SRC}
  DEPENDS pasm_init.p ${PASM_SRC}
  #COMMENT "COMMAND pasm_init.bi"
  )

ADD_CUSTOM_COMMAND(OUTPUT pasm_run.bi
  COMMAND pasm ARGS -V3 -y -CPru_Run pasm_run.p
  COMMAND touch ARGS ${MAIN_SRC}
  DEPENDS pasm_run.p ${PASM_SRC}
  #COMMENT "COMMAND pasm_run.bi"
  )

ADD_CUSTOM_TARGET(pasm
  DEPENDS pasm_run.bi pasm_init.bi
  #COMMENT "TARGET pasm_init.bi pasm_run.bi"
  )


ADD_CUSTOM_COMMAND(OUTPUT ${MAIN_SRC}
  COMMAND touch ARGS ${MAIN_SRC}
  DEPENDS ${FB_HEADERS} ${FBC_SRC}
  COMMENT "BAS code changed"
  )

ADD_CUSTOM_TARGET(fbcode
  DEPENDS ${MAIN_SRC}
  #COMMENT "TARGET ${MAIN_SRC}"
  )

ADD_DEPENDENCIES(fbcode pasm)











#ADD_CUSTOM_COMMAND(OUTPUT pasm_init.bi
  #COMMAND pasm ARGS -V3 -y -CPru_Init pasm_init.p
  ##DEPENDS pruio
  #SOURCES pasm_init.p ${PASM_SRC}
  #)

#ADD_CUSTOM_COMMAND(OUTPUT pasm_run.bi
  #COMMAND pasm ARGS -V3 -y -CPru_Run pasm_run.p
  ##DEPENDS pruio
  #SOURCES pasm_run.p ${PASM_SRC}
  #)

#ADD_CUSTOM_TARGET(fbcode #touch ${CMAKE_SOURCE_DIR}/${MAIN_SRC}
  ##SOURCES ${FB_HEADERS} ${FBC_SRC} pasm_init.bi pasm_run.bi
  #SOURCES pasm_run.bi
  #COMMENT "BAS file changed"
  #)
  #DEPENDS ${FB_HEADERS} ${FBC_SRC} pasm_init.bi pasm_run.bi
  #SOURCES ${FB_HEADERS} ${FBC_SRC} pasm_init.bi pasm_run.bi)
#ADD_CUSTOM_COMMAND(TARGET pruio PRE_BUILD #OUTPUT pasm_run.bi
#ADD_CUSTOM_COMMAND(OUTPUT ${MAIN_SRC}
  #COMMAND touch ARGS ${MAIN_SRC}
  #DEPENDS ${FB_HEADERS} ${FBC_SRC};pasm_init.bi;pasm_run.bi
  #COMMENT "BAS file changed"
  #)
#ADD_CUSTOM_COMMAND(OUTPUT ${TIMESTAMP}
  ##COMMAND touch ARGS ${TIMESTAMP}
  #COMMAND touch ARGS ${TIMESTAMP}
  #DEPENDS ${FB_HEADERS} ${FBC_SRC} pasm_init.bi pasm_run.bi
  #COMMENT "BAS file changed"
  #)

#ADD_CUSTOM_TARGET(pasm #touch ${MAIN_SRC}
                  #DEPENDS pasm_init.bi pasm_run.bi)
##ADD_CUSTOM_TARGET(fbcode ALL touch ${MAIN_SRC}
                  ##DEPENDS ${FB_HEADERS} ${FBC_SRC} pasm_init.bi pasm_run.bi)
##ADD_CUSTOM_TARGET(fbcode touch ${MAIN_SRC}
                  ##DEPENDS ${FB_HEADERS} ${FBC_SRC} pasm_init.bi pasm_run.bi)
#ADD_CUSTOM_TARGET(fbcode DEPENDS ${TIMESTAMP})

#ADD_DEPENDENCIES(fbcode pasm)
