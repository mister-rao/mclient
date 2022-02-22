

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

class RoomsModel extends MessageModel{
  List<dynamic> rooms;
  RoomsModel({required this.rooms, required msgText, required userId, required isMe, required eventType, required myId})
      : super(msgText: msgText, isMe: isMe, eventType: eventType, myId: myId, userId: userId);

}