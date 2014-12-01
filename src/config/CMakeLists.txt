SET(dtbo libpruio-00A0.dtbo)
SET(univ dts_universal)

ADD_CUSTOM_TARGET(dtbo DEPENDS ${dtbo})
SET_TARGET_PROPERTIES(dtbo PROPERTIES EXCLUDE_FROM_ALL 1)
#ADD_DEPENDENCIES(examples fb_examples)

#ADD_CUSTOM_COMMAND(OUTPUT ${dtbo}
  #COMMAND ${univ} ${tar}.bas
  #DEPENDS ${univ}.bas
  #)

ADD_CUSTOM_COMMAND(OUTPUT ${dtbo}
  COMMAND ${CMAKE_Fbc_COMPILER} -w all -e ${univ}.bas
  COMMAND ./${univ} ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS ${univ}.bas P8.bi P9.bi pruiotools.bas
  VERBATIM
  )

INSTALL(FILES ${dtbo}
  DESTINATION /lib/firmware
  )
