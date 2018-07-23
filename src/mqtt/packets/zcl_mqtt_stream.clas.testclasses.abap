
CLASS ltcl_eat_packet DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_mqtt_stream.

    METHODS:
      setup,
      connack FOR TESTING.

ENDCLASS.

CLASS ltcl_eat_packet IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD connack.

    DATA(li_packet) = mo_cut->add_hex( '20020000' )->eat_packet( ).

    cl_abap_unit_assert=>assert_equals(
      act = li_packet->get_type( )
      exp = zif_mqtt_constants=>gc_packets-connack ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_stream DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_mqtt_stream.

    METHODS:
      setup,
      utf8 FOR TESTING,
      peek FOR TESTING,
      add_n_eat FOR TESTING.

ENDCLASS.


CLASS ltcl_stream IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD peek.

    CONSTANTS: lc_hex TYPE xstring VALUE '12'.

    mo_cut->add_hex( lc_hex ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->peek_hex( 1 )
      exp = lc_hex ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_length( )
      exp = 1 ).

  ENDMETHOD.

  METHOD utf8.

    CONSTANTS: lc_str TYPE string VALUE 'MQTT'.

    DATA(lv_hex) = mo_cut->add_utf8( lc_str )->get_hex( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_hex
      exp = '00044D515454' ).

    DATA(lv_str) = mo_cut->eat_utf8( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_str
      exp = lc_str ).

  ENDMETHOD.

  METHOD add_n_eat.

    CONSTANTS: lc_hex TYPE xstring VALUE '1122'.

    mo_cut->add_hex( lc_hex ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_length( )
      exp = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->eat_hex( 2 )
      exp = lc_hex ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_length( )
      exp = 0 ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_length DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_mqtt_stream.

    METHODS:
      setup,
      test IMPORTING iv_hex    TYPE xstring
                     iv_length TYPE i,
      test01 FOR TESTING,
      test02 FOR TESTING,
      test03 FOR TESTING,
      test04 FOR TESTING,
      test05 FOR TESTING,
      test06 FOR TESTING.

ENDCLASS.

CLASS ltcl_length IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test.

    DATA(lv_length) = mo_cut->add_hex( iv_hex )->eat_length( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_length
      exp = iv_length ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_length( )
      exp = 0 ).

    mo_cut->add_length( iv_length ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_hex( )
      exp = iv_hex ).

  ENDMETHOD.

  METHOD test01.

    test( iv_hex    = '02'
          iv_length = 2 ).

  ENDMETHOD.

  METHOD test02.

    test( iv_hex    = '8610'
          iv_length = 2054 ).

  ENDMETHOD.

  METHOD test03.

    test( iv_hex    = '86808001'
          iv_length = 2097158 ).

  ENDMETHOD.

  METHOD test04.

    test( iv_hex    = '80808001'
          iv_length = 2097152 ).

  ENDMETHOD.

  METHOD test05.

    test( iv_hex    = '7F'
          iv_length = 127 ).

  ENDMETHOD.

  METHOD test06.

    test( iv_hex    = '00'
          iv_length = 0 ).

  ENDMETHOD.

ENDCLASS.
