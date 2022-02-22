import 'package:flutter/material.dart';

class SendInvite extends StatelessWidget {
  SendInvite({Key? key}) : super(key: key);
  final _inviteIdcontroller = TextEditingController();
  final _roomNamecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send Invite')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _inviteIdcontroller,
            decoration: InputDecoration(
                labelText: 'Invite Id'
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _roomNamecontroller,
            decoration: InputDecoration(
                labelText: 'Room Name'
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: (){
                Navigator.pop(context, [_inviteIdcontroller.text, _roomNamecontroller.text]);
              }, child: Text('Send Invite'))
        ],
      ),
    );
  }
}
