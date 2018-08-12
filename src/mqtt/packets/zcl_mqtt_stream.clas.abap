CLASS zcl_mqtt_stream DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS add_hex
      IMPORTING
        !iv_hex          TYPE xsequence
      RETURNING
        VALUE(ro_stream) TYPE REF TO zcl_mqtt_stream .
    METHODS add_length
      IMPORTING
        !iv_length TYPE i .
    METHODS add_packet
      IMPORTING
        !ii_packet       TYPE REF TO zif_mqtt_packet
        !io_payload      TYPE REF TO zcl_mqtt_stream OPTIONAL
        !iv_flags        TYPE i DEFAULT 0
      RETURNING
        VALUE(ro_stream) TYPE REF TO zcl_mqtt_stream .
    METHODS add_stream
      IMPORTING
        !io_stream TYPE REF TO zcl_mqtt_stream .
    METHODS add_utf8
      IMPORTING
        !iv_string       TYPE csequence
      RETURNING
        VALUE(ro_stream) TYPE REF TO zcl_mqtt_stream .
    METHODS constructor
      IMPORTING
        !iv_hex TYPE xsequence OPTIONAL .
    METHODS eat_hex
      IMPORTING
        !iv_length    TYPE i
      RETURNING
        VALUE(rv_hex) TYPE xstring .
    METHODS eat_length
      RETURNING
        VALUE(rv_length) TYPE i .
    METHODS eat_packet
      RETURNING
        VALUE(ri_packet) TYPE REF TO zif_mqtt_packet .
    METHODS eat_utf8
      RETURNING
        VALUE(rv_string) TYPE string .
    METHODS get_hex
      RETURNING
        VALUE(rv_hex) TYPE xstring .
    METHODS get_length
      RETURNING
        VALUE(rv_length) TYPE i .
    METHODS peek_hex
      IMPORTING
        !iv_length    TYPE i
      RETURNING
        VALUE(rv_hex) TYPE xstring .
  PROTECTED SECTION.

    DATA mv_hex TYPE xstring .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_STREAM IMPLEMENTATION.


  METHOD add_hex.

    CONCATENATE mv_hex iv_hex INTO mv_hex IN BYTE MODE.

    ro_stream = me.

  ENDMETHOD.


  METHOD add_length.

    DATA: lv_length LIKE iv_length,
          lv_byte   TYPE x.


    ASSERT iv_length >= 0.

    lv_length = iv_length.
    WHILE lv_length > 0.
      lv_byte = lv_length MOD 128.

      lv_length = lv_length DIV 128.
      IF lv_length > 0.
        lv_byte = lv_byte + 128.
      ENDIF.

      add_hex( lv_byte ).
    ENDWHILE.

    IF iv_length = 0.
      add_hex( '00' ).
    ENDIF.

  ENDMETHOD.


  METHOD add_packet.

    DATA: lv_byte   TYPE x,
          lv_length TYPE i.

    lv_byte = ii_packet->get_type( ) * 16 + iv_flags.

    add_hex( lv_byte ).

    IF io_payload IS SUPPLIED.
      lv_length = io_payload->get_length( ).
    ENDIF.
    add_length( lv_length ).

    IF io_payload IS SUPPLIED.
      add_stream( io_payload ).
    ENDIF.

    ro_stream = me.

  ENDMETHOD.


  METHOD add_stream.

    DATA: lv_hex TYPE xstring.


    lv_hex = io_stream->get_hex( ).

    CONCATENATE mv_hex lv_hex INTO mv_hex IN BYTE MODE.

  ENDMETHOD.


  METHOD add_utf8.

    DATA: lv_len TYPE x LENGTH 2.


    DATA(lv_hex) = cl_binary_convert=>string_to_xstring_utf8( iv_string ).

    lv_len = xstrlen( lv_hex ).

    CONCATENATE mv_hex lv_len lv_hex INTO mv_hex IN BYTE MODE.

    ro_stream = me.

  ENDMETHOD.


  METHOD constructor.

    IF iv_hex IS SUPPLIED.
      mv_hex = iv_hex.
    ENDIF.

  ENDMETHOD.


  METHOD eat_hex.

    rv_hex = mv_hex(iv_length).

    mv_hex = mv_hex+iv_length.

  ENDMETHOD.


  METHOD eat_length.

    DATA: lv_byte       TYPE x LENGTH 1,
          lv_multiplier TYPE i VALUE 1.


    DO.
      ASSERT sy-index <= 4.

      lv_byte = eat_hex( 1 ).

      rv_length = rv_length + ( lv_byte MOD 128 ) * lv_multiplier.
      lv_multiplier = lv_multiplier * 128.

      IF lv_byte < 128.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.


  METHOD eat_packet.

    DATA: lv_int TYPE i.


    lv_int = peek_hex( 1 ) / 16.

    CASE lv_int.
      WHEN zif_mqtt_constants=>gc_packets-connect.
        ri_packet = NEW zcl_mqtt_packet_connect( ).
      WHEN zif_mqtt_constants=>gc_packets-connack.
        ri_packet = NEW zcl_mqtt_packet_connack( ).
      WHEN zif_mqtt_constants=>gc_packets-publish.
        ri_packet = NEW zcl_mqtt_packet_publish( ).
      WHEN zif_mqtt_constants=>gc_packets-puback.
        ri_packet = NEW zcl_mqtt_packet_puback( ).
      WHEN zif_mqtt_constants=>gc_packets-pubrec.
        ri_packet = NEW zcl_mqtt_packet_pubrec( ).
      WHEN zif_mqtt_constants=>gc_packets-pubrel.
        ri_packet = NEW zcl_mqtt_packet_pubrel( ).
      WHEN zif_mqtt_constants=>gc_packets-pubcomp.
        ri_packet = NEW zcl_mqtt_packet_pubcomp( ).
      WHEN zif_mqtt_constants=>gc_packets-subscribe.
        ri_packet = NEW zcl_mqtt_packet_subscribe( ).
      WHEN zif_mqtt_constants=>gc_packets-suback.
        ri_packet = NEW zcl_mqtt_packet_suback( ).
      WHEN zif_mqtt_constants=>gc_packets-unsubscribe.
        ri_packet = NEW zcl_mqtt_packet_unsubscribe( ).
      WHEN zif_mqtt_constants=>gc_packets-unsuback.
        ri_packet = NEW zcl_mqtt_packet_unsuback( ).
      WHEN zif_mqtt_constants=>gc_packets-pingreq.
        ri_packet = NEW zcl_mqtt_packet_pingreq( ).
      WHEN zif_mqtt_constants=>gc_packets-pingresp.
        ri_packet = NEW zcl_mqtt_packet_pingresp( ).
      WHEN zif_mqtt_constants=>gc_packets-disconnect.
        ri_packet = NEW zcl_mqtt_packet_disconnect( ).
      WHEN OTHERS.
        ASSERT 0 = 1.
    ENDCASE.

    ri_packet->decode( me ).

  ENDMETHOD.


  METHOD eat_utf8.

    DATA: lv_len TYPE x LENGTH 2,
          lv_int TYPE i.


    lv_len = eat_hex( 2 ).
    lv_int = lv_len.

    rv_string = cl_binary_convert=>xstring_utf8_to_string( eat_hex( lv_int ) ).

  ENDMETHOD.


  METHOD get_hex.

    rv_hex = mv_hex.

  ENDMETHOD.


  METHOD get_length.

    rv_length = xstrlen( mv_hex ).

  ENDMETHOD.


  METHOD peek_hex.

    rv_hex = mv_hex(iv_length).

  ENDMETHOD.
ENDCLASS.
