import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Hwa/data/models/chat_user_info.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';

class ChatUserList extends StatefulWidget {
    final List<ChatUserInfo> userInfoList;
    ChatUserList({Key key, @required this.userInfoList}) : super(key: key);

    @override
    State createState() => new ChatUserListState();
}


class ChatUserListState extends State<ChatUserList> {
    // 현재 채팅 Advertising condition
    bool openedList;


    @override
    void initState() {
        super.initState();
        openedList = true;
    }

    @override
    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);

        return new Container(
            color: Colors.white,
              child: Column(
                  children: <Widget>[
                      Container(
                          width: ScreenUtil().setWidth(620),
                          height: ScreenUtil().setWidth(64),
                          padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(40),
                            right:   ScreenUtil().setWidth(36)
                          ),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(240, 240, 240, 1),
                              border: Border(
                                  top: BorderSide(
                                      width: ScreenUtil().setWidth(1),
                                      color: Color.fromRGBO(39, 39, 39, 0.15)
                                  )
                              )
                          ),
                          child:
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                  Container(
                                      child: Row(
                                          children: <Widget>[
                                              Text(
                                                  widget.userInfoList[0].partType == "BLE"
                                                      ? "내 주변 사람"
                                                      : (
                                                      widget.userInfoList[0].partType == "Online"
                                                          ? "온라인 유저"
                                                          : "관전 유저"
                                                  ),
                                                  style: TextStyle(
                                                      height: 1,
                                                      fontSize: ScreenUtil().setSp(26),
                                                      letterSpacing: ScreenUtil().setWidth(-0.33),
                                                      color: Color.fromRGBO(39, 39, 39, 1)
                                                  ),
                                              ),
                                              Container(
                                                  height: ScreenUtil().setHeight(26),
                                                  padding: EdgeInsets.only(
                                                      left: ScreenUtil().setWidth(16),
                                                      right: ScreenUtil().setWidth(16),
                                                  ),
                                                  child: Text(
                                                      widget.userInfoList.length.toString(),
                                                      style: TextStyle(
                                                          height: 1,
                                                          fontSize: ScreenUtil().setSp(26),
                                                          letterSpacing: ScreenUtil().setWidth(-0.33),
                                                          color: Color.fromRGBO(107, 107, 107, 1)
                                                      ),
                                                  ),
                                              ),
                                          ],
                                      )
                                  ),
                                  Container(
                                      width: ScreenUtil().setWidth(40),
                                      child: FlatButton(
                                          onPressed:(){
                                              setState(() {
                                                  openedList = !openedList;
                                              });
                                          }
                                      ),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image:AssetImage(openedList
                                                                ? "assets/images/icon/iconFold.png"
                                                                : "assets/images/icon/iconExpand.png")
                                          ),
                                      ),
                                  )
                              ],
                          ),
                      ),
                      openedList
                          ? Container(
                               child: ListView.builder(
                                   physics: new NeverScrollableScrollPhysics(),
                                   shrinkWrap: true,
                                   itemCount: widget.userInfoList.length,
                                   itemBuilder: (BuildContext context, int index){
                                       return BuildUserInfo(userInfo: widget.userInfoList[index]);
                                   }
                               ),
                          )
                          : Container(),

                  ],
              )


          );
    }
}

