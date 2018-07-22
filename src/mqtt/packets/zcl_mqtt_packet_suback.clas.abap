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

    DATA(lv_identifier) = io_stream->eat_hex( 2 ).

    WHILE io_stream->get_length( ) > 0.
      APPEND io_stream->eat_hex( 1 ) TO mt_return_codes.
    ENDWHILE.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

* todo
    BREAK-POINT.

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-suback.

  ENDMETHOD.
ENDCLASS.
