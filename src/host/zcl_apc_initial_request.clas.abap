CLASS zcl_apc_initial_request DEFINITION PUBLIC CREATE PUBLIC.
* The HTTP request that opened the connection: the query string of the
* websocket URL and its headers, which is how a client passes a mode or a
* demo id before the first message.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_initial_request.

    METHODS constructor
      IMPORTING
        it_fields  TYPE tihttpnvp OPTIONAL
        it_headers TYPE tihttpnvp OPTIONAL.
  PRIVATE SECTION.
    DATA mt_fields  TYPE tihttpnvp.
    DATA mt_headers TYPE tihttpnvp.
ENDCLASS.

CLASS zcl_apc_initial_request IMPLEMENTATION.

  METHOD constructor.
    mt_fields  = it_fields.
    mt_headers = it_headers.
  ENDMETHOD.

  METHOD if_apc_wsp_initial_request~get_form_fields.
    c_fields = mt_fields.
  ENDMETHOD.

  METHOD if_apc_wsp_initial_request~get_header_fields.
    c_fields = mt_headers.
  ENDMETHOD.

ENDCLASS.
