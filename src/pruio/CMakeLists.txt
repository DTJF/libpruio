add_custom_command(
  OUTPUT pasm_init.bi 
  COMMAND pasm -V3 -y -CPru_Init pasm_init.p
  DEPENDS 
  )
 add_custom_command(
  OUTPUT pasm_run.bi 
  COMMAND pasm -V3 -y -CPru_Run pasm_run.p
  DEPENDS 
  )