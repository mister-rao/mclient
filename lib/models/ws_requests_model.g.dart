// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_requests_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatrixLoginRequest _$MatrixLoginRequestFromJson(Map<String, dynamic> json) =>
    MatrixLoginRequest(
      token: json['token'] as String,
    )..eventType = json['event_type'] as String;

Map<String, dynamic> _$MatrixLoginRequestToJson(MatrixLoginRequest instance) =>
    <String, dynamic>{
      'event_type': instance.eventType,
      'token': instance.token,
    };

GetRoomsRequest _$GetRoomsRequestFromJson(Map<String, dynamic> json) =>
    GetRoomsRequest()..eventType = json['event_type'] as String;

Map<String, dynamic> _$GetRoomsRequestToJson(GetRoomsRequest instance) =>
    <String, dynamic>{
      'event_type': instance.eventType,
    };

SyncChatServerRequest _$SyncChatServerRequestFromJson(
        Map<String, dynamic> json) =>
    SyncChatServerRequest()..eventType = json['event_type'] as String;

Map<String, dynamic> _$SyncChatServerRequestToJson(
        SyncChatServerRequest instance) =>
    <String, dynamic>{
      'event_type': instance.eventType,
    };

CreateRoomRequest _$CreateRoomRequestFromJson(Map<String, dynamic> json) =>
    CreateRoomRequest(
      inviteId:
          (json['invite_id'] as List<dynamic>).map((e) => e as String).toList(),
      roomName: json['room_name'] as String,
    );

Map<String, dynamic> _$CreateRoomRequestToJson(CreateRoomRequest instance) =>
    <String, dynamic>{
      'event_type': instance.eventType,
      'invite': instance.inviteId,
      'room_name': instance.roomName,
    };

SendMessageToRoomRequest _$SendMessageToRoomRequestFromJson(
        Map<String, dynamic> json) =>
    SendMessageToRoomRequest(
      roomId: json['room_id'] as String,
      message: json['message'] as String,
    )
      ..eventType = json['event_type'] as String
      ..messageType = json['message_type'] as String
      ..msgType = json['msg_type'] as String;

Map<String, dynamic> _$SendMessageToRoomRequestToJson(
        SendMessageToRoomRequest instance) =>
    <String, dynamic>{
      'event_type': instance.eventType,
      'message_type': instance.messageType,
      'msg_type': instance.msgType,
      'room_id': instance.roomId,
      'message': instance.message,
    };
