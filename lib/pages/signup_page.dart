import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Hwa/pages/signup_name.dart';

//회원가입 page
class SignUpPage extends StatefulWidget {

  @override
  _SignUpPageState createState() => _SignUpPageState();
  }

class _SignUpPageState extends State<SignUpPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
               decoration: BoxDecoration(
         image: DecorationImage(
           image: AssetImage("assets/images/background/bgMap.png"),
           fit: BoxFit.cover,
         ),
       ),
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

final TextEditingController phoneRegController = new TextEditingController();
final TextEditingController phoneRegAuthController = new TextEditingController();

Container regPhoneText() {
  return Container(
      child:  TextFormField(
  keyboardType: TextInputType.number,
  inputFormatters: <TextInputFormatter>[
  WhitelistingTextInputFormatter.digitsOnly
  ],
  controller: phoneRegController,
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


Container regButton(){
  return Container(
    width: 100.0,
    height: 40.0,
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    margin: EdgeInsets.only(top: 15.0),
    child: RaisedButton(
      onPressed: (){

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
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
      controller: phoneRegAuthController,
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



