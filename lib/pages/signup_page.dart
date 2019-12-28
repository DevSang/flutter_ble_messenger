import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Hwa/utility/red_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


final TextEditingController phoneRegController = new TextEditingController();

//register page
class SignUpPage extends StatefulWidget {

  @override
  _SignUpPageState createState() => _SignUpPageState();
  }

class _SignUpPageState extends State<SignUpPage>{
    FocusNode myFocusNode;
    final TextEditingController _regAuthCodeController = new TextEditingController();

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: new GestureDetector(
            onTap: (){
                FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: new Container(
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
            leading: Padding(
            padding: EdgeInsets.only(left: 16),
            child: IconButton(
                    icon: Image.asset("assets/images/icon/navIconPrev.png"),
                    onPressed: () => Navigator.of(context).pop(null),
                ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Text("회원가입",style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'NotoSans'),
            ),
            ),
        );
    }



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


    Widget _regPhoneNumTextField(){
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: TextFormField(
                maxLength: 11,
                onChanged: (regPhoneNum) {
                    print(regPhoneNum);
                },
                onFieldSubmitted: (regPhoneNum) {
                    print('회원가입 전화번호  :$regPhoneNum');
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


    registerCodeRequest() async {
        if(phoneRegController.text == ''){
            RedToast.toast("휴대폰 번호를 입력해주세요.", ToastGravity.TOP);
        } else {
            FocusScope.of(context).requestFocus(new FocusNode());
            print("phone number :: " +  phoneRegController.text);
            String url = "https://api.hwaya.net/api/v2/auth/A01-SignUpAuth";
            final response = await http.post(url,
                headers: {
                    'Content-Type':'application/json'
                },
                body: jsonEncode({
                    "phone_number": phoneRegController.text
                })
            ).then((http.Response response) {
                print("signup :: " + response.body);
                var data = jsonDecode(response.body);
                String phoneNum = data['phone_number'];
                if (response.statusCode == 200 || response.statusCode == 202) {
                    RedToast.toast("인증문자를 요청하였습니다.", ToastGravity.TOP);
                    print(phoneNum);
                } else {
                    if(data['message'].indexOf('이미 사용중인 전화번호입니다') > -1){
                        RedToast.toast("이미 사용중인 전화번호입니다.", ToastGravity.TOP);
                    } else {
                        RedToast.toast("서버 요청에 실패하였습니다.",ToastGravity.TOP);
                        print('failed：${response.statusCode}');
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
    * @description : 인증번호 입력 필드
    */
    Widget _regAuthTextField(){
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: TextFormField(
                focusNode: myFocusNode,
                maxLength: 6,
                onChanged: (regAuthCode) {
                    print(regAuthCode);
                },
                onFieldSubmitted: (regAuthCode) {
                    print('회원가입 인증코드 입력 :$regAuthCode');
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
    * @description : 다음 버튼
    */
    Widget _regNextButton(){
        return Container(
            width: MediaQuery.of(context).size.width,
            height: 50.0,
            margin: EdgeInsets.only(top: 15.0),
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: RaisedButton(
                onPressed:(){
                    registerNext();
                },
                color: Colors.black38,
                elevation: 0.0,
                child: Text("다음", style: TextStyle(color: Colors.white,  fontFamily: 'NotoSans')),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
        );
    }

    /*
    * @author : sh
    * @date : 2019-12-28
    * @description : 인증번호 입력후 다음누르면
    */
    registerNext() async {
        if(_regAuthCodeController.text == ''){
            RedToast.toast("인증번호를 입력해주세요.", ToastGravity.TOP);
        } else {
            print("register authcode :: " +  _regAuthCodeController.text);
            String url = "https://api.hwaya.net/api/v2/auth/A02-SignUpSmsAuth";
            final response = await http.post(url,
                headers: {
                    'Content-Type':'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: jsonEncode({
                    "phone_number": phoneRegController.text,
                    "auth_number": _regAuthCodeController.text
                })
            ).then((http.Response response) {
                print("register authcode  :: " + response.body);
                var data = jsonDecode(response.body);
                String phoneNum = data['auth_number'];

                if (response.statusCode == 200) {
                    Navigator.pushNamed(context, '/register2');
                    RedToast.toast("인증이 완료 되었습니다.", ToastGravity.TOP);
                } else {
                    RedToast.toast("인증이 실패하였습니다. 인증번호를 확인해주세요.", ToastGravity.TOP);
                    print('failed：${response.statusCode}');
                }
            });
        }
    }
}






