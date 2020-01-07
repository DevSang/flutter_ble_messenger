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
import 'package:provider/provider.dart';

import 'package:Hwa/pages/signin/signup_page.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/home.dart';
import 'package:Hwa/service/set_fcm.dart';
import 'package:Hwa/data/state/user_info_provider.dart';


import 'package:easy_localization/easy_localization.dart';

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
    UserInfoProvider userInfoProvider;

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
        userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);

        googleAccountListner();
	    super.initState();
    }

    /*
     * @author : hk
     * @date : 2020-01-05
     * @description : init SignIn
     */
    void googleAccountListner() async {
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

        setState(() {
            _isLoading = true;
        });

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
                    setState(() { _isLoading = false; });
                });
            }).catchError((err){
	            developer.log('error occured');
	            setState(() { _isLoading = false; });
            });
        } catch (error) {
            developer.log(error);
            setState(() { _isLoading = false; });
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
		final result = await facebookLogin. logIn(["email"]);

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
                "token" : accessToken,
                "social_id" : profileId
            })
        );

        var errorCode = jsonDecode(response.body)['errorCode'];

        if (response.statusCode == 200) {
            var data = jsonDecode(response.body)['data'];
            var token = data['token'];

            if(data['userInfo']['profile_picture_idx'] != null) {
                photoUrl = Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + data['userInfo']['idx'].toString() + "&type=SMALL";
            }

            data['userInfo']['profileURL'] = photoUrl;
            data['userInfo']['token'] = token;
            data['userInfo']['nickname'] = data['userInfo']['jb_user_info']['nickname'];

            await userInfoProvider.setStateAndSaveUserInfoAtSPF(data['userInfo']);
            await userInfoProvider.getUserInfoFromSPF();
            SetFCM.firebaseCloudMessagingListeners();
            HomePageState.initApiCall();

            RedToast.toast("로그인에 성공하였습니다.", ToastGravity.TOP);
            developer.log("# 로그인에 성공하였습니다.");
            developer.log("# 로그인정보 :" + data.toString() );
            developer.log('# [Navigator] SignInPage -> MainPage');
            Navigator.pushNamed(context, '/main');

        } else if(errorCode == 13){
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

        setState(() {
            _isLoading = false;
        });
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
	    spf = await Constant.getSPF();
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

                    var token = data['token'];
                    data['userInfo']['token'] = token;

                    if(data['userInfo']['jb_user_info']['profile_picture_idx'] != null) {
                        spf.setBool("IS_UPLOAD_PROFILE_IMG", true);
                    } else {
                        spf.setBool("IS_UPLOAD_PROFILE_IMG", false);
                    }

                    await userInfoProvider.setStateAndSaveUserInfoAtSPF(data['userInfo']);
                    await userInfoProvider.getUserInfoFromSPF();
                    SetFCM.firebaseCloudMessagingListeners();
                    HomePageState.initApiCall();

                    RedToast.toast("로그인에 성공하였습니다.", ToastGravity.TOP);
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
     * @description : 빌드 위젯
     */
    @override
    Widget build(BuildContext context) {
	    var data = EasyLocalizationProvider.of(context).data;

        return EasyLocalizationProvider(
		    data: data,
		    child: Scaffold(
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
	        )
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                hintText: AppLocalizations.of(context).tr('signIn.signIn.phoneNumber')
                            ),
                        )
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            right: ScreenUtil().setWidth(5)
                        ),
                        child: RaisedButton(
                            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(13), horizontal: ScreenUtil().setWidth(15)),
                            focusNode: contextFocus,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                            ),
                            child: Text(AppLocalizations.of(context).tr('signIn.signIn.getAuthCode'),
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
                        hintText: AppLocalizations.of(context).tr('signIn.signIn.authCode')
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
                child: Text(AppLocalizations.of(context).tr('signIn.signIn.signIn'), style: TextStyle(
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
		                        AppLocalizations.of(context).tr('signIn.signIn.notHaveAccount'),
                            style: TextStyle(
                                color: Color.fromRGBO(107, 107, 107, 1),
                                fontSize: ScreenUtil().setSp(15),
                                fontFamily: 'NotoSans')
                        )
                    ),
                    InkWell(
                        child: Text(AppLocalizations.of(context).tr('signIn.signIn.signUp'), style: TextStyle(
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
	                    AppLocalizations.of(context).tr('signIn.signIn.snsSignIn'),
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
                                googleSignin();
//                                RedToast.toast("구글 로그인은 준비 중 입니다.", ToastGravity.TOP);
                            }
                        ),
                    )
                ],
            )

        );
    }
}



