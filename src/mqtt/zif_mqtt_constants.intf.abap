INTERFACE zif_mqtt_constants
  PUBLIC .


  CONSTANTS: BEGIN OF gc_packets,
               connect     TYPE i VALUE 1,
               connack     TYPE i VALUE 2,
               publish     TYPE i VALUE 3,
               puback      TYPE i VALUE 4,
               pubrec      TYPE i VALUE 5,
               pubrel      TYPE i VALUE 6,
               pubcomp     TYPE i VALUE 7,
               subscribe   TYPE i VALUE 8,
               suback      TYPE i VALUE 9,
               unsubscribe TYPE i VALUE 10,
               unsuback    TYPE i VALUE 11,
               pingreq     TYPE i VALUE 12,
               pingresp    TYPE i VALUE 13,
               disconnect  TYPE i VALUE 14,
             END OF gc_packets.

ENDINTERFACE.
