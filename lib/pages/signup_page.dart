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
            icon: Image.asset("assets/images/icon/navIconClose.png"),
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

final TextEditingController phoneRegController = new TextEditingController();
final TextEditingController _regAuthCodeController = new TextEditingController();

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

        controller: phoneRegController,
        cursorColor: Colors.black,
        obscureText: false,
        style: TextStyle(color: Colors.black, fontFamily: "NotoSans",
        ),
        decoration: InputDecoration(
          suffixIcon: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
              ),
            child: Text("인증문자 받기",style: TextStyle(color: Colors.white, fontFamily: 'NotoSans'),
            ),
              color: Color.fromRGBO(77, 96, 191, 1),
              onPressed: () {
                registerCodeRequest();
              }),
          counterText:"",
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


registerCodeRequest() async {
  print("phone number :: " +  phoneRegController.text);
  String url = "https://api.hwaya.net/api/v2/auth/A01-SignUpAuth";
  final response = await http.post(url,
      headers: {
        'Content-Type':'application/json'
      },
      body: jsonEncode({
        "phone_number": phoneRegController.text
      })
  ).then((http.Response response) {
    print("signup :: " + response.body);
  });
  var data = jsonDecode(response.body);
  String phoneNum = data['phone_number'];
  if (response.statusCode == 200) {
    print(phoneNum);
  } else {
    print('failed：${response.statusCode}');
  }
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
      cursorColor: Colors.black,
      obscureText: true,
      style: TextStyle(color: Colors.black, fontFamily: "NotoSans",),
      decoration: InputDecoration(
        counterText: "",
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
    margin: EdgeInsets.only(top: 15.0),
    padding: EdgeInsets.symmetric(horizontal: 15.0),
  child: RaisedButton(
  onPressed:(){
    registerNext();
  Navigator.pushNamed(context, '/register2');
  },
    color: Colors.black38,
    elevation: 0.0,
  child: Text("다음", style: TextStyle(color: Colors.white,  fontFamily: 'NotoSans')),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
  ),
  );
}


registerNext() async {
  print("register authcode :: " +  _regAuthCodeController.text);
  String url = "https://api.hwaya.net/api/v2/auth/A02-SignUpSmsAuth";
  final response = await http.post(url,
      headers: {
        'Content-Type':'application/json',
        'X-Requested-With': 'XMLHttpRequest'}
        ,
      body: jsonEncode({
        "phone_number": phoneRegController.text,
        "auth_number": _regAuthCodeController.text
      })
  ).then((http.Response response) {
    print("register authcode  :: " + response.body);
  });
  var data = jsonDecode(response.body);
  String phoneNum = data['auth_number'];
  if (response.statusCode == 200) {
    print(phoneNum);
  } else {
    print('failed：${response.statusCode}');
  }
}






