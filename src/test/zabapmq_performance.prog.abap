REPORT zabapmq_performance.

PARAMETERS: p_bytes TYPE i DEFAULT 10000,
            p_host  TYPE text200 DEFAULT 'google.com',
            p_port  TYPE text200 DEFAULT '1234'.

CLASS lcl_apc_handler DEFINITION
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES: if_apc_wsp_event_handler.
    DATA: mv_message TYPE string.

ENDCLASS.

CLASS lcl_apc_handler IMPLEMENTATION.
  METHOD if_apc_wsp_event_handler~on_open.
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_message.
    "message handling
    TRY.
        mv_message = i_message->get_text( ).
      CATCH cx_apc_error INTO DATA(lx_apc_error).
        mv_message = 'foo' && lx_apc_error->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_close.
    "close handling
    mv_message = 'Connection closed !'(005).
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_error.
    "error/close handling
    RETURN.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  PERFORM start.

FORM start.
  TRY.
      PERFORM run.
    CATCH cx_apc_error INTO DATA(lx_apc_error).
      MESSAGE lx_apc_error TYPE 'E'.
  ENDTRY.
ENDFORM.

FORM run RAISING cx_apc_error.

  DATA: li_message_manager TYPE REF TO if_apc_wsp_message_manager,
        li_message         TYPE REF TO if_apc_wsp_message.


  DATA(lo_event_handler) = NEW lcl_apc_handler( ).

  DATA(ls_frame) = VALUE apc_tcp_frame(
    frame_type   = if_apc_tcp_frame_types=>co_frame_type_fixed_length
    fixed_length = 1 ).

  DATA(li_client) = cl_apc_tcp_client_manager=>create(
    i_host          = CONV #( p_host )
    i_port          = CONV #( p_port )
    i_frame         = ls_frame
    i_event_handler = lo_event_handler ).

  li_client->connect( ).

  li_message_manager ?= li_client->get_message_manager( ).
  li_message         ?= li_message_manager->create_message( ).

  GET RUN TIME FIELD DATA(lv_t1).
  DO p_bytes TIMES.
    li_message->set_binary( '00' ).
    li_message_manager->send( li_message ).
  ENDDO.
  GET RUN TIME FIELD DATA(lv_t2).

  li_client->close( CONV #( 'application closed connection !'(006) ) ).

  lv_t1 = ( lv_t2 - lv_t1 ) / 1000000.
  WRITE: / lv_t1.

  WRITE: / 'Done'(007).

ENDFORM.
