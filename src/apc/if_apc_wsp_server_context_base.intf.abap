INTERFACE if_apc_wsp_server_context_base PUBLIC.
* What on_accept, on_close and on_error are handed: three methods, all of
* which raise. The raising is not decoration. SAP's own reference handler
* wraps the call in TRY/CATCH cx_apc_error and defaults on failure, and a
* CATCH around a method that cannot raise is an error under plenty of
* configurations, so being safer than the original is still being different
* from it.
  METHODS get_initial_request
    RETURNING VALUE(r_initial_request) TYPE REF TO if_apc_wsp_initial_request
    RAISING cx_apc_error.

  METHODS get_binding_manager
    RETURNING VALUE(r_binding_manager) TYPE REF TO if_apc_wsp_binding_manager
    RAISING cx_apc_error.

  METHODS get_connection_id
    RETURNING VALUE(r_connection_id) TYPE if_abap_channel_types=>ty_apc_connection_id
    RAISING cx_apc_error.
ENDINTERFACE.
