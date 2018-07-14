interface ZIF_ABAPMQ_MQTT_PACKET
  public .


  methods GET_TYPE
    returning
      value(RV_VALUE) type I .
  methods ENCODE
    returning
      value(RO_STREAM) type ref to ZCL_ABAPMQ_MQTT_STREAM .
endinterface.
