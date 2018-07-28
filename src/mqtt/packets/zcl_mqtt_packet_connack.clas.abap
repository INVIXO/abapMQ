CLASS zcl_mqtt_packet_connack DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_packet .

    TYPES:
      ty_return_code TYPE x LENGTH 1 .

    CONSTANTS:
      BEGIN OF gc_return_code,
        accepted                 TYPE ty_return_code VALUE '00',
        unacceptabe_protocol     TYPE ty_return_code VALUE '01',
        identifer_rejected       TYPE ty_return_code VALUE '02',
        server_unavailable       TYPE ty_return_code VALUE '03',
        bad_username_or_password TYPE ty_return_code VALUE '04',
        not_authorized           TYPE ty_return_code VALUE '05',
      END OF gc_return_code .

    METHODS get_session_present
      RETURNING
        VALUE(rv_session_present) TYPE abap_bool .
    METHODS get_return_code
      RETURNING
        VALUE(rv_return_code) TYPE ty_return_code .
  PROTECTED SECTION.

    DATA mv_session_present TYPE abap_bool .
    DATA mv_return_code TYPE ty_return_code .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_CONNACK IMPLEMENTATION.


  METHOD get_return_code.

    rv_return_code = mv_return_code.

  ENDMETHOD.


  METHOD get_session_present.

    rv_session_present = mv_session_present.

  ENDMETHOD.


  METHOD zif_mqtt_packet~decode.

    CONSTANTS: lc_header TYPE xstring VALUE '2002'.

    ASSERT io_stream->eat_hex( 2 ) = lc_header.

    CASE io_stream->eat_hex( 1 ).
      WHEN '00'.
        mv_session_present = abap_false.
      WHEN '01'.
        mv_session_present = abap_true.
      WHEN OTHERS.
        ASSERT 0 = 1.
    ENDCASE.

    mv_return_code = io_stream->eat_hex( 1 ).

    ASSERT io_stream->get_length( ) = 0.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

    IF mv_session_present = abap_true.
      lo_payload->add_hex( '01' ).
    ELSE.
      lo_payload->add_hex( '00' ).
    ENDIF.

    lo_payload->add_hex( mv_return_code ).

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-connack.

  ENDMETHOD.
ENDCLASS.
