REPORT zabapmq_mqtt_receive.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS:
  p_topic  TYPE text100 DEFAULT 'ozan/iot2' OBLIGATORY,
  p_count  TYPE i DEFAULT 3 OBLIGATORY,
  p_timeou TYPE i DEFAULT 10 OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS:
  p_ws   TYPE c RADIOBUTTON GROUP g1 DEFAULT 'X',
  p_url  TYPE text100 DEFAULT 'ws://broker.hivemq.com:8000/mqtt' OBLIGATORY,
  p_tcp  TYPE c RADIOBUTTON GROUP g1,
  p_host TYPE text100 DEFAULT 'broker.hivemq.com' OBLIGATORY,
  p_port TYPE text100 DEFAULT '1883' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.

START-OF-SELECTION.
  PERFORM run.

FORM run RAISING cx_apc_error.

  TRY.
      CASE abap_true.
        WHEN p_ws.
          DATA(li_transport) = zcl_mqtt_transport_ws=>create_by_url( CONV #( p_url ) ).
        WHEN p_tcp.
          li_transport = zcl_mqtt_transport_tcp=>create(
            iv_host = CONV #( p_host )
            iv_port = CONV #( p_port ) ).
      ENDCASE.

      li_transport->connect( ).
      li_transport->send( NEW zcl_mqtt_packet_connect( ) ).

      DATA(lo_connack) = CAST zcl_mqtt_packet_connack( li_transport->listen( p_timeou ) ).
      WRITE: / 'CONNACK return code:'(003), lo_connack->get_return_code( ).

      li_transport->send( NEW zcl_mqtt_packet_subscribe( VALUE #( ( CONV #( p_topic ) ) ) ) ).
      DATA(lt_return_codes) = CAST zcl_mqtt_packet_suback( li_transport->listen( p_timeou ) )->get_return_codes( ).
      WRITE: / 'SUBACK return code:'(004), lt_return_codes[ 1 ].

      WRITE: /.
      DO p_count TIMES.
        DATA(ls_message) = CAST zcl_mqtt_packet_publish( li_transport->listen( p_timeou ) )->get_message( ).
        WRITE: / ls_message-topic, ls_message-message.
        WRITE: / cl_binary_convert=>xstring_utf8_to_string( ls_message-message ).
      ENDDO.

      li_transport->send( NEW zcl_mqtt_packet_disconnect( ) ).
      li_transport->disconnect( ).

    CATCH zcx_mqtt_timeout.
      WRITE: / 'timeout'.
    CATCH zcx_mqtt.
      BREAK-POINT.
  ENDTRY.

ENDFORM.
