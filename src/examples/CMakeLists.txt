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
  "qep"
  "rb_file"
  "rb_oszi"
  "sos"
  "stepper"
  "triggers"
  CACHE FILEPATH "FB_EXAMPLES source files" FORCE
  )

#SET(CMAKE_LINK_LIBRARY_FILE_FLAG "-Wl")
SET(CMAKE_LINK_LIBRARY_FLAG "-l ")
SET(CMAKE_EXE_LINKER_FLAGS "-Wl -z,relro") # must be global

FOREACH(tar ${FB_EXAMPLES})
  ADD_EXECUTABLE(${tar} EXCLUDE_FROM_ALL ${tar}.bas)
  #TARGET_LINK_LIBRARIES(${tar} pruio fbgfx X11 Xext Xpm Xrandr Xrender)
  TARGET_LINK_LIBRARIES(${tar} pruio fbgfx X11 Xext Xpm Xrandr)
  SET_TARGET_PROPERTIES(${tar} PROPERTIES
    COMPILE_FLAGS "-m ${tar}")
  ADD_DEPENDENCIES(fb_examples ${tar})
ENDFOREACH(tar)
