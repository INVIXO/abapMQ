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

    DATA: lv_byte TYPE x LENGTH 1.


    lv_byte = zif_abapmq_mqtt_packet~get_type( ) * 16.

    ro_stream = NEW #( lv_byte ).
    ro_stream->add_hex( '00' ).

  ENDMETHOD.


  METHOD zif_abapmq_mqtt_packet~get_type.

    rv_value = 12.

  ENDMETHOD.
ENDCLASS.
