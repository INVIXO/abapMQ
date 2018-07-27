class ZCL_MQTT_PACKET_SUBACK definition
  public
  create public .

public section.

  interfaces ZIF_MQTT_PACKET .

  types:
    ty_hex TYPE x LENGTH 1 .
  types:
    ty_return_codes TYPE STANDARD TABLE OF ty_hex WITH EMPTY KEY .

  methods GET_RETURN_CODES
    returning
      value(RT_RETURN_CODES) type TY_RETURN_CODES .
protected section.

  data MT_RETURN_CODES type TY_RETURN_CODES .
private section.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_SUBACK IMPLEMENTATION.


  METHOD get_return_codes.

    rt_return_codes = mt_return_codes.

  ENDMETHOD.


  METHOD zif_mqtt_packet~decode.

    ASSERT io_stream->eat_hex( 1 ) = '90'.

    io_stream->eat_length( ).

* todo, packet identifier
    DATA(lv_identifier) = io_stream->eat_hex( 2 ).

    WHILE io_stream->get_length( ) > 0.
      APPEND io_stream->eat_hex( 1 ) TO mt_return_codes.
    ENDWHILE.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

* todo, packet identifier
    lo_payload->add_hex( '0001' ).

    LOOP AT mt_return_codes INTO DATA(lv_return_code).
      lo_payload->add_hex( lv_return_code ).
    ENDLOOP.

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-suback.

  ENDMETHOD.
ENDCLASS.
