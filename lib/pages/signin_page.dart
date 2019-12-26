import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:Hwa/pages/signup_page.dart';
import 'package:Hwa/utility/call_api.dart';
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background/bgGradeLogin.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            _loginMainImage(),
            _loginInputText(),
            _loginInputCodeField(),
            _SignInButton(),
            _loginText(),
            _socialLogin(),
            _registerSection(),
          ],
        ),
      ),
    appBar: AppBar(
      centerTitle: true,
      backgroundColor: Colors.white,
    title: Text("HWA 로그인",
      style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans'),
    ),
    ),
    );
  }


  Widget _loginMainImage(){
    return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/visualImageLogin.png', width: 200, height: 200)
              ]
        )
    );
  }

  //TODO signin API test
//  signIn(String phone, authCode) async {
//    SharedPreferences loginPref = await SharedPreferences.getInstance();
//    Map data = {
//      'phone': phone,
//      'authcode': authCode
//    };
//
//    var response = CallApi.commonApiCall(data, 'auth/A05-SignInAuth');
//    var jsonResponse = null;
//
//    if(response.statusCode == 200) {
//      jsonResponse = json.encode(response.body);
//      if(jsonResponse != null) {
//        setState(() {
//          _isLoading = false;
//        });
//        loginPref.setString("token", jsonResponse['token']);
//        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
//      }
//    }
//    else {
//      setState(() {
//        _isLoading = false;
//      });
//      print(response.body);
//    }
//  }

//  signIn(String phone, authCode) async {
//    SharedPreferences loginPref = await SharedPreferences.getInstance();
//    Map data = {
//      'phone': phone,
//      'authcode': authCode
//    };
//
//    var jsonResponse = null;
//    var response = await http.post("http://api.hwaya.net/auth/A05-SignInAuth", body: data);
//    if(response.statusCode == 200) {
//      jsonResponse = json.encode(response.body);
//      if(jsonResponse != null) {
//        setState(() {
//          _isLoading = false;
//        });
//        loginPref.setString("token", jsonResponse['token']);
//        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
//      }
//    }
//    else {
//      setState(() {
//        _isLoading = false;
//      });
//      print(response.body);
//    }
//  }


  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController authCodeController = new TextEditingController();

  Widget _loginInputText() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: <Widget>[
          Flexible(
          child: TextFormField(
            maxLength: 11,
              onChanged: (loginAuthCode) {
                print(loginAuthCode);
              },
              onFieldSubmitted: (loginAuthCode) {
                print('login phone number 입력 :$loginAuthCode');
              },
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            controller: phoneController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            counterText: "",
            hintText: "휴대폰 번호 (-없이 숫자만 입력)",
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
          Container(
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              child: Text('인증문자 받기',style: TextStyle(color: Colors.white)),
              color: Colors.grey,
              onPressed: () {
                loginCodeRequest();
              },
            ),
          )

        ],
      ),
    );
  }


  loginCodeRequest() async {
    final uri = 'https://api.hwaya.net/api/v2/auth/A05-SignInAuth';
    var requestBody = {
      'phone_number':'01032711739',
    };

    http.Response response = await http.post(
      uri,
      body: jsonEncode(requestBody),

      headers: {'Content-Type': 'application/json'},
    );

    print(response.body);
  }


  Widget _loginInputCodeField(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Column(
        children: <Widget>[
          TextFormField(
              maxLength: 6,
              onChanged: (loginAuthCode) {
                print(loginAuthCode);
              },
              onFieldSubmitted: (loginAuthCode) {
                print('login authcode 입력 :$loginAuthCode');
              },
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              controller: authCodeController,
              cursorColor: Colors.white,
              obscureText: true,
              style: TextStyle(color: Colors.white70),
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
        ],
      ),
    );
  }

  Widget _SignInButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: RaisedButton(
        onPressed: () {
          loginRequest();
        } ,
        child: Text("Sign In", style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  loginRequest() async {
    final uri = 'https://api.hwaya.net/api/v2/auth/A06-SignInSmsAuth';
    var requestBody = {
      'phone_number':'01032711739',
      "auth_number": "891629"
    };

    http.Response response = await http.post(
      uri,
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'},
    );

    print(response.body);
  }


  Widget _loginText(){
    return Container(
        margin: EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.center,
       children: <Widget>[
       Text("Or Sign in with",style: TextStyle(color: Colors.black, fontSize: 15,fontFamily: 'NotoSans'))
       ],
      )
    );
  }

  Widget _socialLogin(){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
            child: Image.asset('assets/images/sns/snsIconKakao.png')
          ),

          InkWell(
              child: Text("Kakao", style: TextStyle(color: Colors.black38, fontSize: 14,fontFamily: 'NotoSans'),
              )
          ),
          InkWell(
              child: Image.asset('assets/images/sns/snsIconFacebook.png')
          ),
          InkWell(
              child: Text("Facebook", style: TextStyle(color: Colors.black38, fontSize: 14,fontFamily: 'NotoSans'))
          ),
          InkWell(
              child: Image.asset('assets/images/sns/snsIconGoogle.png')
          ),
          InkWell(
              child: Text("Google", style: TextStyle(color: Colors.black38, fontSize: 14,fontFamily: 'NotoSans'))
          ),

        ],
      ),
    );
  }

  Widget _registerSection(){
    return Container(
      margin: EdgeInsets.only(top: 40, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            child: Text("New Here? ", style: TextStyle(color: Colors.black, fontSize: 15,fontFamily: 'NotoSans'))
          ),
          InkWell(
            child: Text("Sign Up", style: TextStyle(color: Colors.black, fontSize: 15,fontFamily: 'NotoSans',fontWeight: FontWeight.bold)),
              onTap: (){ Navigator.pushNamed(context, '/register');
              },
          )
        ],
      ),
    );
  }
}
