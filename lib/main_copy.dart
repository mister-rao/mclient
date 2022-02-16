import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mclient/chat/channel/channel_bloc.dart';
import 'package:mclient/chat/ws_get_it.dart';
import 'package:mclient/src/chat.dart';
import 'package:mclient/src/ws_responses.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chat/matrix_ws_sdk/channel_functions.dart';
import 'chat/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  init();
  getIt<ChannelDriver>().channel.sink.add(jsonEncode({
    "event_type": "hello_flutter",
    "message": "Socket connected from flutter get it"
  }));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ChannelDriver driver = getIt<ChannelDriver>();
  final ChannelBloc _bloc = ChannelBloc();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    channelconnect(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: Routes.routes(),
      initialRoute: Routes.initScreen(),
    );
    //
    // return MaterialApp(
    //   title: 'Flutter Chat App',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: BlocProvider(
    //     create: (context) => ChannelBloc(),
    //     child: ChatPage(),
    //   ),
    // );
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
      Provider.of<ChannelBloc>(context, listen: false)
          .add(LoggedInMatrixUserEvent(user: matrixUser));
    } else if (payload['message']['type'] == "event.message_received") {
      print("Message Recieved");
      Map data = payload['message'];
      MessageReceivedEvent message =
      MessageReceivedEvent(sender: data['sender'], body: data['body'],
          roomId: data['room_id'], roomName: data['room_name'],
          senderId: data['sender_id']);
      String event =
          "message received>> sender: ${message.sender} message: ${message.body}";
      Provider.of<ChannelBloc>(context, listen: false)
          .add(MessageReceived(message: message));
      print(event);


    } else if (payload['message']['type'] == "response.get_profile") {
      print("Get profile Response");
      Map data = payload['message'];
      MatrixGetProfileResponse matrixUserProfile = MatrixGetProfileResponse(
          displayName: data['display_name'], avatarUrl: data['avatar_url']);

      print("Matrix User Profile: ${matrixUserProfile.displayName}");
    } else if (payload['message']['type'] == "response.joined_rooms") {
      print("Get user joined rooms");
      Map data = payload['message'];
      MatrixGetJoinedRoomsResponse matrixUserRoms =
      MatrixGetJoinedRoomsResponse(rooms: data['rooms']);
      print("User Joined room: ${matrixUserRoms.rooms}");
    }
  }
}
