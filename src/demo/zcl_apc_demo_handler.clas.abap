CLASS zcl_apc_demo_handler DEFINITION PUBLIC INHERITING FROM cl_apc_wsp_ext_stateful_base FINAL CREATE PUBLIC.
* The smallest handler that behaves like a demo engine: it answers 'frame'
* with one frame of a plasma as JSON, counts frames and keeps the count
* between messages, which is what stateful means. The shape of the
* protocol is the one oisee/vivid-vibes uses: a config on start, a frame
* per request, 'start' and 'stop' to run or hold.
  PUBLIC SECTION.
    METHODS if_apc_wsp_extension~on_start REDEFINITION.
    METHODS if_apc_wsp_extension~on_message REDEFINITION.
    METHODS if_apc_wsp_extension~on_close REDEFINITION.

    CONSTANTS gc_width  TYPE i VALUE 64.
    CONSTANTS gc_height TYPE i VALUE 40.
  PRIVATE SECTION.
    DATA mv_frame   TYPE i.
    DATA mv_running TYPE abap_bool.

    METHODS send_text
      IMPORTING
        io_manager TYPE REF TO if_apc_wsp_message_manager
        iv_text    TYPE string
      RAISING
        cx_apc_error.

    METHODS render
      RETURNING
        VALUE(rv_json) TYPE string.
ENDCLASS.

CLASS zcl_apc_demo_handler IMPLEMENTATION.

  METHOD if_apc_wsp_extension~on_start.
    mv_running = abap_true.
    mv_frame   = 0.
    send_text( io_manager = i_message_manager
               iv_text    = |\{"type":"config","width":{ gc_width },"height":{ gc_height },"fps":25,"name":"plasma"\}| ).
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_message.
    DATA lv_command TYPE string.

    lv_command = i_message->get_text( ).
    CASE lv_command.
      WHEN 'start'.
        mv_running = abap_true.
      WHEN 'stop'.
        mv_running = abap_false.
      WHEN 'frame'.
        IF mv_running = abap_true.
          send_text( io_manager = i_message_manager
                     iv_text    = render( ) ).
          mv_frame = mv_frame + 1.
        ENDIF.
      WHEN OTHERS.
        send_text( io_manager = i_message_manager
                   iv_text    = |\{"type":"error","reason":"unknown command"\}| ).
    ENDCASE.
  ENDMETHOD.

  METHOD if_apc_wsp_extension~on_close.
    mv_running = abap_false.
  ENDMETHOD.

  METHOD send_text.
    DATA lo_message TYPE REF TO if_apc_wsp_message.

    lo_message = io_manager->create_message( ).
    lo_message->set_text( iv_text ).
    io_manager->send( lo_message ).
  ENDMETHOD.

  METHOD render.
* a plasma: one character per cell, out of the sum of two sines that move
* with the frame number
    DATA lv_x     TYPE i.
    DATA lv_y     TYPE i.
    DATA lv_v     TYPE f.
    DATA lv_time  TYPE f.
    DATA lv_index TYPE i.
    DATA lv_row   TYPE string.
    DATA lv_rows  TYPE string.
    CONSTANTS lc_ramp TYPE string VALUE ` .:-=+*#%@`.

    lv_time = mv_frame / 10.
    lv_y = 0.
    WHILE lv_y < gc_height.
      CLEAR lv_row.
      lv_x = 0.
      WHILE lv_x < gc_width.
        lv_v = sin( lv_x / 8 + lv_time ) + sin( lv_y / 5 - lv_time )
             + sin( ( lv_x + lv_y ) / 9 + lv_time ).
        lv_index = floor( ( lv_v + 3 ) / 6 * 9 ).
        IF lv_index < 0.
          lv_index = 0.
        ELSEIF lv_index > 9.
          lv_index = 9.
        ENDIF.
        lv_row = lv_row && substring( val = lc_ramp off = lv_index len = 1 ).
        lv_x = lv_x + 1.
      ENDWHILE.
      IF lv_rows IS NOT INITIAL.
        lv_rows = lv_rows && ','.
      ENDIF.
      lv_rows = lv_rows && |"{ lv_row }"|.
      lv_y = lv_y + 1.
    ENDWHILE.
    rv_json = |\{"type":"frame","n":{ mv_frame },"rows":[{ lv_rows }]\}|.
  ENDMETHOD.

ENDCLASS.
