import 'package:Hwa/data/models/chat_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';

import 'package:Hwa/data/models/chat_user_info.dart';

import 'package:Hwa/pages/parts/chat_user_list.dart';
import 'package:Hwa/pages/parts/set_user_data.dart';
import 'package:Hwa/pages/parts/set_user_data_online.dart';
import 'package:Hwa/pages/parts/set_user_data_view.dart';
import 'package:Hwa/pages/chatroom_setting.dart';

//TODO: Host 여부에 따른 Setting, Liked에 따른 하트 아이콘
/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-26
 * @description : 단화방 사이드 메뉴
 */
class ChatSideMenu extends StatefulWidget {
    final ChatInfo chatInfo;
    ChatSideMenu({Key key, @required this.chatInfo});

    @override
    State createState() => new ChatSideMenuState(chatInfo: chatInfo);
}


class ChatSideMenuState extends State<ChatSideMenu> {
    ChatSideMenuState({Key key, @required this.chatInfo});

    // 현재 채팅 좋아요 TODO: 추후 맵핑
    final ChatInfo chatInfo;
    BoxDecoration likeCondition;

    // 현재 채팅 참여유저 TODO: 추후 맵핑
    List<ChatUserInfo> userInfoListBLE = new SetUserData().main();// 현재 채팅 참여유저 TODO: 추후 맵핑
    List<ChatUserInfo> userInfoListOnline = new SetUserDataOnline().main();// 현재 채팅 참여유저 TODO: 추후 맵핑
    List<ChatUserInfo> userInfoListView = new SetUserDataView().main();

    @override
    BoxDecoration unlikeChat(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(153, 153, 153, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconLike.png")
            ),
            shape: BoxShape.circle
        );

    }

    @override
    BoxDecoration likeChat(BuildContext context) {
        return BoxDecoration(
            color: Color.fromRGBO(240, 93, 72, 1),
            image: DecorationImage(
                image:AssetImage("assets/images/icon/iconLike.png")
            ),
            shape: BoxShape.circle
        );

    }

    @override
    void initState() {
        super.initState();
        //TODO::: 좋아요 맵핑
        true ? likeCondition = likeChat(context) : likeCondition = unlikeChat(context);
    }
    
    @override
    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 375, height: 667, allowFontScaling: true)..init(context);

        return
        new SizedBox(
            width: ScreenUtil().setWidth(310),
            child: Drawer(
                child: Column(
                    children: <Widget>[
                        Container(
                            color: Colors.white,
                            height: ScreenUtil().setHeight(74),
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(10),
                                bottom: ScreenUtil().setHeight(12),
                                left: ScreenUtil().setWidth(20)
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    Container(
                                        width: ScreenUtil().setWidth(237),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                Container (
                                                    margin: EdgeInsets.only(
                                                        top: ScreenUtil().setHeight(9.5),
                                                        bottom: ScreenUtil().setHeight(10)
                                                    ),
                                                    child: Row(
                                                        children: <Widget>[
                                                            Text(
                                                                "단화방 정보",
                                                                style: TextStyle(
                                                                    fontFamily: "assets/fonts/NotoSansKR-Medium.otf",
                                                                    height: 1,
                                                                    fontSize: ScreenUtil().setSp(16),
                                                                    letterSpacing: ScreenUtil().setWidth(-0.8),
                                                                    color: Color.fromRGBO(39, 39, 39, 1)
                                                                ),
                                                            ),
                                                            Container(
                                                                height: ScreenUtil().setHeight(12),
                                                                padding: EdgeInsets.only(
                                                                    left: ScreenUtil().setWidth(11.5),
                                                                ),
                                                                child: Text(
                                                                    "3,400",
                                                                    style: TextStyle(
                                                                        height: 1,
                                                                        fontSize: ScreenUtil().setSp(13),
                                                                        letterSpacing: ScreenUtil().setWidth(-0.33),
                                                                        color: Color.fromRGBO(107, 107, 107, 1)
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                Container (
                                                    child: Text(
                                                        "스타벅스 강남R점 사람들 얘기나눠요",
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontSize: ScreenUtil().setSp(13),
                                                            letterSpacing: ScreenUtil().setWidth(-0.33),
                                                            color: Color.fromRGBO(107, 107, 107, 1)
                                                        ),
                                                    ),
                                                )
                                            ],
                                        )
                                    ),
                                    GestureDetector(
                                        child: Container(
                                            width: ScreenUtil().setWidth(53),
                                            height: ScreenUtil().setHeight(60),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                    Container(
                                                        width: ScreenUtil().setWidth(32),
                                                        height: ScreenUtil().setHeight(32),
                                                        margin: EdgeInsets.only(
                                                            bottom: ScreenUtil().setHeight(6)
                                                        ),
                                                        decoration: likeCondition,
                                                    ),
                                                    Container(
                                                        width: ScreenUtil().setWidth(40),
                                                        child:
                                                        Text(
                                                            "2,500",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                height: 1,
                                                                fontSize: ScreenUtil().setSp(13),
                                                                letterSpacing: ScreenUtil().setWidth(-0.33)
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            )
                                        ),
                                        onTap:(){
                                            setState(() {
                                                likeCondition == likeChat(context) ? likeCondition = unlikeChat(context) : likeCondition = likeChat(context);
                                            });
                                        }
                                    )
                                ],
                            )
                        ),
                        Flexible(
                            child: ListView(
                                children: <Widget>[
                                    ChatUserList(userInfoList: userInfoListBLE, hostIdx: chatInfo.createUserIdx),
                                    ChatUserList(userInfoList: userInfoListOnline, hostIdx: chatInfo.createUserIdx),
                                    ChatUserList(userInfoList: userInfoListView, hostIdx: chatInfo.createUserIdx),
                                ],
                            ),
                        ),
                        Container(
                            width: ScreenUtil().setWidth(310),
                            height: ScreenUtil().setHeight(48),
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(14),
                              right: ScreenUtil().setWidth(14)
                            ),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(240, 240, 240, 1),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    InkWell(
                                        child: Container(
                                            width: ScreenUtil().setWidth(28),
                                            height: ScreenUtil().setHeight(28),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image:AssetImage("assets/images/icon/iconExit.png")
                                                ),
                                            )
                                        ),
                                    ),
                                    InkWell(
                                        child: Container(
                                            width: ScreenUtil().setWidth(28),
                                            height: ScreenUtil().setHeight(28),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image:AssetImage("assets/images/icon/iconSetting.png")
                                                ),
                                            )
                                        ),
                                        onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (context) {
                                                    return ChatroomSettingPage(chatIdx: 0);
                                                })
                                            );
                                        },
                                    )
                                ],
                            ),
                        )
                    ],
                )
            )
        );
    }
}