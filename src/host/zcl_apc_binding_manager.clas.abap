CLASS zcl_apc_binding_manager DEFINITION PUBLIC CREATE PUBLIC.
* AMC binding: on a system this subscribes the connection to a message
* channel so other sessions can push into it. Nothing subscribes here yet;
* the call is remembered so a handler that binds still runs.
  PUBLIC SECTION.
    INTERFACES if_apc_wsp_binding_manager.

    TYPES: BEGIN OF ty_binding,
             application_id TYPE string,
             channel_id     TYPE string,
             extension_id   TYPE string,
           END OF ty_binding.
    TYPES tt_binding TYPE STANDARD TABLE OF ty_binding WITH DEFAULT KEY.

    METHODS bindings
      RETURNING
        VALUE(rt_bindings) TYPE tt_binding.
  PRIVATE SECTION.
    DATA mt_bindings TYPE tt_binding.
ENDCLASS.

CLASS zcl_apc_binding_manager IMPLEMENTATION.

  METHOD if_apc_ws_binding_manager~bind_amc_message_consumer.
    DATA ls_binding TYPE ty_binding.
    ls_binding-application_id = i_application_id.
    ls_binding-channel_id     = i_channel_id.
    ls_binding-extension_id   = i_channel_extension_id.
    APPEND ls_binding TO mt_bindings.
  ENDMETHOD.

  METHOD if_apc_ws_binding_manager~unbind_amc_message_consumer.
    DELETE mt_bindings WHERE application_id = i_application_id
                         AND channel_id     = i_channel_id
                         AND extension_id   = i_channel_extension_id.
  ENDMETHOD.

  METHOD bindings.
    rt_bindings = mt_bindings.
  ENDMETHOD.

ENDCLASS.
