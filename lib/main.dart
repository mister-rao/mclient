import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mclient/chat/channel/channel_bloc.dart';
import 'package:mclient/chat/ws_get_it.dart';
import 'package:mclient/screens/chat.dart';
import 'package:mclient/models/ws_responses_model.dart';
import 'package:mclient/utilities/global_bloc_observer.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'bloc/chat/chat_bloc.dart';
import 'utilities/channel_functions.dart';
import 'chat/routes.dart';

 void main() {
  // WidgetsFlutterBinding.ensureInitialized();

  /*init();
  getIt<ChannelDriver>().channel.sink.add(jsonEncode({
        "event_type": "hello_flutter",
        "message": "Socket connected from flutter get it"
      }));*/

  BlocOverrides.runZoned(() => runApp(MyApp()), blocObserver: GlobalBlocObserver());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return BlocProvider<ChatBloc>(
      create: (BuildContext context) => ChatBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: Routes.routes(),
        initialRoute: Routes.initScreen(),
      ),
    );
  }
}
