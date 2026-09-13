INTERFACE if_apc_wsp_message_manager PUBLIC.
* How a handler answers: make a message, fill it, send it. On a system the
* send goes out on the socket there and then, inside the callback, which is
* why there is nothing here about collecting anything.
  INTERFACES if_apc_wsp_message_manager_bas.

  CONSTANTS co_sendmode_default TYPE i VALUE 0.
  CONSTANTS co_sendmode_keep_luw TYPE i VALUE 1.

  METHODS create_message
    RETURNING
      VALUE(r_message) TYPE REF TO if_apc_wsp_message
    RAISING
      cx_apc_error.

  METHODS send
    IMPORTING
      !i_message TYPE REF TO if_apc_wsp_message
    RAISING
      cx_apc_error.

  METHODS set_send_mode
    IMPORTING
      !i_mode TYPE i DEFAULT co_sendmode_default
    RAISING
      cx_apc_error.
ENDINTERFACE.
