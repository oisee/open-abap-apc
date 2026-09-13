CLASS cl_apc_wsp_ext_stateless_base DEFINITION PUBLIC ABSTRACT CREATE PUBLIC.
* A handler that keeps nothing between messages; every method does nothing
* unless the subclass redefines it.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_extension.
ENDCLASS.

CLASS cl_apc_wsp_ext_stateless_base IMPLEMENTATION.

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
