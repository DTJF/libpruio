SET(C_TAR
  "1"
  "button"
  "io_input"
  "performance"
  "pwm_cap"
  "qep"
  "rb_file"
  "sos"
  "stepper"
  )

ADD_CUSTOM_TARGET(c_examples)
SET_TARGET_PROPERTIES(c_examples PROPERTIES EXCLUDE_FROM_ALL 1)
ADD_DEPENDENCIES(examples c_examples)

FOREACH(tar ${C_TAR})
  ADD_EXECUTABLE(${tar}_c EXCLUDE_FROM_ALL ${tar}.c)
  TARGET_LINK_LIBRARIES(${tar}_c pruio prussdrv)
  ADD_DEPENDENCIES(c_examples ${tar}_c)
ENDFOREACH(tar)
