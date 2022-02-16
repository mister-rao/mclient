import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mclient/chat/channel/channel_bloc.dart';
import 'package:mclient/chat/models.dart';
import 'package:mclient/chat/ws_get_it.dart';
import 'package:mclient/src/ws_responses.dart';
import 'package:provider/provider.dart';
import 'ChatScreen.dart';
import 'Global.dart';
import 'login_screen.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'matrix_ws_sdk/channel_functions.dart';

class ChatUsersScreen extends StatefulWidget {
  //
  ChatUsersScreen() : super();

  static const String ROUTE_ID = 'chat_users_list_screen';

  @override
  _ChatUsersScreenState createState() => _ChatUsersScreenState();
}

class _ChatUsersScreenState extends State<ChatUsersScreen> {
  //
  List<MatrixUser>? _chatUsers;
  bool? _connectedToSocket;
  String? _errorConnectMessage;
  final ChannelDriver driver =
  getIt<ChannelDriver>();

  @override
  void initState() {
    super.initState();
    driver.getRooms();
    _connectedToSocket = driver.connected;
    _errorConnectMessage = 'Connecting...';
  }


  static openLoginScreen(BuildContext context) async {
    await Navigator.pushReplacementNamed(
      context,
      LoginScreen.ROUTE_ID,
    );
  }

  void mapWebSocketEventsToState(BuildContext context, dynamic payload) {
    if (payload['message']['type'] == "websocket.accept") {
      driver.connected = true;
      print("ChatUsersScreen.mapWebSocketEventsToState>> Connection established.");
    } else if (payload['message']['type'] == "response.jwt_login") {
      print("ChatUsersScreen.mapWebSocketEventsToState>> Login Response");
      Map data = payload['message'];
      MatrixLoginResponse matrixUser = MatrixLoginResponse(
          matrixUserId: data['matrix_user_id'],
          deviceId: data['device_id'],
          matrixToken: data['matrix_token']);
      print("ChatUsersScreen.mapWebSocketEventsToState>> user logged in ${matrixUser.matrixUserId}");
      Provider.of<ChannelBloc>(context, listen: false)
          .add(LoggedInMatrixUserEvent(user: matrixUser));
      driver.syncChatApp();
    } else if (payload['message']['type'] == "event.message_received") {
      print("ChatUsersScreen.mapWebSocketEventsToState>> Message Recieved");
      Map data = payload['message'];
      MessageReceivedEvent message =
      MessageReceivedEvent(sender: data['sender'],
          body: data['body'],
          roomId: data['room_id'],
          roomName: data['room_name'],
          senderId: data['sender_id']);
      String event =
          "ChatUsersScreen.mapWebSocketEventsToState>> message received>> sender: ${message.sender} message: ${message
          .body}";
      print(event);

      Provider.of<ChannelBloc>(context, listen: false)
          .add(MessageReceived(message: message));
    } else if (payload['message']['type'] == "response.get_profile") {
      print("ChatUsersScreen.mapWebSocketEventsToState>> Get profile Response");
      Map data = payload['message'];
      MatrixGetProfileResponse matrixUserProfile = MatrixGetProfileResponse(
          displayName: data['display_name'], avatarUrl: data['avatar_url']);

      print("ChatUsersScreen.mapWebSocketEventsToState>> Matrix User Profile: ${matrixUserProfile.displayName}");
    } else if (payload['message']['type'] == "response.joined_rooms") {
      print("ChatUsersScreen.mapWebSocketEventsToState>> Get user joined rooms");
      Map data = payload['message'];
      MatrixGetJoinedRoomsResponse matrixUserRoms =
      MatrixGetJoinedRoomsResponse(rooms: data['rooms']);
      print("ChatUsersScreen.mapWebSocketEventsToState>> User Joined room: ${matrixUserRoms.rooms}");
    }
  }

  channelconnect(BuildContext context) {
    //function to connect

    try {
      driver.channel.stream.listen(
            (payload) {
          payload = jsonDecode(payload);
          print("ChatUsersScreen.channelconnect: payload>> $payload");
          mapWebSocketEventsToState(context, payload);
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print(_);
      print("error on connecting to websocket.");
    }
  }


  @override
  Widget build(BuildContext context) {
    ChannelBloc bloc = BlocProvider.of<ChannelBloc>(context);

    return BlocProvider<ChannelBloc>.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat Users'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  // getIt<WebSocketChannel>().sink.close();

                  openLoginScreen(context);
                })
          ],
        ),
        body: BlocListener<ChannelBloc, ChannelState>(
          listener: (context, state) {
            if (state is Message) {
              print(">>> MEssage state: $state");
            }
          },
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_connectedToSocket! ? 'Connected' : _errorConnectMessage!),
                SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _chatUsers?.length,
                    itemBuilder: (_, index) {
                      MatrixUser user = _chatUsers![index];
                      return StreamBuilder<ChannelState>(
                          stream: bloc.stream,
                          builder: (context, snapshot) {
                            print(snapshot);
                            return GestureDetector(
                              onTap: () {
                                getIt<G>().toChatUser = user;
                                openChatScreen(context);
                              },
                              child: ListTile(
                                title: Text(user.name),
                                subtitle: Text(
                                    'ID: ${user.matrixUserId}, ${user.name}'),
                              ),
                            );
                          }
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static openChatScreen(BuildContext context) async {
    await Navigator.pushNamed(
      context,
      ChatScreen.ROUTE_ID,
    );
  }

  onConnect(data) {
    print('Connected $data');
    setState(() {
      _connectedToSocket = true;
    });
  }

  onConnectError(data) {
    print('onConnectError $data');
    setState(() {
      _connectedToSocket = false;
      _errorConnectMessage = 'Failed to Connect';
    });
  }

  onConnectTimeout(data) {
    print('onConnectTimeout $data');
    setState(() {
      _connectedToSocket = false;
      _errorConnectMessage = 'Connection timedout';
    });
  }

  onError(data) {
    print('onError $data');
    setState(() {
      _connectedToSocket = false;
      _errorConnectMessage = 'Connection Failed';
    });
  }

  onDisconnect(data) {
    print('onDisconnect $data');
    setState(() {
      _connectedToSocket = false;
      _errorConnectMessage = 'Disconnected';
    });
  }
}
