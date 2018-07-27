
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_mqtt_packet_pubrec.

    METHODS:
      setup,
      test FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW #( ).

  ENDMETHOD.

  METHOD test.

    CONSTANTS: lc_hex TYPE xstring VALUE '52020001'.

    DATA(lo_stream) = NEW zcl_mqtt_stream( lc_hex ).

    mo_cut->zif_mqtt_packet~decode( lo_stream ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->zif_mqtt_packet~encode( )->get_hex( )
      exp = lc_hex ).

  ENDMETHOD.

ENDCLASS.
