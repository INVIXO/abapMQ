
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS:
      test FOR TESTING,
      test_new FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test.

    CONSTANTS: lc_hex TYPE xstring VALUE '100C00044D5154540402001E0000'.

    DATA(lo_encoded) = NEW zcl_mqtt_packet_connect( ).

    DATA(lv_hex) = lo_encoded->zif_mqtt_packet~encode( )->get_hex( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_hex
      exp = lc_hex ).

  ENDMETHOD.

  METHOD test_new.

    CONSTANTS: lc_hex TYPE xstring VALUE '100C00044D5154540402001E0000'.

    DATA(lo_connect) = NEW zcl_mqtt_packet_connect( ).
    lo_connect->zif_mqtt_packet~decode( NEW zcl_mqtt_stream( lc_hex ) ).

    DATA(lv_hex) = lo_connect->zif_mqtt_packet~encode( )->get_hex( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_hex
      exp = lc_hex ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_flags DEFINITION DEFERRED.
CLASS zcl_mqtt_packet_connect DEFINITION LOCAL FRIENDS ltcl_flags.

CLASS ltcl_flags DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA: mo_cut TYPE REF TO zcl_mqtt_packet_connect.

    METHODS: setup,
      test FOR TESTING.

ENDCLASS.


CLASS ltcl_flags IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test.

    CONSTANTS: lc_hex TYPE x LENGTH 1 VALUE '02'.

    DATA: ls_flags TYPE zcl_mqtt_packet_connect=>ty_flags.


    ls_flags = mo_cut->decode_flags( lc_hex ).

    DATA(ls_expected) = VALUE zcl_mqtt_packet_connect=>ty_flags(
      username      = abap_false
      password      = abap_false
      will_retain   = abap_false
      will_qos      = zif_mqtt_packet=>gc_qos-at_most_once
      will_flag     = abap_false
      clean_session = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_flags
      exp = ls_expected ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->encode_flags( ls_flags )
      exp = CONV xstring( lc_hex ) ).

  ENDMETHOD.

ENDCLASS.
