INTERFACE if_apc_wsp_message PUBLIC.
* The message a handler is given and the one it answers with. Names and
* types are a system's, read off one: the parameter is called i_message and
* not iv_text, which matters because a handler may call it by name and then
* a plausible name is a compile error rather than a nuisance.
*
* open-abap-core's copy has three of these and not set_text, which is what
* a handler answering with text needs (oisee/vivid-vibes: create_message,
* set_text, send), so the whole interface is here for the same pull request
* as the rest of the family.
  CONSTANTS co_message_type_text TYPE i VALUE 1.
  CONSTANTS co_message_type_binary TYPE i VALUE 2.

  METHODS get_message_type
    RETURNING VALUE(r_type) TYPE i
    RAISING cx_apc_error.

  METHODS get_binary
    RETURNING VALUE(r_message) TYPE xstring
    RAISING cx_apc_error.

  METHODS set_binary
    IMPORTING !i_message TYPE xstring
    RAISING cx_apc_error.

  METHODS get_text
    RETURNING VALUE(r_message) TYPE string
    RAISING cx_apc_error.

  METHODS set_text
    IMPORTING !i_message TYPE string
    RAISING cx_apc_error.
ENDINTERFACE.
