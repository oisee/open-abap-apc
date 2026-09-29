CLASS cx_abap_timer_error DEFINITION PUBLIC INHERITING FROM cx_static_check CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS session_type_not_supported TYPE sotr_conc VALUE 'FA163EF834D71ED797B29E59351ECEC3' ##NO_TEXT.
    CONSTANTS timer_already_active TYPE sotr_conc VALUE 'E41F13F734061ED6B798B8186ED95C58' ##NO_TEXT.
    CONSTANTS timer_object_not_active TYPE sotr_conc VALUE 'E41F13F734061ED6B798B9E3B3ECDC58' ##NO_TEXT.
    METHODS constructor IMPORTING textid LIKE textid OPTIONAL
                                  previous LIKE previous OPTIONAL.
    METHODS get_text REDEFINITION.
ENDCLASS.

CLASS cx_abap_timer_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( textid = textid previous = previous ).
    IF textid IS NOT INITIAL.
      me->textid = textid.
    ENDIF.
  ENDMETHOD.

  METHOD get_text.
    CASE me->textid.
      WHEN session_type_not_supported.
        result = 'Session type is not supported.'.
      WHEN timer_already_active.
        result = 'Timer object is already active.'.
      WHEN timer_object_not_active.
        result = 'Timer object is not active.'.
      WHEN OTHERS.
        result = super->get_text( ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
