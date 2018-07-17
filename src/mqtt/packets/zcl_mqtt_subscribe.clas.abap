class ZCL_MQTT_SUBSCRIBE definition
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
    ty_topics TYPE STANDARD TABLE OF string WITH DEFAULT KEY .

  methods GET_TOPICS
    returning
      value(RT_TOPICS) type TY_TOPICS .
  methods SET_TOPICS
    importing
      !IT_TOPICS type TY_TOPICS
    returning
      value(RO_SUBSCRIBE) type ref to ZCL_MQTT_SUBSCRIBE .
protected section.

  data MT_TOPICS type TY_TOPICS .
private section.
ENDCLASS.



CLASS ZCL_MQTT_SUBSCRIBE IMPLEMENTATION.


  METHOD GET_TOPICS.

    rt_topics = mt_topics.

  ENDMETHOD.


  METHOD SET_TOPICS.

    mt_topics = it_topics.

    ro_subscribe = me.

  ENDMETHOD.


  METHOD ZIF_MQTT_PACKET~DECODE.

    BREAK-POINT.

  ENDMETHOD.


  METHOD ZIF_MQTT_PACKET~ENCODE.

    ASSERT lines( mt_topics ) > 0.


    DATA(lo_payload) = NEW zcl_abapmq_mqtt_stream( ).

* todo, packet identifier, 2 byte
    lo_payload->add_hex( '0001' ).

    LOOP AT mt_topics INTO DATA(lv_topic).
      lo_payload->add_utf8( lv_topic ).
      lo_payload->add_hex( '00' ). " todo QoS
    ENDLOOP.

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload
      iv_flags   = 2 ).

  ENDMETHOD.


  METHOD ZIF_MQTT_PACKET~GET_TYPE.

    rv_value = zif_mqtt_constants=>gc_packets-subscribe.

  ENDMETHOD.
ENDCLASS.
