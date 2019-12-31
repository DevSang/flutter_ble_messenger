import 'package:Hwa/pages/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:kvsql/kvsql.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kvsql/kvsql.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/utility/custom_switch.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State <ProfilePage>{
  SharedPreferences SPF;
  final store = KvStore();

  bool isSwitched = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
        backgroundColor: Colors.white,
          title: Text("프로필 설정",
            style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'NotoSans'),
          ),
          leading: Padding(
            padding: EdgeInsets.only(left: 16),
            child: IconButton(
              icon: Image.asset("assets/images/icon/navIconPrev.png"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
      ),
      body: Column(
        children: <Widget>[
      Flexible(
      child: ListView(
          children: <Widget>[
          _profileImageSection(context),
          _profileSetting(context),
          _appSetting(context),
          _accountSetting(context)
        ]
    )
      )
    ],
      ),
    );
  }


  Widget _profileImageSection(BuildContext context){
      return Container(
        width: ScreenUtil().setWidth(375),
        height: ScreenUtil().setHeight(177),
          decoration: BoxDecoration(
              color: Color.fromRGBO(178, 178, 178, 1),
          ),
        child: Stack(
          children: <Widget>[
            InkWell(
              child: Center(
                child: Container(
                  width: ScreenUtil().setWidth(90),
                  height: ScreenUtil().setHeight(90),
                  margin: EdgeInsets.only(
                    top: ScreenUtil().setHeight(41),
                    bottom: ScreenUtil().setHeight(46),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: ExactAssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover
                    )
                  ),

                ),
              ),
              onTap: () {
              },
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
                                image:AssetImage("assets/images/icon/iconAttachCamera.png")
                            ),
                            shape: BoxShape.circle
                        )
                    ),
                    onTap:(){
                    }
                )
            )
          ],
        ),
      );
  }

  Widget _profileSetting(BuildContext context){
      return Container(
          child: Stack(
              children: <Widget>[
                  Column(
                      children: <Widget>[
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                              width: MediaQuery.of(context).size.width,
                              height: 30.0,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(214, 214, 214, 1),
                              ),
                              child: Text("프로필",style: TextStyle(fontSize: 14,fontFamily: "NotoSans")),
                          ),
                          Container(

                              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: ScreenUtil().setWidth(1),
                                      color: Color.fromRGBO(39, 39, 39, 1)
                                  )),
                                  color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                children: <Widget>[
                                  Container(
                                    child: Row(
                                        children: <Widget>[
                                    Text("사용자 이름", style: TextStyle(fontSize: 15,fontFamily: "NotoSans",color: Color.fromRGBO(39, 39, 39, 1),
                                        fontWeight: FontWeight.w500,
                                      )
                                  ),
                                      ]
                                    )
                                  ),


                                  Container(

                                      child: Row(
                                          children: <Widget>[

                                            Text("강희근", style: TextStyle(fontSize: 15,fontFamily: "NotoSans", color: Color.fromRGBO(107, 107, 107, 1))),
                                            IconButton(
                                              icon: Image.asset("assets/images/icon/iconMore.png"),
                                              onPressed: (){},
                                            )
                                          ]
                                      )
                                  ),


                                  ],
                              )
                          ),

                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                     Text("한 줄 소개", style: TextStyle(
                                     height: 1,
                                       letterSpacing: ScreenUtil.getInstance().setWidth(-0.75),
                                       fontFamily: "NotoSans",
                                       color: Color.fromRGBO(39, 39, 39, 1),
                                       fontWeight: FontWeight.w500,
                                      )),
                                  Container(
                                      child: Row(
                                          children: <Widget>[
                                             InkWell(child: Text("안녕하세요 강희근입니다.", style: TextStyle(fontSize: 15,fontFamily: "NotoSans",color: Color.fromRGBO(107, 107, 107, 1)))),
                                            IconButton(
                                              icon: Image.asset("assets/images/icon/iconMore.png"),
                                              onPressed: (){},
                                            )
                                          ]
                                      )
                                  ),
                                  ],
                              )
                          ),


                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                            width: MediaQuery.of(context).size.width,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("연락처", style: TextStyle(fontSize: 15,fontFamily: "NotoSans", color: Color.fromRGBO(39, 39, 39, 1),
                                  fontWeight: FontWeight.w500,
                                )),
                                Container(
                                    child: Row(
                                        children: <Widget>[
                                          InkWell(
                                            child: Text("010-1234-5678", style: TextStyle(fontSize: 15,fontFamily: "NotoSans",color: Color.fromRGBO(107, 107, 107, 1)))),
                                          IconButton(
                                            icon: Image.asset("assets/images/icon/iconMore.png"),
                                            onPressed: (){},
                                          )
                                        ]
                                    )
                                ),
                              ],
                            )
                        ),


                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                            width: MediaQuery.of(context).size.width,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("명함 관리", style: TextStyle(fontSize: 15,fontFamily: "NotoSans",color: Color.fromRGBO(39, 39, 39, 1),
                                  fontWeight: FontWeight.w500,
                                )),

                                IconButton(
                                  icon: Image.asset("assets/images/icon/iconMore.png"),
                                  onPressed: (){},
                                )
                              ],
                            )
                        ),


                      ]
                  ),


              ],),


      );
  }

  Widget _appSetting(BuildContext context){
      return Container(
          child: Stack(
              children: <Widget>[
                  Column(
                      children: <Widget>[
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                              width: MediaQuery.of(context).size.width,
                              height: 30.0,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(214, 214, 214, 1),
                              ),
                              child: Text("앱 설정",style: TextStyle(fontSize: 14,fontFamily: "NotoSans")),
                          ),

                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 10.0),
                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                      Text("푸쉬 알림", style: TextStyle(fontSize: 15,fontFamily: "NotoSans",color: Color.fromRGBO(39, 39, 39, 1),
                                        fontWeight: FontWeight.w500,
                                      )),
                                  CustomSwitch(
                                      onChanged: _onSwitchChanged,
                                      value: true,
                                      activeColor: Color.fromRGBO(77, 96, 191, 1)
                                    )
                                  ],
                              )
                          ),



                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 10.0),
                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                      Text("친구 허용 알림", style: TextStyle(fontSize: 15,fontFamily: "NotoSans",color: Color.fromRGBO(39, 39, 39, 1),
                                        fontWeight: FontWeight.w500,
                                      )),
                                  CustomSwitch(
                                        onChanged: _onSwitchChanged,
                                        value: true,
                                        activeColor: Color.fromRGBO(77, 96, 191, 1)
                                    )
                                  ],
                              )
                          ),
                      ]
                  )
              ],
          ),
      );
  }

  void _onSwitchChanged(bool value) {
  }


  Widget _accountSetting(BuildContext context){
      return Container(

          child: Stack(
              children: <Widget>[
                  Column(
                      children: <Widget>[
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                              width: MediaQuery.of(context).size.width,
                              height: 30.0,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(214, 214, 214, 1),
                              ),
                              child: Text("계정",style: TextStyle(fontSize: 14,fontFamily: "NotoSans")),
                          ),

                          InkWell(
                              child:Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 10.0),
                                  width: MediaQuery.of(context).size.width,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                          InkWell( child: Text("로그아웃", style: TextStyle(fontSize: 15,fontFamily: "NotoSans",color: Color.fromRGBO(39, 39, 39, 1),
                                            fontWeight: FontWeight.w500,
                                          ))),
                                        IconButton(
                                          icon: Image.asset("assets/images/icon/iconMore.png"),
                                          onPressed: (){
                                            logOut().then((value) {
                                              Navigator.of(context).popUntil((route) => route.isFirst);
                                            });
                                          },
                                        )
                                      ],
                                  ),
                              ),
                              onTap:() {
                                  logOut().then((value) {
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                  });
                              }
                          ),

                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 10.0),

                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                      InkWell(
                                          child: Text("탈퇴하기", style: TextStyle(fontSize: 15,fontFamily: "NotoSans",color: Color.fromRGBO(39, 39, 39, 1),
                                            fontWeight: FontWeight.w500,
                                          ))),
                                    IconButton(
                                      icon: Image.asset("assets/images/icon/iconMore.png"),
                                      onPressed: (){},
                                    )
                                  ],
                              )
                          ),

                      ]
                  )



              ],


          ),


      );
  }
}
