INTERFACE if_apc_wsp_extension PUBLIC.
* The APC extension a websocket handler implements. open-abap-core has the
* two stateless methods; a stateful handler (cl_apc_wsp_ext_stateful_base)
* also gets on_accept, on_close and on_error, and that is what a real
* handler written for a system uses: oisee/vivid-vibes redefines all five
* and answers on_accept with e_connect_mode = co_connect_mode_accept.
* Destined for a pull request to open-abap-core; until then this project
* ships the family and leaves core's src/tcp out of its dependency.
  CONSTANTS co_connect_mode_accept TYPE i VALUE 1.
  CONSTANTS co_connect_mode_reject TYPE i VALUE 2.

  METHODS on_accept
    IMPORTING
      i_context           TYPE REF TO if_apc_wsp_server_context
    EXPORTING
      e_connect_mode      TYPE i
    RAISING
      cx_apc_error.

  METHODS on_start
    IMPORTING
      i_context         TYPE REF TO if_apc_wsp_server_context
      i_message_manager TYPE REF TO if_apc_wsp_message_manager
    RAISING
      cx_apc_error.

  METHODS on_message
    IMPORTING
      i_message         TYPE REF TO if_apc_wsp_message
      i_message_manager TYPE REF TO if_apc_wsp_message_manager
      i_context         TYPE REF TO if_apc_wsp_server_context
    RAISING
      cx_apc_error.

  METHODS on_close
    IMPORTING
      i_context         TYPE REF TO if_apc_wsp_server_context
      i_message_manager TYPE REF TO if_apc_wsp_message_manager
    RAISING
      cx_apc_error.

  METHODS on_error
    IMPORTING
      i_context         TYPE REF TO if_apc_wsp_server_context
      i_message_manager TYPE REF TO if_apc_wsp_message_manager
      i_reason          TYPE string
    RAISING
      cx_apc_error.
ENDINTERFACE.
