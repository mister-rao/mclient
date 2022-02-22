
import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mclient/chat/ws_get_it.dart';
import 'package:mclient/models/message_model.dart';
import 'package:mclient/models/ws_requests_model.dart';
import 'package:mclient/models/ws_responses_model.dart';
import 'package:mclient/utilities/channel_functions.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_events.dart';
part 'chat_states.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState>{
  StreamController<MessageModel>? controller;
  ChannelDriver? driver;
  ChatBloc() : super(ChatInitialState()){
    controller = StreamController.broadcast();

    on<ChatEvent>((event, emit) async{
      if(event is ConnectWebSocketEvent){
        await _connectToWebSocket();
        emit(WebSocketConnectedState(messageStream: controller!.stream));
      }else if(event is LoginEvent){
        if(driver!.connected) {
          print('From Login Event ===> ');
          driver!.loginToMatrix(event.request);
        }
      } else if(event is SyncEvent){
        if(driver!.connected)
          driver!.syncChatApp();
      } else if(event is SendMessageEvent){
        if(driver!.connected)
          driver!.sendmsg(event.message, '');
      }else if(event is CreateRoomEvent){
        if(driver!.connected) {
          driver!.createRoom(event.inviteId, event.roomName);
          emit(InviteSentState());
        }
      }else if(event is GetRoomsEvent){
        if(driver!.connected) {
          driver!.getRooms();
          emit(RoomsLoadedState(messageStream: controller!.stream));
        }
      }
    });
  }

  Future<void> _connectToWebSocket() async{
    var channel = await WebSocketChannel.connect(Uri.parse('wss://api-dev.glitchh.in/ws/chat/'));
    getIt.registerSingleton<WebSocketChannel>(channel, signalsReady: true);

    driver = ChannelDriver(channel: channel);
    getIt.registerSingleton<ChannelDriver>(driver!, signalsReady: true);

    driver!.channel.stream.listen((payload){
      var message = jsonDecode(payload);
      if(message['message'] != null)
        mapWebSocketEventsToState(
            payload: jsonDecode(payload),
            controller: controller!,
        );
    });
  }

  void mapWebSocketEventsToState({required dynamic payload,
    required StreamController<MessageModel> controller,}) {
    if (payload['message']['type'] == "websocket.accept") {
      driver!.connected = true;
      var message = MessageModel(
          msgText: "Web Socket Connected...",
          eventType: 'websocket.accept',
          isMe: true);
      controller.sink.add(message);
      // print('\n===== Web Socket Connected =====\n');

    } else if (payload['message']['type'] == "response.jwt_login") {
      Map data = payload['message'];
      MatrixLoginResponse matrixUser = MatrixLoginResponse(
          matrixUserId: data['matrix_user_id'],
          deviceId: data['device_id'],
          matrixToken: data['matrix_token']);
      driver!.myId = matrixUser.matrixUserId;
      print('\n==========');
      print('MY ID: ${driver!.myId}');
      print('\n==========');
      driver!.syncChatApp();
      var message = MessageModel(
          msgText: "Login Success ${matrixUser.matrixUserId}", userId: matrixUser.matrixUserId,
          isMe: true,
          eventType: 'response.jwt_login',
          myId: driver!.myId
      );
      controller.sink.add(message);

    } else if (payload['message']['type'] == "event.message_received") {
      Map data = payload['message'];
      MessageReceivedEvent messageEvent = MessageReceivedEvent(
          sender: data['sender'],
          body: data['body'],
          roomId: data['room_id'],
          roomName: data['room_name'],
          senderId: data['sender_id']);
      String event = "message received>> sender: ${messageEvent.sender} message: ${messageEvent.body}";
      print('====== Sender ID: ${messageEvent.senderId} ||| My ID: ${driver!.myId} ======');
      print('IS ME: ');
      print('Message: ${messageEvent.body}\n');

      var message = MessageModel(
          msgText: event,
          userId: messageEvent.senderId,
          eventType: 'event.message_received',
          isMe: (driver!.myId == messageEvent.senderId));

      controller.sink.add(message);

    } else if (payload['message']['type'] == "response.get_profile") {
      Map data = payload['message'];
      MatrixGetProfileResponse matrixUserProfile = MatrixGetProfileResponse(
          displayName: data['display_name'], avatarUrl: data['avatar_url']);

    } else if (payload['message']['type'] == "response.joined_rooms") {
      Map data = payload['message'];
      MatrixGetJoinedRoomsResponse matrixUserRoms =
      MatrixGetJoinedRoomsResponse(rooms: data['rooms']);
      print('Rooms ==> ${matrixUserRoms.rooms}');
      controller.sink.add(RoomsModel(
          eventType: 'response.joined_rooms',
          msgText: '',
          isMe: true,
          myId: '',
          rooms: matrixUserRoms.rooms, userId: ''));
    }
  }
}