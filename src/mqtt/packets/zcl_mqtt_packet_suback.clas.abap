CLASS zcl_mqtt_packet_suback DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_packet .

    TYPES:
      ty_hex TYPE x LENGTH 1 .
    TYPES:
      ty_return_codes TYPE STANDARD TABLE OF ty_hex WITH EMPTY KEY .

    METHODS set_return_codes
      IMPORTING
        !it_return_codes TYPE ty_return_codes .
    METHODS get_return_codes
      RETURNING
        VALUE(rt_return_codes) TYPE ty_return_codes .
    METHODS constructor
      IMPORTING
        !it_return_codes      TYPE ty_return_codes OPTIONAL
        !iv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier OPTIONAL .
    METHODS get_packet_identifier
      RETURNING
        VALUE(rv_packet_identifier) TYPE zif_mqtt_packet=>ty_packet_identifier .
    METHODS set_packet_identifier
      IMPORTING
        !iv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier .
  PROTECTED SECTION.

    DATA mt_return_codes TYPE ty_return_codes .
    DATA mv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_SUBACK IMPLEMENTATION.


  METHOD constructor.

    mv_packet_identifier = iv_packet_identifier.
    mt_return_codes = it_return_codes.

  ENDMETHOD.


  METHOD get_packet_identifier.

    rv_packet_identifier = mv_packet_identifier.

  ENDMETHOD.


  METHOD get_return_codes.

    rt_return_codes = mt_return_codes.

  ENDMETHOD.


  METHOD set_packet_identifier.

    mv_packet_identifier = iv_packet_identifier.

  ENDMETHOD.


  METHOD set_return_codes.

    mt_return_codes = it_return_codes.

  ENDMETHOD.


  METHOD zif_mqtt_packet~decode.

    ASSERT io_stream->eat_hex( 1 ) = '90'.

    io_stream->eat_length( ).

    mv_packet_identifier = io_stream->eat_hex( 2 ).

    WHILE io_stream->get_length( ) > 0.
      APPEND io_stream->eat_hex( 1 ) TO mt_return_codes.
    ENDWHILE.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

    ASSERT NOT mv_packet_identifier IS INITIAL.
    lo_payload->add_hex( mv_packet_identifier ).

    LOOP AT mt_return_codes INTO DATA(lv_return_code).
      lo_payload->add_hex( lv_return_code ).
    ENDLOOP.

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-suback.

  ENDMETHOD.
ENDCLASS.
