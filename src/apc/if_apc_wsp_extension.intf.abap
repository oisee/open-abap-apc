INTERFACE if_apc_wsp_extension PUBLIC.
* The APC extension a websocket handler implements, with the five methods
* and the signatures a real system has. open-abap-core carries two of the
* methods; a stateful handler uses all five, and this is what
* oisee/vivid-vibes is written against.
*
* Read off a system on 2026-09-13 rather than reconstructed, because the
* details are what decide whether a handler written for APC compiles here:
* on_accept takes the context base and not the context, on_close and
* on_error take a reason and a code, and none of them raise.
*
* Destined for a pull request to open-abap-core; until then this project
* ships the family and leaves core's src/tcp out of its dependency.
  INTERFACES if_apc_wsp_extension_common.

  ALIASES co_connect_mode_accept FOR if_apc_wsp_extension_common~co_connect_mode_accept.
  ALIASES co_connect_mode_reject FOR if_apc_wsp_extension_common~co_connect_mode_reject.

  METHODS on_accept
    IMPORTING
      !i_context_base         TYPE REF TO if_apc_wsp_server_context_base
      !i_http_reject_response TYPE REF TO if_apc_wsp_reject_response OPTIONAL
    EXPORTING
      !e_connect_mode         TYPE i.

  METHODS on_start
    IMPORTING
      !i_context         TYPE REF TO if_apc_wsp_server_context
      !i_message_manager TYPE REF TO if_apc_wsp_message_manager.

  METHODS on_message
    IMPORTING
      !i_message         TYPE REF TO if_apc_wsp_message
      !i_message_manager TYPE REF TO if_apc_wsp_message_manager
      !i_context         TYPE REF TO if_apc_wsp_server_context.

  METHODS on_close
    IMPORTING
      !i_reason       TYPE string
      !i_code         TYPE i
      !i_context_base TYPE REF TO if_apc_wsp_server_context_base.

  METHODS on_error
    IMPORTING
      !i_reason       TYPE string
      !i_code         TYPE i
      !i_context_base TYPE REF TO if_apc_wsp_server_context_base.
ENDINTERFACE.
