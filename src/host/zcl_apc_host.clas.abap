CLASS zcl_apc_host DEFINITION PUBLIC CREATE PUBLIC.
* The APC runtime, off a system: it holds one connection to one handler and
* drives it the way the ICF does. open( ) creates the handler class, asks
* on_accept and calls on_start; message( ) hands it what the client sent;
* drain( ) takes what it pushed back. Nothing here talks to a socket, so
* the same host serves a websocket server in Node, a page that calls it
* directly, a worker, or a test.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_handler TYPE string
        it_fields  TYPE tihttpnvp OPTIONAL
      RAISING
        cx_apc_error.

* on_accept and on_start; abap_false when the handler rejects the connection
    METHODS open
      RETURNING
        VALUE(rv_accepted) TYPE abap_bool
      RAISING
        cx_apc_error.

    METHODS message
      IMPORTING
        iv_text TYPE string
      RAISING
        cx_apc_error.

    METHODS close
      IMPORTING
        !iv_reason TYPE string DEFAULT 'closed by the host'
        !iv_code   TYPE i      DEFAULT 1000
      RAISING
        cx_apc_error.

    METHODS error
      IMPORTING
        !iv_reason TYPE string
        !iv_code   TYPE i DEFAULT 1011
      RAISING
        cx_apc_error.

* what the handler has pushed since the last call
    METHODS drain
      RETURNING
        VALUE(rt_messages) TYPE string_table.

    METHODS is_open
      RETURNING
        VALUE(rv_open) TYPE abap_bool.

    METHODS bindings
      RETURNING VALUE(rt_bindings) TYPE zcl_apc_binding_manager=>tt_binding.

  PRIVATE SECTION.
    DATA mv_handler TYPE string.
    DATA mo_ext     TYPE REF TO if_apc_wsp_extension.
*   the concrete class, because the two context interfaces are independent
*   the way a system declares them and one callback takes each: the class
*   answers both, a reference to one of them does not
    DATA mo_context TYPE REF TO zcl_apc_context.
    DATA mo_manager TYPE REF TO zcl_apc_message_manager.
    DATA mv_open    TYPE abap_bool.
ENDCLASS.

CLASS zcl_apc_host IMPLEMENTATION.

  METHOD constructor.
    DATA lo_request TYPE REF TO if_apc_wsp_initial_request.

    mv_handler = to_upper( iv_handler ).
    TRY.
        CREATE OBJECT mo_ext TYPE (mv_handler).
      CATCH cx_sy_create_object_error.
        RAISE EXCEPTION TYPE cx_apc_error.
    ENDTRY.
    CREATE OBJECT lo_request TYPE zcl_apc_initial_request
      EXPORTING
        it_fields = it_fields.
    CREATE OBJECT mo_context TYPE zcl_apc_context
      EXPORTING
        io_request = lo_request.
    CREATE OBJECT mo_manager.
  ENDMETHOD.

  METHOD open.
    DATA lv_mode TYPE i.

    mo_ext->on_accept( EXPORTING i_context_base = mo_context
                       IMPORTING e_connect_mode = lv_mode ).
    IF lv_mode = if_apc_wsp_extension=>co_connect_mode_reject.
      rv_accepted = abap_false.
      RETURN.
    ENDIF.
    mo_ext->on_start( i_context         = mo_context
                      i_message_manager = mo_manager ).
    mv_open    = abap_true.
    rv_accepted = abap_true.
  ENDMETHOD.

  METHOD message.
    DATA lo_message TYPE REF TO zcl_apc_message.

    IF mv_open = abap_false.
      RAISE EXCEPTION TYPE cx_apc_error.
    ENDIF.
    CREATE OBJECT lo_message
      EXPORTING
        iv_text = iv_text.
    mo_ext->on_message( i_message         = lo_message
                        i_message_manager = mo_manager
                        i_context         = mo_context ).
  ENDMETHOD.

  METHOD close.
    IF mv_open = abap_false.
      RETURN.
    ENDIF.
    mv_open = abap_false.
    mo_ext->on_close( i_reason       = iv_reason
                      i_code         = iv_code
                      i_context_base = mo_context ).
  ENDMETHOD.

  METHOD error.
    mo_ext->on_error( i_reason       = iv_reason
                      i_code         = iv_code
                      i_context_base = mo_context ).
  ENDMETHOD.

  METHOD drain.
    rt_messages = mo_manager->drain( ).
  ENDMETHOD.

  METHOD is_open.
    rv_open = mv_open.
  ENDMETHOD.

  METHOD bindings.
    DATA lo_binding TYPE REF TO zcl_apc_binding_manager.
    lo_binding ?= mo_context->if_apc_wsp_server_context~get_binding_manager( ).
    rt_bindings = lo_binding->bindings( ).
  ENDMETHOD.

ENDCLASS.
