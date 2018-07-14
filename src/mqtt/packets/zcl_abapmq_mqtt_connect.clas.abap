class ZCL_ABAPMQ_MQTT_CONNECT definition
  public
  create public .

public section.

  interfaces ZIF_ABAPMQ_MQTT_PACKET .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPMQ_MQTT_CONNECT IMPLEMENTATION.


  METHOD zif_abapmq_mqtt_packet~encode.

    DATA(lo_payload) = NEW zcl_abapmq_mqtt_stream( ).
    lo_payload->add_utf8( 'MQTT' ). " protocol version
    lo_payload->add_hex( '04' ). " protocol level
    lo_payload->add_hex( '02' ). " connect flags
    lo_payload->add_hex( '001E' ). " keepalive
    lo_payload->add_hex( '0000' ). " client id length


    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_abapmq_mqtt_packet~get_type.

    rv_value = 1.

  ENDMETHOD.
ENDCLASS.
