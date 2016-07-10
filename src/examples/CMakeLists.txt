SET(fb_tar
  "1"
  "analyse"
  "button"
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
  )

ADD_CUSTOM_TARGET(fb_examples)
SET_TARGET_PROPERTIES(fb_examples PROPERTIES EXCLUDE_FROM_ALL 1)
ADD_DEPENDENCIES(examples fb_examples)

SET(CMAKE_LINK_LIBRARY_FILE_FLAG "-Wl")
SET(CMAKE_LINK_LIBRARY_FLAG "-l ")

FOREACH(tar ${fb_tar})
  ADD_EXECUTABLE(${tar} EXCLUDE_FROM_ALL ${tar}.bas)
  TARGET_LINK_LIBRARIES(${tar} pruio prussdrv fbgfx X11 Xext Xpm Xrandr Xrender)
  SET_TARGET_PROPERTIES(${tar} PROPERTIES
    COMPILE_FLAGS "-m ${tar}")
  ADD_DEPENDENCIES(fb_examples ${tar})
ENDFOREACH(tar)
