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

#SET(CMAKE_VERBOSE_MAKEFILE 1)

INCLUDE_DIRECTORIES(../c_include)

FOREACH(tar ${c_tar})
  ADD_EXECUTABLE(${tar}_c EXCLUDE_FROM_ALL ${tar}.c)
  TARGET_LINK_LIBRARIES(${tar}_c pruio)
  ADD_DEPENDENCIES(c_examples ${tar}_c)
ENDFOREACH(tar)
