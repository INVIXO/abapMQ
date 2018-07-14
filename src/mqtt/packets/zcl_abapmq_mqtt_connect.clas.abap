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

    DATA: lv_byte1 TYPE x,
          lv_byte2 TYPE x.


    DATA(lo_payload) = NEW zcl_abapmq_mqtt_stream( ).
    lo_payload->add_utf8( 'MQTT' ). " protocol version
    lo_payload->add_hex( '04' ). " protocol level
    lo_payload->add_hex( '02' ). " connect flags
    lo_payload->add_hex( '001E' ). " keepalive
    lo_payload->add_hex( '0000' ). " client id length

    lv_byte1 = zif_abapmq_mqtt_packet~get_type( ) * 16.
    ro_stream = NEW #( lv_byte1 ).
    lv_byte2 = lo_payload->get_length( ).
    ro_stream->add_hex( lv_byte2 ).

    ro_stream->add_stream( lo_payload ).

  ENDMETHOD.


  METHOD zif_abapmq_mqtt_packet~get_type.

    rv_value = 1.

  ENDMETHOD.
ENDCLASS.
