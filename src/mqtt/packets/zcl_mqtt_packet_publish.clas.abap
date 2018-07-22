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

  methods GET_MESSAGE
    returning
      value(RS_MESSAGE) type ZIF_MQTT_PACKET=>TY_MESSAGE .
  methods SET_MESSAGE
    importing
      !IS_MESSAGE type ZIF_MQTT_PACKET=>TY_MESSAGE .
  methods CONSTRUCTOR .
protected section.

  data MS_MESSAGE type ZIF_MQTT_PACKET=>TY_MESSAGE .
  data MV_DUP_FLAG type ABAP_BOOL .
  data MV_QOS_LEVEL type ZIF_MQTT_PACKET=>TY_QOS .
  data MV_RETAIN type ABAP_BOOL .
private section.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_PUBLISH IMPLEMENTATION.


  METHOD constructor.

* todo, add iv_message as optional

  ENDMETHOD.


  METHOD get_message.

    rs_message = ms_message.

  ENDMETHOD.


  METHOD set_message.

    ms_message = is_message.

  ENDMETHOD.


  METHOD zif_mqtt_packet~decode.

    DATA(lv_hex) = io_stream->eat_hex( 1 ).

    IF lv_hex MOD 2 = 1.
      mv_retain = abap_true.
    ENDIF.

    mv_qos_level = ( lv_hex DIV 2 ) MOD 4.

    IF lv_hex MOD 16 = 1.
      mv_dup_flag = abap_true.
    ENDIF.

    io_stream->eat_length( ).

    ms_message-topic = io_stream->eat_utf8( ).

    IF mv_qos_level > 0.
      DATA(lv_packet_identifier) = io_stream->eat_hex( 2 ).
    ENDIF.

    ms_message-message = io_stream->eat_hex( io_stream->get_length( ) ).

    ASSERT io_stream->get_length( ) = 0.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    ASSERT NOT ms_message-topic IS INITIAL.
    ASSERT NOT ms_message-message IS INITIAL.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).
* todo, packet identifier for QoS = 1 or 2
    lo_payload->add_utf8( ms_message-topic ).
    lo_payload->add_hex( ms_message-message ).

    ro_stream = NEW #( ).
* todo, flags
    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-publish.

  ENDMETHOD.
ENDCLASS.
