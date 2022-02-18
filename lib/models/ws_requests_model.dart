import 'package:json_annotation/json_annotation.dart';

part 'ws_requests_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MatrixLoginRequest{ //message data model
  String eventType = "matrix_jwt_login";
  final String token;
  MatrixLoginRequest({required this.token});

  Map<String, dynamic> toJson() => _$MatrixLoginRequestToJson(this);

}

@JsonSerializable(fieldRename: FieldRename.snake)
class GetRoomsRequest{ //message data model
  String eventType = "get_rooms";

  Map<String, dynamic> toJson() => _$GetRoomsRequestToJson(this);

}


@JsonSerializable(fieldRename: FieldRename.snake)
class SyncChatServerRequest{ //message data model
  String eventType = "sync";

  Map<String, dynamic> toJson() => _$SyncChatServerRequestToJson(this);

}


@JsonSerializable(fieldRename: FieldRename.snake)
class SendMessageToRoomRequest {
  String eventType = "send_message";
  String messageType = "m.room.message";
  String msgType = "m.text";
  final String roomId;
  final String message;

  SendMessageToRoomRequest({required this.roomId, required this.message});

  Map<String, dynamic> toJson() => _$SendMessageToRoomRequestToJson(this);


  Map<String, dynamic> _$SendMessageToRoomRequestToJson(SendMessageToRoomRequest instance) =>
      <String, dynamic>{
        "event_type": instance.eventType,
        "room_id": instance.roomId,
        "message_type": instance.messageType,
        "content": {
          "msgtype": instance.msgType,
          "body": instance.message
        }
      };

}