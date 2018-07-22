class ZCL_MQTT_PACKET_SUBSCRIBE definition
  public
  create public .

public section.

  interfaces ZIF_MQTT_PACKET .

  types:
    ty_topics TYPE STANDARD TABLE OF string WITH DEFAULT KEY .

  methods GET_TOPICS
    returning
      value(RT_TOPICS) type TY_TOPICS .
  methods SET_TOPICS
    importing
      !IT_TOPICS type TY_TOPICS
    returning
      value(RO_SUBSCRIBE) type ref to ZCL_MQTT_PACKET_SUBSCRIBE .
  methods CONSTRUCTOR
    importing
      !IT_TOPICS type TY_TOPICS optional .
protected section.

  data MT_TOPICS type TY_TOPICS .
private section.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_SUBSCRIBE IMPLEMENTATION.


  METHOD constructor.

    mt_topics = it_topics.

  ENDMETHOD.


  METHOD get_topics.

    rt_topics = mt_topics.

  ENDMETHOD.


  METHOD set_topics.

    mt_topics = it_topics.

    ro_subscribe = me.

  ENDMETHOD.


  METHOD zif_mqtt_packet~decode.

    BREAK-POINT.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    ASSERT lines( mt_topics ) > 0.


    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

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


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-subscribe.

  ENDMETHOD.
ENDCLASS.
