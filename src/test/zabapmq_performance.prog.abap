REPORT zabapmq_performance.

PARAMETERS: bytes TYPE i DEFAULT 10000,
            host  TYPE text200 DEFAULT 'google.com',
            port  TYPE text200 DEFAULT '1234'.

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
    i_port          = CONV #( port )
    i_frame         = ls_frame
    i_event_handler = lo_event_handler ).

  lo_client->connect( ).

  lo_message_manager ?= lo_client->get_message_manager( ).
  lo_message         ?= lo_message_manager->create_message( ).

  GET RUN TIME FIELD DATA(t1).
  DO bytes TIMES.
    lo_message->set_binary( '00' ).
    lo_message_manager->send( lo_message ).
  ENDDO.
  GET RUN TIME FIELD DATA(t2).

  lo_client->close( 'application closed connection !' ).

  t1 = ( t2 - t1 ) / 1000000.
  WRITE: / t1.

  WRITE: / 'Done'.

ENDFORM.
