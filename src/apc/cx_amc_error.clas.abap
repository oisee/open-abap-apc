CLASS cx_amc_error DEFINITION PUBLIC INHERITING FROM cx_static_check CREATE PUBLIC.
  PUBLIC SECTION.
    DATA reason TYPE string READ-ONLY.
    METHODS constructor IMPORTING textid LIKE textid OPTIONAL
                                  previous LIKE previous OPTIONAL
                                  iv_reason TYPE string OPTIONAL.
    METHODS get_text REDEFINITION.
ENDCLASS.

CLASS cx_amc_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( textid = textid previous = previous ).
    reason = iv_reason.
  ENDMETHOD.
  METHOD get_text.
    result = reason.
  ENDMETHOD.
ENDCLASS.
