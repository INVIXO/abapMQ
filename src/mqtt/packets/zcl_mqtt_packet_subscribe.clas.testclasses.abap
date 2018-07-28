
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_mqtt_packet_subscribe.

    METHODS:
      setup,
      encode FOR TESTING,
      test FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW #( ).

  ENDMETHOD.

  METHOD encode.

    mo_cut->set_topics( VALUE #( ( topic = |something| ) ) ).
    mo_cut->set_packet_identifier( '0001' ).

    DATA(lv_hex) = mo_cut->zif_mqtt_packet~encode( )->get_hex( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_hex
      exp = '820E00010009736F6D657468696E6700' ).

  ENDMETHOD.

  METHOD test.

    CONSTANTS: lc_hex TYPE xstring VALUE '820E00010009736F6D657468696E6700'.

    DATA(lo_stream) = NEW zcl_mqtt_stream( lc_hex ).

    mo_cut->zif_mqtt_packet~decode( lo_stream ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->zif_mqtt_packet~encode( )->get_hex( )
      exp = lc_hex ).

  ENDMETHOD.

ENDCLASS.
