class ZCL_ABAPMQ_MQTT_PUBACK definition
  public
  create public .

public section.

  interfaces ZIF_ABAPMQ_MQTT_PACKET .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPMQ_MQTT_PUBACK IMPLEMENTATION.


  METHOD zif_abapmq_mqtt_packet~get_type.

    rv_value = 4.

  ENDMETHOD.
ENDCLASS.
