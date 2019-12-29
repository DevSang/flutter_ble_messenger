import 'dart:convert';

import 'package:Hwa/constant.dart';
import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/utility/call_api.dart';
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
    bool isLiked;
    int likeCount;
    ChatSideMenu({Key key, @required this.chatInfo, this.isLiked, this.likeCount});

    @override
    State createState() => new ChatSideMenuState(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount);
}


class ChatSideMenuState extends State<ChatSideMenu> {
    ChatSideMenuState({Key key, @required this.chatInfo, this.isLiked, this.likeCount});

    final ChatInfo chatInfo;
    bool isLiked;
    int likeCount;
    // 현재 채팅 참여유저 TODO: 추후 맵핑
    List<ChatUserInfo> userInfoListBLE = new SetUserData().main();// 현재 채팅 참여유저 TODO: 추후 맵핑
    List<ChatUserInfo> userInfoListOnline = new SetUserDataOnline().main();// 현재 채팅 참여유저 TODO: 추후 맵핑
    List<ChatUserInfo> userInfoListView = new SetUserDataView().main();

    @override
    void initState() {
        super.initState();
    }

    /*
     * @author : hs
     * @date : 2019-12-29
     * @description : 단화방 좋아요
    */
    void _likeChat() async {
        setState(() {
            likeCount++;
        });

        try {
            /// 참여 타입 수정
            String uri = "/danhwa/like?roomIdx=" + chatInfo.chatIdx.toString();
            final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

            print(response.body);

        } catch (e) {
            print("#### Error :: "+ e.toString());
        }
    }

    /*
     * @author : hs
     * @date : 2019-12-29
     * @description : 단화방 좋아요 취소
    */
    void _unLikeChat() async {
        setState(() {
            likeCount--;
        });

        try {
            /// 참여 타입 수정
            String uri = "/danhwa/likeCancel?roomIdx=" + chatInfo.chatIdx.toString();
            final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

            print(response.body);

        } catch (e) {
            print("#### Error :: "+ e.toString());
        }
    }

    @override
    Widget build(BuildContext context) {

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
                                                                    chatInfo.userCount.total.toString(),
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
                                                        chatInfo.intro ?? "단화방 정보가 없습니다.",
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
                                                        decoration: isLiked ? likeChat(context) : unlikeChat(context),
                                                    ),
                                                    Container(
                                                        child:
                                                        Text(
                                                            likeCount.toString(),
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
                                                isLiked = !isLiked;
                                            });

                                            isLiked
                                                ? _likeChat()
                                                : _unLikeChat();
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
                                    Constant.USER_IDX == chatInfo.createUser.userIdx
                                        ? InkWell(
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
                                        : Container()
                                ],
                            ),
                        )
                    ],
                )
            )
        );
    }


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

}