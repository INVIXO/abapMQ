class ZCL_MQTT_PACKET_PINGRESP definition
  public
  create public .

public section.

  interfaces ZIF_MQTT_PACKET .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_PINGRESP IMPLEMENTATION.


  METHOD zif_mqtt_packet~decode.

    ASSERT io_stream->eat_hex( 2 ) = 'D000'.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-pingresp.

  ENDMETHOD.
ENDCLASS.
