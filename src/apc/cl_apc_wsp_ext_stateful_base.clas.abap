CLASS cl_apc_wsp_ext_stateful_base DEFINITION PUBLIC ABSTRACT CREATE PUBLIC.
* A handler that lives for the length of the connection: the instance is
* kept between messages, so it can hold state (a demo, a frame counter).
* The same five methods; a subclass redefines what it needs.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_extension.
ENDCLASS.

CLASS cl_apc_wsp_ext_stateful_base IMPLEMENTATION.

  METHOD if_apc_wsp_extension~on_accept.
    e_connect_mode = if_apc_wsp_extension=>co_connect_mode_accept.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_start.
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_message.
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_close.
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_error.
    RETURN.
  ENDMETHOD.

ENDCLASS.
