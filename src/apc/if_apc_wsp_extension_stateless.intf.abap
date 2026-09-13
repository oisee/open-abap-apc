INTERFACE if_apc_wsp_extension_stateless PUBLIC.
* A level of the alias chain, and it exists for one reason: the name
* co_connect_mode_accept has to arrive in a subclass without a prefix, and
* it only does that if every level re-aliases it. The methods are aliased
* here too, which is how a system does it.
  INTERFACES if_apc_wsp_extension.
  INTERFACES if_apc_wsp_extension_common.

  ALIASES co_connect_mode_accept FOR if_apc_wsp_extension~co_connect_mode_accept.
  ALIASES co_connect_mode_reject FOR if_apc_wsp_extension~co_connect_mode_reject.
  ALIASES on_accept  FOR if_apc_wsp_extension~on_accept.
  ALIASES on_close   FOR if_apc_wsp_extension~on_close.
  ALIASES on_error   FOR if_apc_wsp_extension~on_error.
  ALIASES on_message FOR if_apc_wsp_extension~on_message.
  ALIASES on_start   FOR if_apc_wsp_extension~on_start.
ENDINTERFACE.
