INTERFACE if_apc_ws_binding_manager PUBLIC.
* Binding a websocket connection to an AMC channel, so a message published
* on the channel reaches the client. Nothing off stack publishes yet; the
* interface is here so a handler that binds compiles.
*
* The local type aliases are a system's: this interface declares its own
* rather than using if_abap_channel_types, so the names differ while the
* underlying elements are the same.
  TYPES ty_amc_appl_id TYPE if_abap_channel_types=>ty_amc_application_id.
  TYPES ty_amc_channel_id TYPE if_abap_channel_types=>ty_amc_channel_id.
  TYPES ty_amc_channel_ext_id TYPE if_abap_channel_types=>ty_amc_channel_extension_id.

  METHODS bind_amc_message_consumer
    IMPORTING
      !i_application_id       TYPE ty_amc_appl_id
      !i_channel_id           TYPE ty_amc_channel_id
      !i_channel_extension_id TYPE ty_amc_channel_ext_id OPTIONAL
    RAISING cx_apc_error.

  METHODS unbind_amc_message_consumer
    IMPORTING
      !i_application_id       TYPE ty_amc_appl_id
      !i_channel_id           TYPE ty_amc_channel_id
      !i_channel_extension_id TYPE ty_amc_channel_ext_id OPTIONAL
    RAISING cx_apc_error.
ENDINTERFACE.
