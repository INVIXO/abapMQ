
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_mqtt_packet_unsubscribe.

    METHODS:
      setup,
      test FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW #( ).

  ENDMETHOD.

  METHOD test.

*mo_cut->set_topics( value #( ( |foobar| ) ) ).
*data(sdf) = mo_cut->zif_mqtt_packet~encode( )->get_hex( ).
*break-point.

    CONSTANTS: lc_hex TYPE xstring VALUE 'A20A00010006666F6F626172'.

    DATA(lo_stream) = NEW zcl_mqtt_stream( lc_hex ).

    mo_cut->zif_mqtt_packet~decode( lo_stream ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_topics( )
      exp = VALUE zif_mqtt_packet=>ty_topics_tt( ( |foobar| ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->zif_mqtt_packet~encode( )->get_hex( )
      exp = lc_hex ).

  ENDMETHOD.

ENDCLASS.
