import 'package:json_annotation/json_annotation.dart';
part 'ws_responses_model.g.dart';


class MatrixUser {
  final String matrixUserId;
  final String name;

  MatrixUser({required this.matrixUserId, required this.name});
}


@JsonSerializable(fieldRename: FieldRename.snake)
class MatrixLoginResponse{
  String? error;
  final String matrixToken;
  final String deviceId;
  final String matrixUserId;


  MatrixLoginResponse({required this.matrixToken, required this.deviceId, required this.matrixUserId});

  factory MatrixLoginResponse.fromJson(Map<String, dynamic> json) => _$MatrixLoginResponseFromJson(json);

}

@JsonSerializable(fieldRename: FieldRename.snake)
class MatrixGetProfileResponse{
  final String displayName;
  final String? avatarUrl;

  MatrixGetProfileResponse({required this.displayName, required this.avatarUrl});

  factory MatrixGetProfileResponse.fromJson(Map<String, dynamic> json) => _$MatrixGetProfileResponseFromJson(json);

}

@JsonSerializable(fieldRename: FieldRename.snake)
class MatrixGetJoinedRoomsResponse {
    final List<dynamic> rooms;

    MatrixGetJoinedRoomsResponse({required this.rooms});
}


class MessageReceivedEvent {
  final String roomName;
  final String sender;
  final String senderId;
  final String body;
  final String roomId;


  MessageReceivedEvent({required this.sender,
    required this.body, required this.roomName,
    required this.senderId, required this.roomId, });

}