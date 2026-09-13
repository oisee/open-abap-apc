CLASS zcl_apc_probe DEFINITION PUBLIC CREATE PUBLIC.
* The smallest ABAP that exercises what a JavaScript engine must support to
* run transpiled ABAP at all: LOOP AT becomes for await over an async
* generator, string templates, packed arithmetic (BigInt), a class with
* state. run( ) is deterministic, so an embedder can compare one string.
  PUBLIC SECTION.
    CLASS-METHODS run
      RETURNING
        VALUE(rv_result) TYPE string.
ENDCLASS.

CLASS zcl_apc_probe IMPLEMENTATION.

  METHOD run.
    TYPES: BEGIN OF ty_row,
             id    TYPE i,
             name  TYPE string,
             price TYPE p LENGTH 8 DECIMALS 2,
           END OF ty_row.
    DATA lt_rows TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row  TYPE ty_row.
    DATA lv_sum  TYPE p LENGTH 8 DECIMALS 2.
    DATA lv_names TYPE string.
    DATA lv_i    TYPE i.

    lv_i = 1.
    WHILE lv_i <= 5.
      ls_row-id    = lv_i.
      ls_row-name  = |row{ lv_i }|.
      ls_row-price = lv_i * '1.25'.
      APPEND ls_row TO lt_rows.
      lv_i = lv_i + 1.
    ENDWHILE.

* the statement the whole question is about: this is a for await over an
* async generator in the transpiled output
    LOOP AT lt_rows INTO ls_row.
      lv_sum = lv_sum + ls_row-price.
      IF lv_names IS NOT INITIAL.
        lv_names = lv_names && '-'.
      ENDIF.
      lv_names = lv_names && ls_row-name.
    ENDLOOP.

* and a loop with a condition, which the transpiler compiles the same way
    CLEAR lv_i.
    LOOP AT lt_rows INTO ls_row WHERE id > 3.
      lv_i = lv_i + ls_row-id.
    ENDLOOP.

    rv_result = |rows={ lines( lt_rows ) } sum={ lv_sum } names={ lv_names } tail={ lv_i }|.
  ENDMETHOD.

ENDCLASS.
