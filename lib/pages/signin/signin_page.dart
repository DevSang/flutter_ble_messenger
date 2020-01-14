import 'dart:convert';
import 'dart:developer' as developer;

import 'package:Hwa/pages/guide/guide_page.dart';
import 'package:Hwa/pages/signin/signup_name.dart';
import 'package:Hwa/utility/customRoute.dart';
import 'package:Hwa/utility/inputStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Hwa/pages/signin/signup_page.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/home.dart';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/pages/parts/common/loading.dart';


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
    bool lengthConfirmSMS = false;
    bool lengthConfirmLogin = false;
    UserInfoProvider userInfoProvider;
    double sameSize;
    FocusNode phoneFocusNode;
    FocusNode authFocusNode;

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
        sameSize = GetSameSize().main();
        googleAccountListner();
        phoneFocusNode = new FocusNode();
        phoneFocusNode.addListener(_onOnFocusNodeEvent);
        authFocusNode = new FocusNode();
        authFocusNode.addListener(_onOnFocusNodeEvent);
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

        try {
            developer.log("# Google Signin");
            _googleSignIn.signIn().then((result){
                result.authentication.then((googleKey) async {
                    setState(() { _isLoading = true; });
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
        setState(() { _isLoading = false; });
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
        setState(() { _isLoading = true; });

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
                setState(() { _isLoading = false; });
                break;
			case FacebookLoginStatus.error:
				developer.log("# facebookLogin" + result.errorMessage);
                setState(() { _isLoading = false; });
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
            var refreshToken = data['refreshToken'];

            if(data['userInfo']['profile_picture_idx'] != null) {
                photoUrl = Constant.API_SERVER_HTTP + "/api/v2/user/profile/image?target_user_idx=" + data['userInfo']['idx'].toString() + "&type=SMALL";
            }

            data['userInfo']['profileURL'] = photoUrl;
            data['userInfo']['token'] = token;
            data['userInfo']['refreshToken'] = refreshToken;

            await userInfoProvider.setStateAndSaveUserInfoAtSPF(data['userInfo']);
            await userInfoProvider.getUserInfoFromSPF();

            HomePageState.initApiCall(context);

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
        setState(() { _isLoading = true; });

        if(_phoneController.text == '' ){
            developer.log("# Phone number is empty.");
            RedToast.toast(AppLocalizations.of(context).tr('sign.signIn.toast.inputPhone'), ToastGravity.TOP);
        } else {
            _authCodeController.text = '';
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
                RedToast.toast(AppLocalizations.of(context).tr('sign.signIn.toast.request200') , ToastGravity.TOP);
            } else {
                if(response.statusCode == 406){
                    developer.log("# This is not a HWA user.");
                    RedToast.toast(AppLocalizations.of(context).tr('sign.signIn.toast.request406'),ToastGravity.TOP);
                } else {
                    developer.log('# Request failed：${response.statusCode}');
                    RedToast.toast(AppLocalizations.of(context).tr('sign.signIn.toast.requestFail'),ToastGravity.TOP);
                }
            }
        }
        setState(() { _isLoading = false; });
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : Confirm auth code function
     */
    authCodeLoginRequest() async {
        setState(() { _isLoading = true; });

        spf = await Constant.getSPF();
        try {
            if(_authCodeController.text == ''){
                developer.log("# Auth code is empty.");
                RedToast.toast(AppLocalizations.of(context).tr('sign.signIn.toast.inputCode'), ToastGravity.TOP);
            } else if (_phoneController.text == ''){
                developer.log("# Auth code is not empty but phonenumber is empty.");
                RedToast.toast(AppLocalizations.of(context).tr('sign.signIn.toast.inputPhone'), ToastGravity.TOP);
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
                    var refreshToken = data['refreshToken'];
                    data['userInfo']['token'] = token;
                    data['userInfo']['refreshToken'] = refreshToken;

                    await userInfoProvider.setStateAndSaveUserInfoAtSPF(data['userInfo']);
                    await userInfoProvider.getUserInfoFromSPF();
                    HomePageState.initApiCall(context);

                    RedToast.toast(AppLocalizations.of(context).tr('sign.signIn.toast.loginSuccess'), ToastGravity.TOP);
                    developer.log('# [Navigator] SignInPage -> MainPage');
                    Navigator.pushNamed(context, '/main');
                } else {
                    RedToast.toast(AppLocalizations.of(context).tr('sign.signIn.toast.requestFail'), ToastGravity.TOP);
                    developer.log('#Request failed：${response.statusCode}');
                }
            }
        } catch (e) {
            developer.log('#Request failed：${e}');
        }
        setState(() { _isLoading = false; });
    }

    /*
     * @author : hs
     * @date : 2020-01-12
     * @description : 텍스트 필드 포커스에 따른 스타일 적용
    */
    _onOnFocusNodeEvent() {
        setState(() {});
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
		    child: Stack(
                children: <Widget>[
                    Scaffold(
                        body: new GestureDetector(
                            onTap: (){
                                FocusScope.of(context).requestFocus(new FocusNode());
                            },
                            child: new SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
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
                    ),
                    _isLoading ? Loading() : Container()
                ],
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
            width: ScreenUtil().setWidth(219.7),
            height: ScreenUtil().setHeight(80.5),
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(87.5),
                bottom: ScreenUtil().setHeight(64),
            ),
            child: Image.asset(
                'assets/images/loginLogo.png',
                fit: BoxFit.contain,
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
            margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16)
            ),
            child: Container(
                child: TextFormField(
                    focusNode: phoneFocusNode,
                    maxLength: 11,
                    onChanged: (loginAuthCode) {
                        if(loginAuthCode.length == 11 && !lengthConfirmSMS) {
                            setState(() {
                                lengthConfirmSMS = true;
                            });
                        } else if (loginAuthCode.length != 11 && lengthConfirmSMS){
                            setState(() {
                                lengthConfirmSMS = false;
                            });
                        }
                    },
                    onFieldSubmitted: (loginAuthCode) {
                        developer.log('login phone number 입력 :$loginAuthCode');
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                    ],
                    controller: _phoneController,
                    style: InputStyle().inputValue,
                    decoration:  InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(15),
                        ),
                        counterText: "",
                        hintStyle: InputStyle().inputHintText,
                        hintText: AppLocalizations.of(context).tr('sign.signIn.phoneNumber'),
                        enabledBorder:  InputStyle().getEnableBorder,
                        focusedBorder: InputStyle().getFocusBorder,
                        fillColor: InputStyle().getBackgroundColor(phoneFocusNode),
                        filled: true,
                        suffixIcon:
                        Container(
                            width: ScreenUtil().setWidth(100),
                            height: ScreenUtil().setHeight(40),
                            margin: EdgeInsets.only(
                                right: ScreenUtil().setWidth(5),
                                top: ScreenUtil().setWidth(5),
                                bottom: ScreenUtil().setWidth(5),
                            ),
                            child :RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(ScreenUtil().setHeight(8.0))
                                ),
                                color: lengthConfirmSMS ? Color.fromRGBO(77, 96, 191, 1) : Color.fromRGBO(204, 204, 204, 1),
                                child: Text(
                                    AppLocalizations.of(context).tr('sign.signUp.getAuthCode'),
                                    style: TextStyle(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        fontSize: ScreenUtil().setSp(13),
                                        fontFamily: 'NotoSans',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: ScreenUtil().setWidth(-0.65),
                                    ),
                                ),
                                elevation: 0,
                                onPressed: () {
                                    loginCodeRequest();
                                },
                            )
                        )
                    ),
                )
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
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(16),
                right: ScreenUtil().setWidth(16),
                top: ScreenUtil().setHeight(6)
            ),
            child:  Container(
                child: TextFormField(
                    focusNode: authFocusNode,
                    maxLength: 6,
                    onChanged: (regAuthCode) {
                        if(regAuthCode.length == 6 && !lengthConfirmLogin) {
                            setState(() {
                                lengthConfirmLogin = true;
                            });
                        } else if (regAuthCode.length != 6 && lengthConfirmLogin){
                            setState(() {
                                lengthConfirmLogin = false;
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
                    style: InputStyle().inputValue,
                    decoration:  InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(15),
                        ),
                        suffixIcon:
                        Container(
                            width: ScreenUtil().setWidth(100),
                            height: ScreenUtil().setHeight(40),
                            margin: EdgeInsets.only(
                                right: ScreenUtil().setWidth(5),
                                top: ScreenUtil().setWidth(5),
                                bottom: ScreenUtil().setWidth(5),
                            ),
                        ),
                        counterText: "",
                        hintStyle: InputStyle().inputHintText,
                        hintText: AppLocalizations.of(context).tr('sign.signIn.authCode'),
                        enabledBorder:  InputStyle().getEnableBorder,
                        focusedBorder: InputStyle().getFocusBorder,
                        fillColor: InputStyle().getBackgroundColor(authFocusNode),
                        filled: true,
                    ),
                )
            )
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : SignIn button widget
     */
    Widget _SignInButton() {
        var color = lengthConfirmLogin ? Color.fromRGBO(77, 96, 191, 1) : Color.fromRGBO(204, 204, 204, 1);
        return Container(
            width: ScreenUtil().setWidth(343),
            height: ScreenUtil().setHeight(50),
            margin: EdgeInsets.only(
                top: 10,
                bottom: 16,
            ),
            decoration: BoxDecoration(
                color: color,
                borderRadius: new BorderRadius.all(
                    Radius.circular(ScreenUtil().setHeight(8.0))
                )
            ),
            child: InkWell(
                onTap: () {
                    authCodeLoginRequest();
                },
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                        AppLocalizations.of(context).tr('sign.signIn.signIn'),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.w500,
                            letterSpacing: ScreenUtil().setWidth(-0.8)
                        )
                    )
                ),
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
            height: ScreenUtil().setHeight(52),
            decoration:  BoxDecoration(
                border:  Border(
                    bottom: BorderSide(
                        color:Color.fromRGBO(112, 112, 112, 1),
                        width: ScreenUtil().setHeight(0.5)
                    )
                ),
            ),
            padding: EdgeInsets.only(
                bottom: ScreenUtil().setHeight(29)
            ),
            margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16)
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Text(
                        AppLocalizations.of(context).tr('sign.signIn.notHaveAccount'),
                        style: TextStyle(
                            color: Color.fromRGBO(107, 107, 107, 1),
                            fontSize: ScreenUtil().setSp(15),
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.w400,
                        )
                    ),
                    InkWell(
                        child: Text(
                            AppLocalizations.of(context).tr('sign.signIn.signUp'),
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color.fromRGBO(107, 107, 107, 1),
                                fontSize: ScreenUtil().setSp(15),
                                fontFamily: 'NotoSans',
                                fontWeight: FontWeight.w500
                            )
                        ),
                        onTap: () {
                            developer.log('# [Navigator] SignInPage -> SignUpPage');
//                            Navigator.pushNamed(context, '/register');
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                    return SignUpNamePage();
                                })
                            );
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
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(34),
                bottom: ScreenUtil().setHeight(22)
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    Text(
	                    AppLocalizations.of(context).tr('sign.signIn.snsSignIn'),
                        style: TextStyle(
                            color: Color.fromRGBO(107, 107, 107, 1),
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
            padding: EdgeInsets.only(
              bottom:   ScreenUtil().setHeight(51),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Container(
                        width: ScreenUtil().setWidth(50),
                        height: ScreenUtil().setHeight(50),
                        child: InkWell(
                            child: Image.asset(
                                'assets/images/sns/snsIconKakao.png',
                                fit: BoxFit.contain
                            ),
                            onTap:(){
                                RedToast.toast("카카오톡 로그인은 준비 중 입니다.", ToastGravity.TOP);
                            },
                        ),
                    ),
                    Container(
                        width: ScreenUtil().setWidth(50),
                        height: ScreenUtil().setHeight(50),
                        margin: EdgeInsets.only(
                            left: ScreenUtil().setWidth(28)
                        ),
                        child: InkWell(
                            child: Image.asset(
                                'assets/images/sns/snsIconFacebook.png',
                                fit: BoxFit.contain
                            ),
                            onTap:(){
                                facebookLogin();
                            },
                        ),
                    ),
                    Container(
                        width: ScreenUtil().setWidth(50),
                        height: ScreenUtil().setHeight(50),
                        margin: EdgeInsets.only(
                            left: ScreenUtil().setWidth(28)
                        ),
                        child: InkWell(
                            child: Image.asset(
                                'assets/images/sns/snsIconGoogle.png',
                                fit: BoxFit.contain,
                            ),
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



