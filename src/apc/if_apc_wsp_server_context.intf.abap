INTERFACE if_apc_wsp_server_context PUBLIC.
* The full context, which on_start and on_message are handed. It includes
* the base that on_accept, on_close and on_error take, so one object serves
* both, which is how a system does it.
  INTERFACES if_apc_wsp_server_context_base.

  ALIASES get_initial_request FOR if_apc_wsp_server_context_base~get_initial_request.

  METHODS get_binding_manager
    RETURNING VALUE(r_binding_manager) TYPE REF TO if_apc_wsp_binding_manager
    RAISING cx_apc_error.
ENDINTERFACE.
