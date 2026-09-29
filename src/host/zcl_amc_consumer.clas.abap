CLASS zcl_amc_consumer DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_amc_message_consumer.
ENDCLASS.

CLASS zcl_amc_consumer IMPLEMENTATION.
  METHOD if_amc_message_consumer~start_message_delivery.
    RAISE EXCEPTION TYPE cx_amc_error.
  ENDMETHOD.
  METHOD if_amc_message_consumer~stop_message_delivery.
    RAISE EXCEPTION TYPE cx_amc_error.
  ENDMETHOD.
ENDCLASS.
