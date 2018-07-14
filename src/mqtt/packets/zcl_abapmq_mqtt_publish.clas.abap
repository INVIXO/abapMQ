class ZCL_ABAPMQ_MQTT_PUBLISH definition
  public
  create public .

public section.

  interfaces ZIF_ABAPMQ_MQTT_PACKET .

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



CLASS ZCL_ABAPMQ_MQTT_PUBLISH IMPLEMENTATION.


  METHOD get_message.

    rs_message = ms_message.

  ENDMETHOD.


  METHOD set_message.

    ms_message = is_message.

  ENDMETHOD.


  METHOD zif_abapmq_mqtt_packet~decode.

    io_stream->eat_hex( 2 ). " todo, fixed header

    ms_message-topic = io_stream->eat_utf8( ).

* todo, packet identifier for QoS = 1 or 2

    ms_message-message = io_stream->eat_hex( io_stream->get_length( ) ).

  ENDMETHOD.


  METHOD zif_abapmq_mqtt_packet~encode.

    ASSERT NOT ms_message-topic IS INITIAL.
    ASSERT NOT ms_message-message IS INITIAL.

    DATA(lo_payload) = NEW zcl_abapmq_mqtt_stream( ).
* todo, packet identifier for QoS = 1 or 2
    lo_payload->add_utf8( ms_message-topic ).
    lo_payload->add_hex( ms_message-message ).

    ro_stream = NEW #( ).
    ro_stream->add_packet(
      ii_packet  = me
* todo, flags
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_abapmq_mqtt_packet~get_type.

    rv_value = 3.

  ENDMETHOD.
ENDCLASS.
