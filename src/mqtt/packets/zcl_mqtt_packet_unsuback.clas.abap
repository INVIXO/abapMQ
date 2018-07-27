class ZCL_MQTT_PACKET_UNSUBACK definition
  public
  create public .

public section.

  interfaces ZIF_MQTT_PACKET .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_UNSUBACK IMPLEMENTATION.


  METHOD zif_mqtt_packet~decode.

    CONSTANTS: lc_header TYPE xstring VALUE 'B0'.

    ASSERT io_stream->eat_hex( 1 ) = lc_header.

    io_stream->eat_length( ).

* todo, packet identifier
    io_stream->eat_hex( 2 ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

* todo, packet identifier
    lo_payload->add_hex( '0001' ).

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-unsuback.

  ENDMETHOD.
ENDCLASS.
