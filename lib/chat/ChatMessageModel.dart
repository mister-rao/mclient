import 'dart:convert';

import 'package:mclient/chat/models.dart';

ChatMessageModel chatMessageModelFromJson(String str) =>
    ChatMessageModel.fromJson(json.decode(str));

String chatMessageModelToJson(ChatMessageModel data) =>
    json.encode(data.toJson());

class ChatMessageModel {
  String? chatId;
  String? to;
  String? from;
  String? message;
  String? chatType;
  bool? toUserOnlineStatus;

  ChatMessageModel({
    this.chatId,
    this.to,
    this.from,
    this.message,
    this.chatType,
    this.toUserOnlineStatus,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        chatId: json["chat_id"],
        to: json["to"],
        from: json["from"],
        message: json["message"],
        chatType: json["chat_type"],
        toUserOnlineStatus: json['to_user_online_status'],
      );

  Map<String, dynamic> toJson() => {
        "chat_id": chatId,
        "to": to,
        "from": from,
        "message": message,
        "chat_type": chatType,
      };

  factory ChatMessageModel.dummy() => ChatMessageModel(
        chatId: '00',
        to: '0',
        from: '0',
        message: 'xx',
        chatType: 'xx',
        toUserOnlineStatus: false,
      );
}
