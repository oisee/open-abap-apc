CLASS cl_amc_channel_manager DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS co_comm_type_synchronous TYPE i VALUE 1.
    CONSTANTS co_comm_type_asynchronous TYPE i VALUE 2.
    CLASS-METHODS create_message_producer
      IMPORTING i_application_id TYPE if_abap_channel_types=>ty_amc_application_id
                i_channel_id TYPE if_abap_channel_types=>ty_amc_channel_id
                i_channel_extension_id TYPE if_abap_channel_types=>ty_amc_channel_extension_id OPTIONAL
                i_communication_type TYPE i DEFAULT co_comm_type_asynchronous
                i_suppress_echo TYPE abap_bool DEFAULT abap_false
                i_channel_filter TYPE if_abap_channel_types=>ty_amc_channel_filter OPTIONAL
      RETURNING VALUE(r_producer) TYPE REF TO if_amc_message_producer
      RAISING cx_amc_error.
    CLASS-METHODS create_message_consumer
      IMPORTING i_application_id TYPE if_abap_channel_types=>ty_amc_application_id
                i_channel_id TYPE if_abap_channel_types=>ty_amc_channel_id
                i_channel_extension_id TYPE if_abap_channel_types=>ty_amc_channel_extension_id OPTIONAL
                i_channel_filter TYPE if_abap_channel_types=>ty_amc_channel_filter OPTIONAL
      RETURNING VALUE(r_consumer) TYPE REF TO if_amc_message_consumer
      RAISING cx_amc_error.
    CLASS-METHODS get_consumer_session_id
      RETURNING VALUE(r_session_id) TYPE if_abap_channel_types=>ty_amc_consumer_session_id
      RAISING cx_amc_error.
ENDCLASS.

CLASS cl_amc_channel_manager IMPLEMENTATION.
  METHOD create_message_producer.
    RAISE EXCEPTION TYPE cx_amc_error.
  ENDMETHOD.
  METHOD create_message_consumer.
    RAISE EXCEPTION TYPE cx_amc_error.
  ENDMETHOD.
  METHOD get_consumer_session_id.
    CLEAR r_session_id.
  ENDMETHOD.
ENDCLASS.
