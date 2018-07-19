REPORT zabapmq_mqtt_new.

PARAMETERS: p_url TYPE text100 OBLIGATORY DEFAULT 'ws://broker.hivemq.com:8000/mqtt'.

START-OF-SELECTION.
  PERFORM run.

FORM run.

  TRY.
      DATA(li_transport) = zcl_mqtt_transport_ws=>create_by_url( CONV #( p_url ) ).

      li_transport->connect( ).

      li_transport->send( NEW zcl_mqtt_packet_connect( ) ).

      DATA(li_packet) = li_transport->listen( 10 ).

      WRITE: / li_packet->get_type( ).

      li_transport->disconnect( ).
    CATCH zcx_mqtt.
      BREAK-POINT.
  ENDTRY.

ENDFORM.
