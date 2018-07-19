
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS: encode FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD encode.

    DATA(lo_subscribe) = NEW zcl_mqtt_packet_subscribe( ).

    lo_subscribe->set_topics( VALUE #( ( |something| ) ) ).

    DATA(lv_hex) = lo_subscribe->zif_mqtt_packet~encode( )->get_hex( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_hex
      exp = '001122334455' ).

  ENDMETHOD.

ENDCLASS.
