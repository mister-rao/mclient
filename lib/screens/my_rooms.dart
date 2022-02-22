import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mclient/bloc/chat/chat_bloc.dart';
import 'package:mclient/models/message_model.dart';

class MyRooms extends StatefulWidget {
  static const ROUTE = 'MY_ROOMS';
  const MyRooms({Key? key}) : super(key: key);

  @override
  _MyRoomsState createState() => _MyRoomsState();
}

class _MyRoomsState extends State<MyRooms> {
  @override
  void initState() {
    BlocProvider.of<ChatBloc>(context).add(GetRoomsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
          if (state is RoomsLoadedState) {
            return StreamBuilder<MessageModel>(
                stream: state.messageStream,
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.active){
                    if(snapshot.data!.eventType == 'response.joined_rooms'){
                      var model = snapshot.data! as RoomsModel;
                      return Column(
                        children: model.rooms
                            .map((e) => Card(
                            color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(e, style: Theme.of(context).textTheme.headline2),
                            )))
                            .toList(),
                      );
                    }else{
                      return Offstage();
                    }
                  }else{
                    return Center(child: Text('Loading rooms...'));
                  }
                });
          }
          return Center(child: Text('Loading rooms...'));
        }),
      ),
    );
  }
}
