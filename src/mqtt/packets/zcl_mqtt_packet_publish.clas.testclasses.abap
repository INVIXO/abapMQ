
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO zcl_mqtt_packet_publish.

    METHODS:
      setup,
      decode FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW #( ).

  ENDMETHOD.

  METHOD decode.

    CONSTANTS: lc_topic   TYPE string VALUE 'topic',
               lc_message TYPE xstring VALUE '001122334455'.


    mo_cut->set_message( VALUE #(
      topic   = lc_topic
      message = lc_message ) ).

    mo_cut->zif_mqtt_packet~decode( mo_cut->zif_mqtt_packet~encode( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_message( )-topic
      exp = lc_topic ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_message( )-message
      exp = lc_message ).

  ENDMETHOD.

ENDCLASS.
