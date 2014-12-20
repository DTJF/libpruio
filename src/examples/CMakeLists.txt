SET(fb_tar
  "1"
  "analyse"
  "button"
  "io_input"
  "oszi"
  "pwm_adc"
  "pwm_cap"
  "qep"
  "rb_file"
  "rb_oszi"
  "sos"
  "stepper"
  "triggers"
  )

ADD_CUSTOM_TARGET(fb_examples DEPENDS ${fb_tar})
SET_TARGET_PROPERTIES(fb_examples PROPERTIES EXCLUDE_FROM_ALL 1)
ADD_DEPENDENCIES(examples fb_examples)

FOREACH(tar ${fb_tar})
  ADD_CUSTOM_COMMAND(OUTPUT ${tar}
    COMMAND ${CMAKE_Fbc_COMPILER} -v -w all -e ${tar}.bas
    DEPENDS ${tar}.bas
    )
ENDFOREACH(tar)

#TARGET_LINK_LIBRARIES(fb_examples pruio prussdrv fbgfx X11 Xext Xpm Xrandr Xrender)

#FOREACH(tar ${fb_tar})
  #ADD_EXECUTABLE(${tar} EXCLUDE_FROM_ALL ${tar}.bas)
  ##TARGET_LINK_LIBRARIES(${tar} pruio)
  #TARGET_LINK_LIBRARIES(${tar} pruio prussdrv fbgfx fb tinfo m dl pthread gcc gcc_eh c X11 Xext Xpm Xrandr Xrender)
  #SET_TARGET_PROPERTIES(${tar} PROPERTIES
    #COMPILE_FLAGS "-m ${tar} -v"
    #LINK_FLAGS "-v"
    #)
  #ADD_DEPENDENCIES(fb_examples ${tar})
#ENDFOREACH(tar)
