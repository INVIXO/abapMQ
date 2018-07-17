class ZCL_ABAPMQ_MQTT_STREAM definition
  public
  create public .

public section.

  methods EAT_UTF8
    returning
      value(RV_STRING) type STRING .
  methods ADD_HEX
    importing
      !IV_HEX type XSEQUENCE
    returning
      value(RO_STREAM) type ref to ZCL_ABAPMQ_MQTT_STREAM .
  methods ADD_PACKET
    importing
      !II_PACKET type ref to ZIF_MQTT_PACKET
      !IO_PAYLOAD type ref to ZCL_ABAPMQ_MQTT_STREAM optional
      !IV_FLAGS type I default 0
    returning
      value(RO_STREAM) type ref to ZCL_ABAPMQ_MQTT_STREAM .
  methods ADD_STREAM
    importing
      !IO_STREAM type ref to ZCL_ABAPMQ_MQTT_STREAM .
  methods ADD_UTF8
    importing
      !IV_STRING type CSEQUENCE
    returning
      value(RO_STREAM) type ref to ZCL_ABAPMQ_MQTT_STREAM .
  methods CONSTRUCTOR
    importing
      !IV_HEX type XSEQUENCE optional .
  methods GET_HEX
    returning
      value(RV_HEX) type XSTRING .
  methods GET_LENGTH
    returning
      value(RV_LENGTH) type I .
  methods EAT_HEX
    importing
      !IV_LENGTH type I
    returning
      value(RV_HEX) type XSTRING .
protected section.

  data MV_HEX type XSTRING .
private section.
ENDCLASS.



CLASS ZCL_ABAPMQ_MQTT_STREAM IMPLEMENTATION.


  METHOD add_hex.

    CONCATENATE mv_hex iv_hex INTO mv_hex IN BYTE MODE.

    ro_stream = me.

  ENDMETHOD.


  METHOD add_packet.

    DATA: lv_byte1 TYPE x,
          lv_byte2 TYPE x.


    lv_byte1 = ii_packet->get_type( ) * 16 + iv_flags.

    add_hex( lv_byte1 ).

    IF io_payload IS SUPPLIED.
      lv_byte2 = io_payload->get_length( ). " todo, handle properly
    ENDIF.

    add_hex( lv_byte2 ).

    IF io_payload IS SUPPLIED.
      add_stream( io_payload ).
    ENDIF.

  ENDMETHOD.


  METHOD add_stream.

    DATA: lv_hex TYPE xstring.


    lv_hex = io_stream->get_hex( ).

    CONCATENATE mv_hex lv_hex INTO mv_hex IN BYTE MODE.

  ENDMETHOD.


  METHOD add_utf8.

    DATA: lv_str TYPE xstring,
          lv_len TYPE x LENGTH 2.


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
ENDCLASS.
