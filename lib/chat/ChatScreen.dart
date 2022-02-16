import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mclient/chat/ChatMessageModel.dart';
import 'package:mclient/chat/models.dart';
import 'package:mclient/chat/ws_get_it.dart';
import 'package:mclient/src/ws_responses.dart';

import 'ChatBubble.dart';
import 'ChatTitle.dart';
import 'Global.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'matrix_ws_sdk/channel_functions.dart';


class ChatScreen extends StatefulWidget {
  //
  ChatScreen() : super();

  final String title = "Chat Screen";
  final ChannelDriver driver =
  getIt<ChannelDriver>();
  static const String ROUTE_ID = 'chat_screen';

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  //
  late TextEditingController _chatTfController;
  late List<ChatMessageModel> _chatMessages;
  MatrixUser? _chatUser;
  late ScrollController _chatLVController;
  late UserOnlineStatus _userOnlineStatus;

  @override
  void initState() {
    super.initState();
    _userOnlineStatus = UserOnlineStatus.connecting;
    _chatLVController = ScrollController(initialScrollOffset: 0.0);
    _chatTfController = TextEditingController();
    _chatUser = getIt<G>().toChatUser;
    _chatMessages = List.filled(1, ChatMessageModel.dummy());
    _checkOnline();
  }


  _checkOnline() async {
    ChatMessageModel chatMessageModel = ChatMessageModel(
      to: getIt<G>().toChatUser?.matrixUserId,
      from: getIt<G>().loggedInUser?.matrixUserId,
    );
    getIt<WebSocketChannel>().sink.add(chatMessageModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: ChatTitle(
          chatUser: getIt<G>().toChatUser!,
          userOnlineStatus: _userOnlineStatus,
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _chatList(),
              _bottomChatArea(),
            ],
          ),
        ),
      ),
    );
  }

  _chatList() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          cacheExtent: 100,
          controller: _chatLVController,
          reverse: false,
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          itemCount: null == _chatMessages ? 0 : _chatMessages.length,
          itemBuilder: (context, index) {
            ChatMessageModel chatMessage = _chatMessages[index];
            return _chatBubble(
              chatMessage,
            );
          },
        ),
      ),
    );
  }

  _bottomChatArea() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          _chatTextArea(),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              _sendButtonTap();
            },
          ),
        ],
      ),
    );
  }

  _chatTextArea() {
    return Expanded(
      child: TextField(
        controller: _chatTfController,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 0.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.white,
              width: 0.0,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(10.0),
          hintText: 'Type message...',
        ),
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _sendButtonTap() async {
    if (_chatTfController.text.isEmpty) {
      return;
    }
    ChatMessageModel chatMessageModel = ChatMessageModel(
      chatId: '0',
      to: _chatUser?.matrixUserId,
      from: getIt<G>().loggedInUser?.matrixUserId,
      toUserOnlineStatus: false,
      message: _chatTfController.text,
      chatType: 'dm',
    );
    _addMessage(0, chatMessageModel, _isFromMe(getIt<G>().loggedInUser!));
    _clearMessage();
    getIt<WebSocketChannel>().sink.add(_chatTfController.text);
  }

  _clearMessage() {
    _chatTfController.text = '';
  }

  _isFromMe(MatrixLoginResponse fromUser) {
    return fromUser.matrixUserId == getIt<G>().loggedInUser?.matrixUserId;
  }

  _chatBubble(ChatMessageModel chatMessageModel) {
    bool fromMe = chatMessageModel.from == getIt<G>().loggedInUser?.matrixUserId;
    Alignment alignment = fromMe ? Alignment.topRight : Alignment.topLeft;
    Alignment chatArrowAlignment =
    fromMe ? Alignment.topRight : Alignment.topLeft;
    TextStyle textStyle = TextStyle(
      fontSize: 16.0,
      color: fromMe ? Colors.white : Colors.black54,
    );
    Color chatBgColor = fromMe ? Colors.blue : Colors.black12;
    EdgeInsets edgeInsets = fromMe
        ? EdgeInsets.fromLTRB(5, 5, 15, 5)
        : EdgeInsets.fromLTRB(15, 5, 5, 5);
    EdgeInsets margins = fromMe
        ? EdgeInsets.fromLTRB(80, 5, 10, 5)
        : EdgeInsets.fromLTRB(10, 5, 80, 5);

    return Container(
      color: Colors.white,
      margin: margins,
      child: Align(
        alignment: alignment,
        child: Column(
          children: <Widget>[
            CustomPaint(
              painter: ChatBubble(
                color: chatBgColor,
                alignment: chatArrowAlignment,
              ),
              child: Container(
                margin: EdgeInsets.all(10),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: edgeInsets,
                      child: Text(
                        chatMessageModel.message!,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onChatMessageReceived(data) {
    print('onChatMessageReceived $data');
    if (null == data || data.toString().isEmpty) {
      return;
    }
    ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(data);
    bool? online = chatMessageModel.toUserOnlineStatus;
    _updateToUserOnlineStatusInUI(online);
    processMessage(chatMessageModel);
  }

  onMessageBackFromServer(data) {
    ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(data);
    bool? online = chatMessageModel.toUserOnlineStatus;
    print('onMessageBackFromServer $data');
    if (!online!) {
      print('User not connected');
    }
  }

  onUserConnectionStatus(data) {
    ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(data);
    bool? online = chatMessageModel.toUserOnlineStatus;
    _updateToUserOnlineStatusInUI(online);
  }

  _updateToUserOnlineStatusInUI(online) {
    setState(() {
      _userOnlineStatus =
      online ? UserOnlineStatus.online : UserOnlineStatus.not_online;
    });
  }

  processMessage(ChatMessageModel chatMessageModel) {
    _addMessage(0, chatMessageModel, false);
  }

  _addMessage(id, ChatMessageModel chatMessageModel, fromMe) async {
    print('Adding Message to UI ${chatMessageModel.message}');
    setState(() {
      _chatMessages.add(chatMessageModel);
    });
    print('Total Messages: ${_chatMessages.length}');
    _chatListScrollToBottom();
  }

  /// Scroll the Chat List when it goes to bottom
  _chatListScrollToBottom() {
    Timer(Duration(milliseconds: 100), () {
      if (_chatLVController.hasClients) {
        _chatLVController.animateTo(
          _chatLVController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.decelerate,
        );
      }
    });
  }
}

enum UserOnlineStatus { connecting, online, not_online }
