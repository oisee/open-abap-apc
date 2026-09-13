CLASS zcl_apc_message DEFINITION PUBLIC CREATE PUBLIC.
* One websocket message, text or binary, as the handler sees it.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_message.
    METHODS constructor
      IMPORTING
        iv_text TYPE string OPTIONAL.
  PRIVATE SECTION.
    DATA mv_text   TYPE string.
    DATA mv_binary TYPE xstring.
ENDCLASS.

CLASS zcl_apc_message IMPLEMENTATION.

  METHOD constructor.
    mv_text = iv_text.
  ENDMETHOD.

  METHOD if_apc_wsp_message~get_text.
    IF mv_text IS INITIAL AND mv_binary IS NOT INITIAL.
      r_message = cl_abap_codepage=>convert_from( mv_binary ).
    ELSE.
      r_message = mv_text.
    ENDIF.
  ENDMETHOD.

  METHOD if_apc_wsp_message~get_binary.
    IF mv_binary IS INITIAL AND mv_text IS NOT INITIAL.
      rv_binary = cl_abap_codepage=>convert_to( mv_text ).
    ELSE.
      rv_binary = mv_binary.
    ENDIF.
  ENDMETHOD.

  METHOD if_apc_wsp_message~set_binary.
    mv_binary = iv_binary.
    CLEAR mv_text.
  ENDMETHOD.

  METHOD if_apc_wsp_message~set_text.
    mv_text = i_text.
    CLEAR mv_binary.
  ENDMETHOD.

ENDCLASS.
