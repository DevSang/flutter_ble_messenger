import 'package:flutter/material.dart';

//로그인 page

class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();

}

class _SigninPageState extends State<SigninPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Image.asset('images/logo.png'),

          ],
        ),
      ),
    );
  }
}