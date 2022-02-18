part of 'chat_bloc.dart';

abstract class ChatState extends Equatable{
  @override
  List<Object> get props => [];
}

class ChatInitialState extends ChatState{}

class WebSocketConnectedState extends ChatState{
  final Stream<MessageModel> messageStream;
  WebSocketConnectedState({required this.messageStream});

  @override
  List<Object> get props => [];

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => super.hashCode;
}

class WebSocketDisconnectedState extends ChatState{
  WebSocketDisconnectedState();

  @override
  List<Object> get props => [];

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => super.hashCode;
}