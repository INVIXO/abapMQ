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
  methods CONSTRUCTOR
    importing
      !IS_MESSAGE type ZIF_MQTT_PACKET=>TY_MESSAGE optional
      !IV_DUP_FLAG type ABAP_BOOL optional
      !IV_QOS_LEVEL type ZIF_MQTT_PACKET=>TY_QOS optional
      !IV_RETAIN type ABAP_BOOL optional .
protected section.

  data MS_MESSAGE type ZIF_MQTT_PACKET=>TY_MESSAGE .
  data MV_DUP_FLAG type ABAP_BOOL .
  data MV_QOS_LEVEL type ZIF_MQTT_PACKET=>TY_QOS .
  data MV_RETAIN type ABAP_BOOL .

  class-methods DECODE_FLAGS
    importing
      !IV_FLAGS type I
    exporting
      !EV_QOS_LEVEL type ZIF_MQTT_PACKET=>TY_QOS
      !EV_RETAIN type ABAP_BOOL
      !EV_DUP_FLAG type ABAP_BOOL .
  class-methods ENCODE_FLAGS
    importing
      !IV_DUP_FLAG type ABAP_BOOL
      !IV_QOS_LEVEL type ZIF_MQTT_PACKET=>TY_QOS
      !IV_RETAIN type ABAP_BOOL
    returning
      value(RV_FLAGS) type I .
private section.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_PUBLISH IMPLEMENTATION.


  METHOD constructor.

    ms_message   = is_message.
    mv_dup_flag  = iv_dup_flag.
    mv_qos_level = iv_qos_level.
    mv_retain    = iv_retain.

  ENDMETHOD.


  METHOD decode_flags.

    IF iv_flags MOD 2 = 1.
      ev_retain = abap_true.
    ENDIF.

    ev_qos_level = ( iv_flags DIV 2 ) MOD 4.

    IF iv_flags MOD 8 = 1.
      ev_dup_flag = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD encode_flags.

    IF iv_retain = abap_true.
      rv_flags = 1.
    ENDIF.

    rv_flags = rv_flags + iv_qos_level * 2.

    IF iv_dup_flag = abap_true.
      rv_flags = rv_flags + 8.
    ENDIF.

  ENDMETHOD.


  METHOD get_message.

    rs_message = ms_message.

  ENDMETHOD.


  METHOD set_message.

    ms_message = is_message.

  ENDMETHOD.


  METHOD zif_mqtt_packet~decode.

    DATA(lv_hex) = io_stream->eat_hex( 1 ).

    zcl_mqtt_packet_publish=>decode_flags(
      EXPORTING
        iv_flags     = CONV #( lv_hex )
      IMPORTING
        ev_qos_level = mv_qos_level
        ev_retain    = mv_retain
        ev_dup_flag  = mv_dup_flag ).

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

    IF mv_qos_level <> 0.
      BREAK-POINT.
* todo, packet identifier for QoS = 1 or 2
    ENDIF.

    lo_payload->add_utf8( ms_message-topic ).
    lo_payload->add_hex( ms_message-message ).

    DATA(lv_flags) = encode_flags(
      iv_dup_flag  = mv_dup_flag
      iv_qos_level = mv_qos_level
      iv_retain    = mv_retain ).

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-publish.

  ENDMETHOD.
ENDCLASS.
