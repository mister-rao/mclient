import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mclient/chat/channel/channel_bloc.dart';
import 'package:mclient/chat/matrix_ws_sdk/channel_functions.dart';
import 'package:mclient/chat/ws_get_it.dart';
import 'package:mclient/src/ws_requests.dart';
import 'package:mclient/src/ws_responses.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChatPageState();
  }

  static const String ROUTE_ID = 'chat_page';

}

class ChatPageState extends State<ChatPage> {
  final ChannelDriver driver =
      getIt<ChannelDriver>(); //channel varaible for websocket
  late bool connected; // boolean value to track connection status

  String myid = "222"; //my id
  String recieverid = "111"; //reciever id
  // swap myid and recieverid value on another mobile to test send and recieve
  String auth =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjQ1MDk2MTQ5LCJpYXQiOjE2NDUwMDk3NDksImp0aSI6ImNhODNiOTkzYTg0NzRhOGY4OTNhNTUyYjk3MjI2NjRkIiwidXNlcl9pZCI6MSwibWF0cml4X3VzZXJuYW1lIjoiZ2FuZXNoX3Jhb18yODc3In0.UCoNNHPFmRiu_xCcsWN_XxTaf0yifSyFcGZmBmc0r2k"; //auth key

  List<MessageData> msglist = [];

  TextEditingController msgtext = TextEditingController();

  @override
  void initState() {
    connected = false;
    msgtext.text = "";
    channelconnect(context);
    super.initState();
  }

  void mapWebSocketEventsToState(BuildContext context, dynamic payload) {
    if (payload['message']['type'] == "websocket.accept") {
      driver.connected = true;
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
      myid = matrixUser.matrixUserId;
              setState(() {
                msgtext.text = "";
                msglist.add(MessageData(
                    msgtext: "Login Success ${matrixUser.matrixUserId}",
                    userid: "111",
                    isme: false));
              });
      driver.syncChatApp();
      setState(() {
        msgtext.text = "";
        msglist.add(MessageData(
            msgtext: "sync started!!", userid: "111", isme: false));
      });
    } else if (payload['message']['type'] == "event.message_received") {
      print("Message Recieved");
      Map data = payload['message'];
      MessageReceivedEvent message =
          MessageReceivedEvent(sender: data['sender'], body: data['body'],
          roomId: data['room_id'], roomName: data['room_name'],
              senderId: data['sender_id']);
      String event =
          "message received>> sender: ${message.sender} message: ${message.body}";
      print(event);
      setState(() {
        msgtext.text = "";
        msglist.add(
            MessageData(msgtext: event, userid: "111", isme: false));
      });

    } else if (payload['message']['type'] == "response.get_profile") {
      print("Get profile Response");
      Map data = payload['message'];
      MatrixGetProfileResponse matrixUserProfile = MatrixGetProfileResponse(
          displayName: data['display_name'], avatarUrl: data['avatar_url']);
      setState(() {
        msgtext.text = "";
        msglist.add(MessageData(
            msgtext: "User Profile: ${matrixUserProfile.displayName}",
            userid: "111",
            isme: false));
      });
      print("Matrix User Profile: ${matrixUserProfile.displayName}");
    } else if (payload['message']['type'] == "response.joined_rooms") {
      print("Get user joined rooms");
      Map data = payload['message'];
      MatrixGetJoinedRoomsResponse matrixUserRoms =
          MatrixGetJoinedRoomsResponse(rooms: data['rooms']);
      setState(() {
        msgtext.text = "";
        msglist.add(MessageData(
            msgtext: "User Joined Rooms: ${matrixUserRoms.rooms}",
            userid: "111",
            isme: false));
      });
      print("User Joined room: ${matrixUserRoms.rooms}");
    }
  }


  channelconnect(BuildContext context) {
    //function to connect

    try {
      driver.channel.stream.listen(
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
      );
    } catch (_) {
      print(_);
      print("error on connecting to websocket.");
    }
  }


