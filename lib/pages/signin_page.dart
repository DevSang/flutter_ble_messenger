import 'package:flutter/material.dart';

//회원가입 화면

class SigninPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SigninPageState();
  }
}


class SigninPageState extends State<SigninPage>{
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 48.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  height: 90.0,
                ),
                new SizedBox(
                  height: 48.0,
                ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}



