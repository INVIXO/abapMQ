
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_mqtt_packet_suback.

    METHODS:
      setup,
      decode FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW #( ).

  ENDMETHOD.

  METHOD decode.

    DATA(lo_stream) = NEW zcl_mqtt_stream( '9003000100' ).

    mo_cut->zif_mqtt_packet~decode( lo_stream ).

    DATA(lt_expected) = VALUE zcl_mqtt_packet_suback=>ty_return_codes( ( CONV #( '00' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_return_codes( )
      exp = lt_expected ).

  ENDMETHOD.

ENDCLASS.
