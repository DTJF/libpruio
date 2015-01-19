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


ADD_CUSTOM_COMMAND(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/pasm_init.bi
  COMMAND pasm ARGS -V3 -y -CPru_Init pasm_init.p
  COMMAND ${CMAKE_COMMAND} -E touch_nocreate pruio.bas
  DEPENDS pasm_init.p ${PASM_SRC}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

ADD_CUSTOM_COMMAND(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/pasm_run.bi
  COMMAND pasm ARGS -V3 -y -CPru_Run pasm_run.p
  COMMAND ${CMAKE_COMMAND} -E touch_nocreate pruio.bas
  DEPENDS pasm_run.p ${PASM_SRC}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

ADD_CUSTOM_TARGET(pasm DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/pasm_init.bi
  ${CMAKE_CURRENT_SOURCE_DIR}/pasm_run.bi
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
  COMPONENT fbinc
  )




# Check libprussdrv:
#IF (NOT EXISTS /usr/local/include/freebasic/BBB/prussdrv.bi)
#ENDIF()
#IF (NOT EXISTS /usr/local/include/freebasic/BBB/pruss_intc_mapping.bi)
#ENDIF()
# Check the PRU assembler pasm (presence and version):
IF(NOT PASM_ASSEMBER_WORKS)
  EXECUTE_PROCESS(
    COMMAND pasm
    RESULT_VARIABLE assembler_works
	  OUTPUT_VARIABLE output
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

  IF(assembler_works EQUAL "1")
    STRING(REGEX REPLACE "\r?\n" ";" output_lines "${output}")
    SET(works FALSE)
    FOREACH(line IN LISTS output_lines)
      IF(line MATCHES "PRU Assembler Version")
        SET(PASM_ASSEMBER_ID ${line})
      ELSEIF(line MATCHES "y  - Create 'FreeBasic array' binary output")
        SET(works TRUE)
        BREAK()
      ENDIF()
    ENDFOREACH()

    IF(works)
      MESSAGE(STATUS "Check for working PASM assembler OK ==> ${PASM_ASSEMBER_ID}")
      SET(PASM_ASSEMBER_WORKS "${works}" CACHE FILEPATH "pasm assembler" FORCE)
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "Determining if the pasm assembler works passed with "
        "the following output:\n${output}\n\n")
    ELSE()
      MESSAGE(FATAL_ERROR "Wrong PASM assembler version!")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "Determining if the pasm assembler works failed with "
        "the following output:\n${output}\n\n")
    ENDIF()
  ELSE()
    MESSAGE(FATAL_ERROR "PASM assembler not found (command pasm)!")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Finding the pasm assembler failed!")
  ENDIF()
ENDIF()

MARK_AS_ADVANCED(PASM_ASSEMBER_WORKS)
