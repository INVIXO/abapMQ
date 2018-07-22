CLASS zcl_mqtt_packet_subscribe DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_packet .

    TYPES:
      ty_topics TYPE STANDARD TABLE OF string WITH EMPTY KEY .

    METHODS get_topics
      RETURNING
        VALUE(rt_topics) TYPE ty_topics .
    METHODS set_topics
      IMPORTING
        !it_topics          TYPE ty_topics
      RETURNING
        VALUE(ro_subscribe) TYPE REF TO zcl_mqtt_packet_subscribe .
    METHODS constructor
      IMPORTING
        !it_topics TYPE ty_topics OPTIONAL .
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
