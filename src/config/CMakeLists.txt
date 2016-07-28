# Check the device tree compiler dtc (presence and version):
IF(NOT DEFINED DTC_COMPILER_WORKS)
  EXECUTE_PROCESS(
    COMMAND dtc -v
    RESULT_VARIABLE compiler_works
	  OUTPUT_VARIABLE DTC_COMPILER_ID
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

  IF(compiler_works EQUAL "0")
	  EXECUTE_PROCESS(
      COMMAND dtc -h
	    OUTPUT_VARIABLE output
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )

    STRING(REGEX REPLACE "\r?\n" ";" output_lines "${output}")
    SET(DTC_COMPILER_WORKS FALSE)
    FOREACH(line IN LISTS output_lines)
      IF(line MATCHES "-@, --symbols")
        SET(DTC_COMPILER_WORKS TRUE)
        BREAK()
      ENDIF()
    ENDFOREACH()

    IF(DTC_COMPILER_WORKS)
      MSG_LOG("Check for working DTC compiler OK ==> ${DTC_COMPILER_ID}")
      SET(DTC_COMPILER_WORKS "${DTC_COMPILER_WORKS}" CACHE FILEPATH "dtc compiler" FORCE)
      MARK_AS_ADVANCED(DTC_COMPILER_WORKS)
    ELSE()
      MSG_LOG("Wrong DTC compiler (${DTC_COMPILER_ID}, no option -@)!")
    ENDIF()
  ELSE()
    MSG_LOG("DTC compiler not found (command dtc)!")
  ENDIF()
ENDIF()
IF(NOT DTC_COMPILER_WORKS)
  MSG_LOG(">> no target init!")
  RETURN()
ENDIF()


SET(fold /lib/firmware)
SET(dtbo ${fold}/libpruio-00A0.dtbo)
SET(univ dts_universal)

ADD_CUSTOM_COMMAND(OUTPUT ${dtbo}
  COMMAND ${CMAKE_Fbc_COMPILER} -w all -x ${univ} ${CMAKE_CURRENT_SOURCE_DIR}/${univ}.bas
  COMMAND ./${univ} ${fold}
  #COMMAND ${CMAKE_COMMAND} -E remove ${univ}
  DEPENDS ${univ}.bas P8.bi P9.bi pruiotools.bas
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  VERBATIM
  )

ADD_CUSTOM_TARGET(init DEPENDS ${dtbo})



