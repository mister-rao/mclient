import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mclient/bloc/chat/chat_bloc.dart';
import 'package:mclient/models/message_model.dart';
import 'package:mclient/models/ws_requests_model.dart';
import 'package:mclient/models/ws_responses_model.dart';
import 'package:mclient/screens/my_rooms.dart';
import 'package:mclient/screens/send_invite.dart';
import 'package:provider/provider.dart';

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
  // swap myid and recieverid value on another mobile to test send and receive

  String auth = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjQ1NTMxOTA2LCJpYXQiOjE2NDU0NDU1MDYsImp0aSI6IjBkOGNkOTkwNTg3NTQ1Nzc5ZjM5NTk1ZGVhZGY1MjA0IiwidXNlcl9pZCI6MiwibWF0cml4X3VzZXJuYW1lIjoidGFwYXN3aV8yMDA4In0.MXCCJbVSFIyZC2PMnI02JwBVifF2D5YflUAJ4ANgv5I';

  List<MessageModel> msgList = [];

  TextEditingController msgText = TextEditingController();


  @override
  void initState() {
    context.read<ChatBloc>().add(ConnectWebSocketEvent());
    connected = false;
    super.initState();
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
                Icons.login,
                color: Colors.white,
              ),
              onPressed: () {
                final loginRequest = MatrixLoginRequest(token: auth);
                BlocProvider.of<ChatBloc>(context).add(
                    LoginEvent(request: loginRequest));
              },
            ),
            if(connected)
              IconButton(
              icon: const Icon(
                Icons.people,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(MyRooms.ROUTE);
              },
            ),
            if(connected)
              IconButton(
              icon: const Icon(
                Icons.create_new_folder_sharp,
                color: Colors.white,
              ),
              onPressed: () async{
                List? list = await Navigator.of(context).push<List<String>>(
                    MaterialPageRoute(builder: (context) => SendInvite(), fullscreenDialog: true));
                if(list != null){
                  String inviteId = list[0];
                  String roomName = list[1];
                  BlocProvider.of<ChatBloc>(context).add(
                      CreateRoomEvent(inviteId: inviteId, roomName: roomName));
                }
              },
            ),
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
                  BlocConsumer<ChatBloc, ChatState>(
                      listener: (context, state){
                        if(state is InviteSentState){
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invite Sent...')));
                        }
                      },
                      buildWhen: (previous, next){
                        return (next is WebSocketConnectedState);
                      },
                      builder: (context, state){
                        if(state is WebSocketConnectedState){
                          return StreamBuilder<MessageModel>(
                              stream: state.messageStream,
                              builder: (context, snapshot){
                                if (snapshot.connectionState == ConnectionState.active) {
                                  if(snapshot.data!.eventType == 'response.jwt_login'){
                                    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                                      setState((){
                                        myId = snapshot.data!.myId!;
                                        connected = true;
                                      });
                                    });
                                  }else if(snapshot.data!.eventType == 'event.message_received' ||
                                      snapshot.data!.eventType == 'websocket.accept' ||
                                      snapshot.data!.eventType == 'response.jwt_login'){
                                    msgList.add(snapshot.data!);
                                  }
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

