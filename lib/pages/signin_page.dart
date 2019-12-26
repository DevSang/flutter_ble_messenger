import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'NotoSans'),
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


  final TextEditingController _authCodeController =  TextEditingController();
  final TextEditingController _phoneController =  TextEditingController();

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
            controller: _phoneController,
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black,fontFamily: 'NotoSans'),
          decoration: InputDecoration(
            suffixIcon: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text("인증문자 받기",style: TextStyle(color: Colors.white, fontFamily: 'NotoSans'),
                ),
                color: Color.fromRGBO(77, 96, 191, 1),
                onPressed: () {
                  loginCodeRequest();
                }),
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
        ],
      ),
    );
  }

  loginCodeRequest() async {
    print("phone number :: " +  _phoneController.text);
    String url = "https://api.hwaya.net/api/v2/auth/A05-SignInAuth";
    final response = await http.post(url,
        headers: {
          'Content-Type':'application/json'
        },
        body: jsonEncode({
          "phone_number": _phoneController.text
        })
    ).then((http.Response response) {
      print("signin :: " + response.body);
    });
    var data = jsonDecode(response.body);
    String phoneNum = data['phone_number'];
    String message = data['message'];
    if (response.statusCode == 200) {
      print(phoneNum);
      loginToastMsg(message);
    } else {
      loginToastMsg(message);
      print('failed：${response.statusCode}');
    }
  }

  loginToastMsg(String toast){
    return Fluttertoast.showToast(
        msg: "toast",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  Widget _loginInputCodeField(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
              controller: _authCodeController,
              cursorColor: Colors.black,
              obscureText: true,
              style: TextStyle(color: Colors.black, fontFamily: "NotoSans",
              ),
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
//      color: Color.fromRGBO(204, 204, 204, 1),
      child: RaisedButton(
        onPressed: () {
            authCodeLoginRequest();
          },
        child: Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 17, fontFamily: 'NotoSans')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  authCodeLoginRequest() async {
    print("auth number :: " +  _authCodeController.text);
    String url = "https://api.hwaya.net/api/v2/auth/A06-SignInSmsAuth";
    final response = await http.post(url,
        headers: {
          'Content-Type':'application/json',
          'X-Requested-With': 'XMLHttpRequest'},
        body: jsonEncode({
          "phone_number": _phoneController.text,
          "auth_number": _authCodeController.text
        })
    ).then((http.Response response) {
      print("로그인 :: " + response.body);
    });
    var data = jsonDecode(response.body);
    String authNum = data['auth_number'];
    String message = data['message'];
    if (response.statusCode == 200) {
      print(authNum);
      loginToastMsg(message);
    } else {
      loginToastMsg(message);
      print('failed：${response.statusCode}');
    }
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
