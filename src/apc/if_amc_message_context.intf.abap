INTERFACE if_amc_message_context PUBLIC.
  METHODS get_producer_client RETURNING VALUE(rv_client) TYPE sy-mandt.
  METHODS get_producer_username RETURNING VALUE(rv_username) TYPE sy-uname.
ENDINTERFACE.
