INTERFACE if_abap_timer_manager PUBLIC.
  METHODS start_timer
    IMPORTING i_timer_handler TYPE REF TO if_abap_timer_handler
              i_timeout TYPE i
    RAISING cx_abap_timer_error.
  METHODS stop_timer
    IMPORTING i_timer_handler TYPE REF TO if_abap_timer_handler
    RAISING cx_abap_timer_error.
ENDINTERFACE.
