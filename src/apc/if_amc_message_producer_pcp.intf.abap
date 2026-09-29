INTERFACE if_amc_message_producer_pcp PUBLIC.
  INTERFACES if_amc_message_producer.
  METHODS send IMPORTING i_message TYPE REF TO if_ac_message_type_pcp RAISING cx_amc_error.
ENDINTERFACE.
