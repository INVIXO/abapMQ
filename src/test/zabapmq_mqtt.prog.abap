REPORT zabapmq_mqtt.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-005.
PARAMETERS:
  p_rec TYPE c RADIOBUTTON GROUP func DEFAULT 'X',
  p_pub TYPE c RADIOBUTTON GROUP func.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS:
  p_timeou TYPE i DEFAULT 10 OBLIGATORY,
  p_ws     TYPE c RADIOBUTTON GROUP tra DEFAULT 'X',
  p_url    TYPE text100 DEFAULT 'ws://broker.hivemq.com:8000/mqtt' OBLIGATORY,
  p_tcp    TYPE c RADIOBUTTON GROUP tra,
  p_host   TYPE text100 DEFAULT 'broker.hivemq.com' OBLIGATORY,
  p_port   TYPE text100 DEFAULT '1883' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS:
  p_topic TYPE text100 DEFAULT 'ozan/iot2' OBLIGATORY,
  p_count TYPE i DEFAULT 3 OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-006.
PARAMETERS:
  p_ptopic TYPE text100 DEFAULT 'ABAP' OBLIGATORY,
  p_mess   TYPE text100 DEFAULT 'hello world'.
SELECTION-SCREEN END OF BLOCK b4.

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

      CASE abap_true.
        WHEN p_rec.
          PERFORM receive USING li_transport.
        WHEN p_pub.
          PERFORM publish USING li_transport.
        WHEN OTHERS.
          ASSERT 0 = 1.
      ENDCASE.

      li_transport->send( NEW zcl_mqtt_packet_disconnect( ) ).
      li_transport->disconnect( ).

    CATCH zcx_mqtt_timeout.
      WRITE: / 'timeout'.
    CATCH zcx_mqtt.
      WRITE: / 'Error'.
  ENDTRY.

ENDFORM.

FORM receive USING pi_transport TYPE REF TO zif_mqtt_transport RAISING zcx_mqtt cx_apc_error.

  pi_transport->send( NEW zcl_mqtt_packet_subscribe(
    it_topics            = VALUE #( ( topic = CONV #( p_topic ) ) )
    iv_packet_identifier = '0001' ) ).
  DATA(lt_return_codes) = CAST zcl_mqtt_packet_suback( pi_transport->listen( p_timeou ) )->get_return_codes( ).
  WRITE: / 'SUBACK return code:'(004), lt_return_codes[ 1 ].

  WRITE: /.
  DO p_count TIMES.
    DATA(ls_message) = CAST zcl_mqtt_packet_publish( pi_transport->listen( p_timeou ) )->get_message( ).
    WRITE: / ls_message-topic, ls_message-message.
    WRITE: / cl_binary_convert=>xstring_utf8_to_string( ls_message-message ).
  ENDDO.

ENDFORM.

FORM publish USING pi_transport TYPE REF TO zif_mqtt_transport RAISING zcx_mqtt cx_apc_error.

  DATA(ls_message) = VALUE zif_mqtt_packet=>ty_message(
    topic   = p_ptopic
    message = cl_binary_convert=>string_to_xstring_utf8( CONV #( p_mess ) ) ).

  pi_transport->send( NEW zcl_mqtt_packet_publish( is_message = ls_message ) ).

ENDFORM.
