INTERFACE zif_mqtt_transport PUBLIC.


  METHODS connect
    RAISING
      cx_apc_error .
  METHODS disconnect
    RAISING
      cx_apc_error .
  METHODS send
    IMPORTING
      !ii_packet TYPE REF TO zif_mqtt_packet
    RAISING
      zcx_mqtt
      cx_apc_error .
  METHODS listen
    IMPORTING
      !iv_timeout      TYPE i
    RETURNING
      VALUE(ri_packet) TYPE REF TO zif_mqtt_packet
    RAISING
      zcx_mqtt .
ENDINTERFACE.
