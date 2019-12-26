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

//TODO: Host 여부에 따른 Setting
/*
 * @project : HWA - Mobile
 * @author : hs
 * @date : 2019-12-26
 * @description : 단화방 사이드 메뉴
 */
class ChatSideMenu extends StatefulWidget {
    final bool isLike;
    ChatSideMenu({Key key, @required this.isLike});

    @override
    State createState() => new ChatSideMenuState(isLike: isLike);
}


class ChatSideMenuState extends State<ChatSideMenu> {
    ChatSideMenuState({Key key, @required this.isLike});

    // 현재 채팅 좋아요 TODO: 추후 맵핑
    final bool isLike;
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
        isLike ? likeCondition = likeChat(context) : likeCondition = unlikeChat(context);
    }
    
    @override
    Widget build(BuildContext context) {
        ScreenUtil.instance = ScreenUtil(width: 750, height: 1334, allowFontScaling: true)..init(context);

        return
        new SizedBox(
            width: ScreenUtil().setWidth(620),
            child: Drawer(
                child: Column(
                    children: <Widget>[
                        Container(
                            color: Colors.white,
                            height: ScreenUtil().setHeight(148),
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(20),
                                bottom: ScreenUtil().setHeight(24),
                                left: ScreenUtil().setWidth(40)
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    Container(
                                        width: ScreenUtil().setWidth(474),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                Container (
                                                    margin: EdgeInsets.only(
                                                        top: ScreenUtil().setHeight(19),
                                                        bottom: ScreenUtil().setHeight(20)
                                                    ),
                                                    child: Row(
                                                        children: <Widget>[
                                                            Text(
                                                                "단화방 정보",
                                                                style: TextStyle(
                                                                    fontFamily: "assets/fonts/NotoSansKR-Medium.otf",
                                                                    height: 1,
                                                                    fontSize: ScreenUtil().setSp(32),
                                                                    letterSpacing: ScreenUtil().setWidth(-0.8),
                                                                    color: Color.fromRGBO(39, 39, 39, 1)
                                                                ),
                                                            ),
                                                            Container(
                                                                height: ScreenUtil().setHeight(24),
                                                                padding: EdgeInsets.only(
                                                                    left: ScreenUtil().setWidth(23),
                                                                ),
                                                                child: Text(
                                                                    "3,400",
                                                                    style: TextStyle(
                                                                        height: 1,
                                                                        fontSize: ScreenUtil().setSp(26),
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
                                                            fontSize: ScreenUtil().setSp(26),
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
                                            width: ScreenUtil().setWidth(106),
                                            height: ScreenUtil().setHeight(120),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                    Container(
                                                        width: ScreenUtil().setWidth(64),
                                                        height: ScreenUtil().setHeight(64),
                                                        margin: EdgeInsets.only(
                                                            bottom: ScreenUtil().setHeight(12)
                                                        ),
                                                        decoration: likeCondition,
                                                    ),
                                                    Container(
                                                        width: ScreenUtil().setWidth(80),
                                                        child:
                                                        Text(
                                                            "2,500",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                height: 1,
                                                                fontSize: ScreenUtil().setSp(26),
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
                                    ChatUserList(userInfoList: userInfoListBLE),
                                    ChatUserList(userInfoList: userInfoListOnline),
                                    ChatUserList(userInfoList: userInfoListView),
                                ],
                            ),
                        ),
                        Container(
                            width: ScreenUtil().setWidth(620),
                            height: ScreenUtil().setHeight(96),
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(28),
                              right: ScreenUtil().setWidth(28)
                            ),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(240, 240, 240, 1),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    InkWell(
                                        child: Container(
                                            width: ScreenUtil().setWidth(56),
                                            height: ScreenUtil().setHeight(56),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image:AssetImage("assets/images/icon/iconExit.png")
                                                ),
                                            )
                                        ),
                                    ),
                                    InkWell(
                                        child: Container(
                                            width: ScreenUtil().setWidth(56),
                                            height: ScreenUtil().setHeight(56),
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