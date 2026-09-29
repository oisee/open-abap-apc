CLASS ltcl_amc_unavailable DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS producer_without_host FOR TESTING.
    METHODS consumer_without_host FOR TESTING.
ENDCLASS.

CLASS ltcl_amc_unavailable IMPLEMENTATION.
  METHOD producer_without_host.
    DATA lo_error TYPE REF TO cx_amc_error.
    TRY.
        cl_amc_channel_manager=>create_message_producer(
          i_application_id = 'MISSING' i_channel_id = '/missing' ).
        cl_abap_unit_assert=>fail( 'Producer was created without an AMC host' ).
      CATCH cx_amc_error INTO lo_error.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->get_text( ) exp = 'AMC is not available in this host.' ).
    ENDTRY.
  ENDMETHOD.

  METHOD consumer_without_host.
    DATA lo_error TYPE REF TO cx_amc_error.
    TRY.
        cl_amc_channel_manager=>create_message_consumer(
          i_application_id = 'MISSING' i_channel_id = '/missing' ).
        cl_abap_unit_assert=>fail( 'Consumer was created without an AMC host' ).
      CATCH cx_amc_error INTO lo_error.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->get_text( ) exp = 'AMC is not available in this host.' ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
