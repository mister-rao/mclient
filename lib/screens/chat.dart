import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mclient/bloc/chat/chat_bloc.dart';
import 'package:mclient/chat/channel/channel_bloc.dart';
import 'package:mclient/models/message_model.dart';
import 'package:mclient/utilities/channel_functions.dart';
import 'package:mclient/chat/ws_get_it.dart';
import 'package:mclient/models/ws_requests_model.dart';
import 'package:mclient/models/ws_responses_model.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatPageState();
  }

  static const String ROUTE_ID = 'chat_page';
}

class ChatPageState extends State<ChatPage> {

  // final ChannelDriver driver = getIt<ChannelDriver>(); //channel varaible for websocket
  late bool connected; // boolean value to track connection status

  String myId = "222"; //my id
  String receiverId = "111"; //receiver id
  // swap myid and recieverid value on another mobile to test send and receive

  String auth = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjQ1MjY3MDkwLCJpYXQiOjE2NDUxODA2OTAsImp0aSI6IjMxY2ZhNzdlMzRkZTQ5NTk5Y2UwNWE0OGExOTkyYzU2IiwidXNlcl9pZCI6MiwibWF0cml4X3VzZXJuYW1lIjoidGFwYXN3aV8yMDA4In0.aczmVCX-GgVqZO5_6B_DOd2cPw30cIEnAv6HgscUZbY';

  List<MessageModel> msgList = [];

  TextEditingController msgText = TextEditingController();


  @override
  void initState() {
    context.read<ChatBloc>().add(ConnectWebSocketEvent());
    connected = false;
    msgText.text = "";
    // channelConnect(context);
    super.initState();
  }

  void mapWebSocketEventsToState(BuildContext context, dynamic payload) {
    if (payload['message']['type'] == "websocket.accept") {
      // driver.connected = true;
      print("Connection established.");
    } else if (payload['message']['type'] == "response.jwt_login") {
      print("Login Response");
      Map data = payload['message'];
      MatrixLoginResponse matrixUser = MatrixLoginResponse(
          matrixUserId: data['matrix_user_id'],
          deviceId: data['device_id'],
          matrixToken: data['matrix_token']);
      print("user logged in ${matrixUser.matrixUserId}");
      // Provider.of<ChannelBloc>(context, listen: false)
      //     .add(LoggedInMatrixUserEvent(user: matrixUser));
      myId = matrixUser.matrixUserId;
      /*setState(() {
        msgText.text = "";
        msgList.add(MessageData(
            msgtext: "Login Success ${matrixUser.matrixUserId}", userid: "111", isme: false));
      });*/
      // driver.syncChatApp();
      /*setState(() {
        msgText.text = "";
        msgList.add(MessageData(msgtext: "sync started!!", userid: "111", isme: false));
      });*/
    } else if (payload['message']['type'] == "event.message_received") {
      print("Message Recieved");
      Map data = payload['message'];
      MessageReceivedEvent message = MessageReceivedEvent(
          sender: data['sender'],
          body: data['body'],
          roomId: data['room_id'],
          roomName: data['room_name'],
          senderId: data['sender_id']);
      String event = "message received>> sender: ${message.sender} message: ${message.body}";
      print(event);
      /*setState(() {
        msgText.text = "";
        msgList.add(MessageData(msgtext: event, userid: "111", isme: false));
      });*/
    } else if (payload['message']['type'] == "response.get_profile") {
      print("Get profile Response");
      Map data = payload['message'];
      MatrixGetProfileResponse matrixUserProfile = MatrixGetProfileResponse(
          displayName: data['display_name'], avatarUrl: data['avatar_url']);
      /*setState(() {
        msgText.text = "";
        msgList.add(MessageData(
            msgtext: "User Profile: ${matrixUserProfile.displayName}", userid: "111", isme: false));
      });*/
      print("Matrix User Profile: ${matrixUserProfile.displayName}");
    } else if (payload['message']['type'] == "response.joined_rooms") {
      print("Get user joined rooms");
      Map data = payload['message'];
      MatrixGetJoinedRoomsResponse matrixUserRoms =
          MatrixGetJoinedRoomsResponse(rooms: data['rooms']);
      /*setState(() {
        msgText.text = "";
        msgList.add(MessageData(
            msgtext: "User Joined Rooms: ${matrixUserRoms.rooms}", userid: "111", isme: false));
      });*/
      print("User Joined room: ${matrixUserRoms.rooms}");
    }
  }

