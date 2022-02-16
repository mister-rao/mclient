import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mclient/chat/channel/channel_bloc.dart';
import 'package:mclient/src/chat.dart';

import 'ChatScreen.dart';
import 'ChatUsersScreen.dart';
import 'login_screen.dart';

class Routes {
  static routes() {
    return {
      LoginScreen.ROUTE_ID: (context) =>
          BlocProvider(
            create: (context) => ChannelBloc(),
            child: LoginScreen(),
          ),
      ChatUsersScreen.ROUTE_ID: (context) => ChatUsersScreen(),
      ChatScreen.ROUTE_ID: (context) => ChatScreen(),
      ChatPage.ROUTE_ID: (context) => ChatPage(),
    };
  }

  static initScreen() {
    return ChatPage.ROUTE_ID;
  }
}
