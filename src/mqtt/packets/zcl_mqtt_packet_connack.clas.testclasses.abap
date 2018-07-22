
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_mqtt_packet_connack.

    METHODS:
      setup,
      decode FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW #( ).

  ENDMETHOD.

  METHOD decode.

    DATA(lo_stream) = NEW zcl_mqtt_stream( '20020000' ).

    mo_cut->zif_mqtt_packet~decode( lo_stream ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_return_code( )
      exp = '00' ).

  ENDMETHOD.

ENDCLASS.
