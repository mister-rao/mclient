part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class ConnectWebSocketEvent extends ChatEvent{
  ConnectWebSocketEvent();

  @override
  List<Object> get props => [];

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => super.hashCode;
}

class CreateRoomEvent extends ChatEvent{
  final String inviteId;
  final String roomName;
  CreateRoomEvent({required this.inviteId, required this.roomName});

  @override
  List<Object> get props => [];

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => super.hashCode;
}

class LoginEvent extends ChatEvent{
  final MatrixLoginRequest request;
  LoginEvent({required this.request});

  @override
  List<Object> get props => [];

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => super.hashCode;
}

class SyncEvent extends ChatEvent{
  final SyncChatServerRequest request;
  SyncEvent({required this.request});

  @override
  List<Object> get props => [];

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => super.hashCode;
}

class GetRoomsEvent extends ChatEvent{
  GetRoomsEvent();

  @override
  List<Object> get props => [];

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => super.hashCode;
}

class SendMessageEvent extends ChatEvent{
  final String message;
  SendMessageEvent({required this.message});

  @override
  List<Object> get props => [];

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => super.hashCode;
}