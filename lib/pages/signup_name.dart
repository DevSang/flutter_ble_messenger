import 'package:flutter/material.dart';
import 'package:Hwa/app.dart';

final TextEditingController regNameController = new TextEditingController();

class SignUpNamePage extends StatefulWidget{

  static const routeName = '/register2';

  @override
  _SignUpNamePageState createState() => _SignUpNamePageState();
}
class _SignUpNamePageState extends State<SignUpNamePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[
            setRegName(),
          startMain()
          ]
        ),
      ),
    );
  }
}

Container setRegName(){
  return Container(
    child: TextFormField(
      controller: regNameController,
      style: TextStyle(color: Colors.black),
  decoration: InputDecoration(
  hintText: "닉네임을 입력하세요 ",
  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
  hintStyle: TextStyle(color: Colors.black),
  ),
    ),
  );
}

Container startMain(){
  return Container(
    padding: EdgeInsets.only(left: 50, right: 50),
    child: Column(
      children: <Widget>[
        RaisedButton(
          child: Text("시작하기"),
          onPressed: () {}
        ),
      ],
    ),
  );
}

