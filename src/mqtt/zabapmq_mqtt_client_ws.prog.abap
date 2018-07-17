REPORT zabapmq_mqtt_client_ws.


CLASS lcl_apc_handler DEFINITION
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_apc_wsp_event_handler.
    DATA       message TYPE string.
ENDCLASS.

CLASS lcl_apc_handler IMPLEMENTATION.

  METHOD if_apc_wsp_event_handler~on_open.
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_message.
    TRY.
        me->message = i_message->get_binary( ).
      CATCH cx_apc_error INTO DATA(apc_error).
        me->message = apc_error->get_text( ).
      CATCH cx_ac_message_type_pcp_error INTO DATA(pcp_error).
        cl_demo_output=>display( pcp_error->get_text( ) ).
        LEAVE PROGRAM.
    ENDTRY.
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_close.
    me->message = 'Connection closed!'.
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_error.
    WRITE: / 'error'.
    LEAVE PROGRAM.

  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.
  PERFORM start.


CLASS lcl_test DEFINITION.

  PUBLIC SECTION.
    METHODS:
      run
        RAISING
          cx_apc_error,
      receive_byte
        RETURNING
          VALUE(rv_byte) TYPE string,
      receive,
      send
        IMPORTING
          ii_packet TYPE REF TO zif_mqtt_packet
        RAISING
          cx_apc_error.

    DATA: mo_message_manager TYPE REF TO if_apc_wsp_message_manager,
          mo_event_handler   TYPE REF TO lcl_apc_handler,
          mo_message         TYPE REF TO if_apc_wsp_message.

ENDCLASS.

CLASS lcl_test IMPLEMENTATION.

  METHOD run.

    DATA(lo_handler) = NEW lcl_apc_handler( ).

    DATA(client) = cl_apc_wsp_client_manager=>create_by_url(
      i_url           = 'ws://broker.hivemq.com:8000/mqtt'
      i_protocol      = if_apc_wsp_event_handler=>co_event_handler_type
      i_event_handler = lo_handler ).

    client->connect( ).

    DATA: li_msgmgr TYPE REF TO if_apc_wsp_message_manager.
    li_msgmgr ?= client->get_message_manager( ).

    DATA(li_message) = li_msgmgr->create_message( ).
    li_message->set_binary( NEW zcl_mqtt_connect( )->encode( )->get_hex( ) ).
    li_msgmgr->send( li_message ).

    CLEAR lo_handler->message.
    WAIT FOR PUSH CHANNELS UNTIL lo_handler->message IS NOT INITIAL UP TO 1 SECONDS.
    IF sy-subrc = 0.
      WRITE: / lo_handler->message.
    ELSE.
      WRITE: / 'error, subrc,', sy-subrc.
    ENDIF.

*    DATA: lo_client TYPE REF TO if_apc_wsp_client.
*
*
*    CREATE OBJECT mo_event_handler.
*
*    DATA(ls_frame) = VALUE apc_tcp_frame(
*      frame_type   = if_apc_tcp_frame_types=>co_frame_type_fixed_length
*      fixed_length = 1 ).
*
*    lo_client = cl_apc_tcp_client_manager=>create(
*      i_host          = 'broker.hivemq.com'
*      i_port          = '1883'
*      i_frame         = ls_frame
*      i_event_handler = mo_event_handler ).
*
*    lo_client->connect( ).
*
*    mo_message_manager ?= lo_client->get_message_manager( ).
*    mo_message         ?= mo_message_manager->create_message( ).
*
*    WRITE: /, / 'Send CONNECT'.
*    send( NEW zcl_mqtt_connect( ) ).
*    receive( ).
*
*    WRITE: /, / 'Send PINGREQ'.
*    send( NEW zcl_mqtt_pingreq( ) ).
*    receive( ).
*
*    WRITE: /, / 'Send SUBSCRIBE'.
*    send( NEW zcl_mqtt_subscribe( )->set_topics( VALUE #( ( |ozan/iot2| ) ) ) ).
*    receive( ).
*
*    WRITE: /, / 'Setup done'.
*
*    DO 5 TIMES.
*      receive( ).
*    ENDDO.
*
*    WRITE: /.
*
*    lo_client->close( ).

  ENDMETHOD.

  METHOD receive_byte.

*    CLEAR mo_event_handler->m_message.
*    WAIT FOR PUSH CHANNELS UNTIL mo_event_handler->m_message IS NOT INITIAL UP TO 2 SECONDS.
*    IF sy-subrc = 8.
*      WRITE: / 'Timeout occured !'.
*    ELSE.
*      rv_byte = mo_event_handler->m_message.
*    ENDIF.

  ENDMETHOD.

  METHOD receive.

*    DATA: lv_hex    TYPE x LENGTH 1,
*          lo_stream TYPE REF TO zcl_abapmq_mqtt_stream,
*          lv_type   TYPE i,
*          lv_length TYPE i.
*
*
*    lo_stream = NEW #( ).
*
*    DATA(lv_data) = receive_byte( ).
*    lv_hex = lv_data.
*    lo_stream->add_hex( lv_hex ).
*    lv_type = lv_hex / 16.
*
*    lv_data = receive_byte( ). " todo, this is wrong
*    lv_hex = lv_data.
*    lo_stream->add_hex( lv_hex ).
*    lv_length = lv_hex.
*
*    DO lv_length TIMES.
*      lv_data = receive_byte( ).
*      lo_stream->add_hex( CONV xstring( lv_data ) ).
*    ENDDO.
*
*    CASE lv_type.
*      WHEN 2.
*        WRITE: / 'Received CONNACK'.
*      WHEN 3.
*        WRITE: / 'Received PUBLISH'.
*        WRITE: / 'Payload:', lo_stream->get_hex( ).
*        DATA(lo_publish) = NEW zcl_mqtt_publish( ).
*        lo_publish->decode( lo_stream ).
*        WRITE: / cl_binary_convert=>xstring_utf8_to_string( lo_publish->get_message( )-message ).
*      WHEN 9 .
*        WRITE: / 'Received SUBACK'.
*      WHEN 13.
*        WRITE: / 'Received PINGRESP'.
*      WHEN OTHERS.
*        WRITE: / 'Unknown packet', lv_type.
*    ENDCASE.

  ENDMETHOD.

  METHOD send.

*    DATA(lv_hex) = ii_packet->encode( )->get_hex( ).
*    WHILE xstrlen( lv_hex ) > 0.
*      DATA(lv_single) = lv_hex(1).
*      mo_message->set_binary( lv_single ).
*      mo_message_manager->send( mo_message ).
*      lv_hex = lv_hex+1.
*    ENDWHILE.

  ENDMETHOD.

ENDCLASS.

FORM start.
  TRY.
      NEW lcl_test( )->run( ).
      WRITE / 'Done'.
    CATCH cx_apc_error INTO DATA(lx_apc_error).
      MESSAGE lx_apc_error->get_text( ) TYPE 'E'.
  ENDTRY.
ENDFORM.
