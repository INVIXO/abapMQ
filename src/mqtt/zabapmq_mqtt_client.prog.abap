REPORT zabapmq_mqtt_client.

PARAMETERS: message TYPE string LOWER CASE DEFAULT 'foobar'.


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
    frame_type   = if_apc_tcp_frame_types=>co_frame_type_length_field
    fixed_length = 1 ).

  lo_client = cl_apc_tcp_client_manager=>create(
    i_host          = 'broker.hivemq.com'
    i_port          = '1883'
    i_frame         = ls_frame
    i_event_handler = lo_event_handler ).

  lo_client->connect( ).

*  "create message manager and message object for sending the message
*  lo_message_manager ?= lo_client->get_message_manager( ).
*  lo_message         ?= lo_message_manager->create_message( ).
*
*  DATA(lv_binary_message) = cl_abap_codepage=>convert_to( message ).
*  CONCATENATE lv_binary_message lc_terminator INTO lv_binary_message IN BYTE MODE.
*  lo_message->set_binary( '00' ). "lv_binary_message ).
*  lo_message_manager->send( lo_message ).
*
*  DO 40 TIMES.
*    CLEAR lo_event_handler->m_message.
*    WAIT FOR PUSH CHANNELS UNTIL lo_event_handler->m_message IS NOT INITIAL UP TO 2 SECONDS.
*    IF sy-subrc = 8.
*      WRITE: / 'Timeout occured !'.
*      EXIT.
*    ELSE.
*      WRITE: / 'Received message:', lo_event_handler->m_message.
*    ENDIF.
*  ENDDO.

  lo_client->close( 'application closed connection !' ).

  WRITE: / 'Done'.

ENDFORM.
