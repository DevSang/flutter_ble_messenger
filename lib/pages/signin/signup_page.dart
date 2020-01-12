import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:Hwa/pages/signin/signup_name.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/constant.dart';
import 'package:Hwa/home.dart';
import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/pages/parts/common/loading.dart';


/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-30
 * @description : Signup page
 *                  - 휴대폰 번호 입력 및 인증 문자 요청
 *                  - 인증문자 입력 후 signup_name.page로 이동
 *                  - 번호로 가입한 사용자가 Social로 로그인 시도 하면 인증 문자 요청하면 바로 mainpage로 이동
 */

//signup_name page phonenumber 공통 controller
final TextEditingController phoneRegController = new TextEditingController();

class SignUpPage extends StatefulWidget {
    //Parameters
    final String socialId;
    final String socialType;
    final String profileURL;
    final String accessToken;
    SignUpPage({Key key,this.socialId,this.profileURL, this.socialType, this.accessToken}) : super(key: key);

    @override
        _SignUpPageState createState() => _SignUpPageState(socialId: socialId,profileURL: profileURL, socialType: socialType, accessToken:accessToken);
    }

class _SignUpPageState extends State<SignUpPage>{
    //Parameters
    final String socialId;
    final String socialType;
    final String profileURL;
    final String accessToken;
    _SignUpPageState({Key key, this.socialId, this.profileURL, this.socialType, this.accessToken});

    //local var
    SharedPreferences SPF;
    FocusNode phoneFocusNode;
    FocusNode authFocusNode;
    final TextEditingController _regAuthCodeController = new TextEditingController();
    bool lengthConfirmPhone;
    bool lengthConfirmAuth;
    bool _isLoading = false;


    @override
    void initState() {
        super.initState();
        lengthConfirmPhone = false;
        lengthConfirmAuth = false;
        phoneFocusNode = new FocusNode();
        phoneFocusNode.addListener(_onOnFocusNodeEvent);
        authFocusNode = new FocusNode();
        authFocusNode.addListener(_onOnFocusNodeEvent);
    }

