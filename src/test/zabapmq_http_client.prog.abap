REPORT zabapmq_http_client.

PARAMETERS: host TYPE text200 DEFAULT 'google.com'.

CLASS lcl_apc_handler DEFINITION
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES: if_apc_wsp_event_handler.
    DATA: m_message TYPE string.

ENDCLASS.

CLASS lcl_apc_handler IMPLEMENTATION.
  METHOD if_apc_wsp_event_handler~on_open.
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_message.
    "message handling
    TRY.
        m_message = i_message->get_text( ).
      CATCH cx_apc_error INTO DATA(lx_apc_error).
        m_message = 'foo' && lx_apc_error->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_close.
    "close handling
    m_message = 'Connection closed !'.
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_error.
    "error/close handling
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  PERFORM start.

FORM start.
  TRY.
      PERFORM run.
    CATCH cx_apc_error INTO DATA(lx_apc_error).
      MESSAGE lx_apc_error->get_text( ) TYPE 'E'.
  ENDTRY.
ENDFORM.

FORM run RAISING cx_apc_error.

  DATA: lo_client          TYPE REF TO if_apc_wsp_client,
        lo_event_handler   TYPE REF TO lcl_apc_handler,
        lo_message_manager TYPE REF TO if_apc_wsp_message_manager,
        lo_message         TYPE REF TO if_apc_wsp_message.


  CREATE OBJECT lo_event_handler.

  DATA(ls_frame) = VALUE apc_tcp_frame(
    frame_type   = if_apc_tcp_frame_types=>co_frame_type_fixed_length
    fixed_length = 1 ).

  lo_client = cl_apc_tcp_client_manager=>create(
    i_host          = CONV #( host )
    i_port          = '80'
    i_frame         = ls_frame
    i_event_handler = lo_event_handler ).

  lo_client->connect( ).

  lo_message_manager ?= lo_client->get_message_manager( ).
  lo_message         ?= lo_message_manager->create_message( ).

  DATA(lv_text) = 'GET / HTTP/1.1' && cl_abap_char_utilities=>cr_lf && cl_abap_char_utilities=>cr_lf.

  DATA(lv_hex) = cl_binary_convert=>string_to_xstring_utf8( lv_text ).

  WHILE xstrlen( lv_hex ) > 0.
    DATA(lv_single) = lv_hex(1).
    lo_message->set_binary( lv_single ).
    lo_message_manager->send( lo_message ).
    lv_hex = lv_hex+1.
  ENDWHILE.

  DATA(lv_str) = ||.
  DO 100 TIMES.
    CLEAR lo_event_handler->m_message.
    WAIT FOR PUSH CHANNELS UNTIL lo_event_handler->m_message IS NOT INITIAL UP TO 2 SECONDS.
    IF sy-subrc = 8.
      WRITE: / 'Timeout occured !'.
      EXIT.
    ELSE.
      lv_str = lv_str && lo_event_handler->m_message.
    ENDIF.
  ENDDO.
  WRITE: / lv_str.

  WRITE: / 'Done'.

ENDFORM.
