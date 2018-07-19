class ZCL_MQTT_TRANSPORT_WS definition
  public
  create protected .

public section.

  interfaces ZIF_MQTT_TRANSPORT .
  interfaces IF_APC_WSP_EVENT_HANDLER .
  interfaces IF_APC_WSP_EVENT_HANDLER_BASE .

  class-methods CREATE_BY_URL
    importing
      !IV_URL type STRING
    returning
      value(RI_TRANSPORT) type ref to ZIF_MQTT_TRANSPORT .
PROTECTED SECTION.

  DATA mi_client TYPE REF TO if_apc_wsp_client .

  DATA: BEGIN OF ms_message,
          received TYPE abap_bool,
          message  TYPE xstring,
        END OF ms_message.
private section.
ENDCLASS.



CLASS ZCL_MQTT_TRANSPORT_WS IMPLEMENTATION.


  METHOD create_by_url.

    DATA(lo_ws) = NEW zcl_mqtt_transport_ws( ).

    lo_ws->mi_client = cl_apc_wsp_client_manager=>create_by_url(
      i_url           = iv_url
      i_protocol      = if_apc_wsp_event_handler=>co_event_handler_type
      i_event_handler = lo_ws ).

    ri_transport ?= lo_ws.

  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_close.

* todo?

  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_error.

* todo?

  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_message.

    ms_message-received = abap_true.
    ms_message-message = i_message->get_binary( ).

  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_open.

* todo?

  ENDMETHOD.


  METHOD zif_mqtt_transport~connect.

    mi_client->connect( ).

  ENDMETHOD.


  METHOD zif_mqtt_transport~disconnect.

    mi_client->close( ).

  ENDMETHOD.


  METHOD zif_mqtt_transport~listen.

    CLEAR ms_message.
    WAIT FOR PUSH CHANNELS UNTIL ms_message IS NOT INITIAL UP TO iv_timeout SECONDS.
    IF sy-subrc = 0.
      ri_packet = NEW zcl_mqtt_stream( ms_message-message )->eat_packet( ).
    ELSE.
      RAISE EXCEPTION TYPE zcx_mqtt_timeout.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqtt_transport~send.

    DATA: li_msgmgr TYPE REF TO if_apc_wsp_message_manager.

    li_msgmgr ?= mi_client->get_message_manager( ).

    DATA(li_message) = li_msgmgr->create_message( ).
    li_message->set_binary( ii_packet->encode( )->get_hex( ) ).
    li_msgmgr->send( li_message ).

  ENDMETHOD.
ENDCLASS.
