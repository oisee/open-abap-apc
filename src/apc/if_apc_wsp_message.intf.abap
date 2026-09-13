INTERFACE if_apc_wsp_message PUBLIC.
* open-abap-core's copy has get_binary, set_binary and get_text; a handler
* that answers with text needs set_text as well (oisee/vivid-vibes:
* lo_msg = i_message_manager->create_message( ). lo_msg->set_text( ... ).
* i_message_manager->send( lo_msg ).), so it is here too, for the same
* pull request as the rest of the family.
  METHODS get_binary
    RETURNING VALUE(rv_binary) TYPE xstring
    RAISING cx_apc_error.

  METHODS set_binary
    IMPORTING iv_binary TYPE xstring
    RAISING cx_apc_error.

  METHODS get_text
    RETURNING VALUE(r_message) TYPE string
    RAISING cx_apc_error.

  METHODS set_text
    IMPORTING i_text TYPE string
    RAISING cx_apc_error.
ENDINTERFACE.
