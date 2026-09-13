INTERFACE if_apc_wsp_binding_manager PUBLIC.
* An alias shell over if_apc_ws_binding_manager, the same pattern as the
* initial request.
  INTERFACES if_apc_ws_binding_manager.

  ALIASES bind_amc_message_consumer FOR if_apc_ws_binding_manager~bind_amc_message_consumer.
  ALIASES unbind_amc_message_consumer FOR if_apc_ws_binding_manager~unbind_amc_message_consumer.
ENDINTERFACE.
