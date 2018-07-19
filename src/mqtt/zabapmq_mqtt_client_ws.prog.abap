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
    li_message->set_binary( NEW zcl_mqtt_packet_connect( )->encode( )->get_hex( ) ).
    li_msgmgr->send( li_message ).

    CLEAR lo_handler->message.
    WAIT FOR PUSH CHANNELS UNTIL lo_handler->message IS NOT INITIAL UP TO 1 SECONDS.
    IF sy-subrc = 0.
      WRITE: / lo_handler->message.
    ELSE.
      WRITE: / 'error, subrc,', sy-subrc.
    ENDIF.

  ENDMETHOD.

  METHOD receive_byte.

  ENDMETHOD.

  METHOD receive.

  ENDMETHOD.

  METHOD send.

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
