CLASS cx_ac_message_type_pcp_error DEFINITION PUBLIC INHERITING FROM cx_static_check CREATE PUBLIC.
  PUBLIC SECTION.
    DATA message TYPE string.
    METHODS constructor IMPORTING textid LIKE textid OPTIONAL
      previous LIKE previous OPTIONAL message TYPE string OPTIONAL.
ENDCLASS.

CLASS cx_ac_message_type_pcp_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( textid = textid previous = previous ).
    me->message = message.
  ENDMETHOD.
ENDCLASS.
