#
# CMakeFbc - CMake module for FreeBASIC Language
#
# Copyright (C) 2014-2022, Thomas{ dOt ]Freiherr[ aT ]gmx[ DoT }net
#
# All rights reserved.
#
# See ReadMe.md for details.
#
# Modified from CMake 2.6.5 CMakeTestCCompiler.cmake
# See http://www.cmake.org/HTML/Copyright.html for details
#

# This file is used by EnableLanguage in cmGlobalGenerator to
# determine that the selected Fbc compiler can actually compile
# and link the most basic of programs.   If not, a fatal error
# is set and cmake stops processing commands and will not generate
# any makefiles or projects.

IF(CMAKE_Fbc_COMPILER_FORCED)
  # The compiler configuration was forced by the user.
  # Assume the user has configured all compiler information.
  SET(CMAKE_Fbc_COMPILER_WORKS 1)
  RETURN()
ENDIF()

IF(NOT CMAKE_Fbc_COMPILER_WORKS)
  SET(testfile testFbcCompiler)
  SET(testpath ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp)
  FILE(WRITE ${testpath}/${testfile}.bas
    "?__FB_VERSION__;\nEND SIZEOF(ANY PTR)\n")
  EXECUTE_PROCESS(
    COMMAND ${CMAKE_Fbc_COMPILER} -v -m ${testfile} ${testfile}.bas
    WORKING_DIRECTORY ${testpath}
    RESULT_VARIABLE compiler_error
    OUTPUT_VARIABLE output
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  FILE(REMOVE ${testpath}/${testfile}.bas)
  IF(NOT output)
    SET(log "  Compiler test failed: [${output}]\n")
  ELSE()
    # Construct a regex to match linker lines.  It must match both the
    # whole line and just the command (argv[0]).
    SET(linker_regex "^( *|.*[/\\])(linking:|([^/\\]+-)?ld|collect2)[^/\\]*( |$)")
    SET(linker_exclude_regex "collect2 version ")

    SET(implicit_dirs_tmp ".")
    SET(implicit_libs "")
    STRING(REGEX REPLACE "\r?\n" ";" output_lines "${output}")
    FOREACH(line IN LISTS output_lines)
      IF("${line}" MATCHES "^( *|.*[/\\])(linking:|([^/\\]+-)?ld|collect2)[^/\\]*( |$)")
        IF(UNIX)
          SEPARATE_ARGUMENTS(args UNIX_COMMAND "${line}")
        ELSE()
          SEPARATE_ARGUMENTS(args WINDOWS_COMMAND "${line}")
        ENDIF()

        LIST(GET args 1 CMAKE_Fbc_LINKER)
        LIST(REMOVE_AT args 0 1)

        SET(log "${log}  link line: [${line}]\n")
        STRING(REGEX REPLACE ";-([LYz]);" ";-\\1" args "${args}")
        FOREACH(arg IN LISTS args)
          IF("${arg}" MATCHES "^-L(.:)?[/\\]")
            # Unix search path.
            STRING(REGEX REPLACE "^-L" "" tmp "${arg}")
            GET_FILENAME_COMPONENT(dir "${tmp}" ABSOLUTE)
            LIST(APPEND implicit_dirs_tmp ${dir})
            SET(log "${log}    dir [${dir}] <== arg [${arg}]\n")
          ELSEIF("${arg}" MATCHES "^-l[^:]")
            # Unix library.
            STRING(REGEX REPLACE "^-l" "" lib "${arg}")
            LIST(APPEND implicit_libs ${lib})
            SET(log "${log}    lib [${lib}] <== arg [${arg}]\n")
          ELSEIF("${arg}" MATCHES "^(.:)?[/\\].*\\.[aox]$"  )
            # Object file full path.
            GET_FILENAME_COMPONENT(lib "${arg}" ABSOLUTE)
            LIST(APPEND implicit_libs ${lib})
            SET(log "${log}    obj [${lib}] <== arg [${arg}]\n")
          ELSE()
            SET(log "${log}    ignore arg [${arg}]\n")
          ENDIF()
        ENDFOREACH()
        BREAK()
      ELSE()
        SET(log "${log}  ignore line: [${line}]\n")
      ENDIF()
    ENDFOREACH()

    # Look for library search paths reported by linker.
    IF("${output_lines}" MATCHES ";Library search paths:((;\t[^;]+)+)")
      STRING(REPLACE ";\t" ";" implicit_dirs_match "${CMAKE_MATCH_1}")
      SET(log "${log}  Library search paths: [${implicit_dirs_match}]\n")
      LIST(APPEND implicit_dirs_tmp ${implicit_dirs_match})
    ENDIF()

    # Cleanup list of library and framework directories.
    SET(implicit_dirs "")
    FOREACH(d IN LISTS implicit_dirs_tmp)
      STRING(FIND "${d}" "${CMAKE_FILES_DIRECTORY}/" pos)
      IF(NOT pos LESS 0)
        SET(log "${log}  skipping non-system directory [${d}]\n")
      ELSE()
        LIST(APPEND implicit_dirs "${d}")
      ENDIF()
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES implicit_dirs)

    # Log results.
    SET(log "${log}  CMAKE_Fbc_IMPLICIT_LINK_LIBRARIES:\n    [${implicit_libs}]\n")
    SET(log "${log}  CMAKE_Fbc_IMPLICIT_LINK_DIRECTORIES:\n    [${implicit_dirs}]\n")

    SET(CMAKE_Fbc_IMPLICIT_LINK_LIBRARIES "${implicit_libs}")
    SET(CMAKE_Fbc_IMPLICIT_LINK_DIRECTORIES "${implicit_dirs}")

    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
      "Analysing the Fbc compiler passed with "
      "the following output:\n${log}\n\n")
    UNSET(CMAKE_Fbc_COMPILER_WORKS CACHE)
    SET(CMAKE_Fbc_COMPILER_WORKS 1 CACHE INTERNAL "Fbc compiler working" FORCE)

    EXECUTE_PROCESS(
      COMMAND ./${testfile}
      WORKING_DIRECTORY ${testpath}
      RESULT_VARIABLE CMAKE_Fbc_SIZEOF_DATA_PTR
      OUTPUT_VARIABLE CMAKE_Fbc_COMPILER_ID
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )
    FILE(REMOVE ${testpath}/${testfile})
  ENDIF()
  SET(Fbc_TEST_WAS_RUN 1)
