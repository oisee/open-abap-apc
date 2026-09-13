CLASS cl_apc_wsp_ext_stateful_base DEFINITION PUBLIC ABSTRACT CREATE PUBLIC.
* A handler that lives for the length of the connection: the instance is
* kept between messages, so it can hold state (a demo, a frame counter).
*
* The shape is a system's, read off one rather than invented, and two
* things about it matter to a handler written elsewhere. The connect mode
* arrives through the alias chain, which is why a subclass can write
* "e_connect_mode = co_connect_mode_accept" with no prefix. And three of
* the five callbacks are implemented here: a handler that only cares about
* messages redefines on_message and on_start and still accepts a
* connection, because accepting is what this does by default.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_extension_common.
    INTERFACES if_apc_wsp_extension.
    INTERFACES if_apc_wsp_extension_stateful.

    ALIASES co_connect_mode_accept FOR if_apc_wsp_extension_common~co_connect_mode_accept.
    ALIASES co_connect_mode_reject FOR if_apc_wsp_extension_common~co_connect_mode_reject.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS cl_apc_wsp_ext_stateful_base IMPLEMENTATION.

  METHOD if_apc_wsp_extension~on_accept.
*   accept the connection unless a subclass says otherwise
    e_connect_mode = co_connect_mode_accept.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_message.
*   a system declares this ABSTRACT here; abaplint does not honour
*   "INTERFACES x ABSTRACT METHODS y", so it answers with nothing instead
*   and a subclass redefines it as it would there
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_start.
*   abstract on a system, for the same reason as on_message
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_close.
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_error.
    RETURN.
  ENDMETHOD.

ENDCLASS.
