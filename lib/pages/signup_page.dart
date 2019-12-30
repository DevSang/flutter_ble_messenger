import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Hwa/pages/signup_name.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:Hwa/utility/set_user_info.dart';


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
    FocusNode myFocusNode;
    final TextEditingController _regAuthCodeController = new TextEditingController();
    bool lengthConfirm;


    @override
    void initState() {
        super.initState();
        lengthConfirm = false;
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 인증 문자 요청
     */
    registerCodeRequest() async {
        SPF = await SharedPreferences.getInstance();
        if(phoneRegController.text == ''){
            developer.log("# Phone number is empty.");
            RedToast.toast("휴대폰 번호를 입력해주세요.", ToastGravity.TOP);
        } else {
            FocusScope.of(context).requestFocus(new FocusNode());
            developer.log("# Phone number : " +  phoneRegController.text);
            String url = "https://api.hwaya.net/api/v2/auth/A01-SignUpAuth";
            final response = await http.post(url,
                headers: {
                    'Content-Type':'application/json'
                },
                body: jsonEncode({
                    "phone_number": phoneRegController.text,
                    "social_cd": socialType,
                    "social_id": socialId,
                    "token": accessToken
                })
            ).then((http.Response response) {
                developer.log("# Auth code request success.");
                developer.log("# response : " + response.body);

                var data = jsonDecode(response.body);
                if (response.statusCode == 200 || response.statusCode == 202) {

                    if(data['message'] != null){
                        RedToast.toast("인증문자를 요청하였습니다.", ToastGravity.TOP);
                        developer.log("# Code request success");
                    ///이미 가입된 사용자면
                    } else {
                        developer.log("# Confirm auth code success.");
                        developer.log("# Already exist user.");

                        SetUserInfo.set(data['data']['userInfo'],profileURL);

                        var token = data['data']['token'];
                        var userIdx = data['data']['userInfo']['idx'];

                        developer.log("# [SPF SAVE] token : " + token);
                        developer.log("# [SPF SAVE] userIdx : " + userIdx.toString());

                        SPF.setString('token', token);
                        SPF.setString('userIdx', userIdx.toString());

                        developer.log('# [Navigator] SignUpPage -> MainPage');
                        RedToast.toast("이미 인증된 사용자입니다.", ToastGravity.TOP);
                        RedToast.toast("Here you are. 주변 친구들과 단화를 시작해보세요.", ToastGravity.TOP);
                        Navigator.pushNamed(context, '/main');
                    }
                } else {
                    if(data['message'].indexOf('이미 사용중인 전화번호입니다') > -1){
                        RedToast.toast("이미 사용중인 전화번호입니다.", ToastGravity.TOP);
                        developer.log("# Already used phone number");
                    } else {
                        RedToast.toast("서버 요청에 실패하였습니다.",ToastGravity.TOP);
                        developer.log('# Request failed ： ${response.statusCode}');
                    }
                }
            });
        }
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 인증번호 입력후 다음누르면
     */
    registerNext() async {
        SPF = await SharedPreferences.getInstance();

        if(_regAuthCodeController.text == ''){
            developer.log("# Auth code is empty.");
            RedToast.toast("인증번호를 입력해주세요.", ToastGravity.TOP);
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


                    RedToast.toast("인증이 완료 되었습니다.", ToastGravity.TOP);
                } else {
                    RedToast.toast("인증이 실패하였습니다. 인증번호를 확인해주세요.", ToastGravity.TOP);
                    developer.log('failed：${response.statusCode}');
                }
            });
        }
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 빌드 위젯
     */
    @override
    Widget build(BuildContext context){
        return Scaffold(
            body: new GestureDetector(
                //텍스트필드 클릭 후 키보드 올라와 있을때 다른영역 터치해서 포커싱 해제
                onTap: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: new Container(
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
                            _regPhoneTextField(),
                            _regPhoneNumTextField(),
                            _regAuthCodeText(),
                            _regAuthTextField(),
                            _regNextButton(),
                        ]
                    ),
                )
            ),
            appBar: AppBar(
                brightness: Brightness.light,
                backgroundColor: Colors.white,
                elevation: 0.0,
                leading: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: IconButton(
                        icon: Image.asset("assets/images/icon/navIconPrev.png"),
                        onPressed: () => Navigator.of(context).pop(null),
                    ),
                ),
                centerTitle: true,
                title: Text("회원가입",style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans'),
                ),
            ),
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 휴대폰 번호 입력 타이틀 위젯
     */
    Widget _regPhoneTextField(){
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            margin: EdgeInsets.only(top: 20, bottom: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text("휴대폰번호 입력",style: TextStyle(color: Colors.black87, fontSize: 13,fontFamily: 'NotoSans'))
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
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: TextFormField(
                maxLength: 11,
                onChanged: (regPhoneNum) {
                    developer.log(regPhoneNum);
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
                style: TextStyle(color: Colors.black, fontFamily: "NotoSans",
                ),
                decoration: InputDecoration(
                    suffixIcon:
                    Container(
                        margin: EdgeInsets.only(right:5),
                        child :RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text("인증문자 받기",style: TextStyle(color: Colors.white, fontFamily: 'NotoSans'),
                            ),
                            color: Color.fromRGBO(77, 96, 191, 1),
                            onPressed: () {
                                registerCodeRequest();
                            })
                    ),
                    counterText:"",
                    hintText: "휴대폰번호 ( -없이 숫자만 입력)",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                    border:  OutlineInputBorder(
                        borderRadius:  BorderRadius.circular(10.0),
                        borderSide:  BorderSide(
                        ),
                    ),
                    fillColor: Colors.grey[200],
                    filled: true,
                )
            ),
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 인증번호 입력 타이틀 위젯
     */
    Widget _regAuthCodeText(){
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            margin: EdgeInsets.only(top: 20, bottom: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text("인증번호 입력",style: TextStyle(color: Colors.black87, fontSize: 13,fontFamily: 'NotoSans'))
                ],
            )
        );
    }

    /*
     * @author : sh
     * @date : 2019-12-28
     * @description : 인증번호 입력 필드 위젯
     */
    Widget _regAuthTextField(){
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: TextFormField(
                focusNode: myFocusNode,
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
                style: TextStyle(color: Colors.black, fontFamily: "NotoSans",),
                decoration: InputDecoration(
                    counterText: "",
                    hintText: "인증번호",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                    border:  OutlineInputBorder(
                        borderRadius:  BorderRadius.circular(10.0),
                        borderSide:  BorderSide(
                        ),
                    ),
                    fillColor: Colors.grey[200],
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
        var color = lengthConfirm ? Color.fromRGBO(77, 96, 191, 1) : Color.fromRGBO(204, 204, 204, 1);

        return Container(
            width: MediaQuery.of(context).size.width,
            height: 50.0,
            margin: EdgeInsets.only(top: 15.0),
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: RaisedButton(
                onPressed:(){
                    registerNext();
                },
                color: color,
                elevation: 0.0,
                child: Text(
                    "다음",
                    style: TextStyle(color: Colors.white,  fontFamily: 'NotoSans')
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)
                ),
            ),
        );
    }
}