    @override
    void dispose() {
        super.dispose();
        phoneRegController.clear();
        _regAuthCodeController.clear();
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
     * @date : 2019-12-28
     * @description : 인증 문자 요청
     */
    registerCodeRequest() async {
        setState(() {_isLoading = true;});
        final userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);

        SPF = await Constant.getSPF();
        if(phoneRegController.text == ''){
            developer.log("# Phone number is empty.");
            RedToast.toast((AppLocalizations.of(context).tr('sign.signUp.toast.inputPhone')), ToastGravity.TOP);
        } else {
            FocusScope.of(context).requestFocus(new FocusNode());
            developer.log("# Phone number : " +  phoneRegController.text);
            String url = "https://api.hwaya.net/api/v2/auth/A01-SignUpAuth";

            await http.post(url,
                headers: {
                    'Content-Type':'application/json'
                },
                body: jsonEncode({
                    "phone_number": phoneRegController.text,
                    "social_cd": socialType,
                    "social_id": socialId,
                    "token": accessToken
                })
            ).then((http.Response response) async {
                developer.log("# Auth code request success.");
                developer.log("# response : " + response.body);

                var data = jsonDecode(response.body);
                if (response.statusCode == 200 || response.statusCode == 202) {

                    if(data['message'] != null){
                        RedToast.toast((AppLocalizations.of(context).tr('sign.signUp.toast.request200')), ToastGravity.TOP);
                        developer.log("# Code request success");
                    ///이미 가입된 사용자면
                    } else {
                        developer.log("# Confirm auth code success.");
                        developer.log("# Already exist user.");

                        ///최종 Social로 Re-Signup
                        String url = "https://api.hwaya.net/api/v2/auth/A04-SignUp";
                        await http.post(url,
                            headers: {
                                'Content-Type':'application/json'
                            },
                            body: jsonEncode({
                                "phone_number": phoneRegController.text,
                                "social_cd": socialType,
                                "social_id": socialId,
                                "token": accessToken
                            })
                        ).then((http.Response response) async {
                            var token = data['data']['token'];
                            var userIdx = data['data']['userInfo']['idx'];

                            developer.log("# [SPF SAVE] token : " + token);
                            developer.log("# [SPF SAVE] userIdx : " + userIdx.toString());
                            data['data']['userInfo']['token'] = token;
                            data['data']['userInfo']['profileURL'] = profileURL;
                            data['data']['userInfo']['nickname'] = data['data']['userInfo']['jb_user_info']['nickname'];

                            SPF.setString('token', token);
                            SPF.setInt('userIdx', userIdx);

                            await userInfoProvider.getUserInfoFromSPF();
                            await userInfoProvider.setStateAndSaveUserInfoAtSPF(data['data']['userInfo']);
                            HomePageState.initApiCall(context);

                            developer.log('# [Navigator] SignUpPage -> MainPage');
                            RedToast.toast((AppLocalizations.of(context).tr('sign.signUp.toast.alreadyUser')), ToastGravity.TOP);
                            RedToast.toast((AppLocalizations.of(context).tr('sign.signUp.toast.start')), ToastGravity.TOP);
                            Navigator.pushNamed(context, '/main');
                        });
                    }
                } else {
                    if(data['message'].indexOf('이미 사용중인 전화번호입니다') > -1){
                        RedToast.toast((AppLocalizations.of(context).tr('sign.signUp.toast.alreadyPhone')), ToastGravity.TOP);
                        developer.log("# Already used phone number");
                    } else {
                        RedToast.toast((AppLocalizations.of(context).tr('sign.signUp.toast.fail')),ToastGravity.TOP);
                        developer.log('# Request failed ： ${response.statusCode}');
                    }
                }
            });
        }
        setState(() {_isLoading = false;});
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 인증번호 입력후 다음누르면
     */
    registerNext() async {
        setState(() {_isLoading = true;});
        SPF = await SharedPreferences.getInstance();

        if(_regAuthCodeController.text == ''){
            developer.log("# Auth code is empty.");
            RedToast.toast((AppLocalizations.of(context).tr('sign.signUp.toast.inputCode')), ToastGravity.TOP);
        } else {
            developer.log("# Auth code : " +  _regAuthCodeController.text);

            String url = "https://api.hwaya.net/api/v2/auth/A02-SignUpSmsAuth";
            await http.post(url,
                headers: {
                    'Content-Type':'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: jsonEncode({
                    "phone_number": phoneRegController.text,
                    "auth_number": _regAuthCodeController.text
                })
            ).then((http.Response response) {
                developer.log("# Confirm auth code request success.");
                developer.log("# response : " + response.body);

                var data = jsonDecode(response.body);

                if (response.statusCode == 200) {
                    developer.log("# Confirm auth code success.");

                    developer.log('# [Navigator] SignInPage -> SignUpNamePage');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                            return SignUpNamePage(socialId: socialId,profileURL:profileURL, socialType: socialType, accessToken: accessToken);
                        })
                    );


                    RedToast.toast((AppLocalizations.of(context).tr('sign.signUp.toast.authFinish')), ToastGravity.TOP);
                } else {
                    RedToast.toast((AppLocalizations.of(context).tr('sign.signUp.toast.authFail')), ToastGravity.TOP);
                    developer.log('failed：${response.statusCode}');
                }
            });
        }
        setState(() {_isLoading = false;});
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 빌드 위젯
     */
    @override
    Widget build(BuildContext context){
        return Stack(
            children: <Widget>[
                Scaffold(
                    body:  GestureDetector(
                        //텍스트필드 클릭 후 키보드 올라와 있을때 다른영역 터치해서 포커싱 해제
                        onTap: (){
                            FocusScope.of(context).requestFocus( FocusNode());
                        },
                        child:  Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(16)
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        width: ScreenUtil().setWidth(0.5),
                                        color: Color.fromRGBO(178, 178, 178, 0.8)
                                    )
                                )
                            ),

                            child: ListView(
                                children: <Widget>[
                                    _regTextFieldLabel(AppLocalizations.of(context).tr('sign.signUp.textPhoneNumber')),
                                    _regPhoneNumTextField(),
                                    _regTextFieldLabel(AppLocalizations.of(context).tr('sign.signUp.textAuthCode')),
                                    _regAuthTextField(),
                                    _regNextButton(),
                                ]
                            ),
                        )
                    ),
                    appBar: AppBar(
                        brightness: Brightness.light,
                        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                        elevation: 0.0,
                        leading: IconButton(
                            icon: Image.asset("assets/images/icon/navIconClose.png"),
                            onPressed: () => Navigator.of(context).pop(null),
                        ),
                        centerTitle: true,
                        title: Text(
                            AppLocalizations.of(context).tr('sign.signUp.signUpAppbar'),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'NotoSans',
                                fontWeight: FontWeight.w700
                            ),
                        ),
                    ),
                ),
                _isLoading ? Loading() : Container()
            ],
        );
    }

    Color _getBackgroundColor(FocusNode _focusNode) {
        return _focusNode.hasFocus ? Color.fromRGBO(255, 255, 255, 1) : Color.fromRGBO(245, 245, 245, 1);
    }

    OutlineInputBorder _getEnableBorder = OutlineInputBorder(
        borderRadius:  BorderRadius.circular(
            ScreenUtil().setHeight(10.0),
        ),
        borderSide: BorderSide(
            color: Color.fromRGBO(245, 245, 245, 1),
            width: ScreenUtil().setWidth(1)
        ),
    );

    OutlineInputBorder _getFocusBorder = OutlineInputBorder(
        borderSide: BorderSide(
            color: Color.fromRGBO(214, 214, 214, 1),
            width: ScreenUtil().setWidth(1)
        ),
        borderRadius: BorderRadius.circular(
            ScreenUtil().setHeight(10.0)
        ),
    );

    TextStyle inputHintText = TextStyle(
        color: Color.fromRGBO(39, 39, 39, 0.4),
        fontSize: ScreenUtil().setSp(15),
        fontFamily: 'NotoSans',
        fontWeight: FontWeight.w500,
        letterSpacing: ScreenUtil().setWidth(-0.75),
    );

    TextStyle inputValue = TextStyle(
        color: Color.fromRGBO(39, 39, 39, 1),
        fontSize: ScreenUtil().setSp(15),
        fontFamily: 'NanumSquare',
        fontWeight: FontWeight.w500,
        letterSpacing: ScreenUtil().setWidth(-0.38),
    );

    Color buttonColor(bool isActive) {
        return isActive ? Color.fromRGBO(77, 96, 191, 1) : Color.fromRGBO(204, 204, 204, 1);
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 휴대폰 번호 입력 타이틀 위젯
     */
    Widget _regTextFieldLabel(String value){
        return Container(
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(26),
                bottom: ScreenUtil().setHeight(8)
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text(
                        value,
                        style: TextStyle(
                            color: Color.fromRGBO(107, 107, 107, 1),
                            fontSize: ScreenUtil().setSp(13),
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.w500,
                            letterSpacing: ScreenUtil().setWidth(-0.32)
                        )
                    )
                ],
            )
        );
    }

    /*
    * @author : sh
    * @date : 2019-12-28
    * @description : 휴대폰 번호 입력 텍스트필드 위젯
    */
    Widget _regPhoneNumTextField(){
        return Container(
            child: TextFormField(
                focusNode: phoneFocusNode,
                autofocus: true,
                maxLength: 11,
                onChanged: (regPhoneNum) {
                    if(regPhoneNum.length == 11 && !lengthConfirmPhone) {
                        setState(() {
                            lengthConfirmPhone = true;
                        });
                    } else if (regPhoneNum.length != 11 && lengthConfirmPhone){
                        setState(() {
                            lengthConfirmPhone = false;
                        });
                    }
                },
                onFieldSubmitted: (regPhoneNum) {
                    developer.log('회원가입 전화번호  :$regPhoneNum');
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                ],
                controller: phoneRegController,
                cursorColor: Colors.black,
                obscureText: false,
                style: inputValue,
                decoration: InputDecoration(
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
                        child :RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                            ),
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
                            color: buttonColor(lengthConfirmPhone),
                            elevation: 0,
                            onPressed: () {
                                registerCodeRequest();
                            }
                        )
                    ),
                    counterText:"",
                    hintText: AppLocalizations.of(context).tr('sign.signUp.phoneNumber'),
                    hintStyle: inputHintText,
                    enabledBorder:  _getEnableBorder,
                    focusedBorder: _getFocusBorder,
                    fillColor: _getBackgroundColor(phoneFocusNode),
                    filled: true,
                )
            ),
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 인증번호 입력 필드 위젯
     */
    Widget _regAuthTextField(){
        return Container(
            child: TextFormField(
                focusNode: authFocusNode,
                maxLength: 6,
                onChanged: (regAuthCode) {
                    if(regAuthCode.length == 6 && !lengthConfirmAuth) {
                        setState(() {
                            lengthConfirmAuth = true;
                        });
                    } else if (regAuthCode.length != 6 && lengthConfirmAuth){
                        setState(() {
                            lengthConfirmAuth = false;
                        });
                    }
                },
                onFieldSubmitted: (regAuthCode) {
                    developer.log('회원가입 인증코드 입력 :$regAuthCode');
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                ],
                controller: _regAuthCodeController,
                cursorColor: Colors.black,
                obscureText: true,
                style: inputValue,
                decoration: InputDecoration(
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
                    hintText: AppLocalizations.of(context).tr('sign.signUp.authCode'),
                    hintStyle: inputHintText,
                    enabledBorder:  _getEnableBorder,
                    focusedBorder:_getFocusBorder,
                    fillColor: _getBackgroundColor(authFocusNode),
                    filled: true,
                )
            ),
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 다음 버튼 위젯
     */
    Widget _regNextButton(){
        return Container(
            width: ScreenUtil().setWidth(343),
            height: ScreenUtil().setHeight(50),
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(10)
            ),
            child: RaisedButton(
                onPressed:(){
                    registerNext();
                },
                color: buttonColor(lengthConfirmAuth),
                elevation: 0.0,
                child: Text(
                    AppLocalizations.of(context).tr('sign.signUp.nextBtn'),
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'NotoSans', 
                        fontWeight: FontWeight.w500,
                        fontSize: ScreenUtil().setSp(16),
                        letterSpacing: ScreenUtil().setWidth(-0.8)
                    )
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        ScreenUtil().setHeight(8)
                    )
                ),
            ),
        );
    }
}






