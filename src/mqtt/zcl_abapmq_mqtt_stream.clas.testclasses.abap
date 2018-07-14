
CLASS ltcl_utf8 DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_abapmq_mqtt_stream.

    METHODS:
      setup,
      test01 FOR TESTING.

ENDCLASS.


CLASS ltcl_utf8 IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test01.

    DATA(lv_hex) = mo_cut->add_utf8( 'MQTT' )->get_hex( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_hex
      exp = '00044D515454' ).

  ENDMETHOD.

ENDCLASS.
