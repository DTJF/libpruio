CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
PROJECT(libpruio Fbc)

ADD_SUBDIRECTORY(src/pruio)

ADD_LIBRARY(pruio SHARED $<TARGET_OBJECTS:fbcode>)
#SET_TARGET_PROPERTIES(pruio PROPERTIES COMPILE_FLAGS "-Wc -fPIC")

ADD_DEPENDENCIES(pruio fbcode)

#SET(CMAKE_VERBOSE_MAKEFILE 1)






#include(AddFileDependencies)
#SET(MAIN_SRC ${CMAKE_CURRENT_SOURCE_DIR}/src/pruio/pruio_c_wrapper.bas)
#SET(MAIN_SRC ${CMAKE_CURRENT_SOURCE_DIR}/src/c_wrapper/pruio_c_wrapper.bas)
#SET(TIMESTAMP ${CMAKE_CURRENT_BINARY_DIR}/timestamp)

#SET(MAIN_SRC
    #"src/c_wrapper/pruio_c_wrapper.bas"
  #)






#ADD_SUBDIRECTORY(src/c_wrapper)


#foreach(name ${FBC_BI})
#message(STATUS ${name})
#endforeach(name)
#message(STATUS Done in main)
#message(STATUS ${TIMESTAMP} ${FBC_BAS} ${FBC_BI} ${MAIN_SRC})
#message(STATUS ${TIMESTAMP} $<TARGET_OBJECTS:fbcode> ${MAIN_SRC})



#ADD_LIBRARY(pruio SHARED ${MAIN_SRC})
#ADD_LIBRARY(pruio SHARED ${TIMESTAMP} ${FBC_BAS} ${FBC_BI} ${MAIN_SRC})
#ADD_LIBRARY(pruio SHARED ${TIMESTAMP} $<TARGET_OBJECTS:fbcode> ${MAIN_SRC})
#ADD_LIBRARY(pruio SHARED $<TARGET_OBJECTS:fbcode> ${MAIN_SRC})


#ADD_LIBRARY(pruio SHARED src/c_wrapper/pruio_c_wrapper.bas)
#ADD_LIBRARY(pruio SHARED src/c_wrapper/pruio_c_wrapper.bas;${FBC_BI};${FBC_BAS})


#ADD_DEPENDENCIES(fbcode pasm)
#ADD_DEPENDENCIES(pruio pasm)
#ADD_DEPENDENCIES(pasm pruio)
#ADD_DEPENDENCIES(pruio pasm fbcode)




#SET(C_HEADERS
  #"/src/pruio/pruio.hp"
  #"/src/c_wrapper/pruio.h"
  #"/src/c_wrapper/pruio_pins.h"
  #)

#INSTALL(TARGETS pruio
        #LIBRARY DESTINATION lib
        #)
#INSTALL(FILES ${C_HEADERS}
        #DESTINATION include
        #COMPONENT c_install
        #)
