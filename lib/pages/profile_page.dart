import 'package:Hwa/utility/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kvsql/kvsql.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Hwa/utility/get_same_size.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State <ProfilePage>{
    SharedPreferences SPF;
    final store = KvStore();

    bool isSwitched = true;
    double sameSize = GetSameSize().main();

  /*
    * @author : hs
    * @date : 2019-12-28
    * @description : 임시 로그아웃
    */
    Future<void> logOut() async {
        SPF = await SharedPreferences.getInstance();
        await store.onReady;
        SPF.remove('token');
        store.delete("friendList");
        store.delete("test");

        return;
    }

    /*
     * @author : hs
     * @date : 2020-01-01
     * @description : Switch Change
    */
    void _onSwitchChanged(bool value) {
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

                    buildTextItem("사용자 이름", "강희근", false),

                    buildTextItem("한 줄 소개", "안녕하세요 강희근입니다", false),

                    buildTextItem("연락처", "010-1234-5678", false),

                    buildTextItem("명함 관리", "", true)
                ]
            ),
        );
  }

  Widget _appSetting(BuildContext context){
      return Container(
          child: Column(
              children: <Widget>[
                  buildSettingHeader("앱 설정"),

                  buildSwitchItem("푸쉬 알림", false, false),

                  buildSwitchItem("친구 요청 허용", true, true),
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
                          logOut().then((value) {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                          });
                      }
                  ),

                  buildTextItem("탈퇴하기", "", false),

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
                        color: isLast ? Color.fromRGBO(255, 255, 255, 1) : Color.fromRGBO(39, 39, 39, 0.15)
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
                        child: Row(
                            children: <Widget>[
                                Text(
                                    value,
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
                        color: isLast ? Color.fromRGBO(255, 255, 255, 1) : Color.fromRGBO(39, 39, 39, 0.15)
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
}
