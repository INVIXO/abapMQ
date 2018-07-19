
CLASS ltcl_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS: test FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test.

    DATA(lo_connect) = NEW zcl_mqtt_packet_connect( ).

    lo_connect->zif_mqtt_packet~encode( ).


  ENDMETHOD.

ENDCLASS.
