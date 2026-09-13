INTERFACE if_apc_wsp_initial_request PUBLIC.
* An alias shell over if_apc_ws_initial_request, which is where the methods
* are declared. The shell is what handlers are typed with.
  INTERFACES if_apc_ws_initial_request.

  ALIASES co_formfield_encoding_raw FOR if_apc_ws_initial_request~co_formfield_encoding_raw.
  ALIASES co_formfield_encoding_encoded FOR if_apc_ws_initial_request~co_formfield_encoding_encoded.
  ALIASES get_form_field FOR if_apc_ws_initial_request~get_form_field.
  ALIASES get_form_field_cs FOR if_apc_ws_initial_request~get_form_field_cs.
  ALIASES get_form_fields FOR if_apc_ws_initial_request~get_form_fields.
  ALIASES get_header_field FOR if_apc_ws_initial_request~get_header_field.
  ALIASES get_header_fields FOR if_apc_ws_initial_request~get_header_fields.
  ALIASES get_cookie FOR if_apc_ws_initial_request~get_cookie.
  ALIASES get_cookies FOR if_apc_ws_initial_request~get_cookies.
ENDINTERFACE.
