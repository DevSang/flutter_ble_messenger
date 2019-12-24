import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Hwa/pages/signup_name.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



//register page
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
              _regPhoneTextField(),
              _regPhoneNumTextField(),
              regButton(),
              _regAuthCodeText(),
              _regAuthTextField(),
              _regNextButton(context),
              ]
        ),
      ),
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Image.asset("assets/images/icon/navIconPrev.png"),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ),
      centerTitle: true,
      backgroundColor: Colors.white,
      title: Text("회원가입",style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans'),
      ),
    ),
      );
  }
}

final TextEditingController _phoneRegController = new TextEditingController();

Widget _regPhoneTextField(){
  return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("휴대폰번호 입력",style: TextStyle(color: Colors.black87, fontSize: 13,fontFamily: 'NotoSans'))
        ],
      )
  );
}


Widget _regPhoneNumTextField(){
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    child: TextFormField(
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
        obscureText: true,
        style: TextStyle(color: Colors.white70),

        decoration: InputDecoration(
          hintText: "휴대폰번호 ( -없이 숫자만 입력)",
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



Widget _regAuthCodeText(){
  return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("인증번호 입력",style: TextStyle(color: Colors.black87, fontSize: 13,fontFamily: 'NotoSans'))
        ],
      )
  );
}

final TextEditingController _regAuthCodeController = new TextEditingController();



Widget _regAuthTextField(){
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    child: TextFormField(
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
      controller: _regAuthCodeController,
      cursorColor: Colors.white,
      obscureText: true,
      style: TextStyle(color: Colors.white70),

      decoration: InputDecoration(
        hintText: "인증번호",
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
  );
}


Widget _regNextButton(BuildContext context){
  return Container(
  width: MediaQuery.of(context).size.width,
  height: 50.0,
  padding: EdgeInsets.symmetric(horizontal: 15.0),
  child: RaisedButton(
  onPressed:(){
  Navigator.pushNamed(context, '/register2');
  },
    color: Colors.black38,
    elevation: 0.0,
  child: Text("다음", style: TextStyle(color: Colors.white)),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
  ),
  );
}





