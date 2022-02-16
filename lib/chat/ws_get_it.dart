import 'package:get_it/get_it.dart';
import 'package:mclient/chat/Global.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'matrix_ws_sdk/channel_functions.dart';

GetIt getIt = GetIt.instance;
Future<void> init() async {
//
  getIt.registerSingleton<WebSocketChannel>(
      WebSocketChannel.connect(
        Uri.parse("ws://localhost:5555/ws/chat/"),
      ),
      signalsReady: true);

  getIt.registerSingleton<ChannelDriver>(
      ChannelDriver(channel: getIt<WebSocketChannel>()),
      signalsReady: true);

  getIt.registerSingleton<G>(G(), signalsReady: true);
}
