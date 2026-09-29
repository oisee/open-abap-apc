INTERFACE if_amc_message_producer_binary PUBLIC.
  INTERFACES if_amc_message_producer.
  METHODS send IMPORTING i_message TYPE xstring RAISING cx_amc_error.
ENDINTERFACE.
