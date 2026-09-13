CLASS ltcl_host DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS open_sends_the_config FOR TESTING RAISING cx_static_check.
    METHODS a_frame_per_request FOR TESTING RAISING cx_static_check.
    METHODS stop_holds_the_frames FOR TESTING RAISING cx_static_check.
    METHODS the_handler_keeps_its_state FOR TESTING RAISING cx_static_check.
    METHODS unknown_handler_is_an_error FOR TESTING.
    METHODS message_before_open_raises FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_host IMPLEMENTATION.

  METHOD open_sends_the_config.
    DATA lo_host TYPE REF TO zcl_apc_host.
    DATA lt_sent TYPE string_table.
    DATA lv_line TYPE string.

    CREATE OBJECT lo_host
      EXPORTING
        iv_handler = 'ZCL_APC_DEMO_HANDLER'.
    cl_abap_unit_assert=>assert_equals( act = lo_host->open( ) exp = abap_true ).
    lt_sent = lo_host->drain( ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_sent ) exp = 1 ).
    READ TABLE lt_sent INDEX 1 INTO lv_line.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_line CS '"type":"config"' ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_line CS '"width":64' ) ).
* drained: the next call gives nothing
    cl_abap_unit_assert=>assert_initial( lo_host->drain( ) ).
  ENDMETHOD.

  METHOD a_frame_per_request.
    DATA lo_host TYPE REF TO zcl_apc_host.
    DATA lt_sent TYPE string_table.
    DATA lv_line TYPE string.

    CREATE OBJECT lo_host
      EXPORTING
        iv_handler = 'ZCL_APC_DEMO_HANDLER'.
    lo_host->open( ).
    lo_host->drain( ).
    lo_host->message( 'frame' ).
    lt_sent = lo_host->drain( ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_sent ) exp = 1 ).
    READ TABLE lt_sent INDEX 1 INTO lv_line.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_line CS '"type":"frame"' ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_line CS '"n":0' ) ).
* 40 rows of 64 characters
    cl_abap_unit_assert=>assert_true( xsdbool( lv_line CS '"rows":["' ) ).
  ENDMETHOD.

  METHOD stop_holds_the_frames.
    DATA lo_host TYPE REF TO zcl_apc_host.

    CREATE OBJECT lo_host
      EXPORTING
        iv_handler = 'ZCL_APC_DEMO_HANDLER'.
    lo_host->open( ).
    lo_host->drain( ).
    lo_host->message( 'stop' ).
    lo_host->message( 'frame' ).
    cl_abap_unit_assert=>assert_initial( lo_host->drain( ) ).
    lo_host->message( 'start' ).
    lo_host->message( 'frame' ).
    cl_abap_unit_assert=>assert_equals( act = lines( lo_host->drain( ) ) exp = 1 ).
  ENDMETHOD.

  METHOD the_handler_keeps_its_state.
    DATA lo_host TYPE REF TO zcl_apc_host.
    DATA lt_sent TYPE string_table.
    DATA lv_line TYPE string.

    CREATE OBJECT lo_host
      EXPORTING
        iv_handler = 'ZCL_APC_DEMO_HANDLER'.
    lo_host->open( ).
    lo_host->drain( ).
    lo_host->message( 'frame' ).
    lo_host->message( 'frame' ).
    lo_host->message( 'frame' ).
    lt_sent = lo_host->drain( ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_sent ) exp = 3 ).
    READ TABLE lt_sent INDEX 3 INTO lv_line.
    cl_abap_unit_assert=>assert_true( xsdbool( lv_line CS '"n":2' ) ).
* the frames differ: the plasma moves
    DATA lv_first TYPE string.
    READ TABLE lt_sent INDEX 1 INTO lv_first.
    cl_abap_unit_assert=>assert_differs( act = lv_line exp = lv_first ).
  ENDMETHOD.

  METHOD unknown_handler_is_an_error.
    DATA lo_host TYPE REF TO zcl_apc_host.

    TRY.
        CREATE OBJECT lo_host
          EXPORTING
            iv_handler = 'ZCL_NOBODY_HOME'.
        cl_abap_unit_assert=>fail( 'a handler that does not exist must raise' ).
      CATCH cx_apc_error.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD message_before_open_raises.
    DATA lo_host TYPE REF TO zcl_apc_host.

    CREATE OBJECT lo_host
      EXPORTING
        iv_handler = 'ZCL_APC_DEMO_HANDLER'.
    TRY.
        lo_host->message( 'frame' ).
        cl_abap_unit_assert=>fail( 'a message before open must raise' ).
      CATCH cx_apc_error.
        cl_abap_unit_assert=>assert_equals( act = lo_host->is_open( ) exp = abap_false ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
