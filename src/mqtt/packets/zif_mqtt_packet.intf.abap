interface ZIF_MQTT_PACKET
  public .


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
