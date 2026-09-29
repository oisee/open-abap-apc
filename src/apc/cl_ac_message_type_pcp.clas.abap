CLASS cl_ac_message_type_pcp DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_ac_message_type_pcp.
    CLASS-METHODS create RETURNING VALUE(r_message) TYPE REF TO if_ac_message_type_pcp.
    CLASS-METHODS deserialize IMPORTING i_serialized_message TYPE string
      RETURNING VALUE(r_message) TYPE REF TO if_ac_message_type_pcp
      RAISING cx_ac_message_type_pcp_error.
  PRIVATE SECTION.
    CLASS-METHODS unescape IMPORTING iv_text TYPE string
      RETURNING VALUE(rv_text) TYPE string.
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
    r_message = if_ac_message_type_pcp~deserialize( i_serialized_message ).
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~set_field.
    IF i_name IS INITIAL OR i_name = 'pcp-action' OR i_name = 'pcp-body-type'
        OR i_name CS cl_abap_char_utilities=>newline
        OR i_name CS cl_abap_char_utilities=>cr_lf(1).
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
    IF mv_binary_mode = abap_true.
      CLEAR r_message.
      RETURN.
    ENDIF.
    r_message = mv_text.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~get_binary.
    IF mv_binary_mode = abap_false.
      CLEAR r_message.
      RETURN.
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
      DATA lv_value TYPE string.
      DATA lv_name TYPE string.
      lv_value = <field>-value.
      lv_name = <field>-name.
      REPLACE ALL OCCURRENCES OF '\' IN lv_value WITH '\\'.
      REPLACE ALL OCCURRENCES OF ':' IN lv_value WITH '\:'.
      REPLACE ALL OCCURRENCES OF lv_lf IN lv_value WITH '\n'.
      REPLACE ALL OCCURRENCES OF '\' IN lv_name WITH '\\'.
      REPLACE ALL OCCURRENCES OF ':' IN lv_name WITH '\:'.
      r_serialized_message = r_serialized_message && lv_name && ':' && lv_value && lv_lf.
    ENDLOOP.
    r_serialized_message = r_serialized_message && lv_lf.
    IF mv_binary_mode = abap_true.
      r_serialized_message = r_serialized_message && cl_http_utility=>encode_x_base64( mv_binary ).
    ELSE.
      r_serialized_message = r_serialized_message && mv_text.
    ENDIF.
  ENDMETHOD.

  METHOD unescape.
    DATA lv_index TYPE i.
    DATA lv_char TYPE c LENGTH 1.
    DATA lv_escape TYPE abap_bool.
    DO strlen( iv_text ) TIMES.
      lv_index = sy-index - 1.
      lv_char = iv_text+lv_index(1).
      IF lv_escape = abap_true.
        CASE lv_char.
          WHEN 'n'.
            rv_text = rv_text && cl_abap_char_utilities=>newline.
          WHEN ':' OR '\'.
            rv_text = rv_text && lv_char.
          WHEN OTHERS.
            rv_text = rv_text && '\' && lv_char.
        ENDCASE.
        lv_escape = abap_false.
      ELSEIF lv_char = '\'.
        lv_escape = abap_true.
      ELSE.
        rv_text = rv_text && lv_char.
      ENDIF.
    ENDDO.
    IF lv_escape = abap_true.
      rv_text = rv_text && '\'.
    ENDIF.
  ENDMETHOD.

  METHOD if_ac_message_type_pcp~deserialize.
    DATA lv_lf TYPE string.
    DATA lv_separator TYPE string.
    DATA lv_offset TYPE i.
    DATA lv_body_offset TYPE i.
    DATA lv_headers TYPE string.
    DATA lv_body TYPE string.
    DATA lt_lines TYPE string_table.
    DATA lv_line TYPE string.
    DATA lv_colon TYPE i.
    DATA lv_index TYPE i.
    DATA lv_char TYPE c LENGTH 1.
    DATA lv_escape TYPE abap_bool.
    DATA lv_skip TYPE abap_bool.
    DATA lv_action TYPE abap_bool.
    DATA lv_type TYPE string.
    DATA lv_type_seen TYPE abap_bool.
    DATA lv_name TYPE string.
    DATA lv_value TYPE string.
    DATA lv_raw TYPE string.
    DATA lv_value_offset TYPE i.
    DATA ls_field TYPE if_ac_message_type_pcp=>ty_pcp_fields.
    DATA lo_message TYPE REF TO cl_ac_message_type_pcp.

    lv_lf = cl_abap_char_utilities=>newline.
    lv_separator = lv_lf && lv_lf.
    FIND FIRST OCCURRENCE OF lv_separator IN i_serialized_message MATCH OFFSET lv_offset.
    IF sy-subrc = 0.
      lv_headers = i_serialized_message(lv_offset).
      lv_body_offset = lv_offset + 2.
      lv_body = i_serialized_message+lv_body_offset.
    ELSE.
      lv_headers = i_serialized_message.
    ENDIF.
    SPLIT lv_headers AT lv_lf INTO TABLE lt_lines.
    CREATE OBJECT lo_message.
    LOOP AT lt_lines INTO lv_line.
      IF lv_skip = abap_true.
        lv_skip = abap_false.
        CONTINUE.
      ENDIF.
      lv_colon = -1.
      lv_escape = abap_false.
      DO strlen( lv_line ) TIMES.
        lv_index = sy-index - 1.
        lv_char = lv_line+lv_index(1).
        IF lv_escape = abap_true.
          lv_escape = abap_false.
        ELSEIF lv_char = '\'.
          lv_escape = abap_true.
        ELSEIF lv_char = ':'.
          lv_colon = lv_index.
          EXIT.
        ENDIF.
      ENDDO.
      IF lv_colon < 0.
        lv_skip = abap_true.
        CONTINUE.
      ENDIF.
      lv_raw = lv_line(lv_colon).
      lv_name = unescape( lv_raw ).
      lv_value_offset = lv_colon + 1.
      lv_raw = lv_line+lv_value_offset.
      lv_value = unescape( lv_raw ).
      IF lv_name = 'pcp-action'.
        lv_action = abap_true.
      ELSE.
        ls_field-name = lv_name.
        ls_field-value = lv_value.
        APPEND ls_field TO lo_message->mt_fields.
        IF lv_name = 'pcp-body-type' AND lv_type_seen = abap_false.
          lv_type = lv_value.
          lv_type_seen = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lv_action = abap_false.
      RAISE EXCEPTION TYPE cx_ac_message_type_pcp_error
        EXPORTING message = 'Push Channel Protocol message format is not correct.'.
    ENDIF.
    IF lv_type = 'binary'.
      lo_message->if_ac_message_type_pcp~set_binary( cl_http_utility=>decode_x_base64( lv_body ) ).
    ELSE.
      lo_message->if_ac_message_type_pcp~set_text( lv_body ).
    ENDIF.
    r_message = lo_message.
  ENDMETHOD.
ENDCLASS.
