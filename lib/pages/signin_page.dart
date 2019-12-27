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

class _SignInPageState extends State<SignInPage> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  String phone_number, auth_number;

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  checkAuthentication() async {
    Navigator.pushReplacementNamed(context, '/home');
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: new Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background/bgGradeLogin.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView(
            children: <Widget>[
              _loginMainImage(),
              _loginInputText(),
              _loginInputCodeField(),
              _SignInButton(),
              _loginText(),
              _socialLogin(),
              _registerSection(context),
            ],
          ),
        ),
      ),
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text("HWA 로그인",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontFamily: 'NotoSans'),
          )),
    );
  }


  Widget _loginMainImage() {
    return Container(
        height: 203,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/login/visualImageLogin.png',
                width: 241,
                height: 263,
                fit: BoxFit.cover,
                alignment: Alignment(0, -1),
              )
            ]
        )
    );
  }

  final TextEditingController _authCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Widget _loginInputText() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child:
              TextFormField(
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
                style: TextStyle(color: Colors.black, fontFamily: 'NotoSans'),
                decoration:
                  InputDecoration(
                    suffixIcon:
                    Container(
                      margin: EdgeInsets.only(right:5),
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text("인증문자 받기",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'NotoSans'
                            ),
                          ),
                          color: Color.fromRGBO(77, 96, 191, 1),
                          onPressed: () {
                            loginCodeRequest();
                          }
                      )
                    ),
                    counterText: "",
                    hintText: "휴대폰 번호 (-없이 숫자만 입력)",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
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
    print("phone number :: " + _phoneController.text);
    String url = "https://api.hwaya.net/api/v2/auth/A05-SignInAuth";

    Map requestData = {
      'phone_number': _phoneController.text,
    };

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode(requestData)
    );

    var data = jsonDecode(response.body);
    String message = data['message'];

    if (response.statusCode == 200 || response.statusCode == 202) {
      print("#Auth code requset info :" + response.body);
      print("#인증문자 요청에 성공하였습니다.");
      loginToastMsg("인증문자 요청에 성공하였습니다.");
    } else {
      loginToastMsg("서버 요청에 실패하였습니다.");
      print('failed：${response.statusCode}');
    }
  }

  loginToastMsg(String message) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  Widget _loginInputCodeField() {
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
                hintStyle: TextStyle(color: Colors.black38, fontSize:15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
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

  _getAndSaveToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await authCodeLoginRequest();
    await prefs.setString('jwt', token);
  }

  Widget _SignInButton() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 50.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
//      color: Color.fromRGBO(204, 204, 204, 1),
      child: RaisedButton(
        onPressed: () {
//          _getAndSaveToken();
          authCodeLoginRequest();
        },
        child: Text("Sign In", style: TextStyle(
            color: Colors.white, fontSize: 17, fontFamily: 'NotoSans')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

   authCodeLoginRequest() async {
     SharedPreferences loginPref = await SharedPreferences.getInstance();

    try {
      print("auth number :: " + _authCodeController.text);
      String url = "https://api.hwaya.net/api/v2/auth/A06-SignInSmsAuth";
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest'},
          body: jsonEncode({
            "phone_number": _phoneController.text,
            "auth_number": _authCodeController.text
          })
      );

      var data = jsonDecode(response.body)['data'];

      if (response.statusCode == 200) {
        print("로그인에 성공하였습니다.");
        print("로그인정보 :" + response.body);

        var token = data['token'];
        loginPref.setString('token', token.toString());

        loginToastMsg("로그인에 성공하였습니다.");
        Navigator.pushNamed(context, '/main');
      } else {
        loginToastMsg("서버 요청에 실패하였습니다.");
        print('failed：${response.statusCode}');
      }
    } catch (e) {
      showError(e);
    }

  }

  showError(String errMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errMessage),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Widget _loginText() {
    return Container(
        margin: EdgeInsets.only(top: 20, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Or Sign in with", style: TextStyle(
                color: Colors.black, fontSize: 15, fontFamily: 'NotoSans'))
          ],
        )
    );
  }

  Widget _socialLogin() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
              child: Image.asset('assets/images/sns/snsIconKakao.png')
          ),

          InkWell(
              child: Text("Kakao", style: TextStyle(
                  color: Colors.black54, fontSize: 15, fontFamily: 'NotoSans'),
              )
          ),
          InkWell(
              child: Image.asset('assets/images/sns/snsIconFacebook.png')
          ),
          InkWell(
              child: Text("Facebook", style: TextStyle(
                  color: Colors.black54, fontSize: 15, fontFamily: 'NotoSans'))
          ),
          InkWell(
              child: Image.asset('assets/images/sns/snsIconGoogle.png')
          ),
          InkWell(
              child: Text("Google", style: TextStyle(
                  color: Colors.black54, fontSize: 15, fontFamily: 'NotoSans'))
          ),
        ],
      ),
    );
  }


  Widget _registerSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
              child: Text("New Here? ", style: TextStyle(
                  color: Colors.black, fontSize: 15, fontFamily: 'NotoSans'))
          ),
          InkWell(
            child: Text("Sign Up", style: TextStyle(color: Colors.black,
                fontSize: 15,
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushNamed(context, '/register');
            },
          )
        ],
      ),
    );
  }
}



