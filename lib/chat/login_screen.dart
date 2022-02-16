import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mclient/chat/channel/channel_bloc.dart';
import 'package:mclient/chat/ws_get_it.dart';
import 'package:mclient/src/ws_requests.dart';
import 'package:provider/provider.dart';
import 'ChatUsersScreen.dart';
import 'Global.dart';
import 'matrix_ws_sdk/channel_functions.dart';
import 'models.dart';

class LoginScreen extends StatefulWidget {
  //
  LoginScreen() : super();

  static const String ROUTE_ID = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //
  late TextEditingController _usernameController;
  final ChannelDriver driver = getIt<ChannelDriver>();
  String auth =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjQ1MDk2MTQ5LCJpYXQiOjE2NDUwMDk3NDksImp0aSI6ImNhODNiOTkzYTg0NzRhOGY4OTNhNTUyYjk3MjI2NjRkIiwidXNlcl9pZCI6MSwibWF0cml4X3VzZXJuYW1lIjoiZ2FuZXNoX3Jhb18yODc3In0.UCoNNHPFmRiu_xCcsWN_XxTaf0yifSyFcGZmBmc0r2k"; //auth key

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChannelBloc, ChannelState>(
      listener: (context, state) {
        print("LoginScreen.BlocListner: >> State: $state");
        if (state is LoggedInMatrixUserState) {
          getIt<G>().loggedInUser = state.user;
          driver.syncChatApp();

          Navigator.pushReplacementNamed(
            context,
            ChatUsersScreen.ROUTE_ID,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Let's Chat"),
          ),
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(20.0),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                OutlineButton(
                    child: const Text('LOGIN'),
                    onPressed: () {
                      _loginBtnTap();
                    })
              ],
            ),
          ),
        );
      },
    );
  }

  _loginBtnTap() async {
    print("LoginScreen._loginBtnTapped!");
    final loginRequest = MatrixLoginRequest(token: auth);
    Provider.of<ChannelBloc>(context, listen: false)
        .add(MatrixLoginInEvent(loginRequest: loginRequest));

    // openHomeScreen(context);
  }
}
