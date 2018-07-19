class ZCL_MQTT_PACKET_PUBACK definition
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



CLASS ZCL_MQTT_PACKET_PUBACK IMPLEMENTATION.


  METHOD ZIF_MQTT_PACKET~DECODE.

* todo

  ENDMETHOD.


  METHOD ZIF_MQTT_PACKET~ENCODE.

* todo

  ENDMETHOD.


  METHOD ZIF_MQTT_PACKET~GET_TYPE.

    rv_value = zif_mqtt_constants=>gc_packets-puback.

  ENDMETHOD.
ENDCLASS.
