CLASS zcl_apc_context DEFINITION PUBLIC CREATE PUBLIC.
* The server context a handler is given: the request that opened the
* connection and the binding manager.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_server_context.

    METHODS constructor
      IMPORTING
        io_request TYPE REF TO if_apc_wsp_initial_request OPTIONAL.
  PRIVATE SECTION.
    DATA mo_request TYPE REF TO if_apc_wsp_initial_request.
    DATA mo_binding TYPE REF TO zcl_apc_binding_manager.
ENDCLASS.

CLASS zcl_apc_context IMPLEMENTATION.

  METHOD constructor.
    mo_request = io_request.
    IF mo_request IS INITIAL.
      CREATE OBJECT mo_request TYPE zcl_apc_initial_request.
    ENDIF.
    CREATE OBJECT mo_binding.
  ENDMETHOD.

  METHOD if_apc_wsp_server_context_base~get_initial_request.
    r_initial_request = mo_request.
  ENDMETHOD.

  METHOD if_apc_wsp_server_context~get_binding_manager.
    r_binding_manager = mo_binding.
  ENDMETHOD.

ENDCLASS.
