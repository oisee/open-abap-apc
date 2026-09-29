CLASS cl_abap_timer_manager DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_abap_timer_manager.
    CLASS-METHODS get_timer_manager
      RETURNING VALUE(r_timer_manager) TYPE REF TO if_abap_timer_manager
      RAISING cx_abap_timer_error.
ENDCLASS.

CLASS cl_abap_timer_manager IMPLEMENTATION.
  METHOD get_timer_manager.
    RAISE EXCEPTION TYPE cx_abap_timer_error
      EXPORTING textid = cx_abap_timer_error=>session_type_not_supported
                reason = 'session_type_not_supported'.
  ENDMETHOD.

  METHOD if_abap_timer_manager~start_timer.
    RAISE EXCEPTION TYPE cx_abap_timer_error
      EXPORTING textid = cx_abap_timer_error=>session_type_not_supported
                reason = 'session_type_not_supported'.
  ENDMETHOD.

  METHOD if_abap_timer_manager~stop_timer.
    RAISE EXCEPTION TYPE cx_abap_timer_error
      EXPORTING textid = cx_abap_timer_error=>session_type_not_supported
                reason = 'session_type_not_supported'.
  ENDMETHOD.
ENDCLASS.
