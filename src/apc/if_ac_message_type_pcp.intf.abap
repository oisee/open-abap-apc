INTERFACE if_ac_message_type_pcp PUBLIC.
  TYPES: BEGIN OF ty_pcp_fields,
           name TYPE string,
           value TYPE string,
         END OF ty_pcp_fields,
         tt_pcp_fields TYPE STANDARD TABLE OF ty_pcp_fields.
  CLASS-METHODS deserialize
    IMPORTING i_serialized_message TYPE string
    RETURNING VALUE(r_message) TYPE REF TO if_ac_message_type_pcp
    RAISING cx_ac_message_type_pcp_error.
  METHODS set_field IMPORTING i_name TYPE string i_value TYPE string
    RAISING cx_ac_message_type_pcp_error.
  METHODS get_field IMPORTING i_name TYPE string EXPORTING e_exists TYPE abap_bool
    RETURNING VALUE(r_value) TYPE string RAISING cx_ac_message_type_pcp_error.
  METHODS get_fields CHANGING VALUE(c_fields) TYPE tt_pcp_fields
    RAISING cx_ac_message_type_pcp_error.
  METHODS delete_field IMPORTING i_name TYPE string RAISING cx_ac_message_type_pcp_error.
  METHODS set_text IMPORTING i_message TYPE string RAISING cx_ac_message_type_pcp_error.
  METHODS set_binary IMPORTING i_message TYPE xstring RAISING cx_ac_message_type_pcp_error.
  METHODS get_text RETURNING VALUE(r_message) TYPE string RAISING cx_ac_message_type_pcp_error.
  METHODS get_binary RETURNING VALUE(r_message) TYPE xstring RAISING cx_ac_message_type_pcp_error.
  METHODS serialize RETURNING VALUE(r_serialized_message) TYPE string
    RAISING cx_ac_message_type_pcp_error.
ENDINTERFACE.
