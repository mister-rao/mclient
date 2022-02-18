class MessageModel {
  //message data model
  String msgText;
  String? userId;
  bool isMe;

  MessageModel({required this.msgText, this.userId, required this.isMe});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'text': msgText,
  };
}