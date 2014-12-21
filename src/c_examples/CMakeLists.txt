SET(C_TAR
  "1"
  "button"
  "io_input"
  "pwm_cap"
  "qep"
  "rb_file"
  "sos"
  "stepper"
  )

ADD_CUSTOM_TARGET(c_examples DEPENDS ${C_TAR})
SET_TARGET_PROPERTIES(c_examples PROPERTIES EXCLUDE_FROM_ALL 1)
ADD_DEPENDENCIES(examples c_examples)

FOREACH(tar ${C_TAR})
  ADD_CUSTOM_COMMAND(OUTPUT ${tar}
    COMMAND ${CMAKE_C_COMPILER} -Wall -o ${tar} ${tar}.c -lpruio -lprussdrv -Wno-unused-variable
    DEPENDS ${tar}.c
    )
ENDFOREACH(tar)

#FOREACH(tar ${C_TAR})
  #ADD_EXECUTABLE(${tar}_c EXCLUDE_FROM_ALL ${tar}.c)
  #ADD_DEPENDENCIES(c_examples ${tar}_c)
#ENDFOREACH(tar)
