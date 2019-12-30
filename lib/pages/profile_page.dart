import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State <ProfilePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
        backgroundColor: Colors.white,
          title: Text("프로필 설정",
            style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'NotoSans'),
          ),
          leading: Padding(
            padding: EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Image.asset("assets/images/icon/navIconPrev.png"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
      ),
      body: Column(
        children: <Widget>[
          _ProfileImageSection(context)
        ],
      ),
    );
  }
}

Widget _ProfileImageSection(BuildContext context){
 return Container(
    width: MediaQuery.of(context).size.width,
    height: 200,
    decoration: BoxDecoration(
      color: Color.fromRGBO(214, 214, 214, 1),
    ),
    child: Stack(children: <Widget>[
      Row(

        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 140.0,
            height: 140.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: ExactAssetImage(
                      'assets/images/logo.png'),
                  fit: BoxFit.cover,
                )
            ),
            padding: EdgeInsets.only(top: 100.0, left: 80.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Color.fromRGBO(77, 96, 191, 1),
                  radius: 25.0,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ],
      )
    ],),
  );
}