SET(c_tar
  "1"
  "button"
  "button2"
  "io_input"
  "performance"
  "pwm_cap"
  "qep"
  "rb_file"
  "sos"
  "stepper"
  )

FOREACH(tar ${c_tar})
  ADD_EXECUTABLE(${tar}_c EXCLUDE_FROM_ALL ${tar}.c)
  TARGET_LINK_LIBRARIES(${tar}_c pruio)
  ADD_DEPENDENCIES(c_examples ${tar}_c)
ENDFOREACH(tar)
