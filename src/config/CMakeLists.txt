SET(dtbo libpruio-00A0.dtbo)
SET(univ dts_universal)

ADD_CUSTOM_TARGET(dtbo DEPENDS ${dtbo})

ADD_CUSTOM_COMMAND(OUTPUT ${dtbo}
  COMMAND ${CMAKE_Fbc_COMPILER} -w all -x ${univ} -e ${CMAKE_CURRENT_SOURCE_DIR}/${univ}.bas
  COMMAND ./${univ} .
  COMMAND ${CMAKE_COMMAND} -E remove ${univ}
  DEPENDS ${univ}.bas P8.bi P9.bi pruiotools.bas
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  VERBATIM
  )

INSTALL(FILES ${dtbo}
  DESTINATION /lib/firmware
  COMPONENT bin
  )


# Check the device tree compiler dtc (presence and version):
IF(NOT DTC_COMPILER_WORKS)
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
      IF(line MATCHES "-@, --symbols <arg>")
        SET(DTC_COMPILER_WORKS TRUE)
        BREAK()
      ENDIF()
    ENDFOREACH()

    IF(DTC_COMPILER_WORKS)
      MESSAGE(STATUS "Check for working DTC compiler OK ==> ${DTC_COMPILER_ID}")
      SET(DTC_COMPILER_WORKS "${DTC_COMPILER_WORKS}" CACHE FILEPATH "dtc compiler" FORCE)
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "Determining if the dtc compiler works passed with "
        "the following output:\n${DTC_COMPILER_ID}\n\n")
    ELSE()
      MESSAGE(FATAL_ERROR "Wrong DTC compiler (${DTC_COMPILER_ID}, no option -@)!")
      FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "Determining if the dtc compiler works failed with "
        "the following output:\n${DTC_COMPILER_ID}, no option -@\n\n")
    ENDIF()
  ELSE()
    MESSAGE(FATAL_ERROR "DTC compiler not found (command dtc)!")
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
      "Finding the dtc compiler failed!")
  ENDIF()
ENDIF()

MARK_AS_ADVANCED(DTC_COMPILER_WORKS)
