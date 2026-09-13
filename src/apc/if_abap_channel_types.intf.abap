INTERFACE if_abap_channel_types PUBLIC.
* The types the APC and AMC interfaces are declared with. A system types
* them through DDIC data elements; off stack the elements do not exist, so
* each one carries the width the element really has, read off a system
* (DD04L) rather than guessed:
*
*   APC_CONNECTION_ID             CHAR 32
*   APC_CONNECTION_ATTACH_HANDLE  SSTR 255, a short string
*   APC_APPLICATION_ID            CHAR 30
*   APC_WSP_PROTOCOL_TYPE_ID      CHAR 30
*   AMC_APPLICATION_ID            CHAR 30
*   AMC_CHANNEL_ID                SSTR 140
*   AMC_CHANNEL_EXTENSION_ID      CHAR 60
*   AMC_CONSUMER_SESSION_ID       SSTR 255
*
* Left out on purpose, because nobody has read them and a plausible shape
* is worse than an absent one: ty_apc_tcp_frame, ty_vscan_profile,
* ty_ssfapplssl, ty_apc_proxy, ty_apc_connect_options, ty_seoclsname,
* ty_amc_channel_filter. A handler that uses one will not compile here, and
* that is the honest answer until it is read.
  TYPES ty_ihttpnvp TYPE ihttpnvp.
  TYPES ty_tihttpnvp TYPE STANDARD TABLE OF ty_ihttpnvp WITH DEFAULT KEY.

* the cookie structure of a system, whose domain field is called xdomain
  TYPES: BEGIN OF ty_ihttpcki,
           name    TYPE string,
           value   TYPE string,
           xdomain TYPE string,
           path    TYPE string,
           secure  TYPE i,
           expires TYPE string,
         END OF ty_ihttpcki.
  TYPES ty_tihttpcki TYPE STANDARD TABLE OF ty_ihttpcki WITH DEFAULT KEY.

  TYPES ty_apc_application_id TYPE c LENGTH 30.
  TYPES ty_apc_wsp_protocol_type_id TYPE c LENGTH 30.
  TYPES ty_apc_connection_id TYPE c LENGTH 32.
  TYPES ty_apc_conn_attach_handle TYPE string.

  TYPES ty_amc_application_id TYPE c LENGTH 30.
  TYPES ty_amc_channel_id TYPE string.
  TYPES ty_amc_channel_extension_id TYPE c LENGTH 60.
  TYPES ty_amc_consumer_session_id TYPE string.
ENDINTERFACE.
