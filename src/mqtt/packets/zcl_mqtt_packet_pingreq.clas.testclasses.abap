
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mi_cut TYPE REF TO zif_mqtt_packet.

    METHODS:
      setup,
      test FOR TESTING.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.
    mi_cut = NEW zcl_mqtt_packet_pingreq( ).
  ENDMETHOD.

  METHOD test.

    DATA(lv_hex) = mi_cut->encode( )->get_hex( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_hex
      exp = 'C000' ).

  ENDMETHOD.

ENDCLASS.
