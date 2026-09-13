INTERFACE if_apc_wsp_reject_response PUBLIC.
* How a handler says why it refused a connection. Optional on on_accept,
* and off stack nothing reads it yet; it is here so a handler that sets it
* compiles unchanged.
  METHODS set_status
    IMPORTING
      !i_code   TYPE i
      !i_reason TYPE string OPTIONAL.
ENDINTERFACE.
