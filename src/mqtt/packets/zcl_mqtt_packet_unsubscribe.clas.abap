CLASS zcl_mqtt_packet_unsubscribe DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_packet .

    METHODS get_topics
      RETURNING
        VALUE(rt_topics) TYPE zif_mqtt_packet=>ty_topics_tt .
    METHODS set_topics
      IMPORTING
        !it_topics TYPE zif_mqtt_packet=>ty_topics_tt .
    METHODS constructor
      IMPORTING
        !it_topics            TYPE zif_mqtt_packet=>ty_topics_tt OPTIONAL
        !iv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier OPTIONAL .
    METHODS get_packet_identifier
      RETURNING
        VALUE(rv_packet_identifier) TYPE zif_mqtt_packet=>ty_packet_identifier .
    METHODS set_packet_identifier
      IMPORTING
        !iv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier .
  PROTECTED SECTION.

    DATA mt_topics TYPE zif_mqtt_packet=>ty_topics_tt .
    DATA mv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_UNSUBSCRIBE IMPLEMENTATION.


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

  ENDMETHOD.


  METHOD zif_mqtt_packet~decode.

    CONSTANTS: lc_header TYPE xstring VALUE 'A2'.

    ASSERT io_stream->eat_hex( 1 ) = lc_header.

    io_stream->eat_length( ).

    mv_packet_identifier = io_stream->eat_hex( 2 ).

    WHILE io_stream->get_length( ) > 0.
      APPEND io_stream->eat_utf8( ) TO mt_topics.
    ENDWHILE.

    ASSERT lines( mt_topics ) > 0.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

    ASSERT NOT mv_packet_identifier IS INITIAL.
    lo_payload->add_hex( mv_packet_identifier ).

    ASSERT lines( mt_topics ) > 0.
    LOOP AT mt_topics INTO DATA(lv_topic).
      lo_payload->add_utf8( lv_topic ).
    ENDLOOP.

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      iv_flags   = 2
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-unsubscribe.

  ENDMETHOD.
ENDCLASS.
