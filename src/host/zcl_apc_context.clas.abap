CLASS zcl_apc_context DEFINITION PUBLIC CREATE PUBLIC.
* The server context a handler is given: the request that opened the
* connection, the binding manager, and the identity of the connection.
*
* It implements both interfaces because the callbacks take different ones,
* on_start and on_message the full context and on_accept, on_close and
* on_error the base. A system declares them independently and so do we; one
* object answering both is this class's convenience rather than a claim
* about what SAP declares.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_server_context.
    INTERFACES if_apc_wsp_server_context_base.

    METHODS constructor
      IMPORTING
        io_request TYPE REF TO if_apc_wsp_initial_request OPTIONAL
        iv_connection_id TYPE if_abap_channel_types=>ty_apc_connection_id OPTIONAL.
  PRIVATE SECTION.
    DATA mo_request TYPE REF TO if_apc_wsp_initial_request.
    DATA mo_binding TYPE REF TO zcl_apc_binding_manager.
    DATA mv_connection_id TYPE if_abap_channel_types=>ty_apc_connection_id.
ENDCLASS.

CLASS zcl_apc_context IMPLEMENTATION.

  METHOD constructor.
    mo_request = io_request.
    IF mo_request IS INITIAL.
      CREATE OBJECT mo_request TYPE zcl_apc_initial_request.
    ENDIF.
    CREATE OBJECT mo_binding.
    mv_connection_id = iv_connection_id.
  ENDMETHOD.

  METHOD if_apc_wsp_server_context~get_initial_request.
    r_initial_request = mo_request.
  ENDMETHOD.

  METHOD if_apc_wsp_server_context~get_binding_manager.
    r_binding_manager = mo_binding.
  ENDMETHOD.

  METHOD if_apc_wsp_server_context~get_connection_id.
    r_connection_id = mv_connection_id.
  ENDMETHOD.

  METHOD if_apc_wsp_server_context~get_connection_attach_handle.
*   a system hands back a handle another session can attach to, which needs
*   a system to attach to. Off stack the connection id is the only identity
*   there is, so that is what comes back rather than something invented.
    r_connection_attach_handle = mv_connection_id.
  ENDMETHOD.

  METHOD if_apc_wsp_server_context_base~get_initial_request.
    r_initial_request = if_apc_wsp_server_context~get_initial_request( ).
  ENDMETHOD.

  METHOD if_apc_wsp_server_context_base~get_binding_manager.
    r_binding_manager = if_apc_wsp_server_context~get_binding_manager( ).
  ENDMETHOD.

  METHOD if_apc_wsp_server_context_base~get_connection_id.
    r_connection_id = mv_connection_id.
  ENDMETHOD.

ENDCLASS.
