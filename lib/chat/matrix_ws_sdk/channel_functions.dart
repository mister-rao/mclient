import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mclient/chat/channel/channel_bloc.dart';
import 'package:mclient/src/ws_requests.dart';
import 'package:mclient/src/ws_responses.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../ws_get_it.dart';

class ChannelDriver {
  set connected(value) => _connected = value;
  get connected => _connected;
  bool _connected = false;
  final WebSocketChannel channel;



  ChannelDriver({required this.channel});

  Future<void> loginToMatrix(MatrixLoginRequest request) async {
    if (_connected == true) {
      String msg = jsonEncode(request.toJson());
      channel.sink.add(msg); //send message to receiver channel
    } else {
      print("Websocket is not connected.");
    }
  }

  Future<void> getRooms() async {
    if (_connected == true) {
      String msg = jsonEncode(GetRoomsRequest().toJson());
      channel.sink.add(msg); //send message to receiver channel
    } else {
      print("Websocket is not connected.");
    }
  }

  Future<void> syncChatApp() async {
    if (_connected == true) {
      String msg = jsonEncode(SyncChatServerRequest().toJson());
      channel.sink.add(msg); //send message to reciever channel
    } else {
      print("Websocket is not connected.");
    }
  }

  Future<void> sendmsg(String sendmsg, String id) async {
    if (_connected == true) {
      String msg = jsonEncode(SendMessageToRoomRequest(
              roomId: "!UPZfqhWWOSbluGRasc:matrix.glitchh.in", message: sendmsg)
          .toJson());

      channel.sink.add(msg); //send message to reciever channel
    } else {
      print("Websocket is not connected.");
    }
  }
}
