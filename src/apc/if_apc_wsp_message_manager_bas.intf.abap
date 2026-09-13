INTERFACE if_apc_wsp_message_manager_bas PUBLIC.
* Empty on a system, and that is the whole content: a marker the message
* manager includes and nothing else. It is here so the inclusion below is
* the real one, and it is worth saying out loud that SAP has no shape for
* buffering what a handler sent. zcl_apc_host's drain( ) is ours, because
* a host that is not the ICM has nowhere to push to, and it is deliberately
* not hung off this interface.
ENDINTERFACE.
