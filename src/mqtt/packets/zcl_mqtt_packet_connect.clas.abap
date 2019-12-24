CLASS zcl_mqtt_packet_connect DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_packet .

    METHODS constructor
      IMPORTING
        !iv_clean_session TYPE abap_bool DEFAULT abap_true
        !iv_username      TYPE string OPTIONAL
        !iv_password      TYPE string OPTIONAL
        !iv_client_id     TYPE string OPTIONAL
        iv_will_qos       TYPE zif_mqtt_packet=>ty_qos OPTIONAL
        is_will_message   TYPE zif_mqtt_packet=>ty_message OPTIONAL
        iv_will_retain    TYPE abap_bool OPTIONAL
        !iv_keep_alive    TYPE i DEFAULT 30 .
  PROTECTED SECTION.

    TYPES:
      BEGIN OF ty_flags,
        username      TYPE abap_bool,
        password      TYPE abap_bool,
        will_retain   TYPE abap_bool,
        will_qos      TYPE zif_mqtt_packet=>ty_qos,
        will_flag     TYPE abap_bool,
        clean_session TYPE abap_bool,
      END OF ty_flags .

    CONSTANTS lc_protocol_name TYPE string VALUE 'MQTT' ##NO_TEXT.
    CONSTANTS lc_protocol_level TYPE xstring VALUE '04' ##NO_TEXT.
    DATA mv_username TYPE string .
    DATA mv_password TYPE xstring .
    DATA mv_client_id TYPE string .
    DATA mv_will_qos TYPE zif_mqtt_packet=>ty_qos .
    DATA ms_will_message TYPE zif_mqtt_packet=>ty_message .
    DATA mv_will_retain TYPE abap_bool .
    DATA:
      mv_keep_alive TYPE x LENGTH 2 .
    DATA mv_clean_session TYPE abap_bool .

    CLASS-METHODS decode_flags
      IMPORTING
        !iv_hex         TYPE xsequence
      RETURNING
        VALUE(rs_flags) TYPE ty_flags .
    CLASS-METHODS encode_flags
      IMPORTING
        !is_flags     TYPE ty_flags
      RETURNING
        VALUE(rv_hex) TYPE xstring .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_CONNECT IMPLEMENTATION.


  METHOD constructor.

    mv_clean_session = iv_clean_session.
    mv_client_id     = iv_client_id.
    mv_keep_alive    = iv_keep_alive.
    mv_password      = cl_binary_convert=>string_to_xstring_utf8( CONV #( iv_password ) ).
    mv_username      = iv_username.
    ms_will_message  = is_will_message.
    mv_will_qos      = iv_will_qos.
    mv_will_retain   = iv_will_retain.

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

    DATA: lv_length TYPE i.

    ASSERT io_stream->eat_hex( 1 ) = '10'.
    io_stream->eat_length( ).
    ASSERT io_stream->eat_utf8( )  = lc_protocol_name.
    ASSERT io_stream->eat_hex( 1 ) = lc_protocol_level.

    DATA(ls_flags) = decode_flags( io_stream->eat_hex( 1 ) ).
    mv_clean_session = ls_flags-clean_session.
    mv_will_qos      = ls_flags-will_qos.
    mv_will_retain   = ls_flags-will_retain.

    mv_keep_alive = io_stream->eat_hex( 2 ).

    mv_client_id = io_stream->eat_utf8( ).

    IF ls_flags-will_flag = abap_true.
      ms_will_message-topic = io_stream->eat_utf8( ).
      lv_length = io_stream->eat_hex( 2 ).
      ms_will_message-message = io_stream->eat_hex( lv_length ).
    ENDIF.

    IF ls_flags-username = abap_true.
      mv_username = io_stream->eat_utf8( ).
    ENDIF.

    IF ls_flags-password = abap_true.
      lv_length = io_stream->eat_hex( 2 ).
      mv_password = io_stream->eat_hex( lv_length ).
    ENDIF.

    ASSERT io_stream->get_length( ) = 0.

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
      lv_length = xstrlen( mv_password ). " <-- fix, was xstrlen( ms_will_message-message ).
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
