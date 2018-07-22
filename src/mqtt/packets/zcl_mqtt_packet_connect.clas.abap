class ZCL_MQTT_PACKET_CONNECT definition
  public
  create public .

public section.

  interfaces ZIF_MQTT_PACKET .

  methods CONSTRUCTOR
    importing
      !IV_CLEAN_SESSION type ABAP_BOOL default ABAP_TRUE
      !IV_USERNAME type STRING optional
      !IV_PASSWORD type STRING optional
      !IV_CLIENT_ID type STRING optional
      !IV_KEEP_ALIVE type I default 30 .
protected section.

  types:
    BEGIN OF ty_flags,
      username      TYPE abap_bool,
      password      TYPE abap_bool,
      will_retain   TYPE abap_bool,
      will_qos      TYPE zif_mqtt_packet=>ty_qos,
      will_flag     TYPE abap_bool,
      clean_session TYPE abap_bool,
    END OF ty_flags .

  constants LC_PROTOCOL_NAME type STRING value 'MQTT' ##NO_TEXT.
  constants LC_PROTOCOL_LEVEL type XSTRING value '04' ##NO_TEXT.
  data MV_USERNAME type STRING .
  data MV_PASSWORD type XSTRING .
  data MV_CLIENT_ID type STRING .
  data MV_WILL_QOS type ZIF_MQTT_PACKET=>TY_QOS .
  data MS_WILL_MESSAGE type ZIF_MQTT_PACKET=>TY_MESSAGE .
  data MV_WILL_RETAIN type ABAP_BOOL .
  data:
    mv_keep_alive TYPE x LENGTH 2 .
  data MV_CLEAN_SESSION type ABAP_BOOL .

  class-methods DECODE_FLAGS
    importing
      !IV_HEX type XSEQUENCE
    returning
      value(RS_FLAGS) type TY_FLAGS .
  class-methods ENCODE_FLAGS
    importing
      !IS_FLAGS type TY_FLAGS
    returning
      value(RV_HEX) type XSTRING .
private section.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_CONNECT IMPLEMENTATION.


  METHOD constructor.

    mv_clean_session = iv_clean_session.
    mv_client_id     = iv_client_id.
    mv_keep_alive    = iv_keep_alive.
    mv_password      = iv_password.
    mv_username      = iv_username.

* todo
*ms_will_message
*mv_will_qos
*mv_will_retain

  ENDMETHOD.


  METHOD decode_flags.

    DATA: lv_int TYPE i.

    lv_int = iv_hex.

    IF lv_int DIV 128 = 1.
      rs_flags-username = abap_true.
    ENDIF.

    IF lv_int DIV 64 = 1.
      rs_flags-password = abap_true.
    ENDIF.

    IF lv_int DIV 32 = 1.
      rs_flags-will_retain = abap_true.
    ENDIF.

    rs_flags-will_qos = ( lv_int DIV 8 ) MOD 4.

    IF lv_int DIV 4 = 1.
      rs_flags-will_flag = abap_true.
    ENDIF.

    IF lv_int DIV 2 = 1.
      rs_flags-clean_session = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD encode_flags.

    DATA: lv_int TYPE i,
          lv_hex TYPE x LENGTH 1.


    IF is_flags-username = abap_true.
      lv_int = lv_int + 128.
    ENDIF.

    IF is_flags-password = abap_true.
      lv_int = lv_int + 64.
    ENDIF.

    IF is_flags-will_retain = abap_true.
      lv_int = lv_int + 32.
    ENDIF.

    lv_int = lv_int + is_flags-will_qos * 8.

    IF is_flags-will_flag = abap_true.
      lv_int = lv_int + 4.
    ENDIF.

    IF is_flags-clean_session = abap_true.
      lv_int = lv_int + 2.
    ENDIF.

    lv_hex = lv_int.
    rv_hex = lv_hex.

  ENDMETHOD.


  METHOD zif_mqtt_packet~decode.

* todo
    BREAK-POINT.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    DATA: lv_length TYPE x LENGTH 2.

    DATA(lo_payload) = NEW zcl_mqtt_stream( ).

    lo_payload->add_utf8( lc_protocol_name ).

    lo_payload->add_hex( lc_protocol_level ).

    lo_payload->add_hex( encode_flags( VALUE #(
      username      = boolc( NOT mv_username IS INITIAL )
      password      = boolc( NOT mv_password IS INITIAL )
      will_retain   = mv_will_retain
      will_qos      = mv_will_qos
      will_flag     = boolc( NOT ms_will_message IS INITIAL )
      clean_session = mv_clean_session ) ) ).

    lo_payload->add_hex( mv_keep_alive ).

    lo_payload->add_utf8( mv_client_id ).

    IF NOT ms_will_message IS INITIAL.
      lo_payload->add_utf8( ms_will_message-topic ).
      lv_length = xstrlen( ms_will_message-message ).
      lo_payload->add_hex( lv_length ).
      lo_payload->add_hex( ms_will_message-message ).
    ENDIF.

    IF NOT mv_username IS INITIAL.
      lo_payload->add_utf8( mv_username ).
    ENDIF.

    IF NOT mv_password IS INITIAL.
      lv_length = xstrlen( ms_will_message-message ).
      lo_payload->add_hex( lv_length ).
      lo_payload->add_hex( mv_password ).
    ENDIF.

    ro_stream = NEW #( ).

    ro_stream->add_packet(
      ii_packet  = me
      io_payload = lo_payload ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-connect.

  ENDMETHOD.
ENDCLASS.
