CLASS cx_abap_timer_error DEFINITION PUBLIC INHERITING FROM cx_static_check CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS session_type_not_supported TYPE sotr_conc VALUE 'SESSION_TYPE_NOT_SUPPORTED' ##NO_TEXT.
    DATA reason TYPE string READ-ONLY.
    METHODS constructor IMPORTING textid LIKE textid OPTIONAL
                                  previous LIKE previous OPTIONAL
                                  reason TYPE string OPTIONAL.
    METHODS get_text REDEFINITION.
ENDCLASS.

CLASS cx_abap_timer_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( textid = textid previous = previous ).
    me->reason = reason.
    IF textid IS NOT INITIAL.
      me->textid = textid.
    ENDIF.
  ENDMETHOD.

  METHOD get_text.
    result = reason.
  ENDMETHOD.
ENDCLASS.