  channelConnect(BuildContext context) {
    //function to connect
    try {
      /*driver.channel.stream.listen(
        (payload) {
          payload = jsonDecode(payload);
          print("Main.channelconnect: ws_stream_data>> $payload");
          mapWebSocketEventsToState(context, payload);
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
        },
        onError: (error) {
          print(error.toString());
        },
      );*/
    } catch (_) {
      print(_);
      print("error on connecting to websocket.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My ID: $myId"),
          leading: Icon(Icons.circle, color: connected ? Colors.greenAccent : Colors.redAccent),
          //if app is connected to node.js then it will be gree, else red.
          titleSpacing: 0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                final loginRequest = MatrixLoginRequest(token: auth);
                BlocProvider.of<ChatBloc>(context).add(
                    LoginEvent(request: loginRequest));
                /*final loginRequest = MatrixLoginRequest(token: auth);
                driver.loginToMatrix(loginRequest);

                // Provider.of<ChannelBloc>(context, listen: false).add(
                //   MatrixLoginInEvent(loginRequest: loginRequest),
                // );
                setState(() {
                  msgText.text = "";
                  msgList.add(
                      MessageData(msgtext: "Logging in to Matrix", userid: "111", isme: false));
                });*/
              },
            )
          ],
        ),
        body: Stack(
          children: [
            //Chat Messages
            Positioned(
                top: 0,
                bottom: 70,
                left: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.all(15),
                    child:
                  BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state){
                        if(state is WebSocketConnectedState){
                          return StreamBuilder<MessageModel>(
                              stream: state.messageStream,
                              builder: (context, snapshot){
                                print('Snameshot DATA: ');
                                print('${snapshot.data!.toJson().toString()}\n');
                                if (snapshot.connectionState == ConnectionState.active) {
                                  msgList.add(snapshot.data!);
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: msgList.map((msg) => Container(
                                          margin: EdgeInsets.only(
                                            //if is my message, then it has margin 40 at left
                                            left: msg.isMe ? 40 : 0,
                                            right: msg.isMe ? 0 : 40, //else margin at right
                                          ),
                                          child: Card(
                                              color: msg.isMe ? Colors.blue[100] : Colors.red[100],
                                              //if its my message then, blue background else red background
                                              child: Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(15),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        msg.isMe ? "ID: ME" : "ID: " + msg.userId!),
                                                    Container(
                                                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                                                      child: Text("Message: " + msg.msgText,
                                                          style: const TextStyle(fontSize: 17)),
                                                    ),
                                                  ],
                                                ),
                                              )))).toList(),
                                    ),
                                  );
                                } else {
                                  return const Text('Connecting....');
                                }
                              });
                        }
                        return const Text('Connecting....');
                      },
                    )
                  /*SingleChildScrollView(
                        child: Column(
                          children: [
                            const Text("Your Messages", style: TextStyle(fontSize: 20)),
                            Column(
                              children: msgList.map((oneMsg) {
                            return Container(
                                margin: EdgeInsets.only(
                                  //if is my message, then it has margin 40 at left
                                  left: oneMsg.isme ? 40 : 0,
                                  right: oneMsg.isme ? 0 : 40, //else margin at right
                                ),
                                child: Card(
                                    color: oneMsg.isme ? Colors.blue[100] : Colors.red[100],
                                    //if its my message then, blue background else red background
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              oneMsg.isme ? "ID: ME" : "ID: " + oneMsg.userid),
                                          Container(
                                            margin: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text("Message: " + oneMsg.msgtext,
                                                style: const TextStyle(fontSize: 17)),
                                          ),
                                        ],
                                      ),
                                    )));
                              }).toList(),
                            )
                          ],
                    ))*/
                )),


            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Container(
                  margin: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    child: const Icon(Icons.account_circle_sharp),
                    onPressed: () {
                      // driver.getRooms();
                      /*setState(() {
                        msgText.text = "";
                        msgList.add(MessageData(
                            msgtext: "fetching user rooms", userid: "111", isme: false));
                      });*/
                    },
                  )),
            ),

            //Send Message Textfield
            Positioned(
              //position text field at bottom of screen

              bottom: 0, left: 0, right: 0,
              child: Container(
                  color: Colors.black12,
                  height: 70,
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.all(10),
                        child: TextField(
                          controller: msgText,
                          decoration: const InputDecoration(hintText: "Enter your Message"),
                        ),
                      )),
                      Container(
                          margin: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            child: const Icon(Icons.send),
                            onPressed: () {
                              if (msgText.text != "") {
                                context.read<ChatBloc>().add(
                                    SendMessageEvent(message: msgText.text));
                                // driver.sendmsg(msgText.text, receiverId);
                                /*setState(() {
                                  msgList.add(MessageData(
                                      msgtext: msgText.text, userid: "111", isme: true));
                                  msgText.text = "";
                                });*/
                              } else {
                                print("Enter message");
                              }
                            },
                          ))
                    ],
                  )),
            )
          ],
        ));
  }
}

class MessageData {
  //message data model
  String msgtext, userid;
  bool isme;

  MessageData({required this.msgtext, required this.userid, required this.isme});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': msgtext,
      };
}

