INTERFACE if_amc_message_receiver_binary PUBLIC.
  METHODS receive IMPORTING i_message TYPE xstring
                            i_context TYPE REF TO if_amc_message_context.
ENDINTERFACE.
