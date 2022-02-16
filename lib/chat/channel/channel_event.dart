part of 'channel_bloc.dart';

@immutable
abstract class ChannelEvent {}

class MatrixLoginInEvent extends ChannelEvent {
  final MatrixLoginRequest loginRequest;
  MatrixLoginInEvent({required this.loginRequest});
}

class LoggedInMatrixUserEvent extends ChannelEvent {
  final MatrixLoginResponse user;
  LoggedInMatrixUserEvent({required this.user}) {
    print(">>>> matrix user logged in ${user.matrixUserId}");
  }
}

class MessageReceived extends ChannelEvent {
  final MessageReceivedEvent message;
  MessageReceived({required this.message}) {
   print("message recieved>>> $message");
  }
}