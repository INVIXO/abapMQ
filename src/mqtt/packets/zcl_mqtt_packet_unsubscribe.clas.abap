class ZCL_MQTT_PACKET_UNSUBSCRIBE definition
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



CLASS ZCL_MQTT_PACKET_UNSUBSCRIBE IMPLEMENTATION.


  METHOD zif_mqtt_packet~decode.

* todo
    BREAK-POINT.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

* todo
    BREAK-POINT.

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-unsubscribe.

  ENDMETHOD.
ENDCLASS.
