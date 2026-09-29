CLASS cl_ac_message_type_pcp DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_ac_message_type_pcp.
    CLASS-METHODS create RETURNING VALUE(r_message) TYPE REF TO if_ac_message_type_pcp.
    CLASS-METHODS deserialize IMPORTING i_serialized_message TYPE string
      RETURNING VALUE(r_message) TYPE REF TO if_ac_message_type_pcp
      RAISING cx_ac_message_type_pcp_error.
  PRIVATE SECTION.
    DATA mt_fields TYPE if_ac_message_type_pcp=>tt_pcp_fields.
    DATA mv_text TYPE string.
    DATA mv_binary TYPE xstring.
    DATA mv_binary_mode TYPE abap_bool.
ENDCLASS.

CLASS cl_ac_message_type_pcp IMPLEMENTATION.
  METHOD create.
    CREATE OBJECT r_message TYPE cl_ac_message_type_pcp.
  ENDMETHOD.

  METHOD deserialize.
* The transpiler does not dispatch interface class methods. Keep the contract
* declaration and provide this class entry point until it does.
    r_message = if_ac_message_type_pcp~deserialize( i_serialized_message ).
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~set_field.
* to measure on A4H (probe PCP1): name case, replacement order, colon in a name and reserved fields.
    IF i_name IS INITIAL OR i_name = 'pcp-action' OR i_name = 'pcp-body-type'
        OR i_name CS ':' OR i_name CS cl_abap_char_utilities=>newline
        OR i_name CS cl_abap_char_utilities=>cr_lf.
      RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
        EXPORTING message = 'Invalid PCP field name'.
    ENDIF.
    FIELD-SYMBOLS <field> TYPE if_ac_message_type_pcp=>ty_pcp_fields.
    LOOP AT mt_fields ASSIGNING <field> WHERE name = i_name.
      <field>-value = i_value.
      RETURN.
    ENDLOOP.
    DATA ls_field TYPE if_ac_message_type_pcp=>ty_pcp_fields.
    ls_field-name = i_name.
    ls_field-value = i_value.
    APPEND ls_field TO mt_fields.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~get_field.
* to measure on A4H (probe PCP1): field-name case.
    e_exists = abap_false.
    CLEAR r_value.
    FIELD-SYMBOLS <field> TYPE if_ac_message_type_pcp=>ty_pcp_fields.
    LOOP AT mt_fields ASSIGNING <field> WHERE name = i_name.
      e_exists = abap_true.
      r_value = <field>-value.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~get_fields.
    c_fields = mt_fields.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~delete_field.
    DELETE mt_fields WHERE name = i_name.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~set_text.
    mv_text = i_message.
    CLEAR mv_binary.
    mv_binary_mode = abap_false.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~set_binary.
    mv_binary = i_message.
    CLEAR mv_text.
    mv_binary_mode = abap_true.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~get_text.
* to measure on A4H (probe PCP2): cross-type getter behaviour.
    IF mv_binary_mode = abap_true.
      RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
        EXPORTING message = 'PCP body is binary'.
    ENDIF.
    r_message = mv_text.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~get_binary.
* to measure on A4H (probe PCP2): cross-type getter behaviour.
    IF mv_binary_mode = abap_false.
      RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
        EXPORTING message = 'PCP body is text'.
    ENDIF.
    r_message = mv_binary.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~serialize.
    DATA lv_lf TYPE string.
    lv_lf = cl_abap_char_utilities=>newline.
    r_serialized_message = 'pcp-action:MESSAGE' && lv_lf.
    IF mv_binary_mode = abap_true.
* to measure on A4H (probe PCP2): binary body encoding and header.
      r_serialized_message = r_serialized_message && 'pcp-body-type:binary' && lv_lf.
    ELSE.
      r_serialized_message = r_serialized_message && 'pcp-body-type:text' && lv_lf.
    ENDIF.
    FIELD-SYMBOLS <field> TYPE if_ac_message_type_pcp=>ty_pcp_fields.
    LOOP AT mt_fields ASSIGNING <field>.
