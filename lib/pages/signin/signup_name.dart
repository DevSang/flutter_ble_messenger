import 'dart:ui';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:Hwa/data/state/user_info_provider.dart';

import 'package:Hwa/pages/signin/signup_page.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/home.dart';
import 'package:Hwa/service/set_fcm.dart';


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
    final TextEditingController _regNameController =  TextEditingController();

    @override
    void initState() {
        userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);

        super.initState();
        availNick = false;
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
                });
            } else {
                developer.log("# Invalid nickname");
                setState(() {
                    availNick = false;
                });
            }
        });
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : 회원가입 완료 request
     */
    registerFinish(BuildContext context) async {

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
            SetFCM.firebaseCloudMessagingListeners();
            HomePageState.initApiCall();

            RedToast.toast("Here we are. 주변 친구들과 단화를 시작해보세요.", ToastGravity.TOP);

            Navigator.pushNamed(context, '/main');
        } else {
            developer.log('#Request failed：${response.statusCode}');
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
                title: Text("회원가입",style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans'))
            ),
            body: Container(
                child: ListView(
                    children: <Widget>[
                        _regNickTextField(),
                        _regAuthTextField(),
                        _regStartBtn(context)
                    ]
                ),
            )
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-30
     * @description : 닉네임 입력 타이틀 위젯
     */
    Widget _regNickTextField(){
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            margin: EdgeInsets.only(top: 30),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text("닉네임 입력",style: TextStyle(color: Colors.black87, fontSize: 13,fontFamily: 'NotoSans'))
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
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: TextFormField(
                    validator: (value) {
                        if (value.isEmpty) {
                            return '닉네임을 입력해주세요';
                        } else if(!availNick) {
                            return '이미 사용중인 닉네임입니다.';
                        }
                        return null;
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
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        counterText: "",
                        hintText: "닉네임을 입력하세요",
                        suffixIcon: IconButton(
                            icon: Image.asset("assets/images/icon/iconDeleteSmall.png"),
                            onPressed: () => _regNameController.clear(),
                        ),
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
            width: MediaQuery.of(context).size.width,
            height: 50.0,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: RaisedButton(
                onPressed:(){
                    if (_formKey.currentState.validate()) {
                        registerFinish(context);
                    }
                },
                color: color,
                elevation: 0.0,
                child: Text("시작하기", style: TextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)
                )
            )
        );
    }
}



