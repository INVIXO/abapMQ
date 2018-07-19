
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
