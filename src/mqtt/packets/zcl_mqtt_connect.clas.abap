class ZCL_MQTT_CONNECT definition
  public
  create public .

public section.

  interfaces ZIF_MQTT_PACKET .

  aliases DECODE
    for ZIF_MQTT_PACKET~DECODE .
  aliases ENCODE
    for ZIF_MQTT_PACKET~ENCODE .
  aliases GET_TYPE
    for ZIF_MQTT_PACKET~GET_TYPE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MQTT_CONNECT IMPLEMENTATION.


  METHOD ZIF_MQTT_PACKET~ENCODE.

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


  METHOD ZIF_MQTT_PACKET~GET_TYPE.

    rv_value = zif_mqtt_constants=>gc_packets-connect.

  ENDMETHOD.
ENDCLASS.
