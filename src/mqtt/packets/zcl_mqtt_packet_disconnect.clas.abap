CLASS zcl_mqtt_packet_disconnect DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_packet .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_PACKET_DISCONNECT IMPLEMENTATION.


  METHOD zif_mqtt_packet~decode.

    ASSERT io_stream->eat_hex( 2 ) = 'E000'.

  ENDMETHOD.


  METHOD zif_mqtt_packet~encode.

    ro_stream = NEW #( ).

    ro_stream->add_packet( me ).

  ENDMETHOD.


  METHOD zif_mqtt_packet~get_type.

    rv_value = zif_mqtt_constants=>gc_packets-disconnect.

  ENDMETHOD.
ENDCLASS.
