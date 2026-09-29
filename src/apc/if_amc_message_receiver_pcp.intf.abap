INTERFACE if_amc_message_receiver_pcp PUBLIC.
  METHODS receive IMPORTING i_message TYPE REF TO if_ac_message_type_pcp
                            i_context TYPE REF TO if_amc_message_context.
ENDINTERFACE.
