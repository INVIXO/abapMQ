REPORT zabapmq_mqtt_new.

PARAMETERS: p_url TYPE text100 OBLIGATORY DEFAULT 'ws://broker.hivemq.com:8000/mqtt'.

START-OF-SELECTION.
  PERFORM run.

FORM run.

  TRY.
      DATA(li_transport) = zcl_mqtt_transport_ws=>create_by_url( CONV #( p_url ) ).

      li_transport->connect( ).
      li_transport->send( NEW zcl_mqtt_packet_connect( ) ).

      DATA(lo_connack) = CAST zcl_mqtt_packet_connack( li_transport->listen( 10 ) ).
      WRITE: / 'CONNACK return code:', lo_connack->get_return_code( ).

      li_transport->send( NEW zcl_mqtt_packet_subscribe( VALUE #( ( |ozan/iot2| ) ) ) ).
      DATA(lt_return_codes) = CAST zcl_mqtt_packet_suback( li_transport->listen( 10 ) )->get_return_codes( ).
      WRITE: / 'SUBACK return code:', lt_return_codes[ 1 ].

      WRITE: /.
      DO 3 TIMES.
        DATA(ls_message) = CAST zcl_mqtt_packet_publish( li_transport->listen( 10 ) )->get_message( ).
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
