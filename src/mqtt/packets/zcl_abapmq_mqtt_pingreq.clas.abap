class ZCL_ABAPMQ_MQTT_PINGREQ definition
  public
  create public .

public section.

  interfaces ZIF_ABAPMQ_MQTT_PACKET .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPMQ_MQTT_PINGREQ IMPLEMENTATION.


  METHOD zif_abapmq_mqtt_packet~encode.

    ro_stream = NEW #( ).

    ro_stream->add_packet( me ).

  ENDMETHOD.


  METHOD zif_abapmq_mqtt_packet~get_type.

    rv_value = 12.

  ENDMETHOD.
ENDCLASS.
