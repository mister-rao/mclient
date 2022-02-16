import 'package:mclient/src/ws_responses.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'SocketUtils.dart';
import 'models.dart';

class G {
  // Socket
  SocketUtils? socketUtils;
  List<User>? dummyUsers;

  // Logged In User
  MatrixLoginResponse? loggedInUser;

  // Single Chat - To Chat User
  MatrixUser? toChatUser;

  List<MessageReceivedEvent>? chatMessages;



}
