class ZCL_ABAPMQ_MQTT_TRANSPORT definition
  public
  final
  create public .

public section.

  methods CONNECT
    importing
      !IV_HOST type CSEQUENCE
      !IV_PORT type I
      !II_HANDLER type ref to ZIF_ABAPMQ_MQTT_HANDLER .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPMQ_MQTT_TRANSPORT IMPLEMENTATION.


  method CONNECT.
  endmethod.
ENDCLASS.
