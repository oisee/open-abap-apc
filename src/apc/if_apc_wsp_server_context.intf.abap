INTERFACE if_apc_wsp_server_context PUBLIC.
* The context on_start and on_message are handed. Four methods and two
* constants, declared here rather than inherited from the base: that is what
* a system declares, and the earlier version of this file included the base
* instead because my host found it convenient to pass one object to
* callbacks that take either. The convenience now lives in zcl_apc_context,
* which implements both, and the interface says what a system says.
  CONSTANTS co_con_security_by_user_id TYPE i VALUE 2.
  CONSTANTS co_con_security_by_program_id TYPE i VALUE 3.

  METHODS get_initial_request
    RETURNING VALUE(r_initial_request) TYPE REF TO if_apc_wsp_initial_request
    RAISING cx_apc_error.

  METHODS get_binding_manager
    RETURNING VALUE(r_binding_manager) TYPE REF TO if_apc_wsp_binding_manager
    RAISING cx_apc_error.

  METHODS get_connection_id
    RETURNING VALUE(r_connection_id) TYPE if_abap_channel_types=>ty_apc_connection_id
    RAISING cx_apc_error.

* SAP's own reference handler calls this one, so a family without it cannot
* compile the canonical demo
  METHODS get_connection_attach_handle
    IMPORTING !i_connection_security TYPE i DEFAULT co_con_security_by_user_id
    RETURNING VALUE(r_connection_attach_handle) TYPE if_abap_channel_types=>ty_apc_conn_attach_handle
    RAISING cx_apc_error.
ENDINTERFACE.
