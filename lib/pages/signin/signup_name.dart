import 'dart:ui';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:Hwa/utility/inputStyle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:Hwa/data/state/user_info_provider.dart';
import 'package:Hwa/pages/signin/signup_page.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/home.dart';
import 'package:Hwa/pages/parts/common/loading.dart';
import 'package:Hwa/utility/validators.dart';

/*
 * @project : HWA - Mobile
 * @author : sh
 * @date : 2019-12-30
 * @description : Signup name page
 *                  - 닉네임 설정 후 main page로 이동
 */
class SignUpNamePage extends StatefulWidget{
    //Parameters var
    final String socialId;
    final String socialType;
    final String profileURL;
    final String accessToken;
    SignUpNamePage({Key key,this.socialId, this.socialType, this.accessToken, this.profileURL}) : super(key: key);

    @override
    _SignUpNamePageState createState() => _SignUpNamePageState(socialId: socialId, profileURL: profileURL, socialType: socialType, accessToken:accessToken);
}

class _SignUpNamePageState extends State<SignUpNamePage>{
    UserInfoProvider userInfoProvider;
    //Parameters var
    final String socialId;
    final String socialType;
    final String profileURL;
    final String accessToken;
    _SignUpNamePageState({Key key, this.socialId, this.socialType,this.profileURL, this.accessToken});

    //local var
    bool availNick;
    bool alreadyNick;
    FocusNode nickFocusNode;
    final TextEditingController _regNameController =  TextEditingController();
    bool _isLoading = false;

