interface ZIF_MQTT_TRANSPORT
  public .


  methods CONNECT
    raising
      ZCX_MQTT .
  methods DISCONNECT
    raising
      ZCX_MQTT .
  methods SEND
    importing
      !II_PACKET type ref to ZIF_MQTT_PACKET
    raising
      ZCX_MQTT .
  methods LISTEN
    importing
      !IV_TIMEOUT type I
    returning
      value(RI_PACKET) type ref to ZIF_MQTT_PACKET
    raising
      ZCX_MQTT .
endinterface.
