class ZCL_ABAPMQ_MQTT_SUBSCRIBE definition
  public
  create public .

public section.

  interfaces ZIF_ABAPMQ_MQTT_PACKET .

  types:
    ty_topics type standard table of string with default key .

  methods GET_TOPICS
    returning
      value(RT_TOPICS) type TY_TOPICS .
  methods SET_TOPICS
    importing
      !IT_TOPICS type TY_TOPICS
    returning
      value(RO_SUBSCRIBE) type ref to ZCL_ABAPMQ_MQTT_SUBSCRIBE .
protected section.

  data MT_TOPICS type TY_TOPICS .
private section.
ENDCLASS.



CLASS ZCL_ABAPMQ_MQTT_SUBSCRIBE IMPLEMENTATION.


  METHOD get_topics.

    rt_topics = mt_topics.

  ENDMETHOD.


  METHOD set_topics.

    mt_topics = it_topics.

    ro_subscribe = me.

  ENDMETHOD.


  METHOD zif_abapmq_mqtt_packet~decode.

    BREAK-POINT.

  ENDMETHOD.


  METHOD zif_abapmq_mqtt_packet~encode.

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


  METHOD zif_abapmq_mqtt_packet~get_type.

    rv_value = 8.

  ENDMETHOD.
ENDCLASS.
