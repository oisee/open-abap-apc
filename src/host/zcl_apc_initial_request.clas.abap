CLASS zcl_apc_initial_request DEFINITION PUBLIC CREATE PUBLIC.
* The HTTP request that opened the connection: the query string of the
* websocket URL and its headers, which is how a client passes a mode or a
* demo id before the first message.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_initial_request.

    METHODS constructor
      IMPORTING
        it_fields  TYPE if_abap_channel_types=>ty_tihttpnvp OPTIONAL
        it_headers TYPE if_abap_channel_types=>ty_tihttpnvp OPTIONAL
        it_cookies TYPE if_abap_channel_types=>ty_tihttpcki OPTIONAL.
  PRIVATE SECTION.
    DATA mt_fields  TYPE if_abap_channel_types=>ty_tihttpnvp.
    DATA mt_headers TYPE if_abap_channel_types=>ty_tihttpnvp.
    DATA mt_cookies TYPE if_abap_channel_types=>ty_tihttpcki.
ENDCLASS.

CLASS zcl_apc_initial_request IMPLEMENTATION.

  METHOD constructor.
    mt_fields  = it_fields.
    mt_headers = it_headers.
    mt_cookies = it_cookies.
  ENDMETHOD.

  METHOD if_apc_ws_initial_request~get_form_fields.
    c_fields = mt_fields.
  ENDMETHOD.

  METHOD if_apc_ws_initial_request~get_header_fields.
    c_fields = mt_headers.
  ENDMETHOD.

* the one SAP's own reference handler calls: the state a client carries is
* in the query of the ws:// URL
  METHOD if_apc_ws_initial_request~get_form_field.
    DATA ls_field TYPE if_abap_channel_types=>ty_ihttpnvp.
    LOOP AT mt_fields INTO ls_field.
      IF to_upper( ls_field-name ) = to_upper( i_name ).
        r_value = ls_field-value.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_apc_ws_initial_request~get_form_field_cs.
    DATA ls_field TYPE if_abap_channel_types=>ty_ihttpnvp.
    LOOP AT mt_fields INTO ls_field.
      IF ls_field-name = i_name.
        r_value = ls_field-value.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_apc_ws_initial_request~get_header_field.
    DATA ls_field TYPE if_abap_channel_types=>ty_ihttpnvp.
    LOOP AT mt_headers INTO ls_field.
      IF to_upper( ls_field-name ) = to_upper( i_name ).
        r_value = ls_field-value.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_apc_ws_initial_request~get_cookie.
    DATA ls_cookie TYPE if_abap_channel_types=>ty_ihttpcki.
    LOOP AT mt_cookies INTO ls_cookie.
      IF ls_cookie-name = i_name.
        e_value   = ls_cookie-value.
        e_domain  = ls_cookie-xdomain.
        e_expires = ls_cookie-expires.
        e_secure  = ls_cookie-secure.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_apc_ws_initial_request~get_cookies.
    c_cookies = mt_cookies.
  ENDMETHOD.

ENDCLASS.
