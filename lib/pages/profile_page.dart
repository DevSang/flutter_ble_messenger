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
          _profileImageSection(context),
          _profileSetting(context),
          _appSetting(),
          _accountSetting()
    ],
      ),
    );
  }
}

Widget _profileImageSection(BuildContext context){
 return Container(

   padding: EdgeInsets.only(top: 50.0),
    width: MediaQuery.of(context).size.width,
    height: 200,
    decoration: BoxDecoration(
      color: Color.fromRGBO(178, 178, 178, 1),
    ),
    child: Stack(children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: ExactAssetImage(
                      'assets/images/logo.png'),
                  fit: BoxFit.cover,
                )
            ),
            padding: EdgeInsets.only(top: 60.0, left: 50.0),
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

Widget _profileSetting(BuildContext context){
  return Container(
    child: Stack(
      children: <Widget>[
        Column(
    children: <Widget>[
    Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          width: MediaQuery.of(context).size.width,
          height: 30.0,
          decoration: BoxDecoration(
            color: Color.fromRGBO(214, 214, 214, 1),
          ),
          child: Text("프로필",style: TextStyle(fontSize: 14,fontFamily: "NotoSans")),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
          child: Row(
            children: <Widget>[
    Text("사용자 이름", style: TextStyle(fontSize: 15,fontFamily: "NotoSans")),

  InkWell(
          child: Text("강희근", style: TextStyle(fontSize: 15,fontFamily: "NotoSans")),
    )
  ],
  )
        ),

      Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
          child: Row(
            children: <Widget>[
              Text("한 줄 소개", style: TextStyle(fontSize: 15,fontFamily: "NotoSans")),

              InkWell(
                child: Text("안녕하세요 강희근입니다.", style: TextStyle(fontSize: 15,fontFamily: "NotoSans")),
              )
            ],
          )
      ),

//작업중

  ]
  ),


    ],),


  );
}

Widget _appSetting(){
  return Container(

  );
}

Widget _accountSetting(){
  return Container(

  );
}