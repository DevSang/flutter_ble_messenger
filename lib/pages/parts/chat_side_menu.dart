import 'dart:convert';
import 'dart:developer' as developer;

import 'package:Hwa/constant.dart';
import 'package:Hwa/data/models/chat_info.dart';
import 'package:Hwa/data/models/chat_join_info.dart';
import 'package:Hwa/pages/bottom_navigation.dart';
import 'package:Hwa/pages/tab/chat_tab.dart';
import 'package:Hwa/pages/tab/hwa_tab.dart';
import 'package:Hwa/service/stomp_client.dart';
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
    final List<ChatJoinInfo> chatJoinInfoList;
    final StompClient sc;
    final String from;
    ChatSideMenu({Key key, @required this.chatInfo, this.isLiked, this.likeCount, this.chatJoinInfoList, this.sc, this.from});

    @override
    State createState() => new ChatSideMenuState(chatInfo: chatInfo, isLiked: isLiked, likeCount: likeCount, chatJoinInfoList: chatJoinInfoList);
}


class ChatSideMenuState extends State<ChatSideMenu> {
    ChatSideMenuState({Key key, @required this.chatInfo, this.isLiked, this.likeCount, this.chatJoinInfoList});

    final ChatInfo chatInfo;
    bool isLiked;
    int likeCount;
    final List<ChatJoinInfo> chatJoinInfoList;

    List<ChatJoinInfo> userInfoListBle = <ChatJoinInfo>[];
    List<ChatJoinInfo> userInfoListBleOut = <ChatJoinInfo>[];
    List<ChatJoinInfo> userInfoListOnline  = <ChatJoinInfo>[];



    @override
    void initState() {
        super.initState();

        _getChatJoinInfo();
    }

    /*
     * @author : hs
     * @date : 2019-12-30
     * @description : 단화방 정보 받아오기
    */
    void _getChatJoinInfo() {
        if (chatJoinInfoList != null && chatJoinInfoList.length > 0) {
            for(var chatJoinInfo in chatJoinInfoList) {

                switch(chatJoinInfo.joinType) {
                    case "BLE_JOIN": userInfoListBle.add(chatJoinInfo);
                        break;
                    case "BLE_OUT": userInfoListBleOut.add(chatJoinInfo);
                        break;
                    case "ONLINE": userInfoListOnline.add(chatJoinInfo);
                        break;
                }
            }
            setState(() { });
        }
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

    /*
     * @author : hs
     * @date : 2019-12-31
     * @description : 단화방 나가기
    */
    void quitChat() async {

        try {
            /// 참여 타입 수정
            String uri = "/danhwa/out?roomIdx=" + chatInfo.chatIdx.toString();
            final response = await CallApi.messageApiCall(method: HTTP_METHOD.post, url: uri);

            developer.log("quit" + response.body);

            widget.sc.disconnect();

            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                    int activeTab;

                    if (widget.from == 'HwaTab') {
                        activeTab = 0;
                    }
                    else {
                        activeTab = 2;
                    }

                    return BottomNavigation(activeIndex: activeTab);
                })
            );

        } catch (e) {
            developer.log("#### Error :: "+ e.toString());
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
                                    ChatUserList(userInfoList: userInfoListBle, joinType: "BLE_JOIN", hostIdx: chatInfo.createUserIdx),
                                    ChatUserList(userInfoList: userInfoListBleOut, joinType: "BLE_OUT", hostIdx: chatInfo.createUserIdx),
                                    ChatUserList(userInfoList: userInfoListOnline, joinType: "ONLINE", hostIdx: chatInfo.createUserIdx),
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
                                        onTap: () {
                                            quitChat();
                                        },
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