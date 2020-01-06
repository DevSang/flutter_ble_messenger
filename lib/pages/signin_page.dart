import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:Hwa/constant.dart';
import 'package:Hwa/home.dart';

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
    SharedPreferences spf;
    bool _isLoading = false;
    FocusNode contextFocus;
    String phone_number, auth_number;
    bool lengthConfirm = false;

    //Social signin - Google
    GoogleSignInAccount _currentUser;
    GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: <String>[
            'email',
            'https://www.googleapis.com/auth/contacts.readonly',
        ],
    );

    @override
    void initState() {
	    initSignIn();
	    super.initState();
    }

    /*
     * @author : hk
     * @date : 2020-01-05
     * @description : init SignIn
     */
    void initSignIn() async {
	    spf = await Constant.getSPF();

	    // Google 사용자 status listener
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
     * @description : google signin function, TODO 에러 처리
     */
    void googleSignin() async {
        try {
            developer.log("# Google Signin");
            _googleSignIn.signIn().then((result){
                result.authentication.then((googleKey) async {
                    socialSigninAfterProcess(
                        "google",
                        googleKey.accessToken.toString(),
                        _googleSignIn.currentUser.id.toString(),
                        _googleSignIn.currentUser.photoUrl.toString()
                    );
                }).catchError((err){
	                developer.log('inner error');
                });
            }).catchError((err){
	            developer.log('error occured');
            });
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
                socialSigninAfterProcess(
                    "facebook",
                    result.accessToken.token.toString(),
                    profile['id'].toString(),
                    profile['picture']['data']['url'].toString()
                );

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
     * @description : Social signin 이후 처리
     */
    socialSigninAfterProcess (String loginType, accessToken, profileId, photoUrl) async {
        String url = "https://api.hwaya.net/api/v2/auth/A08-SocialSignIn";
        final response = await http.post(url,
            headers: {
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: jsonEncode({
                "login_type" : loginType,
                "token" : accessToken
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
                    return SignUpPage(
                        socialId:profileId,
                        profileURL: photoUrl,
                        socialType: loginType,
                        accessToken: accessToken);
                })
            );
        } else {
            developer.log('#Request failed：${response.statusCode}');
            RedToast.toast("서버 요청에 실패하였습니다.", ToastGravity.TOP);
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

                    spf.setString('token', token.toString());
                    spf.setInt('userIdx', userIdx);

                    await Constant.initUserInfo();
                    HomePageState.initApiCall();

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
        var pushToken = spf.getString("pushToken");
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
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ListView(
                        children: <Widget>[
                            _loginMainImage(),
                            _loginInputText(),
                            _loginInputCodeField(),
                            _SignInButton(),
                            _registerSection(context),
                            _signinText(),
                            _socialSignin()
                        ],
                    ),
                ),
            ),
            resizeToAvoidBottomPadding: false,
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : 이미지 위젯
     */
    Widget _loginMainImage() {
        return Container(
            height: ScreenUtil().setHeight(232),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Image.asset(
                        'assets/images/loginLogo.png',
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
            height: ScreenUtil().setHeight(50),
            width: ScreenUtil().setWidth(343),
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16), vertical: ScreenUtil().setHeight(3)),
            decoration: new BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: new BorderRadius.all(Radius.circular(ScreenUtil().setHeight(10.0)))
            ),
            child: Row(
                children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left:ScreenUtil().setWidth(15)),
                        width: ScreenUtil().setWidth(217),
                        child: TextFormField(
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
                            style: TextStyle(color: Colors.black, fontFamily: 'NotoSans',  fontSize: 15),
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                counterText: "",
                                hintStyle: TextStyle(color: Color.fromRGBO(39, 39, 39, 0.5), fontSize: ScreenUtil().setSp(15), fontWeight: FontWeight.w500),
                                hintText: '휴대폰번호 ( -없이 숫자만 입력)'
                            ),
                        )
                    )
                    ,RaisedButton(
                        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(13), horizontal: ScreenUtil().setWidth(15)),
                        focusNode: contextFocus,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                        ),
                        child: Text("인증문자 받기",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'NotoSans',
                                fontSize: ScreenUtil().setSp(13)
                            ),
                        ),
                        color: Color.fromRGBO(77, 96, 191, 1),
                        onPressed: () {
                            loginCodeRequest();
                        }
                    )
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
            height: ScreenUtil().setHeight(50),
            width: ScreenUtil().setWidth(343),
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16), vertical: ScreenUtil().setHeight(3)),
            decoration: new BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: new BorderRadius.all(Radius.circular(ScreenUtil().setHeight(10.0)))
            ),
            child:  Container(
                margin: EdgeInsets.only(left:ScreenUtil().setWidth(15)),
                width: ScreenUtil().setWidth(215),
                child: TextFormField(
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
                    obscureText: true,
                    style: TextStyle(color: Colors.black, fontFamily: 'NotoSans',  fontSize: 15),
                    decoration: new InputDecoration(
                        contentPadding: EdgeInsets.only(top:ScreenUtil().setHeight(3)),
                        border: InputBorder.none,
                        counterText: "",
                        hintStyle: TextStyle(color: Color.fromRGBO(39, 39, 39, 0.5), fontSize: ScreenUtil().setSp(15), fontWeight: FontWeight.w500),
                        hintText: '인증번호'
                    ),
                )
            )
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
            margin: EdgeInsets.only(top:ScreenUtil().setHeight(3)),
            width: MediaQuery.of(context).size.width,
            height: ScreenUtil().setHeight(50),
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            color: Colors.white,
            child: RaisedButton(
                onPressed: () {
                    authCodeLoginRequest();
                },
                color: color,
                child: Text("로그인", style: TextStyle(
                    color: Colors.white, fontSize: 17, fontFamily: 'NotoSans')
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenUtil().setHeight(10.0))),
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
            decoration: new BoxDecoration(
                border: new Border(bottom: BorderSide(color:Color.fromRGBO(122, 122, 122, 1), width: 0.5)),
            ),
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(16), bottom: ScreenUtil().setHeight(34)),
            margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    InkWell(
                        child: Text(
                            "계정이 없으세요? ",
                            style: TextStyle(
                                color: Color.fromRGBO(107, 107, 107, 1),
                                fontSize: ScreenUtil().setSp(15),
                                fontFamily: 'NotoSans')
                        )
                    ),
                    InkWell(
                        child: Text("회원가입", style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color.fromRGBO(107, 107, 107, 1),
                                fontSize: ScreenUtil().setSp(15),
                                fontFamily: 'NotoSans',
                                fontWeight: FontWeight.w600
                            )
                        ),
                        onTap: () {
                            developer.log('# [Navigator] SignInPage -> SignUpPage');
                            Navigator.pushNamed(context, '/register');
                        },
                    )
                ],
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
            margin: EdgeInsets.only(top:ScreenUtil().setHeight(34), bottom: ScreenUtil().setHeight(17)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    Text(
                        "SNS계정으로 간편로그인 하세요.",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.w400,
                            letterSpacing: ScreenUtil().setWidth(-0.75)
                        )
                    )
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                        child: InkWell(
                            child: Image.asset('assets/images/sns/snsIconKakao.png'),
                            onTap:(){
                                RedToast.toast("카카오톡 로그인은 준비 중 입니다.", ToastGravity.TOP);
                            },
                        ),
                    ),
                    Container(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                        margin: EdgeInsets.only(left: ScreenUtil().setWidth(23)),
                        child: InkWell(
                            child: Image.asset('assets/images/sns/snsIconFacebook.png'),
                            onTap:(){
                                facebookLogin();
                            },
                        ),
                    ),
                    Container(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                        margin: EdgeInsets.only(left: ScreenUtil().setWidth(23)),
                        child: InkWell(
                            child: Image.asset('assets/images/sns/snsIconGoogle.png'),
                            onTap:() {
//                                googleSignin();
                                RedToast.toast("구글 로그인은 준비 중 입니다.", ToastGravity.TOP);
                            }
                        ),
                    )
                ],
            )

        );
    }
}



