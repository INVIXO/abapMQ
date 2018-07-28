CLASS zcl_mqtt_packet_pingreq DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_packet .

    ALIASES decode
      FOR zif_mqtt_packet~decode .
    ALIASES encode
      FOR zif_mqtt_packet~encode .
    ALIASES get_type
      FOR zif_mqtt_packet~get_type .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_PINGREQ IMPLEMENTATION.


  METHOD zif_mqtt_packet~decode.

    ASSERT io_stream->eat_hex( 2 ) = 'C000'.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    ro_stream = NEW #( ).

    ro_stream->add_packet( me ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-pingreq.

  ENDMETHOD.
ENDCLASS.
