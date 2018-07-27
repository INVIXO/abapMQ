class ZCL_MQTT_PACKET_PUBREL definition
  public
  create public .

public section.

  interfaces ZIF_MQTT_PACKET .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_PUBREL IMPLEMENTATION.


  METHOD zif_mqtt_packet~decode.

    ASSERT io_stream->eat_hex( 1 ) = '62'.

    io_stream->eat_length( ).

* todo, packet identifier
    DATA(lv_identifier) = io_stream->eat_hex( 2 ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

* todo, packet identifier
    lo_payload->add_hex( '0001' ).

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      iv_flags   = 2
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-pubrel.

  ENDMETHOD.
ENDCLASS.
