CLASS zcl_amc_producer DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_amc_message_producer_text.
    INTERFACES if_amc_message_producer_binary.
    INTERFACES if_amc_message_producer_pcp.
ENDCLASS.

CLASS zcl_amc_producer IMPLEMENTATION.
  METHOD if_amc_message_producer_text~send.
    RAISE EXCEPTION TYPE cx_amc_error.
  ENDMETHOD.
  METHOD if_amc_message_producer_binary~send.
    RAISE EXCEPTION TYPE cx_amc_error.
  ENDMETHOD.
  METHOD if_amc_message_producer_pcp~send.
    RAISE EXCEPTION TYPE cx_amc_error.
  ENDMETHOD.
ENDCLASS.
