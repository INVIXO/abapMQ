
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS: test FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test.

    DATA(lo_connect) = NEW zcl_mqtt_packet_disconnect( ).

    DATA(lv_hex) = lo_connect->zif_mqtt_packet~encode( )->get_hex( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_hex
      exp = 'E000' ).

  ENDMETHOD.

ENDCLASS.
