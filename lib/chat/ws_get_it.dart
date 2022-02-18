import 'package:get_it/get_it.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utilities/channel_functions.dart';

GetIt getIt = GetIt.instance;
Future<void> init() async {
//
  getIt.registerSingleton<WebSocketChannel>(
      WebSocketChannel.connect(
        Uri.parse("wss://api-dev.glitchh.in/ws/chat/"),
      ),
      signalsReady: true);

  getIt.registerSingleton<ChannelDriver>(
      ChannelDriver(channel: getIt<WebSocketChannel>()),
      signalsReady: true);
}
