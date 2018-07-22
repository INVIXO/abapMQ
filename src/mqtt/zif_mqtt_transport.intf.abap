interface ZIF_MQTT_TRANSPORT
  public .


  methods CONNECT
    raising
      CX_APC_ERROR .
  methods DISCONNECT
    raising
      CX_APC_ERROR .
  methods SEND
    importing
      !II_PACKET type ref to ZIF_MQTT_PACKET
    raising
      ZCX_MQTT
      CX_APC_ERROR .
  methods LISTEN
    importing
      !IV_TIMEOUT type I
    returning
      value(RI_PACKET) type ref to ZIF_MQTT_PACKET
    raising
      ZCX_MQTT .
endinterface.
