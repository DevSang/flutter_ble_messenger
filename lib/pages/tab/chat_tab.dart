import 'package:flutter/material.dart';

class ChatTab extends StatefulWidget {
  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("참여했던 단화방", style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans')
        ),
        leading: SizedBox (
          width: 15.0,
          height: 15.0,
          child: FloatingActionButton (
            heroTag: "profile",
            backgroundColor: Colors.black54,
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ),

      ),

    );
  }
}
