class ZCL_MQTT_PACKET_CONNACK definition
  public
  create public .

public section.

  interfaces ZIF_MQTT_PACKET .

  types:
    ty_return_code TYPE x LENGTH 1 .

  constants:
    BEGIN OF gc_return_code,
                 accepted                 TYPE ty_return_code VALUE '00',
                 unacceptabe_protocol     TYPE ty_return_code VALUE '01',
                 identifer_rejected       TYPE ty_return_code VALUE '02',
                 server_unavailable       TYPE ty_return_code VALUE '03',
                 bad_username_or_password TYPE ty_return_code VALUE '04',
                 not_authorized           TYPE ty_return_code VALUE '05',
               END OF gc_return_code .

  methods GET_SESSION_PRESENT
    returning
      value(RV_SESSION_PRESENT) type ABAP_BOOL .
  methods GET_RETURN_CODE
    returning
      value(RV_RETURN_CODE) type TY_RETURN_CODE .
protected section.

  data MV_SESSION_PRESENT type ABAP_BOOL .
  data MV_RETURN_CODE type TY_RETURN_CODE .
private section.
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
