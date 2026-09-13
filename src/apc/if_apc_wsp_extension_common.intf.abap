INTERFACE if_apc_wsp_extension_common PUBLIC.
* Where the connect modes really live, read off a system rather than
* guessed: the constants are on this interface and every level above
* re-aliases them, which is what lets a handler write
* "e_connect_mode = co_connect_mode_accept" with no prefix at all.
  CONSTANTS co_connect_mode_accept TYPE i VALUE 1.
  CONSTANTS co_connect_mode_reject TYPE i VALUE 2.
ENDINTERFACE.
