INTERFACE if_apc_ws_initial_request PUBLIC.
* The upgrade request a handler reads. Where the methods really live: the
* WSP interface beside this one is an alias shell over it, WS and not WSP.
*
* get_form_field is the one that matters most, because it is what SAP's own
* reference handler calls: the state a client carries is in the query of the
* ws:// URL rather than in a header. Every method raises, and the reference
* handler catches and defaults, so a conforming request is allowed to fail.
  CONSTANTS co_formfield_encoding_raw TYPE i VALUE 1.
  CONSTANTS co_formfield_encoding_encoded TYPE i VALUE 2.

  METHODS get_form_field
    IMPORTING
      !i_name TYPE string
      !i_formfield_encoding TYPE i DEFAULT 0
    RETURNING VALUE(r_value) TYPE string
    RAISING cx_apc_error.

  METHODS get_form_field_cs
    IMPORTING
      !i_name TYPE string
      !i_formfield_encoding TYPE i DEFAULT 0
    RETURNING VALUE(r_value) TYPE string
    RAISING cx_apc_error.

  METHODS get_header_field
    IMPORTING !i_name TYPE string
    RETURNING VALUE(r_value) TYPE string
    RAISING cx_apc_error.

  METHODS get_header_fields
    CHANGING !c_fields TYPE if_abap_channel_types=>ty_tihttpnvp
    RAISING cx_apc_error.

  METHODS get_form_fields
    IMPORTING !i_formfield_encoding TYPE i DEFAULT 0
    CHANGING !c_fields TYPE if_abap_channel_types=>ty_tihttpnvp
    RAISING cx_apc_error.

  METHODS get_cookie
    IMPORTING
      !i_name TYPE string
      !i_path TYPE string DEFAULT ''
    EXPORTING
      !e_value   TYPE string
      !e_domain  TYPE string
      !e_expires TYPE string
      !e_secure  TYPE i
    RAISING cx_apc_error.

  METHODS get_cookies
    CHANGING !c_cookies TYPE if_abap_channel_types=>ty_tihttpcki
    RAISING cx_apc_error.
ENDINTERFACE.
