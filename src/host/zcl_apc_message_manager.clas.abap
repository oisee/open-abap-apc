CLASS zcl_apc_message_manager DEFINITION PUBLIC CREATE PUBLIC.
* What the handler sends goes here. On a system this puts a frame on the
* socket; here it collects, and the host hands the frames to whoever drives
* it: a browser page, a websocket server, a test.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_message_manager.

    METHODS drain
      RETURNING
        VALUE(rt_messages) TYPE string_table.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mv_send_mode TYPE i.
    DATA mt_sent TYPE string_table.
ENDCLASS.

CLASS zcl_apc_message_manager IMPLEMENTATION.

  METHOD if_apc_wsp_message_manager~create_message.
    CREATE OBJECT r_message TYPE zcl_apc_message.
  ENDMETHOD.

  METHOD if_apc_wsp_message_manager~send.
    APPEND i_message->get_text( ) TO mt_sent.
  ENDMETHOD.

  METHOD drain.
    rt_messages = mt_sent.
    CLEAR mt_sent.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_sent ).
  ENDMETHOD.

  METHOD if_apc_wsp_message_manager~set_send_mode.
*   a system decides whether a send closes the LUW; off stack there is no
*   LUW to keep, so the mode is remembered and nothing acts on it yet
    mv_send_mode = i_mode.
  ENDMETHOD.

ENDCLASS.
