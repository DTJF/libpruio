CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
PROJECT(libpruio Fbc)

SET(MAIN_SRC ${CMAKE_CURRENT_SOURCE_DIR}/src/c_wrapper/pruio_c_wrapper.bas)
#SET(TIMESTAMP ${CMAKE_CURRENT_BINARY_DIR}/timestamp)

#EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E touch timestamp)


#ADD_SUBDIRECTORY(src/c_wrapper)
ADD_SUBDIRECTORY(src/pruio)

#SET(CMAKE_VERBOSE_MAKEFILE 1)

ADD_LIBRARY(pruio SHARED ${MAIN_SRC})
#ADD_LIBRARY(pruio SHARED ${MAIN_SRC} ${TIMESTAMP})
#ADD_LIBRARY(pruio SHARED src/c_wrapper/pruio_c_wrapper.bas)
#ADD_LIBRARY(pruio SHARED src/c_wrapper/pruio_c_wrapper.bas;${FB_HEADERS};${FBC_SRC})

SET_TARGET_PROPERTIES(pruio PROPERTIES COMPILE_FLAGS "-Wc -fPIC")
#ADD_DEPENDENCIES(pruio pasm)
#ADD_DEPENDENCIES(pasm pruio)
#ADD_DEPENDENCIES(pruio pasm fbcode)
ADD_DEPENDENCIES(pruio fbcode)

#ADD_CUSTOM_COMMAND(TARGET pruio
  #COMMAND touch ARGS timestamp
  #DEPENDS ${FB_HEADERS} ${FBC_SRC} pasm_init.bi pasm_run.bi
  #COMMENT "COMMAND timestamp"
  #)




SET(C_HEADERS
  "/src/pruio/pruio.hp"
  "/src/c_wrapper/pruio.h"
  "/src/c_wrapper/pruio_pins.h"
  )

#INSTALL(FILES "libpruio.so" DESTINATION lib)
INSTALL(TARGETS pruio
        LIBRARY DESTINATION lib
        )
INSTALL(FILES
        ${C_HEADERS} DESTINATION include
        COMPONENT c_install
        )
INSTALL(FILES ${FB_HEADERS}
        ${FB_HEADERS_EXT} DESTINATION include/freebasic/BBB
        COMPONENT fb_install
        )
