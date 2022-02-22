import 'package:mclient/screens/chat.dart';
import 'package:mclient/screens/my_rooms.dart';

class Routes {
  static routes() {
    return {
      ChatPage.ROUTE_ID: (context) => ChatPage(),
      MyRooms.ROUTE: (context) => MyRooms()
    };
  }

  static initScreen() {
    return ChatPage.ROUTE_ID;
  }
}
