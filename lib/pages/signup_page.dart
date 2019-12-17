import 'package:flutter/material.dart';

//회원가입 page
class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
  }

class _SignUpPageState extends State<SignUpPage>{
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

