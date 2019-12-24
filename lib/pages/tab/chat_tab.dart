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
        title: Row (
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text("참여했던 단화방", style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans')
        ),
        ]
    ),

          leading: InkWell(
    onTap: () => Navigator.pushNamed(context, '/profile'),
            child: CircleAvatar (
            radius: 55.0,
            backgroundImage: AssetImage("assets/images/sns/snsIconFacebook.png"),
          ),
    ),

        actions: <Widget>[
              InkWell(
                child: Text('최신순', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'NotoSans'))),
      InkWell(
        child: Text('|', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'NotoSans'))),
          InkWell(
            child: Text('참여날짜순', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'NotoSans')),
              )
        ],
    ),
    );
  }
}
