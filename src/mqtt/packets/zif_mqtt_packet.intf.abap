interface ZIF_MQTT_PACKET
  public .


  types TY_QOS type I .
  types:
    ty_packet_identifier TYPE x LENGTH 2 .
  types TY_TOPIC type STRING .
  types:
    BEGIN OF ty_message,
      topic   TYPE ty_topic,
      message TYPE xstring,
    END OF ty_message .
  types:
    ty_topics_tt TYPE STANDARD TABLE OF ty_topic WITH EMPTY KEY .

  constants:
    BEGIN OF gc_qos,
               at_most_once  TYPE ty_qos VALUE 0,
               at_least_once TYPE ty_qos VALUE 1,
               exactly_once  TYPE ty_qos VALUE 2,
             END OF gc_qos .

  methods GET_TYPE
    returning
      value(RV_VALUE) type I .
  methods ENCODE
    returning
      value(RO_STREAM) type ref to ZCL_MQTT_STREAM .
  methods DECODE
    importing
      !IO_STREAM type ref to ZCL_MQTT_STREAM .
endinterface.
