CLASS zcl_apc_odata_probe DEFINITION PUBLIC CREATE PUBLIC.
* The shape of a Gateway entity set handler, with the database stubbed: a
* canned result of rows instead of a SELECT, then what the DPC really
* spends its time on. A read of ZSTG_DEMO through the steamgate demo does
* exactly this: turn $filter into select-options, filter the rows, map the
* fields of the DDIC structure onto the entity structure, then serialise.
* Measured to say what a JavaScript engine costs on the runtime side alone,
* with no sql.js in the way.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_row,
             travel_id   TYPE c LENGTH 8,
             description TYPE c LENGTH 40,
             status      TYPE c LENGTH 1,
             seats       TYPE i,
             price       TYPE p LENGTH 8 DECIMALS 2,
           END OF ty_row.
    TYPES tt_row TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_entity,
             travel_id   TYPE string,
             description TYPE string,
             status      TYPE string,
             status_text TYPE string,
             seats       TYPE i,
             price       TYPE string,
           END OF ty_entity.
    TYPES tt_entity TYPE STANDARD TABLE OF ty_entity WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_range,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE c LENGTH 40,
             high   TYPE c LENGTH 40,
           END OF ty_range.
    TYPES tt_range TYPE STANDARD TABLE OF ty_range WITH DEFAULT KEY.

* the canned database: iv_rows rows, built once
    CLASS-METHODS rows
      IMPORTING
        iv_rows       TYPE i
      RETURNING
        VALUE(rt_rows) TYPE tt_row.

* the select-options a $filter turns into, built here so a caller in another
* language does not have to construct ABAP types by hand
    CLASS-METHODS status_range
      IMPORTING
        iv_status        TYPE c
      RETURNING
        VALUE(rt_ranges) TYPE tt_range.

* one request: filter, map, serialise, and give back the JSON
    CLASS-METHODS get_entityset
      IMPORTING
        it_rows        TYPE tt_row
        it_status      TYPE tt_range
        iv_top         TYPE i DEFAULT 100
      RETURNING
        VALUE(rv_json) TYPE string.
ENDCLASS.

CLASS zcl_apc_odata_probe IMPLEMENTATION.

  METHOD rows.
    DATA ls_row TYPE ty_row.
    DATA lv_i   TYPE i.

    lv_i = 1.
    WHILE lv_i <= iv_rows.
      ls_row-travel_id   = |T{ lv_i }|.
      ls_row-description = |Travel number { lv_i } to somewhere|.
      CASE lv_i MOD 3.
        WHEN 0.
          ls_row-status = 'O'.
        WHEN 1.
          ls_row-status = 'A'.
        WHEN OTHERS.
          ls_row-status = 'X'.
      ENDCASE.
      ls_row-seats = lv_i MOD 40 + 1.
      ls_row-price = lv_i * '12.55'.
      APPEND ls_row TO rt_rows.
      lv_i = lv_i + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD status_range.
    DATA ls_range TYPE ty_range.

    ls_range-sign   = 'I'.
    ls_range-option = 'EQ'.
    ls_range-low    = iv_status.
    APPEND ls_range TO rt_ranges.
  ENDMETHOD.

  METHOD get_entityset.
    DATA ls_row    TYPE ty_row.
    DATA ls_range  TYPE ty_range.
    DATA ls_entity TYPE ty_entity.
    DATA lt_result TYPE tt_entity.
    DATA lv_taken  TYPE i.
    DATA lv_hit    TYPE abap_bool.
    DATA lv_json   TYPE string.

* the filter, the way a DPC applies select-options
    LOOP AT it_rows INTO ls_row.
      IF it_status IS INITIAL.
        lv_hit = abap_true.
      ELSE.
        lv_hit = abap_false.
        LOOP AT it_status INTO ls_range.
          IF ls_range-option = 'EQ' AND ls_row-status = ls_range-low.
            lv_hit = abap_true.
          ELSEIF ls_range-option = 'BT' AND ls_row-status >= ls_range-low AND ls_row-status <= ls_range-high.
            lv_hit = abap_true.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF lv_hit = abap_false.
        CONTINUE.
      ENDIF.

* the mapping the DPC does per row
      CLEAR ls_entity.
      ls_entity-travel_id   = ls_row-travel_id.
      ls_entity-description = ls_row-description.
      ls_entity-status      = ls_row-status.
      CASE ls_row-status.
        WHEN 'O'.
          ls_entity-status_text = 'Open'.
        WHEN 'A'.
          ls_entity-status_text = 'Accepted'.
        WHEN OTHERS.
          ls_entity-status_text = 'Cancelled'.
      ENDCASE.
      ls_entity-seats = ls_row-seats.
      ls_entity-price = |{ ls_row-price }|.
      APPEND ls_entity TO lt_result.

      lv_taken = lv_taken + 1.
      IF lv_taken >= iv_top.
        EXIT.
      ENDIF.
    ENDLOOP.

* and the JSON the gateway writes back
    LOOP AT lt_result INTO ls_entity.
      IF lv_json IS NOT INITIAL.
        lv_json = lv_json && ','.
      ENDIF.
      lv_json = lv_json &&
        |\{"TravelId":"{ ls_entity-travel_id }","Description":"{ ls_entity-description }",| &&
        |"Status":"{ ls_entity-status }","StatusText":"{ ls_entity-status_text }",| &&
        |"Seats":{ ls_entity-seats },"Price":"{ ls_entity-price }"\}|.
    ENDLOOP.
    rv_json = |\{"d":\{"results":[{ lv_json }]\}\}|.
  ENDMETHOD.

ENDCLASS.
