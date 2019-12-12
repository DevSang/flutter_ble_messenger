import 'package:flutter/material.dart';

//로그인 page

class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();

}

class _SigninPageState extends State<SigninPage>{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
        home: Scaffold(
        body: Center(
          child: Image.asset('assets/images/logo.png'),
        ),
    ),
    );
  }
  }


