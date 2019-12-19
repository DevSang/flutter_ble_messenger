import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Hwa/pages/signup_name.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show utf8;



//???? page
class SignUpPage extends StatefulWidget {

  @override
  _SignUpPageState createState() => _SignUpPageState();
  }

class _SignUpPageState extends State<SignUpPage>{



  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        child: ListView(
            children: <Widget>[
              headerSection(),
              regPhoneText(),
              regButton(),
              regAuthText(),
              regNextButton(context),
              ]
        ),
      )
      );
  }
}

final TextEditingController _phoneRegController = new TextEditingController();
final TextEditingController _phoneRegAuthController = new TextEditingController();

Container regPhoneText() {
  return Container(
      child:  TextFormField(
        maxLength: 11,
        onChanged: (regPhoneNum) {
          print(regPhoneNum);
        },
        onFieldSubmitted: (regPhoneNum) {
          print('회원가입 전화번호  :$regPhoneNum');
        },
  keyboardType: TextInputType.number,
  inputFormatters: <TextInputFormatter>[
  WhitelistingTextInputFormatter.digitsOnly
  ],
  controller: _phoneRegController,
  cursorColor: Colors.white,
  style: TextStyle(color: Colors.black),
  decoration: InputDecoration(
    hintText: "전화번호 입력",
  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
  hintStyle: TextStyle(color: Colors.black),
  ),
  ),
  );
}

postTest() async {
  final uri = 'https://api.hwaya.net/auth/A01-SignUpAuth';
  var requestBody = {
    'phone_number':'01032711739',
//      'auth_code':'218796'
  };

  http.Response response = await http.post(
    uri,
    body: jsonEncode(requestBody),

    headers: {'Content-Type': 'application/json'},
  );

  print(response.body);
}

Container regButton(){
  return Container(
    width: 100.0,
    height: 40.0,
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    margin: EdgeInsets.only(top: 15.0),
    child: RaisedButton(
      onPressed: (){
        postTest();
      },
      color: Colors.blue,

      child: Text("인증번호 받기", style: TextStyle(color: Colors.white)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    ),
  );
}





Container regAuthText() {
  return Container(
    child:  TextFormField(
      maxLength: 6,
      onChanged: (regAuthCode) {
        print(regAuthCode);
      },
      onFieldSubmitted: (regAuthCode) {
        print('회원가입 인증코드 입력 :$regAuthCode');
      },
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
      controller: _phoneRegAuthController,
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: "인증번호 입력",
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
        hintStyle: TextStyle(color: Colors.black),
      ),
    ),
  );
}

Container regNextButton(BuildContext context){
  return Container(
      padding: EdgeInsets.only(left: 50, right: 50),
  child: RaisedButton(
    child: Text("다음", style: TextStyle(color: Colors.white)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      onPressed: () {
        Navigator.pushNamed(context, '/register2');
        },
  ),
  );
}

Container headerSection() {
  return Container(
    margin: EdgeInsets.only(top: 50.0),
    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
    child: Text("회원 가입화면 ",
        style: TextStyle(
            color: Colors.black,
            fontSize: 40.0,
            fontWeight: FontWeight.bold)),
  );
}



