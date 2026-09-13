INTERFACE if_apc_wsp_server_context_base PUBLIC.
* What on_accept, on_close and on_error are handed. Every method raises on a
* system, and that is not decoration: SAP's own reference handler wraps the
* call in TRY/CATCH cx_apc_error and defaults on failure, so an interface
* that cannot raise makes a faithful handler's CATCH an error. Being safer
* than the original is still being different from it.
*
* Two methods are still missing here against a system and arrive with the
* channel types they are declared with (get_binding_manager,
* get_connection_id).
  METHODS get_initial_request
    RETURNING VALUE(r_initial_request) TYPE REF TO if_apc_wsp_initial_request
    RAISING cx_apc_error.
ENDINTERFACE.