    @override
    void initState() {
        userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
        nickFocusNode = new FocusNode();
        nickFocusNode.addListener(_onOnFocusNodeEvent);

        super.initState();
        availNick = false;
        alreadyNick = false;
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
     * @description : 닉네임 검증 request
     */
    void validateNickname(nickname) async {
        await http.get("https://api.hwaya.net/api/v2/auth/A03-Nickname?nickname=$nickname")
            .then((response) {
            var jsonResult = jsonDecode(response.body).toString();
            if(jsonResult.indexOf("사용 가능한 닉네임입니다") > -1){
                developer.log("# Vaild nickname");
                setState(() {
                    availNick = true;
                    alreadyNick = false;
                });
            } else {
                developer.log("# Invalid nickname");
                setState(() {
                    availNick = false;
                    alreadyNick = true;
                });
            }
        });
    }

    /*
     * @author : hs
     * @date : 2020-01-14
     * @description : Validator
    */


    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : 회원가입 완료 request
     */
    registerFinish(BuildContext context) async {
        setState(() { _isLoading = true; });

        String url = "https://api.hwaya.net/api/v2/auth/A04-SignUp";
        final response = await http.post(url,
            headers: {
                'Content-Type': 'application/json'
            },
            body: jsonEncode({
                "phone_number": phoneRegController.text,
                "nickname": _regNameController.text,
                "social_cd": socialType,
                "social_id": socialId,
                "token": accessToken
            })
        );

        var data = jsonDecode(response.body);

        if (response.statusCode == 200) {
            developer.log("# 회원가입에 성공하였습니다.");
            developer.log("# Response : " + response.body);

            data['data']['userInfo']['token'] = data['data']['token'];
            data['data']['userInfo']['profileURL'] = profileURL;
            data['data']['userInfo']['nickname'] = _regNameController.text;

            await userInfoProvider.setStateAndSaveUserInfoAtSPF(data['data']['userInfo']);
            await userInfoProvider.getUserInfoFromSPF();
            HomePageState.initApiCall(context);

            RedToast.toast((AppLocalizations.of(context).tr('sign.signUpName.toast.start')), ToastGravity.TOP);

            Navigator.pushNamed(context, '/guide');
        } else {
            developer.log('#Request failed：${response.statusCode}');
        }
        setState(() { _isLoading = false; });

    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : 빌드 위젯
     */
    @override
    Widget build(BuildContext context) {
        return Stack(
            children: <Widget>[
                Scaffold(
                    appBar: AppBar(
                        brightness: Brightness.light,
                        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                        elevation: 0.0,
                        leading: Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: IconButton(
                                icon: Image.asset("assets/images/icon/navIconClose.png"),
                                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                            ),
                        ),
                        centerTitle: true,
                        title: Text(
                            (AppLocalizations.of(context).tr('sign.signUpName.signUpAppbar')),
                            style: TextStyle(
                                fontFamily: "NotoSans",
                                color: Color.fromRGBO(39, 39, 39, 1),
                                fontSize: ScreenUtil().setSp(16),
                                letterSpacing: ScreenUtil().setWidth(-0.8),
                            )
                        )
                    ),
                    body: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(16)
                        ),
                        child: ListView(
                            children: <Widget>[
                                _regNickTextField(),
                                _regAuthTextField(),
                                _regStartBtn(context)
                            ]
                        ),
                    )
                ),
                _isLoading ? Loading() : Container()
            ],
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : 닉네임 입력 타이틀 위젯
     */
    Widget _regNickTextField(){
        return Container(
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(26),
                bottom: ScreenUtil().setHeight(8)
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text(
                        AppLocalizations.of(context).tr('sign.signUpName.textNickname'),
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
     * @date : 2019-12-30
     * @description : 닉네임 텍스트필드 위젯
     */
    final _formKey = GlobalKey<FormState>();
    Widget _regAuthTextField(){
        return Form(
            key: _formKey,
            child: TextFormField(
                autovalidate: true,
                focusNode: nickFocusNode,
                autofocus: true,
                maxLength: 8,
                validator: (String value) {
                    availNick = false;
                    if(alreadyNick) {
                        return (AppLocalizations.of(context).tr('sign.signUpName.NicknameAlready'));
                    } else if(value.length < 2) {
                        return '닉네임을 한 글자 이상 입력하세요.';
                    } else if (!Validator().validateName(value)) {
                        return '사용할 수 없는 닉네임입니다.';
                    } else {
                        availNick = true;
                        return null;
                    }
                },
                onChanged: (value){
                    validateNickname(value);
                },
                onFieldSubmitted: (regNickname) {
                    developer.log('닉네임 입력 :$regNickname');
                },
                keyboardType: TextInputType.text,
                inputFormatters: <TextInputFormatter>[
                ],
                controller: _regNameController,
                textAlign: TextAlign.left,
                cursorColor: Colors.black,
                obscureText: false,
                style: InputStyle().inputValue,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(15),
                    ),
                    counterText: "",
                    hintText: (AppLocalizations.of(context).tr('sign.signUpName.nickName')),
                    hintStyle: InputStyle().inputHintText,
                    enabledBorder:  InputStyle().getEnableBorder,
                    focusedBorder: InputStyle().getFocusBorder,
                    fillColor: InputStyle().getBackgroundColor(nickFocusNode),
                    filled: true,
                    suffixIcon: Container(
                        width: ScreenUtil().setWidth(15),
                        height: ScreenUtil().setHeight(40),
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setWidth(5),
                            bottom: ScreenUtil().setWidth(5),
                        ),
                        child: Visibility(
                            visible: _regNameController.text.length > 0,
                            child: IconButton(
                                icon: availNick
                                    ? Image.asset("assets/images/icon/iconDeleteSmall.png")
                                    : Image.asset("assets/images/icon/error.png"),
                                onPressed: () {
                                    nickFocusNode.requestFocus();
                                    Future.delayed(Duration(milliseconds: 50), () {
                                        _regNameController.clear();
                                    });

                                },
                            )
                        )
                    ),
                    focusedErrorBorder: InputStyle().getErrorBorder,
                )
            ),
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : 시작하기 버튼 위젯
     */
    Widget _regStartBtn(BuildContext context){
        var color = availNick ? Color.fromRGBO(77, 96, 191, 1) : Color.fromRGBO(204, 204, 204, 1);

        return Container(
            width: ScreenUtil().setWidth(343),
            height: ScreenUtil().setHeight(50),
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(34)
            ),
            child: RaisedButton(
                onPressed:(){
                    if (_formKey.currentState.validate()) {
                        registerFinish(context);
                    }
                },
                color: color,
                elevation: 0.0,
                child: Text(
                    AppLocalizations.of(context).tr('sign.signUpName.startBtn'),
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
            )
        );
    }
}