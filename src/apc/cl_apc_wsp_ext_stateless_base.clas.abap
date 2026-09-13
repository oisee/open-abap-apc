CLASS cl_apc_wsp_ext_stateless_base DEFINITION PUBLIC ABSTRACT CREATE PUBLIC.
* A handler that is made again for every message, so it holds no state. The
* same family and the same alias chain; on_message is what a subclass must
* write, and the rest is answered here.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_extension_common.
    INTERFACES if_apc_wsp_extension.
    INTERFACES if_apc_wsp_extension_stateless.

    ALIASES co_connect_mode_accept FOR if_apc_wsp_extension_common~co_connect_mode_accept.
    ALIASES co_connect_mode_reject FOR if_apc_wsp_extension_common~co_connect_mode_reject.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS cl_apc_wsp_ext_stateless_base IMPLEMENTATION.

  METHOD if_apc_wsp_extension~on_accept.
    e_connect_mode = co_connect_mode_accept.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_start.
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_message.
*   a system declares this ABSTRACT here; abaplint does not honour
*   "INTERFACES x ABSTRACT METHODS y", so it answers with nothing instead
*   and a subclass redefines it as it would there
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_close.
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_error.
    RETURN.
  ENDMETHOD.

ENDCLASS.
