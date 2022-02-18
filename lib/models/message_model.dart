class MessageModel {
  //message data model
  String msgText;
  String? userId;
  bool isMe;
  String? eventType;
  String? myId;

  MessageModel({required this.msgText, this.userId, required this.isMe, this.eventType, this.myId});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'text': msgText,
  };
}