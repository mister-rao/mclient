import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mclient/utilities/global_bloc_observer.dart';

import 'bloc/chat/chat_bloc.dart';
import 'chat/routes.dart';

 void main() {
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
