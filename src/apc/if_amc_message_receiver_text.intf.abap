INTERFACE if_amc_message_receiver_text PUBLIC.
  METHODS receive IMPORTING i_message TYPE string
                            i_context TYPE REF TO if_amc_message_context.
ENDINTERFACE.