class BuildUserInfo extends StatelessWidget {
    final ChatUserInfo userInfo;
    BuildUserInfo({this.userInfo});

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            child: Stack(
                children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(40),
                            right: ScreenUtil().setWidth(36)
                        ),
                        height: ScreenUtil().setHeight(104),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                Container(
                                    width: ScreenUtil().setWidth(504),
                                    child: Row(
                                        children: <Widget>[
                                            // 프로필 이미지
                                            Container(
                                                child: ClipRRect(
                                                    borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(70)),
                                                    child: Image.asset(
                                                        userInfo.profileImg,
                                                        width: ScreenUtil().setWidth(80),
                                                        height: ScreenUtil().setWidth(80),
                                                    )
                                                )
                                            ),
                                            // 이름
                                            Container(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil().setWidth(21)
                                                ),
                                                child: Text(
                                                    userInfo.nick,
                                                    style: TextStyle(
                                                        height: 1,
                                                        fontSize: ScreenUtil().setSp(26),
                                                        letterSpacing: ScreenUtil().setWidth(-0.33),
                                                        color: Color.fromRGBO(39, 39, 39, 1)
                                                    ),
                                                )
                                            ),
                                        ],
                                    ),
                                ),
                                // 연락처 아이콘
                                userInfo.existContact ? contactIcon : new Container()
                            ],
                        )
                    ),
                    // 방장 뱃지
                    userInfo.isHost ? badgeHost : new Container(),

                    // 자신 뱃지
                    userInfo.isMe ? badgeMe : new Container(),
                ],
            ),
            onTap: (){
                _showModalSheet(context);
            },
        );
    }

    Widget contactIcon = new Container(
        width: ScreenUtil().setWidth(40),
        height: ScreenUtil().setHeight(40),
        decoration: BoxDecoration(
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconAddress.png")
            ),
        )
    );

    Widget badgeHost = new Positioned(
        top: ScreenUtil().setHeight(40),
        left: ScreenUtil().setWidth(15),
        child: GestureDetector(
            child: Container(
                width: ScreenUtil().setWidth(40),
                height: ScreenUtil().setHeight(40),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(77, 96, 191, 1),
                    image: DecorationImage(
                        image:AssetImage("assets/images/icon/iconBell.png")
                    ),
                    shape: BoxShape.circle
                )
            )
        )
    );

    Widget badgeMe = new Positioned(
        top: ScreenUtil().setHeight(40),
        left: ScreenUtil().setWidth(15),
        child: GestureDetector(
            child: Container(
                width: ScreenUtil().setWidth(40),
                height: ScreenUtil().setHeight(40),
                decoration: BoxDecoration(
                    color: Colors.orange,
                    image: DecorationImage(
                        image:AssetImage("assets/images/icon/iconBell.png")
                    ),
                    shape: BoxShape.circle
                )
            )
        )
    );

    void _showModalSheet(BuildContext context) {
        showModalBottomSheet(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(30)),
                    topRight: Radius.circular(ScreenUtil().setWidth(30)),
                ),
            ),
            context: context,
            builder: (builder) {
                return Container(
                    height: ScreenUtil().setHeight(640),
                    decoration: BoxDecoration(
                    ),
                    child: Column(
                        children: <Widget>[
                            Container(
                                width: ScreenUtil().setWidth(750),
                                height: ScreenUtil().setHeight(120),
                                padding: EdgeInsets.all(
                                    ScreenUtil().setWidth(30)
                                ),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: ScreenUtil().setWidth(1),
                                            color: Colors.blue
                                        )
                                    )
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                        Container(
                                            width: ScreenUtil().setWidth(70),
                                            height: ScreenUtil().setHeight(40),
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                image: DecorationImage(
                                                    image:AssetImage("assets/images/icon/iconBell.png")
                                                )
                                            )
                                        ),
                                        Container(
                                            child: Text(
                                                '강희근',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(26),
                                                    color: Color.fromRGBO(39, 39, 39, 1)
                                                ),
                                            )
                                        ),
                                        Container(
                                            width: ScreenUtil().setWidth(70),
                                            height: ScreenUtil().setHeight(40),
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                image: DecorationImage(
                                                    image:AssetImage("assets/images/icon/iconBell.png")
                                                )
                                            ),
                                            child: FlatButton(
                                                onPressed:(){
                                                    Navigator.pop(context);
                                                }
                                            ),
                                        ),
                                    ],
                                )
                            ),
                            Container(
                                margin: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(30),
                                    bottom: ScreenUtil().setHeight(30),
                                ),
                                child: ClipRRect(
                                    borderRadius: new BorderRadius.circular(ScreenUtil().setWidth(70)),
                                    child: Image.asset(
                                        userInfo.profileImg,
                                        width: ScreenUtil().setWidth(180),
                                        height: ScreenUtil().setWidth(180),
                                    )
                                )
                            ),
                            Container(
                                child: Text("안녕하세요. 강희근입니다.")
                            ),
                            Container(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(50),
                                    right: ScreenUtil().setWidth(50),
                                ),
                                margin: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(30),
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                        userFunc("assets/images/icon/iconBell.png", "친구 요청", null),
                                        userFunc("assets/images/icon/iconBell.png", "1:1 채팅", null),
                                        userFunc("assets/images/icon/iconBell.png", "차단하기", null),
                                        userFunc("assets/images/icon/iconBell.png", "내보내기", null)
                                    ],
                                ),
                            )
                        ],
                    ),
                );
            }
        );
    }

    Widget userFunc(String iconSrc, String title,Function fn) {
        return new Container(
            child: Column(
                children: <Widget>[
                    GestureDetector(
                        child: Container(
                            margin: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(10),
                            ),
                            width: ScreenUtil().setWidth(120),
                            height: ScreenUtil().setHeight(120),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(210, 217, 250, 1),
                                image: DecorationImage(
                                    image:AssetImage(iconSrc)
                                ),
                                shape: BoxShape.circle
                            )
                        ),
                        onTap:(){
                            fn();
                        }
                    ),
                    Text(
                        title,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(22)
                        )
                    )
                ],
            ),
        );
    }
}