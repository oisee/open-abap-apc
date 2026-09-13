INTERFACE if_apc_wsp_reject_response PUBLIC.
* How a handler says why it refused a connection, optional on on_accept.
* Nothing off stack reads it yet; it is here so a handler that fills it
* compiles unchanged.
  METHODS set_status
    IMPORTING
      !i_code   TYPE i
      !i_reason TYPE string OPTIONAL
    RAISING cx_apc_error.

  METHODS set_response_headers
    IMPORTING !i_response_headers TYPE if_abap_channel_types=>ty_tihttpnvp.

  METHODS set_response_body
    IMPORTING !i_response_body TYPE xstring.
ENDINTERFACE.
