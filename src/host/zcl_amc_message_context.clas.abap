CLASS zcl_amc_message_context DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_amc_message_context.
    METHODS constructor IMPORTING iv_client TYPE sy-mandt
                                  iv_username TYPE sy-uname.
  PRIVATE SECTION.
    DATA mv_client TYPE sy-mandt.
    DATA mv_username TYPE sy-uname.
ENDCLASS.

CLASS zcl_amc_message_context IMPLEMENTATION.
  METHOD constructor.
    mv_client = iv_client.
    mv_username = iv_username.
  ENDMETHOD.
  METHOD if_amc_message_context~get_producer_client.
    rv_client = mv_client.
  ENDMETHOD.
  METHOD if_amc_message_context~get_producer_username.
    rv_username = mv_username.
  ENDMETHOD.
ENDCLASS.
