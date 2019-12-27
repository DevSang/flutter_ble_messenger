import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:Hwa/app.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:Hwa/pages/signup_page.dart';
import 'dart:convert';

final TextEditingController _regNameController =  TextEditingController();

class SignUpNamePage extends StatefulWidget{
  @override
  _SignUpNamePageState createState() => _SignUpNamePageState();
}

class _SignUpNamePageState extends State<SignUpNamePage>{
  bool availNick;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    availNick = false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Image.asset("assets/images/icon/navIconClose.png"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text("회원가입",style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans'),
          ),
        ),
      body: Container(
        child: ListView(
          children: <Widget>[
            _regNickTextField(),
            _regAuthTextField(),
            _regStartBtn(context)
          ]
        ),
      ),

    );
  }
}

Widget _regNickTextField(){
  return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("닉네임 입력",style: TextStyle(color: Colors.black87, fontSize: 13,fontFamily: 'NotoSans'))
        ],
      )
  );
}


validateUsername(nickname) {
  bool _isValid;
  http.get("https://api.hwaya.net/api/v2/auth/A03-Nickname?nickname=$nickname")
      .then((val) {
        print(val.body.toString());
  });
  return _isValid;
}

final _formKey = GlobalKey<FormState>();


Widget _regAuthTextField(){
  return Form(
    key: _formKey,
    child: Padding(

        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
child: TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            return '닉네임을 입력해주세요';
          } else {
            if (validateUsername(value)) {
              return '이미 사용중인 닉네임입니다.';
            }
          }
        },
        onChanged: (regNickname) {
          validateUsername(regNickname);
        },
        onFieldSubmitted: (regNickname) {
          print('닉네임 입력 :$regNickname');
        },
        keyboardType: TextInputType.text,
        inputFormatters: <TextInputFormatter>[
        ],
        controller: _regNameController,
        textAlign: TextAlign.left,
        cursorColor: Colors.black,
        obscureText: true,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          counterText: "",
          hintText: "닉네임을 입력하세요",
          suffixIcon: IconButton(
              icon: Image.asset("assets/images/icon/iconDeleteSmall.png"),
              onPressed: () => _regNameController.clear(),
          ),
          hintStyle: TextStyle(color: Colors.black38),
          border:  OutlineInputBorder(
            borderRadius:  BorderRadius.circular(10.0),
            borderSide:  BorderSide(
            ),
          ),
          fillColor: Colors.grey[200],
          filled: true,
        )
    ),
    ),
  );
}



Widget _regStartBtn(BuildContext context){
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50.0,
    margin: EdgeInsets.only(top: 10),
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    child: RaisedButton(
      onPressed:(){
     if (_formKey.currentState.validate()) {
       registerFinish();
    }
     else{
       Navigator.pushNamed(context, '/main');
     }
      },
      color: Colors.black38,
      elevation: 0.0,
      child: Text("시작하기", style: TextStyle(color: Colors.white)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),

    ),
  );
}

// 시작하기 연결
registerFinish() async {
  print("phone number :: " + _regNameController.text);
  String url = "https://api.hwaya.net/api/v2/auth/A04-SignUp";
  final response = await http.post(url,
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "phone_number": phoneRegController.text,
        "nickname": _regNameController.text
      })
  ).then((http.Response response) {
    print("signin :: " + response.body);
  });
  var data = jsonDecode(response.body);
  String phoneNum = data['phone_number'];
  String message = data['message'];
  String token = data['token'];
  if (response.statusCode == 200) {
    print(phoneNum);
    print(token);
  } else {
    print('failed：${response.statusCode}');
  }
}