ENDIF()

IF(CMAKE_Fbc_COMPILER_WORKS)
  MESSAGE(STATUS "Found working Fbc compiler ==> ${CMAKE_Fbc_COMPILER} (${CMAKE_Fbc_COMPILER_ID})")
  IF(FBC_TEST_WAS_RUN)
    FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
      "Determining if the Fbc compiler works passed with "
      "the following output:\n${output}\n\n")
  ENDIF()

  # Re-configure to save learned information.
  GET_FILENAME_COMPONENT(modpath ${CMAKE_CURRENT_LIST_FILE} PATH)
  CONFIGURE_FILE(
    ${modpath}/CMakeFbcCompiler.cmake.in
    ${CMAKE_PLATFORM_INFO_DIR}/CMakeFbcCompiler.cmake
    @ONLY IMMEDIATE # IMMEDIATE must be here for compatibility mode <= 2.0
    )
  INCLUDE(${CMAKE_PLATFORM_INFO_DIR}/CMakeFbcCompiler.cmake)
ELSE()
  FILE(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
    "Determining if the Fbc compiler works failed with "
    "the following output:\n${output}\n\n")
  MESSAGE(FATAL_ERROR
      "Check for working Fbc compiler failed: ${CMAKE_Fbc_COMPILER}."
     " This compiler is not able to compile a simple test program."
     " It fails with the following output:\n---8<---\n${output}\n--->8---"
    "\nCMake will not be able to correctly generate this project."
    "\n  To force a specific Fbc compiler set the FBC environment variable"
    "\n  ie: export FBC=\"/usr/local/bin/fbc\"\n")
ENDIF()