* to measure on A4H (probe PCP1): backslash and newline in values.
      IF <field>-value CS lv_lf OR <field>-value CS cl_abap_char_utilities=>cr_lf.
        RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
          EXPORTING message = 'PCP field value contains newline'.
      ENDIF.
      DATA lv_value TYPE string.
      lv_value = <field>-value.
      REPLACE ALL OCCURRENCES OF '\' IN lv_value WITH '\\'.
      REPLACE ALL OCCURRENCES OF ':' IN lv_value WITH '\:'.
      r_serialized_message = r_serialized_message && <field>-name && ':' && lv_value && lv_lf.
    ENDLOOP.
    r_serialized_message = r_serialized_message && lv_lf.
    IF mv_binary_mode = abap_true.
      r_serialized_message = r_serialized_message && cl_http_utility=>encode_x_base64( mv_binary ).
    ELSE.
      r_serialized_message = r_serialized_message && mv_text.
    ENDIF.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~deserialize.
* to measure on A4H (probe PCP3): malformed input and reserved headers.
    DATA lv_lf TYPE string.
    lv_lf = cl_abap_char_utilities=>newline.
    DATA lv_separator TYPE string.
    lv_separator = lv_lf && lv_lf.
    DATA lv_offset TYPE i.
    FIND FIRST OCCURRENCE OF lv_separator IN i_serialized_message MATCH OFFSET lv_offset.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
        EXPORTING message = 'PCP header has no empty line'.
    ENDIF.
    DATA lv_headers TYPE string.
    DATA lv_body TYPE string.
    lv_headers = i_serialized_message(lv_offset).
    DATA lv_body_offset TYPE i.
    lv_body_offset = lv_offset + 2.
    lv_body = i_serialized_message+lv_body_offset.
    DATA lt_lines TYPE string_table.
    SPLIT lv_headers AT lv_lf INTO TABLE lt_lines.
    DATA lv_action TYPE abap_bool.
    DATA lv_type TYPE string.
    DATA lo_message TYPE REF TO if_ac_message_type_pcp.
    lo_message = create( ).
    DATA lv_line TYPE string.
    LOOP AT lt_lines INTO lv_line.
      DATA lv_colon TYPE i.
      FIND FIRST OCCURRENCE OF ':' IN lv_line MATCH OFFSET lv_colon.
      IF sy-subrc <> 0 OR lv_colon = 0.
        RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
          EXPORTING message = 'Invalid PCP header line'.
      ENDIF.
      DATA lv_name TYPE string.
      DATA lv_value TYPE string.
      lv_name = lv_line(lv_colon).
      DATA lv_value_offset TYPE i.
      lv_value_offset = lv_colon + 1.
      lv_value = lv_line+lv_value_offset.
      DATA lv_unescaped TYPE string.
      DATA lv_index TYPE i.
      DATA lv_escape TYPE abap_bool.
      CLEAR lv_unescaped.
      lv_escape = abap_false.
      DO strlen( lv_value ) TIMES.
        DATA lv_char TYPE c LENGTH 1.
        lv_index = sy-index - 1.
        lv_char = lv_value+lv_index(1).
        IF lv_escape = abap_true.
          IF lv_char <> ':' AND lv_char <> '\'.
            RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
              EXPORTING message = 'Invalid PCP escape'.
          ENDIF.
          lv_unescaped = lv_unescaped && lv_char.
          lv_escape = abap_false.
        ELSEIF lv_char = '\'.
          lv_escape = abap_true.
        ELSE.
          lv_unescaped = lv_unescaped && lv_char.
        ENDIF.
      ENDDO.
      IF lv_escape = abap_true.
        RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
          EXPORTING message = 'Incomplete PCP escape'.
      ENDIF.
      CASE lv_name.
        WHEN 'pcp-action'.
          IF lv_unescaped <> 'MESSAGE' OR lv_action = abap_true.
            RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
              EXPORTING message = 'Invalid PCP action'.
          ENDIF.
          lv_action = abap_true.
        WHEN 'pcp-body-type'.
          IF lv_type IS NOT INITIAL.
            RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
              EXPORTING message = 'Duplicate PCP body type'.
          ENDIF.
          lv_type = lv_unescaped.
        WHEN OTHERS.
          lo_message->set_field( i_name = lv_name i_value = lv_unescaped ).
      ENDCASE.
    ENDLOOP.
    IF lv_action = abap_false OR ( lv_type <> 'text' AND lv_type <> 'binary' ).
      RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
        EXPORTING message = 'Missing PCP action or body type'.
    ENDIF.
    IF lv_type = 'binary'.
      lo_message->set_binary( cl_http_utility=>decode_x_base64( lv_body ) ).
    ELSE.
      lo_message->set_text( lv_body ).
    ENDIF.
    r_message = lo_message.
  ENDMETHOD.
ENDCLASS.
