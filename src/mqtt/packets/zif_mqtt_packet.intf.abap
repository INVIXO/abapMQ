INTERFACE zif_mqtt_packet
  PUBLIC .


  TYPES ty_qos TYPE i.

  TYPES:
    BEGIN OF ty_message,
      topic   TYPE string,
      message TYPE xstring,
    END OF ty_message .

  CONSTANTS: BEGIN OF gc_qos,
               at_most_once  TYPE ty_qos VALUE 0,
               at_least_once TYPE ty_qos VALUE 1,
               exactly_once  TYPE ty_qos VALUE 2,
             END OF gc_qos.

  METHODS get_type
    RETURNING
      VALUE(rv_value) TYPE i .
  METHODS encode
    RETURNING
      VALUE(ro_stream) TYPE REF TO zcl_mqtt_stream .
  METHODS decode
    IMPORTING
      !io_stream TYPE REF TO zcl_mqtt_stream .
ENDINTERFACE.
