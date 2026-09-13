CLASS cx_apc_error DEFINITION PUBLIC INHERITING FROM cx_static_check CREATE PUBLIC.
* What every APC call raises. It inherits cx_static_check, which is what
* makes a handler's TRY/CATCH obligatory rather than optional, and it
* carries the ten fields a system puts on it so a handler that reads
* error_code or channel_id compiles unchanged.
*
* The textids are SOTR concepts, which are identifiers of texts in a table
* nobody has here. The fifteen a handler is most likely to catch by name
* are below with the values a system has, read off one; the other thirty-odd
* are not, because a name without its value is no use to a CATCH and an
* invented value would be worse than an absent one.
*
* Note co_message_type_text and co_message_type_binary: STRING here, and
* integers 1 and 2 on if_apc_wsp_message. Same names, different types,
* different places, and they must not be unified.
  PUBLIC SECTION.
    CONSTANTS cx_apc_error TYPE sotr_conc VALUE 'E41F13F734061ED5B98882F2F8178DC6' ##NO_TEXT.
    CONSTANTS send_error TYPE sotr_conc VALUE 'E61F13F7B4071ED29F8518B7D0009F78' ##NO_TEXT.
    CONSTANTS receive_error TYPE sotr_conc VALUE 'E61F13F7B4071ED29F85100F061A1F10' ##NO_TEXT.
    CONSTANTS protocol_error TYPE sotr_conc VALUE 'E41F13F734041ED398CEB71C82C4DD19' ##NO_TEXT.
    CONSTANTS message_size_exceeded TYPE sotr_conc VALUE 'E61F13F7B4071EE4BFA8DA5739CB814C' ##NO_TEXT.
    CONSTANTS message_type_is_not_supported TYPE sotr_conc VALUE '005056A207C81ED29DBFBDE008A786FC' ##NO_TEXT.
    CONSTANTS access_apc_ws_message_failed TYPE sotr_conc VALUE '005056B400AC1ED1BDBAE8F248CCCA7D' ##NO_TEXT.
    CONSTANTS request_field_access_failed TYPE sotr_conc VALUE 'E61F13F7B4071ED28DA8950C81A85867' ##NO_TEXT.
    CONSTANTS connection_is_not_established TYPE sotr_conc VALUE 'E41F13F734061ED4BBC880043C484D01' ##NO_TEXT.
    CONSTANTS method_call_is_not_supported TYPE sotr_conc VALUE '005056B400AC1EE1BDCE7F01FAEA0D22' ##NO_TEXT.
    CONSTANTS apc_application_not_available TYPE sotr_conc VALUE 'E41F13F734061EE4AADD8222BDF3CA75' ##NO_TEXT.
    CONSTANTS apc_application_is_stateful TYPE sotr_conc VALUE 'E41F13F734061EE4AADD8BB4D50ECAC3' ##NO_TEXT.
    CONSTANTS invalid_parameter_value TYPE sotr_conc VALUE 'E61F13F7B4071EE29DD6352E2A4BD12D' ##NO_TEXT.
    CONSTANTS internal_processing_error TYPE sotr_conc VALUE 'E61F13F7B4071EE580EDD56A1BDED1D2' ##NO_TEXT.

    CONSTANTS co_message_type_text TYPE string VALUE 'TEXT' ##NO_TEXT.
    CONSTANTS co_message_type_binary TYPE string VALUE 'BINARY' ##NO_TEXT.

    DATA error_code TYPE i.
    DATA error_text TYPE string.
    DATA connection_state TYPE i.
    DATA wsp_protocol_type_id TYPE string.
    DATA wsp_protocol_application_id TYPE string.
    DATA wsp_event_handler_type TYPE string.
    DATA application_id TYPE if_abap_channel_types=>ty_amc_application_id.
    DATA channel_id TYPE if_abap_channel_types=>ty_amc_channel_id.
    DATA channel_ext_id TYPE if_abap_channel_types=>ty_amc_channel_extension_id.
    DATA method_name TYPE string.

    METHODS constructor
      IMPORTING
        !textid   LIKE textid OPTIONAL
        !previous LIKE previous OPTIONAL
        !error_code TYPE i OPTIONAL
        !error_text TYPE string OPTIONAL
        !connection_state TYPE i OPTIONAL
        !wsp_protocol_type_id TYPE string OPTIONAL
        !wsp_protocol_application_id TYPE string OPTIONAL
        !wsp_event_handler_type TYPE string OPTIONAL
        !application_id TYPE if_abap_channel_types=>ty_amc_application_id OPTIONAL
        !channel_id TYPE if_abap_channel_types=>ty_amc_channel_id OPTIONAL
        !channel_ext_id TYPE if_abap_channel_types=>ty_amc_channel_extension_id OPTIONAL
        !method_name TYPE string OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS cx_apc_error IMPLEMENTATION.

  METHOD constructor.
    super->constructor( textid = textid previous = previous ).
    me->error_code = error_code.
    me->error_text = error_text.
    me->connection_state = connection_state.
    me->wsp_protocol_type_id = wsp_protocol_type_id.
    me->wsp_protocol_application_id = wsp_protocol_application_id.
    me->wsp_event_handler_type = wsp_event_handler_type.
    me->application_id = application_id.
    me->channel_id = channel_id.
    me->channel_ext_id = channel_ext_id.
    me->method_name = method_name.
*   a system defaults the textid to its own name when none was given
    IF textid IS INITIAL.
      me->textid = cx_apc_error.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
