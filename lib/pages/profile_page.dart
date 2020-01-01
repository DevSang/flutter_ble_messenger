import 'dart:convert';
import 'dart:developer' as developer;

import 'package:Hwa/constant.dart';
import 'package:Hwa/utility/call_api.dart';
import 'package:Hwa/utility/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kvsql/kvsql.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Hwa/utility/get_same_size.dart';
import 'package:Hwa/utility/custom_dialog.dart';
import 'package:Hwa/pages/signin_page.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State <ProfilePage>{
    SharedPreferences SPF;
    final store = KvStore();

    bool isSwitched = true;
    double sameSize = GetSameSize().main();

    String nickName;
    String intro;
    String phoneNum;
    bool allowedPush = true;
    bool allowedFriend = true;

    @override
    void initState() {
        super.initState();

        getSettingInfo();
    }

  /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 로그아웃
    */
    Future<void> logOut() async {
        SPF = await SharedPreferences.getInstance();
        await store.onReady;
        await SPF.remove('token');
        await store.delete("friendList");
        await store.delete("test");

        Navigator.of(context).pushAndRemoveUntil(
	        MaterialPageRoute(builder: (BuildContext context) => SignInPage()),
	        ModalRoute.withName('/login')
        );

        return;
    }

    /*
     * @author : hs
     * @date : 2020-01-01
     * @description : Switch Change
    */
    void _onSwitchChanged(bool value) {
    }

    /*
     * @author : hs
     * @date : 2020-01-01
     * @description : 프로필 설정 받아오기
    */
    void getSettingInfo() async {
        try {
            /// 참여 타입 수정
            String uri = "/api/v2/user/profile?target_user_idx=" + Constant.USER_IDX.toString();
            final response = await CallApi.commonApiCall(method: HTTP_METHOD.get, url: uri);

            Map<String, dynamic> jsonParse = json.decode(response.body);
            Map<String, dynamic> profile = jsonParse['data'];

            setState(() {
                nickName = profile['nickname'];
                intro = profile['description'];
                phoneNum = profile['phone_number'];
                allowedPush = profile['is_push_allowed'];
                allowedFriend = profile['is_friend_request_allowed'];
            });

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    /*
     * @author : hs
     * @date : 2020-01-01
     * @description : 프로필 저장
    */
    void saveSettingInfo() async {
        try {
            String uri = "/api/v2/user/profile";
            final response = await CallApi.commonApiCall(
                method: HTTP_METHOD.post,
                url: uri,
                data: {
                    "nickname" : nickName,
                    "description" : intro,
                    "is_push_allowed"  : allowedPush,
                    "is_friend_request_allowed" : allowedFriend
                }
            );

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
        }
    }

    
    void popNav() async {
        await saveSettingInfo();
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: Color.fromRGBO(77, 96, 191, 1), //change your color here
                ),
                title: Text(
                    "프로필 설정",
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil.getInstance().setSp(16)
                    ),
                ),
                leading: new IconButton(
                    icon: new Image.asset('assets/images/icon/navIconPrev.png'),
                    onPressed: (){
                        Navigator.of(context).pop(null);
                    }
                ),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white,
                brightness: Brightness.light,
            ),
            body: Column(
                children: <Widget>[
                    Flexible(
                        child: ListView(
                            children: <Widget>[
                                // 프로필 이미지
                                _profileImageSection(context),

                                // 프로필 설정
                                _profileSetting(context),

                                // 앱 설정
                                _appSetting(context),

                                // 계정 설정
                                _accountSetting(context)
                            ]
                        )
                    )
                ],
            ),
        );
    }


    Widget _profileImageSection(BuildContext context) {
        return Container(
              width: ScreenUtil().setWidth(375),
              height: ScreenUtil().setHeight(178),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(178, 178, 178, 1),
              ),
              child: Stack(
                  children: <Widget>[
                      InkWell(
                          child: Center(
                              child: Container(
                                  width: ScreenUtil().setHeight(90),
                                  height: ScreenUtil().setHeight(90),
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(41),
                                      bottom: ScreenUtil().setHeight(46),
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: ScreenUtil().setWidth(1),
                                          color: Color.fromRGBO(0, 0, 0, 0.05)
                                      ),
                                      borderRadius: new BorderRadius.circular(ScreenUtil().setHeight(45)),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: new BorderRadius.circular(ScreenUtil().setHeight(45)),
                                      child: Image.asset(
                                          'assets/images/icon/thumbnailUnset1.png',
                                          fit: BoxFit.cover,
                                      )
                                  ),
                              ),
                          ),
                          onTap: () {},
                      ),
                      Positioned(
                          bottom: ScreenUtil().setHeight(41),
                          left: ScreenUtil().setWidth(206),
                          child: InkWell(
                              child: Container(
                                  width: ScreenUtil().setWidth(32),
                                  height: ScreenUtil().setHeight(32),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(77, 96, 191, 1),
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/icon/iconAttachCamera.png")
                                      ),
                                      shape: BoxShape.circle
                                  )
                              ),
                              onTap: () {}
                          )
                      )
                  ],
              ),
        );
    }

    Widget _profileSetting(BuildContext context) {
        return Container(
            child: Column(
                children: <Widget>[
                    buildSettingHeader("프로필"),

                    buildTextItem("사용자 이름", nickName, false),

                    buildTextItem("한 줄 소개", intro, false),

                    buildTextInfoItem("연락처", phoneNum, true),

//                    buildTextItem("명함 관리", "", true)
                ]
            ),
        );
  }

  Widget _appSetting(BuildContext context){
      return Container(
          child: Column(
              children: <Widget>[
                  buildSettingHeader("앱 설정"),

                  buildSwitchItem("푸쉬 알림", allowedPush, false),

                  buildSwitchItem("친구 요청 허용", allowedFriend, true),
              ]
          )
      );
  }


    Widget _accountSetting(BuildContext context){
      return Container(
          child: Column(
              children: <Widget>[
                  buildSettingHeader("계정"),

                  InkWell(
                      child: buildTextItem("로그아웃", "", false),
                      onTap:() {
                          logOut();
                      }
                  ),

                  buildTextItem("탈퇴하기", "", true),

              ]
          )
      );
    }

    Widget buildSettingHeader(String title) {
        return Container(
            padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16)
            ),
            width: MediaQuery.of(context).size.width,
            height: ScreenUtil().setHeight(25),
            decoration: BoxDecoration(
                color: Color.fromRGBO(235, 235, 235, 1),
            ),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    title,
                    style: TextStyle(
                        fontFamily: "NotoSans",
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(39, 39, 39, 1),
                        fontSize: ScreenUtil.getInstance().setSp(13),
                        letterSpacing: ScreenUtil.getInstance().setWidth(-0.65)
                    )
                ),
            ),
        );
    }

    Widget buildTextItem(String title, String value, bool isLast) {
        return Container(
            height: ScreenUtil().setHeight(49),
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(16)
            ),
            padding: EdgeInsets.only(
                right: ScreenUtil().setWidth(8)
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setWidth(1),
                        color: isLast ? Colors.white : Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    Container(
                        child: InkWell(
                            child: Row(
                                children: <Widget>[
                                    Text(
                                        value ?? "",
                                        style: TextStyle(
                                            height: 1,
                                            fontFamily: "NotoSans",
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromRGBO(107, 107, 107, 1),
                                            fontSize: ScreenUtil.getInstance().setSp(15),
                                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                                        )
                                    ),
                                    Container(
                                        width: ScreenUtil().setWidth(20),
                                        height: ScreenUtil().setHeight(20),
                                        margin: EdgeInsets.only(
                                            left: ScreenUtil().setWidth(6)
                                        ),
                                        child: Image.asset(
                                            'assets/images/icon/iconMore.png'
                                        )
                                    )
                                ],
                            ),
                            onTap: (){
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) => CustomDialog(
                                        title: title,
                                        type: 1,
                                        leftButtonText: "취소",
                                        rightButtonText: "저장하기",
                                        value: value,
                                        hintText: value == null ? "소개글을 입력해 보세요 :)" : "",
                                        func: () => {

                                        }
                                    ),
                                );
                            },
                        )
                    )
                ],
            )
        );
    }

    Widget buildSwitchItem(String title, bool value, bool isLast) {
        return Container(
            height: ScreenUtil().setHeight(49),
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(16)
            ),
            padding: EdgeInsets.only(
                right: ScreenUtil().setWidth(8)
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setWidth(1),
                        color: isLast ? Colors.white : Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    CustomSwitch(
                        onChanged: (val){
                            print(val);
                            _onSwitchChanged(val);
                        } ,
                        value: value,
                        inactiveColor: Color.fromRGBO(235, 235, 235, 1),
                        activeColor: Color.fromRGBO(77, 96, 191, 1),
                        shadow: BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            offset: new Offset(
                                ScreenUtil().setWidth(0),
                                ScreenUtil().setWidth(0)
                            ),
                            blurRadius: 2
                        )
                    )
                ],
            )
        );
    }


    Widget buildTextInfoItem(String title, String value, bool isLast) {
        return Container(
            height: ScreenUtil().setHeight(49),
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(16)
            ),
            padding: EdgeInsets.only(
                right: ScreenUtil().setWidth(16)
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setWidth(1),
                        color: isLast ? Colors.white : Color.fromRGBO(39, 39, 39, 0.15)
                    )
                )
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Text(
                        title,
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(39, 39, 39, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    ),
                    Text(
                        value ?? "",
                        style: TextStyle(
                            height: 1,
                            fontFamily: "NotoSans",
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(107, 107, 107, 1),
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            letterSpacing: ScreenUtil.getInstance().setWidth(-0.75)
                        )
                    )
                ],
            )
        );
    }
}
