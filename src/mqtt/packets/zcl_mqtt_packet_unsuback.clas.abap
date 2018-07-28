CLASS zcl_mqtt_packet_unsuback DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_packet .

    METHODS constructor
      IMPORTING
        !iv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier OPTIONAL .
    METHODS get_packet_identifier
      RETURNING
        VALUE(rv_packet_identifier) TYPE zif_mqtt_packet=>ty_packet_identifier .
    METHODS set_packet_identifier
      IMPORTING
        !iv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier .
  PROTECTED SECTION.

    DATA mv_packet_identifier TYPE zif_mqtt_packet=>ty_packet_identifier .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_UNSUBACK IMPLEMENTATION.


  METHOD constructor.

    mv_packet_identifier = iv_packet_identifier.

  ENDMETHOD.


  METHOD get_packet_identifier.

    rv_packet_identifier = mv_packet_identifier.

  ENDMETHOD.


  METHOD set_packet_identifier.

    mv_packet_identifier = iv_packet_identifier.

  ENDMETHOD.


  METHOD zif_mqtt_packet~decode.

    CONSTANTS: lc_header TYPE xstring VALUE 'B0'.

    ASSERT io_stream->eat_hex( 1 ) = lc_header.

    io_stream->eat_length( ).

    mv_packet_identifier = io_stream->eat_hex( 2 ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

    ASSERT NOT mv_packet_identifier IS INITIAL.
    lo_payload->add_hex( mv_packet_identifier ).

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-unsuback.

  ENDMETHOD.
ENDCLASS.
