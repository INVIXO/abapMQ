CLASS zcl_mqtt_packet_subscribe DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_packet .

    TYPES: BEGIN OF ty_topic,
             topic TYPE zif_mqtt_packet=>ty_topic,
             qos   TYPE zif_mqtt_packet=>ty_qos,
           END OF ty_topic.

    TYPES:
      ty_topics TYPE STANDARD TABLE OF ty_topic WITH EMPTY KEY .

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
        !it_topics            TYPE ty_topics OPTIONAL
        !iv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier OPTIONAL .
    METHODS get_packet_identifier
      RETURNING
        VALUE(rv_packet_identifier) TYPE zif_mqtt_packet=>ty_packet_identifier .
    METHODS set_packet_identifier
      IMPORTING
        !iv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier .
  PROTECTED SECTION.

    DATA mt_topics TYPE ty_topics .
    DATA mv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_SUBSCRIBE IMPLEMENTATION.


  METHOD constructor.

    mt_topics = it_topics.
    mv_packet_identifier = iv_packet_identifier.

  ENDMETHOD.


  METHOD get_packet_identifier.

    rv_packet_identifier = mv_packet_identifier.

  ENDMETHOD.


  METHOD get_topics.

    rt_topics = mt_topics.

  ENDMETHOD.


  METHOD set_packet_identifier.

    mv_packet_identifier = iv_packet_identifier.

  ENDMETHOD.


  METHOD set_topics.

    mt_topics = it_topics.

    ro_subscribe = me.

  ENDMETHOD.


  METHOD zif_mqtt_packet~decode.

    DATA: ls_topic LIKE LINE OF mt_topics.


    ASSERT io_stream->eat_hex( 1 ) = '82'.

    io_stream->eat_length( ).

    mv_packet_identifier = io_stream->eat_hex( 2 ).

    WHILE io_stream->get_length( ) > 0.
      ls_topic-topic = io_stream->eat_utf8( ).
      ls_topic-qos = io_stream->eat_hex( 1 ).
      APPEND ls_topic TO mt_topics.
    ENDWHILE.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    ASSERT lines( mt_topics ) > 0.


    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

    ASSERT NOT mv_packet_identifier IS INITIAL.
    lo_payload->add_hex( mv_packet_identifier ).

    LOOP AT mt_topics INTO DATA(ls_topic).
      lo_payload->add_utf8( ls_topic-topic ).
      lo_payload->add_hex( CONV xstring( ls_topic-qos ) ).
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
