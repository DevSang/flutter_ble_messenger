import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:Hwa/pages/signup_page.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/utility/set_user_info.dart';


/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-29
 * @description : Sign in page
 *                  - 인증문자 요청 및 social signin
 */
class SignInPage extends StatefulWidget {
    @override
    _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
    final TextEditingController _authCodeController = TextEditingController();
    final TextEditingController _phoneController = TextEditingController();
    SharedPreferences SPF;
    bool _isLoading = false;
    FocusNode contextFocus;
    String phone_number, auth_number;
    bool lengthConfirm;

    //Social signin
    GoogleSignInAccount _currentUser;
    GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: <String>[
            'email',
            'https://www.googleapis.com/auth/contacts.readonly',
        ],
    );

    @override
    void initState() {
        super.initState();
        lengthConfirm = false;

        //Google사용자 status listner
        _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
            setState(() {
                _currentUser = account;
            });
            if (_currentUser != null) {
                developer.log("# Google current user : " + _currentUser.toString());
            }
        });
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : google signin function
     */
    void googleSignin() async {
        try {
            developer.log("# Google Signin");
//            var result = await _googleSignIn.signIn();
//            final http.Response response = await http.get(
//                'https://people.googleapis.com/v1/people/me/connections'
//                    '?requestMask.includeField=person.names',
//                headers: await _currentUser.authHeaders,
//            );

            _googleSignIn.signIn().then((result){
                result.authentication.then((googleKey){
                    print(googleKey.accessToken);
                    print(googleKey.idToken);
                    print(_googleSignIn.currentUser.displayName);
                }).catchError((err){
                    print('inner error');
                });
            }).catchError((err){
                print('error occured');
            });

//            String url = "https://api.hwaya.net/api/v2/auth/A08-SocialSignIn";
//            final response = await http.post(url,
//                headers: {
//                    'Content-Type': 'application/json',
//                    'X-Requested-With': 'XMLHttpRequest'
//                },
//                body: jsonEncode({
//                    "login_type" : "facebook",
//                    "token" : result.accessToken.token.toString()
//                })
//            );


        } catch (error) {
            developer.log(error);
        }
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : facebook signin function
     */
	void facebookLogin() async {
        developer.log("# Facebook Signin");
        final facebookLogin = FacebookLogin();
		final result = await facebookLogin.logIn(["email"]);

		switch (result.status) {
			case FacebookLoginStatus.loggedIn:
                final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${result.accessToken.token}');
                final profile = json.decode(graphResponse.body);
                developer.log(profile.toString());

                String url = "https://api.hwaya.net/api/v2/auth/A08-SocialSignIn";
                final response = await http.post(url,
                    headers: {
                        'Content-Type': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: jsonEncode({
                        "login_type" : "facebook",
                        "token" : result.accessToken.token.toString()
                    })
                );

                var data = jsonDecode(response.body);
                var message = data['message'].toString();
                if (response.statusCode == 200) {
                    developer.log("# 로그인에 성공하였습니다.");
                    developer.log("# 로그인정보 :" + response.body);
                    RedToast.toast("로그인에 성공하였습니다.", ToastGravity.TOP);

                    pushTokenRequest();

                    developer.log('# [Navigator] SignInPage -> MainPage');
                    Navigator.pushNamed(context, '/main');

                } else if(message.indexOf("HWA 에서 사용자를 찾을 수 없습니다") > -1){
                    developer.log('# New user');
                    RedToast.toast("환영합니다. 휴대폰 인증을 진행해주세요.", ToastGravity.TOP);

                    developer.log('# [Navigator] SignInPage -> SignUpPage');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                            return SignUpPage(socialId: profile['id'].toString(), profileURL: profile['picture']['data']['url'].toString(), socialType: "facebook", accessToken: result.accessToken.token.toString());
                        })
                    );
                } else {
                    developer.log('#Request failed：${response.statusCode}');
                    RedToast.toast("서버 요청에 실패하였습니다.",ToastGravity.TOP);
                }
				break;
			case FacebookLoginStatus.cancelledByUser:
				developer.log("# facebookLogin cancelledByUser");
				break;
			case FacebookLoginStatus.error:
				developer.log("# facebookLogin" + result.errorMessage);
				break;
		}
	}

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Auth code request function
     */
    loginCodeRequest() async {
        if(_phoneController.text == '' ){
            developer.log("# Phone number is empty.");
            RedToast.toast("휴대폰 번호를 입력해주세요.", ToastGravity.TOP);
        } else {
            FocusScope.of(context).requestFocus(new FocusNode());
            developer.log("# Requerst phone number : " + _phoneController.text);
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

            if (response.statusCode == 200 || response.statusCode == 202) {
                developer.log("# Auth code requset info :" + response.body);
                developer.log("# 인증문자 요청에 성공하였습니다.");
                RedToast.toast("인증문자를 요청하였습니다.", ToastGravity.TOP);
            } else {
                if(response.statusCode == 406){
                    developer.log("# This is not a HWA user.");
                    RedToast.toast("가입 되어있지 않은 번호입니다. 번호를 다시 확인해주세요.",ToastGravity.TOP);
                } else {
                    developer.log('# Request failed：${response.statusCode}');
                    RedToast.toast("서버 요청에 실패하였습니다.",ToastGravity.TOP);
                }
            }
        }
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Confirm auth code function
     */
    authCodeLoginRequest() async {
        SPF = await SharedPreferences.getInstance();

        try {
            if(_authCodeController.text == ''){
                developer.log("# Auth code is empty.");
                RedToast.toast("인증번호를 입력해주세요.", ToastGravity.TOP);
            } else {
                developer.log("# Auth number : " + _authCodeController.text);
                String url = "https://api.hwaya.net/api/v2/auth/A06-SignInSmsAuth";
                final response = await http.post(url,
                    headers: {
                        'Content-Type': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: jsonEncode({
                        "phone_number": _phoneController.text,
                        "auth_number": _authCodeController.text
                    })
                );

                var data = jsonDecode(response.body)['data'];

                if (response.statusCode == 200) {
                    developer.log("# 로그인에 성공하였습니다.");
                    developer.log("# 로그인정보 :" + response.body);
                    SetUserInfo.set(data['userInfo'], "");

                    var token = data['token'];
                    var userIdx = data['userInfo']['idx'];

                    SPF.setString('token', token.toString());
                    SPF.setString('userIdx', userIdx.toString());

                    RedToast.toast("로그인에 성공하였습니다.", ToastGravity.TOP);
                    pushTokenRequest();
                    developer.log('# [Navigator] SignInPage -> MainPage');
                    Navigator.pushNamed(context, '/main');
                } else {
                    RedToast.toast("서버 요청에 실패하였습니다.", ToastGravity.TOP);
                    developer.log('#Request failed：${response.statusCode}');
                }
            }
        } catch (e) {
            developer.log('#Request failed：${e}');
        }
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Save push token function
     */
    pushTokenRequest() async {
        SPF = await SharedPreferences.getInstance();

        var pushToken = SPF.getString("pushToken");
        try {
            String url = "/api/v2/user/push_token?push_token=" + pushToken;
            final response = await CallApi.commonApiCall(method: HTTP_METHOD.post, url: url);
            if(response != null){
                developer.log("# Push token 저장에 성공하였습니다.");
            } else {
                developer.log('#Request failed：${response.statusCode}');
            }
        } catch (e) {
            developer.log('#Request failed：${e}');
        }
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : 빌드 위젯
     */
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
                            _signinText(),
                            _socialSignin(),
                            _registerSection(context),
                        ],
                    ),
                ),
            ),
            appBar: AppBar(
                centerTitle: true,
                brightness: Brightness.light,
                backgroundColor: Colors.white,
                elevation: 0.0,
                title: Text("HWA 로그인",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'NotoSans'),
                ),
            ),
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : 이미지 위젯
     */
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

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Phone number textfield widget
     */
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
                                developer.log(loginAuthCode);
                            },
                            onFieldSubmitted: (loginAuthCode) {
                                developer.log('login phone number 입력 :$loginAuthCode');
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
                                        focusNode: contextFocus,
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

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Auth code textfield widget
     */
    Widget _loginInputCodeField() {
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: Column(
                children: <Widget>[
                    TextFormField(
                        maxLength: 6,
                        onChanged: (regAuthCode) {
                            if(regAuthCode.length == 6 && !lengthConfirm) {
                                setState(() {
                                    lengthConfirm = true;
                                });
                            } else if (regAuthCode.length != 6 && lengthConfirm){
                                setState(() {
                                    lengthConfirm = false;
                                });
                            }
                        },
                        onFieldSubmitted: (loginAuthCode) {
                            developer.log('login authcode 입력 :$loginAuthCode');
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                        ],
                        controller: _authCodeController,
                        cursorColor: Colors.black,
                        obscureText: true,
                        style: TextStyle(color: Colors.black, fontFamily: "NotoSans"),
                        decoration: InputDecoration(
                            counterText: "",
                            hintText: "인증번호",
                            hintStyle: TextStyle(color: Colors.black38, fontSize:15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(),
                            ),
                            fillColor: Colors.grey[200],
                            filled: true,
                        )
                    ),
                ],
            ),
        );
    }


    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Signin button widget
     */
    Widget _SignInButton() {
        var color = lengthConfirm ? Color.fromRGBO(77, 96, 191, 1) : Color.fromRGBO(204, 204, 204, 1);
        return Container(
            width: MediaQuery.of(context).size.width,
            height: 50.0,
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            color: Colors.white,
            child: RaisedButton(
                onPressed: () {
                    authCodeLoginRequest();
                },
                color: color,
                child: Text("Sign In", style: TextStyle(
                    color: Colors.white, fontSize: 17, fontFamily: 'NotoSans')
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Signin button widget
     */
    Widget _signinText() {
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

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Social Signin widget
     */
    Widget _socialSignin() {
        return Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                    RaisedButton(
                      color: Colors.white,
                      child: Row(
                            children: <Widget>[
                                InkWell(
                                    child: Image.asset('assets/images/sns/snsIconKakao.png'),
                                ),
                                InkWell(
                                    child: Text("Kakao", style: TextStyle(color: Colors.black54, fontSize: 15, fontFamily: 'NotoSans'))
                                ),
                            ],
                        ),
                        onPressed: () {

                        },
                    ),
                    RaisedButton(
                      color: Colors.white,
                        child: Row(
                            children: <Widget>[
                                InkWell(
                                    child: Image.asset('assets/images/sns/snsIconFacebook.png'),
                                ),
                                InkWell(
                                    child: Text("Facebook", style: TextStyle(color: Colors.black54, fontSize: 15, fontFamily: 'NotoSans'))
                                ),
                            ],
                        ),
                        onPressed: () {
                            facebookLogin();
                        },
                    ),
                    RaisedButton(
                      color: Colors.white,
                      child: Row(
                            children: <Widget>[
                                InkWell(
                                    child: Image.asset('assets/images/sns/snsIconGoogle.png'),
                                ),
                                InkWell(
                                    child: Text("Google", style: TextStyle(color: Colors.black54, fontSize: 15, fontFamily: 'NotoSans'))
                                ),
                            ],
                        ),
                        onPressed:googleSignin,
                    ),
                ],
            ),
        );
    }


    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Signup button widget
     */
    Widget _registerSection(BuildContext context) {
        return Container(
            margin: EdgeInsets.only(top: 40, bottom: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    InkWell(
                        child: Text(
                            "New Here? ",
                            style: TextStyle(
                                color: Colors.black, fontSize: 15, fontFamily: 'NotoSans')
                        )
                    ),
                    InkWell(
                        child: Text("Sign Up", style: TextStyle(color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.bold)),
                        onTap: () {
                            developer.log('# [Navigator] SignInPage -> SignUpPage');
                            Navigator.pushNamed(context, '/register');
                        },
                    )
                ],
            ),
        );
    }
}



