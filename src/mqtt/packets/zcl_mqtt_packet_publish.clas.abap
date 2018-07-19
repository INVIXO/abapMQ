class ZCL_MQTT_PACKET_PUBLISH definition
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

  types:
    BEGIN OF ty_message,
             topic   TYPE string,
             message TYPE xstring,
           END OF ty_message .

  methods GET_MESSAGE
    returning
      value(RS_MESSAGE) type TY_MESSAGE .
  methods SET_MESSAGE
    importing
      !IS_MESSAGE type TY_MESSAGE .
protected section.

  data MS_MESSAGE type TY_MESSAGE .
private section.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_PUBLISH IMPLEMENTATION.


  METHOD GET_MESSAGE.

    rs_message = ms_message.

  ENDMETHOD.


  METHOD SET_MESSAGE.

    ms_message = is_message.

  ENDMETHOD.


  METHOD ZIF_MQTT_PACKET~DECODE.

    io_stream->eat_hex( 2 ). " todo, fixed header

    ms_message-topic = io_stream->eat_utf8( ).

* todo, packet identifier for QoS = 1 or 2

    ms_message-message = io_stream->eat_hex( io_stream->get_length( ) ).

  ENDMETHOD.


  METHOD ZIF_MQTT_PACKET~ENCODE.

    ASSERT NOT ms_message-topic IS INITIAL.
    ASSERT NOT ms_message-message IS INITIAL.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).
* todo, packet identifier for QoS = 1 or 2
    lo_payload->add_utf8( ms_message-topic ).
    lo_payload->add_hex( ms_message-message ).

    ro_stream = NEW #( ).
    ro_stream->add_packet(
      ii_packet  = me
* todo, flags
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD ZIF_MQTT_PACKET~GET_TYPE.

    rv_value = zif_mqtt_constants=>gc_packets-publish.

  ENDMETHOD.
ENDCLASS.
