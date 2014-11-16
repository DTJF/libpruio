add_custom_command(
  OUTPUT libpruio.so 
  COMMAND fbc -w all -dylib -x libpruio.so pruio_c_wrapper.bas
  DEPENDS 
  )