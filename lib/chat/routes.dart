import 'package:mclient/screens/chat.dart';

class Routes {
  static routes() {
    return {
      ChatPage.ROUTE_ID: (context) => ChatPage(),
    };
  }

  static initScreen() {
    return ChatPage.ROUTE_ID;
  }
}
