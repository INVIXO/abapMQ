class ZCL_ABAPMQ_MQTT_CONNACK definition
  public
  create public .

public section.

  interfaces ZIF_ABAPMQ_MQTT_PACKET .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPMQ_MQTT_CONNACK IMPLEMENTATION.


  METHOD zif_abapmq_mqtt_packet~get_type.

    rv_value = 2.

  ENDMETHOD.
ENDCLASS.
