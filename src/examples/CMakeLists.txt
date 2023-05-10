SET(FB_EXAMPLES
  "1"
  "analyse"
  "button"
  "button2"
  "io_input"
  "oszi"
  "performance"
  "pwm_adc"
  "pwm_cap"
  "pruss_add"
  "pruss_toggle"
  "qep"
  "rb_file"
  "rb_oszi"
  "sos"
  "stepper"
  "stepper2"
  "triggers"
  CACHE FILEPATH "FB_EXAMPLES source files" FORCE
  )

SET(CMAKE_VERBOSE_MAKEFILE 1)

ADD_CUSTOM_COMMAND(OUTPUT BBB
  COMMAND test -L BBB || ln -s ../pruio BBB
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

SET(CMAKE_LINK_LIBRARY_FLAG "-l ") # must be global
SET(CMAKE_EXE_LINKER_FLAGS "-Wl -z,relro") # must be global

FOREACH(tar ${FB_EXAMPLES})
  ADD_EXECUTABLE(${tar} EXCLUDE_FROM_ALL ${tar}.bas BBB)
  TARGET_LINK_LIBRARIES(${tar} pruio fbgfx X11 Xext Xpm Xrandr)
  SET_TARGET_PROPERTIES(${tar} PROPERTIES
    COMPILE_FLAGS "-m ${tar} -gen gcc -Wc -O2,-D_FORTIFY_SOURCE=2,-fstack-protector-strong,-Wformat,-Werror=format-security"
    #LINK_FLAGS "-Wl -z,relro"
    )
  ADD_DEPENDENCIES(fb_examples ${tar})
ENDFOREACH(tar)
