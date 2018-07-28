CLASS zcl_mqtt_packet_publish DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_packet .

    ALIASES decode
      FOR zif_mqtt_packet~decode .
    ALIASES encode
      FOR zif_mqtt_packet~encode .
    ALIASES get_type
      FOR zif_mqtt_packet~get_type .

    METHODS get_message
      RETURNING
        VALUE(rs_message) TYPE zif_mqtt_packet=>ty_message .
    METHODS set_message
      IMPORTING
        !is_message TYPE zif_mqtt_packet=>ty_message .
    METHODS constructor
      IMPORTING
        !is_message           TYPE zif_mqtt_packet=>ty_message OPTIONAL
        !iv_dup_flag          TYPE abap_bool OPTIONAL
        !iv_qos_level         TYPE zif_mqtt_packet=>ty_qos OPTIONAL
        !iv_retain            TYPE abap_bool OPTIONAL
        !iv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier OPTIONAL .
    METHODS get_packet_identifier
      RETURNING
        VALUE(rv_packet_identifier) TYPE zif_mqtt_packet=>ty_packet_identifier .
    METHODS set_packet_identifier
      IMPORTING
        !iv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier .
  PROTECTED SECTION.

    DATA ms_message TYPE zif_mqtt_packet=>ty_message .
    DATA mv_dup_flag TYPE abap_bool .
    DATA mv_qos_level TYPE zif_mqtt_packet=>ty_qos .
    DATA mv_retain TYPE abap_bool .
    DATA mv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier .

    CLASS-METHODS decode_flags
      IMPORTING
        !iv_flags     TYPE i
      EXPORTING
        !ev_qos_level TYPE zif_mqtt_packet=>ty_qos
        !ev_retain    TYPE abap_bool
        !ev_dup_flag  TYPE abap_bool .
    CLASS-METHODS encode_flags
      IMPORTING
        !iv_dup_flag    TYPE abap_bool
        !iv_qos_level   TYPE zif_mqtt_packet=>ty_qos
        !iv_retain      TYPE abap_bool
      RETURNING
        VALUE(rv_flags) TYPE i .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_PUBLISH IMPLEMENTATION.


  METHOD constructor.

    ms_message   = is_message.
    mv_dup_flag  = iv_dup_flag.
    mv_qos_level = iv_qos_level.
    mv_retain    = iv_retain.
    mv_packet_identifier = iv_packet_identifier.

  ENDMETHOD.


  METHOD decode_flags.

    IF iv_flags MOD 2 = 1.
      ev_retain = abap_true.
    ELSE.
      ev_retain = abap_false.
    ENDIF.

    ev_qos_level = ( iv_flags DIV 2 ) MOD 4.

    IF iv_flags MOD 8 = 1.
      ev_dup_flag = abap_true.
    ELSE.
      ev_dup_flag = abap_false.
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


  METHOD get_packet_identifier.

    rv_packet_identifier = mv_packet_identifier.

  ENDMETHOD.


  METHOD set_message.

    ms_message = is_message.

  ENDMETHOD.


  METHOD set_packet_identifier.

    mv_packet_identifier = iv_packet_identifier.

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
      mv_packet_identifier = io_stream->eat_hex( 2 ).
    ENDIF.

    ms_message-message = io_stream->eat_hex( io_stream->get_length( ) ).

    ASSERT io_stream->get_length( ) = 0.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    ASSERT NOT ms_message-topic IS INITIAL.
    ASSERT NOT ms_message-message IS INITIAL.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

    IF mv_qos_level > 0.
      ASSERT NOT mv_packet_identifier IS INITIAL.
      lo_payload->add_hex( mv_packet_identifier ).
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
