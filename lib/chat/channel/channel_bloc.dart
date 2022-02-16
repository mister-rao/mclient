import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:mclient/chat/matrix_ws_sdk/channel_functions.dart';
import 'package:mclient/src/ws_requests.dart';
import 'package:mclient/src/ws_responses.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Global.dart';
import '../ws_get_it.dart';

part 'channel_event.dart';
part 'channel_state.dart';

class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  ChannelBloc() : super(ChannelInitial()) {
    late final _controller = StreamController<MessageReceivedEvent>.broadcast();

    // public variables

     Stream<MessageReceivedEvent> messageEventStream;
    messageEventStream = _controller.stream.map((event) => event);



    driver = getIt<ChannelDriver>();

    on<ChannelEvent>((event, emit) {
      print("ChannelBloc.bloc event>>: $event");

      /*
      All request events to websocket server defined below
       */
      if (event is MatrixLoginInEvent) {
        driver.loginToMatrix(event.loginRequest);
      }
      if (event is LoggedInMatrixUserEvent) {
        getIt<G>().loggedInUser = event.user;
        emit(LoggedInMatrixUserState(user: event.user));
        print("ChannelBloc.bloc>> emitState: LoggedInMatrixUser");
      }
      /*
      All response events from Websocket defined below
      */
      if (event is MessageReceived) {
        getIt<G>().chatMessages?.add(event.message);
        _controller.add(event.message);
        emit(Message(message: event.message));
      }


    });


  }
  ChannelDriver driver = getIt<ChannelDriver>();

  void dispose() {
    driver.channel.sink.close();
  }



}
