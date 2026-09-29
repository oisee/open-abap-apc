CLASS ltcl_pcp DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS escaped_fields_round_trip FOR TESTING RAISING cx_static_check.
    METHODS lenient_headers FOR TESTING RAISING cx_static_check.
    METHODS missing_action_raises FOR TESTING.
    METHODS cross_type_getters FOR TESTING RAISING cx_static_check.
    METHODS repeated_round_trip FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_pcp IMPLEMENTATION.
  METHOD escaped_fields_round_trip.
    DATA lo_message TYPE REF TO if_ac_message_type_pcp.
    DATA lo_copy TYPE REF TO if_ac_message_type_pcp.
    DATA lv_serialized TYPE string.
    DATA lv_value TYPE string.
    DATA lv_lf TYPE string.
    DATA lv_exists TYPE abap_bool.
    DATA lt_fields TYPE if_ac_message_type_pcp=>tt_pcp_fields.
    DATA ls_field TYPE if_ac_message_type_pcp=>ty_pcp_fields.
    lv_lf = cl_abap_char_utilities=>newline.
    lo_message = cl_ac_message_type_pcp=>create( ).
    lv_value = 'a:b' && lv_lf && 'c\d'.
    lo_message->set_field( i_name = 'a:b' i_value = lv_value ).
    lv_serialized = lo_message->serialize( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_serialized CS 'a\:b:a\:b\nc\\d' ) ).
    lo_copy = cl_ac_message_type_pcp=>deserialize( lv_serialized ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_copy->get_field( EXPORTING i_name = 'a:b' IMPORTING e_exists = lv_exists )
      exp = lv_value ).
    cl_abap_unit_assert=>assert_equals( act = lv_exists exp = abap_true ).
    lo_message->set_field( i_name = 'first' i_value = 'old' ).
    lo_message->set_field( i_name = 'second' i_value = 'keep' ).
    lo_message->set_field( i_name = 'first' i_value = 'new' ).
    lo_message->get_fields( CHANGING c_fields = lt_fields ).
    READ TABLE lt_fields INDEX 2 INTO ls_field.
    cl_abap_unit_assert=>assert_equals( act = ls_field-name exp = 'first' ).
    cl_abap_unit_assert=>assert_equals( act = ls_field-value exp = 'new' ).
    lo_message->set_field(
      i_name = 'raw' i_value = cl_abap_char_utilities=>cr_lf(1) && cl_abap_char_utilities=>horizontal_tab ).
    lv_serialized = lo_message->serialize( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_serialized CS cl_abap_char_utilities=>cr_lf(1) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_serialized CS cl_abap_char_utilities=>horizontal_tab ) ).
  ENDMETHOD.

  METHOD lenient_headers.
    DATA lo_message TYPE REF TO if_ac_message_type_pcp.
    DATA lt_fields TYPE if_ac_message_type_pcp=>tt_pcp_fields.
    DATA ls_field TYPE if_ac_message_type_pcp=>ty_pcp_fields.
    DATA lv_lf TYPE string.
    lv_lf = cl_abap_char_utilities=>newline.
    lo_message = cl_ac_message_type_pcp=>deserialize(
      'pcp-action:MESSAGE' && lv_lf && 'broken' && lv_lf && 'lost:yes'
      && lv_lf && 'pcp-body-type:text' && lv_lf && 'pcp-body-type:binary'
      && lv_lf && 'x:one' && lv_lf && 'x:two' && lv_lf && 'odd:\q' && lv_lf && lv_lf && 'body' ).
    lo_message->get_fields( CHANGING c_fields = lt_fields ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_fields ) exp = 5 ).
    READ TABLE lt_fields INDEX 3 INTO ls_field.
    cl_abap_unit_assert=>assert_equals( act = ls_field-value exp = 'one' ).
    READ TABLE lt_fields INDEX 5 INTO ls_field.
    cl_abap_unit_assert=>assert_equals( act = ls_field-value exp = '\q' ).
    cl_abap_unit_assert=>assert_equals( act = lo_message->get_text( ) exp = 'body' ).
    lo_message = cl_ac_message_type_pcp=>deserialize( 'pcp-action:MESSAGE' ).
    cl_abap_unit_assert=>assert_initial( lo_message->get_text( ) ).
  ENDMETHOD.

  METHOD missing_action_raises.
    TRY.
        cl_ac_message_type_pcp=>deserialize( 'x:1' ).
        cl_abap_unit_assert=>fail( 'Missing action must raise' ).
      CATCH cx_ac_message_type_pcp_error.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD cross_type_getters.
    DATA lo_message TYPE REF TO if_ac_message_type_pcp.
    lo_message = cl_ac_message_type_pcp=>create( ).
    lo_message->set_binary( '01' ).
    cl_abap_unit_assert=>assert_initial( lo_message->get_text( ) ).
    lo_message->set_text( 'text' ).
    cl_abap_unit_assert=>assert_initial( lo_message->get_binary( ) ).
  ENDMETHOD.

  METHOD repeated_round_trip.
    DATA lo_message TYPE REF TO if_ac_message_type_pcp.
    DATA lv_first TYPE string.
    DATA lv_second TYPE string.
    DATA lv_third TYPE string.
    DATA lt_fields TYPE if_ac_message_type_pcp=>tt_pcp_fields.
    DATA ls_field TYPE if_ac_message_type_pcp=>ty_pcp_fields.
    DATA lv_body_types TYPE i.
    DATA lv_expected_type TYPE string.
    DO 2 TIMES.
      lo_message = cl_ac_message_type_pcp=>create( ).
      lo_message->set_field( i_name = 'custom' i_value = 'a:b' ).
      IF sy-index = 1.
        lo_message->set_text( 'text body' ).
        lv_expected_type = 'text'.
      ELSE.
        lo_message->set_binary( '00FF' ).
        lv_expected_type = 'binary'.
      ENDIF.
      lv_first = lo_message->serialize( ).
      lo_message = cl_ac_message_type_pcp=>deserialize( lv_first ).
      lv_second = lo_message->serialize( ).
      lo_message = cl_ac_message_type_pcp=>deserialize( lv_second ).
      lv_third = lo_message->serialize( ).
      cl_abap_unit_assert=>assert_equals( act = lv_third exp = lv_first ).
      lo_message->get_fields( CHANGING c_fields = lt_fields ).
      CLEAR lv_body_types.
      LOOP AT lt_fields INTO ls_field WHERE name = 'pcp-body-type'.
        lv_body_types = lv_body_types + 1.
        cl_abap_unit_assert=>assert_equals( act = ls_field-value exp = lv_expected_type ).
      ENDLOOP.
      cl_abap_unit_assert=>assert_equals( act = lv_body_types exp = 1 ).
    ENDDO.
  ENDMETHOD.
ENDCLASS.
