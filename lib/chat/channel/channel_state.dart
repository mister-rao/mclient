part of 'channel_bloc.dart';

@immutable
abstract class ChannelState {}

class ChannelInitial extends ChannelState {}

class LoggedInMatrixUserState extends ChannelState {
  final MatrixLoginResponse user;

  LoggedInMatrixUserState({required this.user});
}


class Message extends ChannelState {
  final MessageReceivedEvent message;

  Message({required this.message});
}