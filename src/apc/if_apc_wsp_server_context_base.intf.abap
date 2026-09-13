INTERFACE if_apc_wsp_server_context_base PUBLIC.
* What on_accept, on_close and on_error are handed: the part of the context
* that exists before a connection does. The full context
* (if_apc_wsp_server_context) is what on_start and on_message get.
  METHODS get_initial_request
    RETURNING VALUE(r_initial_request) TYPE REF TO if_apc_wsp_initial_request.
ENDINTERFACE.