  // channelconnect(BuildContext context) {
  //   //function to connect
  //
  //   try {
  //     driver.channel.stream.listen(
  //       (payload) {
  //         payload = jsonDecode(payload);
  //         print("Chat.channelconnect: payload>> $payload");
  //         mapWebSocketEventsToState(context, payload);
  //       },
  //       onDone: () {
  //         //if WebSocket is disconnected
  //         print("Web socket is closed");
  //       },
  //       onError: (error) {
  //         print(error.toString());
  //       },
  //     );
  //     // channel IP : Port
  //     // channel.stream.listen(
  //     //   (payload) {
  //     //     payload = jsonDecode(payload);
  //     //     print(payload);
  //     //     setState(() {
  //     //       if (payload['message']['type'] == "websocket.accept") {
  //     //         driver.connected = true;
  //     //         connected = true;
  //     //         setState(() {});
  //     //         print("Connection establised.");
  //     //       } else if (payload['message']['type'] == "response.jwt_login") {
  //     //         print("Login Response");
  //     //         Map data = payload['message'];
  //     //         MatrixLoginResponse matrixUser = MatrixLoginResponse(
  //     //             matrixUserId: data['matrix_user_id'],
  //     //             deviceId: data['device_id'],
  //     //             matrixToken: data['matrix_token']);
  //     //         print("user logged in ${matrixUser.matrixUserId}");
  //     //         myid = matrixUser.matrixUserId;
  //     //         setState(() {
  //     //           msgtext.text = "";
  //     //           msglist.add(MessageData(
  //     //               msgtext: "Login Success ${matrixUser.matrixUserId}",
  //     //               userid: "111",
  //     //               isme: false));
  //     //         });
  //     //         driver.syncChatApp();
  //     //         setState(() {
  //     //           msgtext.text = "";
  //     //           msglist.add(MessageData(
  //     //               msgtext: "sync started!!", userid: "111", isme: false));
  //     //         });
  //     //       } else if (payload['message']['type'] == "event.message_received") {
  //     //         print("Message Recieved");
  //     //         Map data = payload['message'];
  //     //         MessageReceivedEvent message = MessageReceivedEvent(
  //     //           roomId: data['room_id'],roomName: data['room_name'],
  //     //             senderId: data['sender_id'],
  //     //             sender: data['sender'], body: data['body']);
  //     //         String event =
  //     //             "message received>> sender: ${message.sender} message: ${message.body}";
  //     //         print(event);
  //     //         setState(() {
  //     //           msgtext.text = "";
  //     //           msglist.add(
  //     //               MessageData(msgtext: event, userid: "111", isme: false));
  //     //         });
  //     //       } else if (payload['message']['type'] == "response.get_profile") {
  //     //         print("Get profile Response");
  //     //         Map data = payload['message'];
  //     //         MatrixGetProfileResponse matrixUserProfile =
  //     //             MatrixGetProfileResponse(
  //     //                 displayName: data['display_name'],
  //     //                 avatarUrl: data['avatar_url']);
  //     //         setState(() {
  //     //           msgtext.text = "";
  //     //           msglist.add(MessageData(
  //     //               msgtext: "User Profile: ${matrixUserProfile.displayName}",
  //     //               userid: "111",
  //     //               isme: false));
  //     //         });
  //     //         print("Matrix User Profile: ${matrixUserProfile.displayName}");
  //     //       } else if (payload['message']['type'] == "response.joined_rooms") {
  //     //         print("Get user joined rooms");
  //     //         Map data = payload['message'];
  //     //         MatrixGetJoinedRoomsResponse matrixUserRoms =
  //     //             MatrixGetJoinedRoomsResponse(rooms: data['rooms']);
  //     //         setState(() {
  //     //           msgtext.text = "";
  //     //           msglist.add(MessageData(
  //     //               msgtext: "User Joined Rooms: ${matrixUserRoms.rooms}",
  //     //               userid: "111",
  //     //               isme: false));
  //     //         });
  //     //         print("User Joined room: ${matrixUserRoms.rooms}");
  //     //       }
  //     //     });
  //     //   },
  //     //   onDone: () {
  //     //     //if WebSocket is disconnected
  //     //     print("Web socket is closed");
  //     //     setState(() {
  //     //       connected = false;
  //     //     });
  //     //   },
  //     //   onError: (error) {
  //     //     print(error.toString());
  //     //   },
  //     // );
  //   } catch (_) {
  //     print(_);
  //     print("error on connecting to websocket.");
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text("My ID: $myid"),
          leading: Icon(Icons.circle,
              color: connected ? Colors.greenAccent : Colors.redAccent),
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
                driver.loginToMatrix(loginRequest);

                // Provider.of<ChannelBloc>(context, listen: false).add(
                //   MatrixLoginInEvent(loginRequest: loginRequest),
                // );
                setState(() {
                  msgtext.text = "";
                  msglist.add(MessageData(
                      msgtext: "Logging in to Matrix",
                      userid: "111",
                      isme: false));
                });
              },
            )
          ],
        ),
        body: Container(
            child: Stack(
          children: [
            Positioned(
                top: 0,
                bottom: 70,
                left: 0,
                right: 0,
                child: Container(
                    padding: EdgeInsets.all(15),
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        Container(
                          child: Text("Your Messages",
                              style: TextStyle(fontSize: 20)),
                        ),
                        Container(
                            child: Column(
                          children: msglist.map((onemsg) {
                            return Container(
                                margin: EdgeInsets.only(
                                  //if is my message, then it has margin 40 at left
                                  left: onemsg.isme ? 40 : 0,
                                  right: onemsg.isme
                                      ? 0
                                      : 40, //else margin at right
                                ),
                                child: Card(
                                    color: onemsg.isme
                                        ? Colors.blue[100]
                                        : Colors.red[100],
                                    //if its my message then, blue background else red background
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              child: Text(onemsg.isme
                                                  ? "ID: ME"
                                                  : "ID: " +
                                                      onemsg.userid)),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: Text(
                                                "Message: " +
                                                    onemsg.msgtext,
                                                style: TextStyle(
                                                    fontSize: 17)),
                                          ),
                                        ],
                                      ),
                                    )));
                          }).toList(),
                        ))
                      ],
                    )))),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Container(
                  margin: EdgeInsets.all(10),
                  child: ElevatedButton(
                    child: Icon(Icons.account_circle_sharp),
                    onPressed: () {
                      driver.getRooms();
                      setState(() {
                        msgtext.text = "";
                        msglist.add(MessageData(
                            msgtext: "fetching user rooms",
                            userid: "111",
                            isme: false));
                      });
                    },
                  )),
            ),
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
                        margin: EdgeInsets.all(10),
                        child: TextField(
                          controller: msgtext,
                          decoration: InputDecoration(
                              hintText: "Enter your Message"),
                        ),
                      )),
                      Container(
                          margin: EdgeInsets.all(10),
                          child: ElevatedButton(
                            child: Icon(Icons.send),
                            onPressed: () {
                              if (msgtext.text != "") {
                                driver.sendmsg(msgtext.text, recieverid);
                                setState(() {
                                  msglist.add(MessageData(
                                      msgtext: msgtext.text,
                                      userid: "111",
                                      isme: true));
                                  msgtext.text = "";
                                });
                              } else {
                                print("Enter message");
                              }
                            },
                          ))
                    ],
                  )),
            )
          ],
        )));
  }
}

class MessageData {
  //message data model
  String msgtext, userid;
  bool isme;
  MessageData(
      {required this.msgtext, required this.userid, required this.isme});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': msgtext,
      };
}
