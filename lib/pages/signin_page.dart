import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:Hwa/pages/signup_page.dart';
import 'package:Hwa/app.dart';
import 'dart:convert';

//로그인 page
class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>{

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey
        ),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            headerSection(),
            textSection(),
            buttonSection(),
            registerSection(),
          ],
        ),
      ),
    );
  }

  signIn(String phone, authCode) async {
    SharedPreferences loginPref = await SharedPreferences.getInstance();
    Map data = {
      'phone': phone,
      'authcode': authCode
    };

    var jsonResponse = null;
    var response = await http.post("http://api.hwaya.net/auth/A05-SignInAuth", body: data);
    if(response.statusCode == 200) {
      jsonResponse = json.encode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        loginPref.setString("token", jsonResponse['token']);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
      }
    }
    else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: phoneController.text.isEmpty || authCodeController.text.isEmpty ? null : () {
          setState(() {
            _isLoading = true;
          });
          signIn(phoneController.text, authCodeController.text);
        },
        elevation: 0.0,
        color: Colors.purple,
        child: Text("로그인", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }


  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController authCodeController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            controller: phoneController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              hintText: "전화번호",

              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            controller: authCodeController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              hintText: "인증번호",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Container registerSection(){
    return Container(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("가입하기"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()),
          )
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("HWA",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}
