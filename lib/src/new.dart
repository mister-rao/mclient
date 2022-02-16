import 'package:flutter/material.dart';
import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';

Client? client;

void main() {
  client = Client("HappyChat",
      enableE2eeRecovery: true,
      verificationMethods: {KeyVerificationMethod.numbers},
      supportedLoginTypes: {AuthenticationTypes.password});

  if (client == null) {
    throw ('The client is not initialized');
  }

  var uri = Uri.parse("http://192.168.178.20:8008");
  client!.homeserver = uri;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _title = 'My Title';
  final roomId = '!RezBsiFvjPJAMnpYpc:cloudbucket1.matrix.host';
  Room? _room;

  _MyHomePageState() {
    this._title = "CONNECTING";
  }

  Future<void> loginClient() async {
    try {
      await client!.login(
          LoginType.mLoginPassword,
          identifier: AuthenticationUserIdentifier(user: 'ganesh'),
          password: 'qwerty@123');

      print("Client supports encryption ${client!.encryptionEnabled}"); //* This is always false!!!

      this._room = client!.getRoomById(roomId);
      if (this._room == null) {
        throw ('Room not found');
      }

      print("Room is ${this._room!.encrypted ? "already" : "not"} encrypted");

      if (!this._room!.encrypted) {
        this._room!.enableEncryption();
      }

      final joinedRooms = await client!.getJoinedRooms();

      if (!joinedRooms.contains(this.roomId)) {
        this._room!.join();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMessage() async {
    try {
      // * Also tried this
      // var eventContent = Map<String, dynamic>();
      // eventContent['body'] = 'Hallo du Äffchen';
      //eventContent['msgtype'] = MessageTypes.Text;
      //_room!.sendEvent(eventContent, type: 'm.room.message');

      _room!.sendTextEvent('Encrypted now');
    } catch (e) {
      setState(() {
        _title = 'FAIL';
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
                onPressed: loginClient, child: const Text('Initialize'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sendMessage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}