import 'dart:convert';

import 'package:Hwa/utility/call_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//로그인 page
class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  SharedPreferences spf;

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
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: new Container(
          padding:
              EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16.0)),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background/bgGradeLogin.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
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
          brightness: Brightness.light,
          title: Text(
            "HWA 로그인",
            style: TextStyle(
                fontFamily: "NotoSans",
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(39, 39, 39, 1),
                fontSize: ScreenUtil.getInstance().setSp(16),
                letterSpacing: ScreenUtil().setWidth(-0.8)),
          ),
          elevation: 0.0,
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _loginMainImage() {
    return Container(
        height: ScreenUtil().setHeight(203),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Image.asset(
            'assets/images/login/visualImageLogin.png',
            width: ScreenUtil().setWidth(241),
            height: ScreenUtil().setHeight(263),
            fit: BoxFit.cover,
            alignment: Alignment(0, -1),
          )
        ]));
  }

  final TextEditingController _authCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Widget _loginInputText() {
    return Container(
      width: ScreenUtil().setWidth(343),
      height: ScreenUtil().setHeight(50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(210),
            child: TextField(
              maxLines: 1,
              maxLength: 11,
              onChanged: (loginAuthCode) {
                print(loginAuthCode);
              },
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              controller: _phoneController,
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black, fontFamily: 'NotoSans'),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(15),
                    vertical: ScreenUtil().setHeight(15)
                ),
                counterText: "",
                hintText: "휴대폰 번호 (-없이 숫자만 입력)",
                hintStyle: TextStyle(
                    fontFamily: "NotoSans",
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(39, 39, 39, 0.4),
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    letterSpacing: ScreenUtil().setWidth(-0.75)
                ),
              )
            ),
          ),
          InkWell(
            child:
            Container(
              width: ScreenUtil().setWidth(100),
              height: ScreenUtil().setHeight(44),
              margin: EdgeInsets.only(
                  right: ScreenUtil().setWidth(3),
                  bottom: ScreenUtil().setWidth(3),
                  top: ScreenUtil().setWidth(3)
              ),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(77, 96, 191, 1),
                  borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil().setWidth(8)
                  )
                )
              ),
              child: Center(
                child: Text(
                  '인증문자 받기',
                  style: TextStyle(
                      fontFamily: "NotoSans",
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: ScreenUtil.getInstance().setSp(13),
                      letterSpacing: ScreenUtil().setWidth(-0.65)
                  ),
                ),
              )
            ),
            onTap: () {
              loginCodeRequest();
            },
          )
        ],
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: ScreenUtil().setWidth(1),
          color: Color.fromRGBO(214, 214, 214, 1),
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        color: Color.fromRGBO(245, 245, 245, 1),
      ),
    );
  }

  Widget _loginInputCodeField() {
    return Container(
      width: ScreenUtil().setWidth(343),
      height: ScreenUtil().setHeight(50.0),
      margin: EdgeInsets.only(
        top: ScreenUtil().setHeight(6),
        bottom: ScreenUtil().setHeight(6),
      ),
      child: TextFormField(
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
          style: TextStyle(
            color: Colors.black,
            fontFamily: "NotoSans",
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(15),
                vertical: ScreenUtil().setHeight(15)
            ),
            counterText: "",
            hintText: "인증번호",
            hintStyle: TextStyle(
                fontFamily: "NotoSans",
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(39, 39, 39, 0.4),
                fontSize: ScreenUtil.getInstance().setSp(15),
                letterSpacing: ScreenUtil().setWidth(-0.75)),
          )
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: ScreenUtil().setWidth(1),
          color: Color.fromRGBO(214, 214, 214, 1),
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        color: Color.fromRGBO(245, 245, 245, 1),
      ),
    );
  }

  loginCodeRequest() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    print("phone number :: " + _phoneController.text);
    String url = "https://api.hwaya.net/api/v2/auth/A05-SignInAuth";

    Map requestData = {
      'phone_number': _phoneController.text,
    };

    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData));

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

  _getAndSaveToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await authCodeLoginRequest();
    await prefs.setString('jwt', token);
  }

  Widget _SignInButton() {
    return InkWell(
      child: Container(
        width: ScreenUtil().setWidth(343),
        height: ScreenUtil().setHeight(50.0),
        child: Center(
          child: Text("Sign In",
              style: TextStyle(
                  height: 1,
                  fontFamily: "NotoSans",
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: ScreenUtil.getInstance().setSp(16),
                  letterSpacing: ScreenUtil().setWidth(-0.8))),
        ),
        decoration: BoxDecoration(
            color: Color.fromRGBO(204, 204, 204, 1),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8))),
      ),
      onTap: () {
//          _getAndSaveToken();
        authCodeLoginRequest();
      },
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
            'X-Requested-With': 'XMLHttpRequest'
          },
          body: jsonEncode({
            "phone_number": _phoneController.text,
            "auth_number": _authCodeController.text
          }));

      var data = jsonDecode(response.body)['data'];

      if (response.statusCode == 200) {
        print("#로그인에 성공하였습니다.");
        print("#로그인정보 :" + response.body);

        var token = data['token'];
        var userIdx = data['userInfo']['idx'];
        loginPref.setString('token', token.toString());
        loginPref.setString('userIdx', userIdx.toString());
        loginToastMsg("로그인에 성공하였습니다.");
        pushTokenRequest();
        Navigator.pushNamed(context, '/main');
      } else {
        loginToastMsg("서버 요청에 실패하였습니다.");
        print('failed：${response.statusCode}');
      }
    } catch (e) {
      showError(e);
    }
  }

  pushTokenRequest() async {
    spf = await SharedPreferences.getInstance();
    var userIdx = spf.getString("userIdx");
    var pushToken = spf.getString("pushToken");
    try {
      String url = "/api/v2/user/push_token?user_idx=" +
          userIdx +
          "&push_token=" +
          pushToken;
      final response =
          await CallApi.commonApiCall(method: HTTP_METHOD.post, url: url);
      if (response != null) {
        print("#Push token 저장에 성공하였습니다.");
      } else {
        print("#서버요청에 실패하였습니다");
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
        margin: EdgeInsets.only(
            top: ScreenUtil().setHeight(40),
            bottom: ScreenUtil().setHeight(23)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Or Sign in with",
                style: TextStyle(
                    height: 1,
                    fontFamily: "NotoSans",
                    fontWeight: FontWeight.w400,
                    letterSpacing: ScreenUtil.getInstance().setHeight(-0.38),
                    fontSize: ScreenUtil(allowFontScaling: true).setSp(15),
                    color: Color.fromRGBO(39, 39, 39, 1)
                )
            )
          ],
        ));
  }

  Widget _socialLogin() {
    return Container(
      height: ScreenUtil().setHeight(22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(child: Image.asset('assets/images/sns/snsIconKakao.png')),
          InkWell(
              child: Text(
            "Kakao",
            style: TextStyle(
                color: Colors.black54, fontSize: 15, fontFamily: 'NotoSans'),
          )),
          InkWell(
              child: Image.asset('assets/images/sns/snsIconFacebook.png')),
          InkWell(
              child: Text(
                  "Facebook",
                  style: TextStyle(
                      fontFamily: "NotoSans",
                      fontWeight: FontWeight.w500,
                      letterSpacing: ScreenUtil.getInstance().setHeight(-0.33),
                      fontSize: ScreenUtil(allowFontScaling: true).setSp(13),
                      color: Color.fromRGBO(107, 107, 107, 1)
                  )
              )
          ),
          InkWell(child: Image.asset('assets/images/sns/snsIconGoogle.png')),
          InkWell(
              child: Text("Google",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      fontFamily: 'NotoSans'))),
        ],
      ),
    );
  }

  Widget _registerSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
              child: Text("New Here? ",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'NotoSans'))),
          InkWell(
            child: Text("Sign Up",
                style: TextStyle(
                    color: Colors.black,
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
