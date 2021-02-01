CLASS zcl_mqtt_transport_tcp DEFINITION
  PUBLIC
  CREATE PROTECTED .

  PUBLIC SECTION.

    INTERFACES zif_mqtt_transport .
    INTERFACES if_apc_wsp_event_handler .
    INTERFACES if_apc_wsp_event_handler_base .

    CLASS-METHODS create
      IMPORTING
        !iv_host            TYPE string
        !iv_port            TYPE string
        iv_protocol         TYPE i DEFAULT cl_apc_tcp_client_manager=>co_protocol_type_tcp
      RETURNING
        VALUE(ri_transport) TYPE REF TO zif_mqtt_transport
      RAISING
        cx_apc_error .
  PROTECTED SECTION.

    TYPES:
      ty_byte TYPE x LENGTH 1 .

    DATA:
      BEGIN OF ms_message,
        received TYPE abap_bool,
        message  TYPE x LENGTH 1,
      END OF ms_message .
    DATA mi_client TYPE REF TO if_apc_wsp_client .

    METHODS receive_byte
      IMPORTING
        !iv_timeout    TYPE i
      RETURNING
        VALUE(rv_byte) TYPE ty_byte
      RAISING
        zcx_mqtt_timeout .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MQTT_TRANSPORT_TCP IMPLEMENTATION.


  METHOD create.

    DATA(lo_tcp) = NEW zcl_mqtt_transport_tcp( ).

    DATA(ls_frame) = VALUE apc_tcp_frame(
      frame_type   = if_apc_tcp_frame_types=>co_frame_type_fixed_length
      fixed_length = 1 ).

    lo_tcp->mi_client = cl_apc_tcp_client_manager=>create(
      i_protocol      = iv_protocol
      i_host          = iv_host
      i_port          = iv_port
      i_frame         = ls_frame
      i_event_handler = lo_tcp ).

    ri_transport ?= lo_tcp.

  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_close.

* todo?
    RETURN.

  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_error.

* todo?
    RETURN.

  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_message.

    ms_message-received = abap_true.
    TRY.
        ms_message-message = i_message->get_binary( ).
      CATCH cx_apc_error.
        ASSERT 0 = 1. " todo
    ENDTRY.

  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_open.

    RETURN.

  ENDMETHOD.


  METHOD receive_byte.

    CLEAR ms_message.
    WAIT FOR PUSH CHANNELS UNTIL ms_message IS NOT INITIAL UP TO iv_timeout SECONDS.
    IF sy-subrc = 0.
      rv_byte = ms_message-message.
    ELSE.
      RAISE EXCEPTION TYPE zcx_mqtt_timeout.
    ENDIF.

  ENDMETHOD.


  METHOD zif_mqtt_transport~connect.

    mi_client->connect( ).

  ENDMETHOD.


  METHOD zif_mqtt_transport~disconnect.

    mi_client->close( ).

  ENDMETHOD.


  METHOD zif_mqtt_transport~listen.

    DATA: lv_length     TYPE i,
          lv_multiplier TYPE i VALUE 1.


    DATA(lo_stream) = NEW zcl_mqtt_stream( ).

    DATA(lv_byte) = receive_byte( iv_timeout ).
    lo_stream->add_hex( lv_byte ).

    DO.
      ASSERT sy-index <= 4.

      lv_byte = receive_byte( iv_timeout ).
      lo_stream->add_hex( lv_byte ).

      lv_length = lv_length + ( lv_byte MOD 128 ) * lv_multiplier.
      lv_multiplier = lv_multiplier * 128.

      IF lv_byte < 128.
        EXIT.
      ENDIF.
    ENDDO.

    DO lv_length TIMES.
      lv_byte = receive_byte( iv_timeout ).
      lo_stream->add_hex( lv_byte ).
    ENDDO.

    ri_packet = lo_stream->eat_packet( ).

  ENDMETHOD.


  METHOD zif_mqtt_transport~send.

    DATA: li_msgmgr TYPE REF TO if_apc_wsp_message_manager.

    li_msgmgr ?= mi_client->get_message_manager( ).
    DATA(li_message) = li_msgmgr->create_message( ).

    DATA(lv_hex) = ii_packet->encode( )->get_hex( ).

    WHILE xstrlen( lv_hex ) > 0.
      DATA(lv_single) = lv_hex(1).
      li_message->set_binary( lv_single ).
      li_msgmgr->send( li_message ).
      lv_hex = lv_hex+1.
    ENDWHILE.

  ENDMETHOD.
ENDCLASS.
