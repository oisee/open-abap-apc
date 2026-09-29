INTERFACE if_amc_message_consumer PUBLIC.
  METHODS start_message_delivery IMPORTING i_receiver TYPE REF TO object RAISING cx_amc_error.
  METHODS stop_message_delivery RAISING cx_amc_error.
ENDINTERFACE.
