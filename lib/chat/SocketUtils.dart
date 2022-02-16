import 'dart:io';

import 'ChatMessageModel.dart';
import 'models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketUtils {
  //
  static const String _serverIP = 'ws://localhost:5555/ws/chat/';
  static const int SERVER_PORT = 4002;
  static const String _connectUrl = '$_serverIP';

  // Events
  static const String ON_MESSAGE_RECEIVED = 'receive_message';
  static const String SUB_EVENT_MESSAGE_SENT = 'message_sent_to_user';
  static const String IS_USER_CONNECTED_EVENT = 'is_user_connected';
  static const String IS_USER_ONLINE_EVENT = 'check_online';
  static const String SUB_EVENT_MESSAGE_FROM_SERVER = 'message_from_server';

  // Status
  static const int STATUS_MESSAGE_NOT_SENT = 10001;
  static const int STATUS_MESSAGE_SENT = 10002;
  static const int STATUS_MESSAGE_DELIVERED = 10003;
  static const int STATUS_MESSAGE_READ = 10004;

  // Type of Chat
  static const String SINGLE_CHAT = 'single_chat';

  late User _fromUser;

  late WebSocketChannel _channel;

  initSocket(User fromUser) async {
    print('Connecting user: ${fromUser.name}');
    this._fromUser = fromUser;
    await _init();
  }

  _init() async {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://localhost:5555/ws/chat/"),
    );
  }


  sendSingleChatMessage(ChatMessageModel chatMessageModel, User toChatUser) {
    print('Sending Message to: ${toChatUser.name}, ID: ${toChatUser.id}');
    if (null == _channel) {
      print("Socket is Null, Cannot send message");
      return;
    }
    _channel.sink.add("single_chat_message: ${chatMessageModel.toJson()}");
  }



  checkOnline(ChatMessageModel chatMessageModel) {
    print('Checking Online: ${chatMessageModel.to}');
    if (null == _channel) {
      print("Socket is Null, Cannot send message");
      return;
    }
    _channel.sink.add("IS_USER_ONLINE_EVENT, ${chatMessageModel.toJson()}");
  }

  connectToSocket() async {
    if (null == _channel) {
      print("Socket is Null");
      return;
    }
    print("Connecting to socket...");
    await _init();
  }


  closeConnection() {
    if (null != _channel) {
      print("Close Connection");
    }
  }
}
