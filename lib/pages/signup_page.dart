import 'package:flutter/material.dart';

//회원가입 page

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
  }

class _SignupPageState extends State<SignupPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
            title: Text("회원가입",
            style: TextStyle(
              color:Colors.black45,
                fontSize: 19.0
            )),
        )
    );
  }
}

