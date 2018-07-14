class ZCL_ABAPMQ_MQTT_STREAM definition
  public
  create public .

public section.

  methods ADD_HEX
    importing
      !IV_HEX type XSEQUENCE
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
protected section.

  data MV_HEX type XSTRING .
private section.
ENDCLASS.



CLASS ZCL_ABAPMQ_MQTT_STREAM IMPLEMENTATION.


  METHOD add_hex.

    CONCATENATE mv_hex iv_hex INTO mv_hex IN BYTE MODE.

    ro_stream = me.

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


  METHOD get_hex.

    rv_hex = mv_hex.

  ENDMETHOD.


  METHOD get_length.

    rv_length = xstrlen( mv_hex ).

  ENDMETHOD.
ENDCLASS.
