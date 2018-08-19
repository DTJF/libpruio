SET(PASM_SRC
  "pruio.hp"
  "pruio_ball.p"
  "pruio_adc.p"
  "pruio_gpio.p"
  "pruio_pwmss.p"
  "pruio_timer.p"
  CACHE FILEPATH "ASM source files" FORCE
  )

SET(SRC_BAS
  "pruio.bas"
  "pruio_adc.bas"
  "pruio_gpio.bas"
  "pruio_pwmss.bas"
  "pruio_timer.bas"
  "pruio_prussdrv.bas"
  "pruio_c_wrapper.bas"
  CACHE FILEPATH "BASIC source files" FORCE
  )

SET(SRC_BI
  "pruio.hp"
  "pruio.bi"
  "pruio_globals.bi"
  "pruio_pins.bi"
  "pruio_adc.bi"
  "pruio_gpio.bi"
  "pruio_pwmss.bi"
  "pruio_timer.bi"
  "pruio_intc.bi"
  "pruio_prussdrv.bi"
  CACHE FILEPATH "BASIC header files" FORCE
  )

SET(SRC_BI_EXTRA
    "pruio_out.bi"
  )

# Check the PRU assembler pasm (presence and version):
IF(NOT DEFINED PASM_ASSEMBER_WORKS)
  FIND_PROGRAM(pasm_bin pasm DOC "pasm assembler" HINTS /usr/local/bin)
  IF(NOT pasm_bin)
    MSG_LOG(">> no target <all> (pasm assembler missing)")
    RETURN()
  ENDIF()
  EXECUTE_PROCESS(
    COMMAND ${pasm_bin} # no ARGS -> helptext
    RESULT_VARIABLE assembler_works
	  OUTPUT_VARIABLE pasm_vers
	  ERROR_VARIABLE pasm_opts
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
    )

  IF(assembler_works EQUAL "1")
    STRING(REGEX REPLACE "\r?\n" ";" output_lines "${pasm_opts}\n${pasm_vers}\n")
    FOREACH(line IN LISTS output_lines)
      IF(line MATCHES "PRU Assembler Version")
        SET(PASM_ASSEMBER_ID ${line})
        BREAK()
      ENDIF()
    ENDFOREACH()

    SET(fb_option FALSE)
    FOREACH(line IN LISTS output_lines)
      IF(line MATCHES "f  - Create 'FreeBasic array' binary output")
        SET(fb_option "f")
        BREAK()
      ELSEIF(line MATCHES "y  - Create 'FreeBasic array' binary output")
        SET(fb_option "y")
        BREAK()
      ENDIF()
    ENDFOREACH()

    IF(fb_option)
      MESSAGE(STATUS "Check for PASM assembler OK ==> Option -${fb_option} in ${PASM_ASSEMBER_ID}")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "Determining if the pasm assembler works passed with "
        "the following output:\n${output}\n\n")
      SET(PASM_ASSEMBER_WORKS "${fb_option}" CACHE STRING "pasm assembler" FORCE)
      MARK_AS_ADVANCED(PASM_ASSEMBER_WORKS)
    ELSE()
      MESSAGE(STATUS "PASM assembler insufficient! (${PASM_ASSEMBER_ID})")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "Determining if the pasm assembler works failed with "
        "the following output:\n${output}\n\n")
    ENDIF()
  ELSE()
    MESSAGE(STATUS "PASM assembler not found (command pasm)!")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "Finding the pasm assembler failed!")
  ENDIF()
ENDIF()

IF(NOT DEFINED PASM_ASSEMBER_WORKS)
  MSG_LOG(">> no target <all> (pasm assembler problem)")
  RETURN()
ENDIF()


ADD_CUSTOM_COMMAND(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/pasm_init.bi
  COMMAND pasm ARGS -V3 -${PASM_ASSEMBER_WORKS} -CPru_Init pasm_init.p
  COMMAND ${CMAKE_COMMAND} -E touch_nocreate pruio.bas
  DEPENDS pasm_init.p ${PASM_SRC}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

ADD_CUSTOM_COMMAND(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/pasm_run.bi
  COMMAND pasm ARGS -V3 -${PASM_ASSEMBER_WORKS} -CPru_Run pasm_run.p
  COMMAND ${CMAKE_COMMAND} -E touch_nocreate pruio.bas
  DEPENDS pasm_run.p ${PASM_SRC}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )

ADD_CUSTOM_TARGET(pasm DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/pasm_init.bi
  ${CMAKE_CURRENT_SOURCE_DIR}/pasm_run.bi
  )

ADD_LIBRARY(pruiofbcode OBJECT ${SRC_BAS})
SET_TARGET_PROPERTIES(pruiofbcode PROPERTIES
  COMPILE_FLAGS "-Wc -fPIC"
  )
ADD_DEPENDENCIES(pruiofbcode pasm)
ADD_Fbc_SRC_DEPS(pruiofbcode)

MSG_LOG(">> target <all> OK!")
